"""
Job application tracking endpoints
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel
from datetime import date
from sqlalchemy.orm import Session
from app.core.database import get_db, Application
from app.core.security import verify_token

router = APIRouter()

class ApplicationCreate(BaseModel):
    company: str
    position: str
    status: Optional[str] = "applied"
    job_description: Optional[str] = None
    application_date: Optional[date] = None
    notes: Optional[str] = None

class ApplicationUpdate(BaseModel):
    company: Optional[str] = None
    position: Optional[str] = None
    status: Optional[str] = None
    job_description: Optional[str] = None
    application_date: Optional[date] = None
    notes: Optional[str] = None

class ApplicationResponse(BaseModel):
    id: str
    user_id: str
    company: str
    position: str
    status: str
    job_description: Optional[str]
    application_date: str
    notes: Optional[str]
    created_at: str
    updated_at: str

@router.get("/", response_model=List[ApplicationResponse])
async def get_applications(token: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all applications for current user"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        applications = db.query(Application).filter(Application.user_id == payload['sub']).offset(skip).limit(limit).all()

        return [
            {
                "id": app.id,
                "user_id": app.user_id,
                "company": app.company,
                "position": app.position,
                "status": app.status,
                "job_description": app.job_description,
                "application_date": app.application_date.isoformat() if app.application_date else None,
                "notes": app.notes,
                "created_at": app.created_at.isoformat() if app.created_at else None,
                "updated_at": app.updated_at.isoformat() if app.updated_at else None
            }
            for app in applications
        ]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch applications: {str(e)}"
        )

@router.post("/", response_model=ApplicationResponse)
async def create_application(application_data: ApplicationCreate, token: str, db: Session = Depends(get_db)):
    """Create a new job application"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Create new application
        new_application = Application(
            user_id=payload['sub'],
            company=application_data.company,
            position=application_data.position,
            status=application_data.status or "applied",
            job_description=application_data.job_description,
            application_date=application_data.application_date or date.today(),
            notes=application_data.notes
        )

        db.add(new_application)
        db.commit()
        db.refresh(new_application)

        return {
            "id": new_application.id,
            "user_id": new_application.user_id,
            "company": new_application.company,
            "position": new_application.position,
            "status": new_application.status,
            "job_description": new_application.job_description,
            "application_date": new_application.application_date.isoformat() if new_application.application_date else None,
            "notes": new_application.notes,
            "created_at": new_application.created_at.isoformat() if new_application.created_at else None,
            "updated_at": new_application.updated_at.isoformat() if new_application.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create application: {str(e)}"
        )

@router.get("/{application_id}", response_model=ApplicationResponse)
async def get_application(application_id: str, token: str, db: Session = Depends(get_db)):
    """Get a specific application by ID"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get application
        application = db.query(Application).filter(
            Application.id == application_id,
            Application.user_id == payload['sub']
        ).first()

        if not application:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found"
            )

        return {
            "id": application.id,
            "user_id": application.user_id,
            "company": application.company,
            "position": application.position,
            "status": application.status,
            "job_description": application.job_description,
            "application_date": application.application_date.isoformat() if application.application_date else None,
            "notes": application.notes,
            "created_at": application.created_at.isoformat() if application.created_at else None,
            "updated_at": application.updated_at.isoformat() if application.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch application: {str(e)}"
        )

@router.put("/{application_id}", response_model=ApplicationResponse)
async def update_application(application_id: str, application_update: ApplicationUpdate, token: str, db: Session = Depends(get_db)):
    """Update a job application"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if application exists and belongs to user
        application = db.query(Application).filter(
            Application.id == application_id,
            Application.user_id == payload['sub']
        ).first()

        if not application:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found"
            )

        # Update application fields
        if application_update.company is not None:
            application.company = application_update.company
        if application_update.position is not None:
            application.position = application_update.position
        if application_update.status is not None:
            application.status = application_update.status
        if application_update.job_description is not None:
            application.job_description = application_update.job_description
        if application_update.application_date is not None:
            application.application_date = application_update.application_date
        if application_update.notes is not None:
            application.notes = application_update.notes

        db.commit()
        db.refresh(application)

        return {
            "id": application.id,
            "user_id": application.user_id,
            "company": application.company,
            "position": application.position,
            "status": application.status,
            "job_description": application.job_description,
            "application_date": application.application_date.isoformat() if application.application_date else None,
            "notes": application.notes,
            "created_at": application.created_at.isoformat() if application.created_at else None,
            "updated_at": application.updated_at.isoformat() if application.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update application: {str(e)}"
        )

@router.delete("/{application_id}")
async def delete_application(application_id: str, token: str, db: Session = Depends(get_db)):
    """Delete a job application"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if application exists and belongs to user
        application = db.query(Application).filter(
            Application.id == application_id,
            Application.user_id == payload['sub']
        ).first()

        if not application:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found"
            )

        # Delete application
        db.delete(application)
        db.commit()

        return {"message": "Application deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete application: {str(e)}"
        )

@router.get("/stats/summary", response_model=Dict[str, Any])
async def get_application_stats(token: str, db: Session = Depends(get_db)):
    """Get application statistics for current user"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get all applications for user
        applications = db.query(Application).filter(Application.user_id == payload['sub']).all()

        if not applications:
            return {
                "total": 0,
                "applied": 0,
                "interviewing": 0,
                "rejected": 0,
                "accepted": 0
            }

        # Count by status
        stats = {}
        for app in applications:
            status = app.status
            stats[status] = stats.get(status, 0) + 1

        return {
            "total": len(applications),
            "applied": stats.get('applied', 0),
            "interviewing": stats.get('interviewing', 0),
            "rejected": stats.get('rejected', 0),
            "accepted": stats.get('accepted', 0)
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch application stats: {str(e)}"
        )
