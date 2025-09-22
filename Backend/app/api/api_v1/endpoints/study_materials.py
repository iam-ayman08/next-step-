"""
Study Materials API endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import List, Optional
import os
import shutil
from datetime import datetime

from app.core.database import (
    StudyMaterial, StudyMaterialDownload, StudyMaterialRating,
    User, get_db
)
from app.core.security import get_current_user

router = APIRouter()

# Create uploads directory if it doesn't exist
UPLOAD_DIR = "uploads/study_materials"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload")
async def upload_study_material(
    title: str = Form(...),
    description: str = Form(""),
    subject_code: str = Form(...),
    subject_name: str = Form(...),
    tags: str = Form(""),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload a new study material"""

    # Validate file type
    allowed_types = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png']
    file_extension = file.filename.split('.')[-1].lower()

    if file_extension not in allowed_types:
        raise HTTPException(status_code=400, detail="File type not allowed")

    # Generate unique filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{current_user.id}_{timestamp}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    # Save file
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save file: {str(e)}")

    # Get file size
    file_size = os.path.getsize(file_path)

    # Create database record
    db_material = StudyMaterial(
        title=title,
        description=description,
        subject_code=subject_code,
        subject_name=subject_name,
        file_path=file_path,
        file_type=file_extension,
        file_size=file_size,
        uploaded_by=current_user.id,
        tags=tags,
        is_approved=current_user.role == "alumni"  # Auto-approve if uploaded by alumni
    )

    db.add(db_material)
    db.commit()
    db.refresh(db_material)

    return {
        "message": "Study material uploaded successfully",
        "material_id": db_material.id,
        "is_approved": db_material.is_approved
    }

@router.get("/")
async def get_study_materials(
    subject_code: Optional[str] = None,
    subject_name: Optional[str] = None,
    approved_only: bool = True,
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get study materials with optional filters"""

    query = db.query(StudyMaterial)

    # Apply filters
    if subject_code:
        query = query.filter(StudyMaterial.subject_code.ilike(f"%{subject_code}%"))

    if subject_name:
        query = query.filter(StudyMaterial.subject_name.ilike(f"%{subject_name}%"))

    if approved_only:
        query = query.filter(StudyMaterial.is_approved == True)

    # Order by creation date (newest first)
    query = query.order_by(desc(StudyMaterial.created_at))

    # Paginate
    materials = query.offset(skip).limit(limit).all()

    return materials

@router.get("/{material_id}")
async def get_study_material(
    material_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific study material"""

    material = db.query(StudyMaterial).filter(StudyMaterial.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Study material not found")

    # Check if user can view this material
    if not material.is_approved and material.uploaded_by != current_user.id:
        raise HTTPException(status_code=403, detail="Material not yet approved")

    return material

@router.post("/{material_id}/download")
async def download_study_material(
    material_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Download a study material and track the download"""

    material = db.query(StudyMaterial).filter(StudyMaterial.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Study material not found")

    if not material.is_approved:
        raise HTTPException(status_code=403, detail="Material not yet approved")

    # Record download
    download_record = StudyMaterialDownload(
        material_id=material_id,
        user_id=current_user.id
    )

    db.add(download_record)

    # Increment download count
    material.download_count += 1

    db.commit()

    return {
        "message": "Download recorded",
        "file_path": material.file_path,
        "download_count": material.download_count
    }

@router.post("/{material_id}/rate")
async def rate_study_material(
    material_id: str,
    rating: int,
    review: str = "",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Rate a study material"""

    if rating < 1 or rating > 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")

    material = db.query(StudyMaterial).filter(StudyMaterial.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Study material not found")

    if not material.is_approved:
        raise HTTPException(status_code=403, detail="Cannot rate unapproved material")

    # Check if user already rated this material
    existing_rating = db.query(StudyMaterialRating).filter(
        StudyMaterialRating.material_id == material_id,
        StudyMaterialRating.user_id == current_user.id
    ).first()

    if existing_rating:
        # Update existing rating
        existing_rating.rating = rating
        existing_rating.review = review
        existing_rating.updated_at = func.now()
    else:
        # Create new rating
        new_rating = StudyMaterialRating(
            material_id=material_id,
            user_id=current_user.id,
            rating=rating,
            review=review
        )
        db.add(new_rating)

    # Recalculate average rating
    ratings = db.query(StudyMaterialRating).filter(
        StudyMaterialRating.material_id == material_id
    ).all()

    if ratings:
        avg_rating = sum(r.rating for r in ratings) / len(ratings)
        material.rating = round(avg_rating, 1)
        material.rating_count = len(ratings)

    db.commit()

    return {
        "message": "Rating submitted successfully",
        "average_rating": material.rating,
        "total_ratings": material.rating_count
    }

@router.get("/{material_id}/ratings")
async def get_material_ratings(
    material_id: str,
    skip: int = 0,
    limit: int = 10,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get ratings for a study material"""

    material = db.query(StudyMaterial).filter(StudyMaterial.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Study material not found")

    ratings = db.query(StudyMaterialRating).filter(
        StudyMaterialRating.material_id == material_id
    ).offset(skip).limit(limit).all()

    return ratings

@router.put("/{material_id}/approve")
async def approve_study_material(
    material_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Approve a study material (alumni only)"""

    if current_user.role != "alumni":
        raise HTTPException(status_code=403, detail="Only alumni can approve materials")

    material = db.query(StudyMaterial).filter(StudyMaterial.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Study material not found")

    material.is_approved = True
    material.approved_by = current_user.id
    material.approved_at = func.now()

    db.commit()

    return {"message": "Study material approved successfully"}

@router.delete("/{material_id}")
async def delete_study_material(
    material_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a study material"""

    material = db.query(StudyMaterial).filter(StudyMaterial.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Study material not found")

    # Check if user can delete this material
    if material.uploaded_by != current_user.id and current_user.role != "alumni":
        raise HTTPException(status_code=403, detail="Not authorized to delete this material")

    # Delete file from disk
    try:
        if os.path.exists(material.file_path):
            os.remove(material.file_path)
    except Exception as e:
        print(f"Failed to delete file: {e}")

    # Delete from database
    db.delete(material)
    db.commit()

    return {"message": "Study material deleted successfully"}

@router.get("/stats/summary")
async def get_study_materials_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get study materials statistics"""

    total_materials = db.query(func.count(StudyMaterial.id)).scalar()
    approved_materials = db.query(func.count(StudyMaterial.id)).filter(
        StudyMaterial.is_approved == True
    ).scalar()
    total_downloads = db.query(func.sum(StudyMaterial.download_count)).scalar() or 0
    avg_rating = db.query(func.avg(StudyMaterial.rating)).scalar() or 0

    return {
        "total_materials": total_materials,
        "approved_materials": approved_materials,
        "total_downloads": total_downloads,
        "average_rating": round(avg_rating, 2)
    }

@router.get("/subjects/popular")
async def get_popular_subjects(
    limit: int = 10,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get most popular subjects based on material count"""

    popular_subjects = db.query(
        StudyMaterial.subject_code,
        StudyMaterial.subject_name,
        func.count(StudyMaterial.id).label('material_count')
    ).filter(
        StudyMaterial.is_approved == True
    ).group_by(
        StudyMaterial.subject_code,
        StudyMaterial.subject_name
    ).order_by(
        desc(func.count(StudyMaterial.id))
    ).limit(limit).all()

    return [
        {
            "subject_code": subject_code,
            "subject_name": subject_name,
            "material_count": material_count
        }
        for subject_code, subject_name, material_count in popular_subjects
    ]
