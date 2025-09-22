"""
Scholarship management endpoints
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import desc, and_
from app.core.database import get_db, Scholarship, ScholarshipApplication, User
from app.core.security import verify_token

router = APIRouter()

# Pydantic models for API requests/responses
class ScholarshipCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str = Field(..., min_length=10)
    amount: int = Field(..., gt=0)
    category: str = Field(..., pattern="^(merit-based|need-based|research|achievement)$")
    eligibility_criteria: Optional[str] = None
    application_deadline: datetime
    max_applications: Optional[int] = Field(default=100, ge=1)

class ScholarshipResponse(BaseModel):
    id: str
    title: str
    description: str
    amount: int
    category: str
    eligibility_criteria: Optional[str]
    application_deadline: datetime
    max_applications: int
    current_applications: int
    status: str
    created_by: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ScholarshipApplicationCreate(BaseModel):
    scholarship_id: str
    personal_statement: str = Field(..., min_length=50, max_length=2000)
    academic_achievements: Optional[str] = None
    financial_need_statement: Optional[str] = None

class ScholarshipApplicationResponse(BaseModel):
    id: str
    scholarship_id: str
    applicant_id: str
    personal_statement: str
    academic_achievements: Optional[str]
    financial_need_statement: Optional[str]
    status: str
    reviewed_by: Optional[str]
    reviewed_at: Optional[datetime]
    review_notes: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ScholarshipListResponse(BaseModel):
    scholarships: List[ScholarshipResponse]
    total: int

# Scholarship CRUD endpoints
@router.post("/scholarships", response_model=ScholarshipResponse)
async def create_scholarship(
    scholarship_data: ScholarshipCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Create a new scholarship (Alumni only)"""
    try:
        # Verify user is alumni
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can create scholarships"
            )

        # Create scholarship
        new_scholarship = Scholarship(
            title=scholarship_data.title,
            description=scholarship_data.description,
            amount=scholarship_data.amount,
            category=scholarship_data.category,
            eligibility_criteria=scholarship_data.eligibility_criteria,
            application_deadline=scholarship_data.application_deadline,
            max_applications=scholarship_data.max_applications,
            created_by=user.id
        )

        db.add(new_scholarship)
        db.commit()
        db.refresh(new_scholarship)

        return new_scholarship

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create scholarship: {str(e)}"
        )

@router.get("/scholarships", response_model=ScholarshipListResponse)
async def get_scholarships(
    skip: int = 0,
    limit: int = 10,
    category: Optional[str] = None,
    status: str = "active",
    db: Session = Depends(get_db)
):
    """Get all scholarships with optional filtering"""
    try:
        query = db.query(Scholarship).filter(Scholarship.status == status)

        if category:
            query = query.filter(Scholarship.category == category)

        total = query.count()
        scholarships = query.offset(skip).limit(limit).all()

        return ScholarshipListResponse(
            scholarships=scholarships,
            total=total
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch scholarships: {str(e)}"
        )

@router.get("/scholarships/{scholarship_id}", response_model=ScholarshipResponse)
async def get_scholarship(
    scholarship_id: str,
    db: Session = Depends(get_db)
):
    """Get a specific scholarship by ID"""
    try:
        scholarship = db.query(Scholarship).filter(Scholarship.id == scholarship_id).first()

        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Scholarship not found"
            )

        return scholarship

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch scholarship: {str(e)}"
        )

@router.put("/scholarships/{scholarship_id}", response_model=ScholarshipResponse)
async def update_scholarship(
    scholarship_id: str,
    scholarship_data: ScholarshipCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Update a scholarship (Alumni only)"""
    try:
        # Verify user is alumni and owns the scholarship
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can update scholarships"
            )

        scholarship = db.query(Scholarship).filter(
            and_(Scholarship.id == scholarship_id, Scholarship.created_by == user.id)
        ).first()

        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Scholarship not found or access denied"
            )

        # Update fields
        for field, value in scholarship_data.dict().items():
            if hasattr(scholarship, field):
                setattr(scholarship, field, value)

        db.commit()
        db.refresh(scholarship)

        return scholarship

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update scholarship: {str(e)}"
        )

@router.delete("/scholarships/{scholarship_id}")
async def delete_scholarship(
    scholarship_id: str,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Delete a scholarship (Alumni only)"""
    try:
        # Verify user is alumni and owns the scholarship
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can delete scholarships"
            )

        scholarship = db.query(Scholarship).filter(
            and_(Scholarship.id == scholarship_id, Scholarship.created_by == user.id)
        ).first()

        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Scholarship not found or access denied"
            )

        db.delete(scholarship)
        db.commit()

        return {"message": "Scholarship deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete scholarship: {str(e)}"
        )

# Scholarship Application endpoints
@router.post("/scholarships/{scholarship_id}/apply", response_model=ScholarshipApplicationResponse)
async def apply_for_scholarship(
    scholarship_id: str,
    application_data: ScholarshipApplicationCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Apply for a scholarship"""
    try:
        # Verify user is student
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "student":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only students can apply for scholarships"
            )

        # Check if scholarship exists and is active
        scholarship = db.query(Scholarship).filter(
            and_(Scholarship.id == scholarship_id, Scholarship.status == "active")
        ).first()

        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Scholarship not found or not active"
            )

        # Check if application deadline has passed
        if scholarship.application_deadline < datetime.now():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Application deadline has passed"
            )

        # Check if maximum applications reached
        if scholarship.current_applications >= scholarship.max_applications:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Maximum number of applications reached"
            )

        # Check if user already applied
        existing_application = db.query(ScholarshipApplication).filter(
            and_(
                ScholarshipApplication.scholarship_id == scholarship_id,
                ScholarshipApplication.applicant_id == user.id
            )
        ).first()

        if existing_application:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You have already applied for this scholarship"
            )

        # Create application
        new_application = ScholarshipApplication(
            scholarship_id=scholarship_id,
            applicant_id=user.id,
            personal_statement=application_data.personal_statement,
            academic_achievements=application_data.academic_achievements,
            financial_need_statement=application_data.financial_need_statement
        )

        # Update scholarship application count
        scholarship.current_applications += 1

        db.add(new_application)
        db.commit()
        db.refresh(new_application)

        return new_application

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to submit application: {str(e)}"
        )

@router.get("/scholarships/{scholarship_id}/applications")
async def get_scholarship_applications(
    scholarship_id: str,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get all applications for a scholarship (Alumni only)"""
    try:
        # Verify user is alumni and owns the scholarship
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can view applications"
            )

        scholarship = db.query(Scholarship).filter(
            and_(Scholarship.id == scholarship_id, Scholarship.created_by == user.id)
        ).first()

        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Scholarship not found or access denied"
            )

        applications = db.query(ScholarshipApplication).filter(
            ScholarshipApplication.scholarship_id == scholarship_id
        ).all()

        return applications

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch applications: {str(e)}"
        )

@router.put("/scholarships/applications/{application_id}")
async def review_scholarship_application(
    application_id: str,
    status: str,
    review_notes: Optional[str] = None,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Review a scholarship application (Alumni only)"""
    try:
        # Verify user is alumni
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can review applications"
            )

        application = db.query(ScholarshipApplication).filter(
            ScholarshipApplication.id == application_id
        ).first()

        if not application:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found"
            )

        # Verify alumni owns the scholarship
        scholarship = db.query(Scholarship).filter(
            Scholarship.id == application.scholarship_id
        ).first()

        if scholarship.created_by != user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied"
            )

        # Update application
        application.status = status
        application.reviewed_by = user.id
        application.reviewed_at = datetime.now()
        application.review_notes = review_notes

        db.commit()

        return {"message": f"Application {status} successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to review application: {str(e)}"
        )
