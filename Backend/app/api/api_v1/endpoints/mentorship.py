"""
Mentorship management endpoints
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.core.database import get_db, Mentorship, User
from app.core.security import verify_token

router = APIRouter()

class MentorshipRequest(BaseModel):
    mentor_id: str
    message: Optional[str] = None

class MentorshipUpdate(BaseModel):
    status: Optional[str] = None

class MentorshipResponse(BaseModel):
    id: str
    mentor_id: str
    mentee_id: str
    status: str
    message: Optional[str]
    created_at: str
    updated_at: str

@router.get("/", response_model=List[MentorshipResponse])
async def get_mentorships(token: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all mentorships for current user (both as mentor and mentee)"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get mentorships where user is mentor or mentee
        mentorships = db.query(Mentorship).filter(
            (Mentorship.mentor_id == payload['sub']) | (Mentorship.mentee_id == payload['sub'])
        ).offset(skip).limit(limit).all()

        return [
            {
                "id": mentorship.id,
                "mentor_id": mentorship.mentor_id,
                "mentee_id": mentorship.mentee_id,
                "status": mentorship.status,
                "message": mentorship.message,
                "created_at": mentorship.created_at.isoformat() if mentorship.created_at else None,
                "updated_at": mentorship.updated_at.isoformat() if mentorship.updated_at else None
            }
            for mentorship in mentorships
        ]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch mentorships: {str(e)}"
        )

@router.post("/request", response_model=MentorshipResponse)
async def request_mentorship(mentorship_request: MentorshipRequest, token: str, db: Session = Depends(get_db)):
    """Request mentorship from another user"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if users exist
        mentor = db.query(User).filter(User.id == mentorship_request.mentor_id).first()
        mentee = db.query(User).filter(User.id == payload['sub']).first()

        if not mentor:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Mentor not found"
            )

        if not mentee:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Check if mentorship already exists
        existing_mentorship = db.query(Mentorship).filter(
            Mentorship.mentor_id == mentorship_request.mentor_id,
            Mentorship.mentee_id == payload['sub']
        ).first()

        if existing_mentorship:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Mentorship request already exists"
            )

        # Create mentorship request
        new_mentorship = Mentorship(
            mentor_id=mentorship_request.mentor_id,
            mentee_id=payload['sub'],
            message=mentorship_request.message,
            status="pending"
        )

        db.add(new_mentorship)
        db.commit()
        db.refresh(new_mentorship)

        return {
            "id": new_mentorship.id,
            "mentor_id": new_mentorship.mentor_id,
            "mentee_id": new_mentorship.mentee_id,
            "status": new_mentorship.status,
            "message": new_mentorship.message,
            "created_at": new_mentorship.created_at.isoformat() if new_mentorship.created_at else None,
            "updated_at": new_mentorship.updated_at.isoformat() if new_mentorship.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create mentorship request: {str(e)}"
        )

@router.get("/{mentorship_id}", response_model=MentorshipResponse)
async def get_mentorship(mentorship_id: str, token: str, db: Session = Depends(get_db)):
    """Get a specific mentorship by ID"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get mentorship
        mentorship = db.query(Mentorship).filter(
            Mentorship.id == mentorship_id,
            (Mentorship.mentor_id == payload['sub']) | (Mentorship.mentee_id == payload['sub'])
        ).first()

        if not mentorship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Mentorship not found"
            )

        return {
            "id": mentorship.id,
            "mentor_id": mentorship.mentor_id,
            "mentee_id": mentorship.mentee_id,
            "status": mentorship.status,
            "message": mentorship.message,
            "created_at": mentorship.created_at.isoformat() if mentorship.created_at else None,
            "updated_at": mentorship.updated_at.isoformat() if mentorship.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch mentorship: {str(e)}"
        )

@router.put("/{mentorship_id}", response_model=MentorshipResponse)
async def update_mentorship(mentorship_id: str, mentorship_update: MentorshipUpdate, token: str, db: Session = Depends(get_db)):
    """Update mentorship status (accept/reject)"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if mentorship exists and user is the mentor
        mentorship = db.query(Mentorship).filter(
            Mentorship.id == mentorship_id,
            Mentorship.mentor_id == payload['sub']
        ).first()

        if not mentorship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Mentorship not found or you are not authorized to update it"
            )

        # Update mentorship status
        if mentorship_update.status is not None:
            mentorship.status = mentorship_update.status

        db.commit()
        db.refresh(mentorship)

        return {
            "id": mentorship.id,
            "mentor_id": mentorship.mentor_id,
            "mentee_id": mentorship.mentee_id,
            "status": mentorship.status,
            "message": mentorship.message,
            "created_at": mentorship.created_at.isoformat() if mentorship.created_at else None,
            "updated_at": mentorship.updated_at.isoformat() if mentorship.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update mentorship: {str(e)}"
        )

@router.delete("/{mentorship_id}")
async def delete_mentorship(mentorship_id: str, token: str, db: Session = Depends(get_db)):
    """Delete a mentorship request"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if mentorship exists and user is involved
        mentorship = db.query(Mentorship).filter(
            Mentorship.id == mentorship_id,
            (Mentorship.mentor_id == payload['sub']) | (Mentorship.mentee_id == payload['sub'])
        ).first()

        if not mentorship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Mentorship not found or you are not authorized to delete it"
            )

        # Delete mentorship
        db.delete(mentorship)
        db.commit()

        return {"message": "Mentorship deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete mentorship: {str(e)}"
        )

@router.get("/requests/pending", response_model=List[MentorshipResponse])
async def get_pending_requests(token: str, db: Session = Depends(get_db)):
    """Get pending mentorship requests for current user (as mentor)"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get pending requests where user is mentor
        pending_requests = db.query(Mentorship).filter(
            Mentorship.mentor_id == payload['sub'],
            Mentorship.status == 'pending'
        ).all()

        return [
            {
                "id": mentorship.id,
                "mentor_id": mentorship.mentor_id,
                "mentee_id": mentorship.mentee_id,
                "status": mentorship.status,
                "message": mentorship.message,
                "created_at": mentorship.created_at.isoformat() if mentorship.created_at else None,
                "updated_at": mentorship.updated_at.isoformat() if mentorship.updated_at else None
            }
            for mentorship in pending_requests
        ]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch pending requests: {str(e)}"
        )

@router.get("/mentees/active", response_model=List[MentorshipResponse])
async def get_active_mentees(token: str, db: Session = Depends(get_db)):
    """Get active mentorships where user is mentor"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get active mentorships where user is mentor
        active_mentees = db.query(Mentorship).filter(
            Mentorship.mentor_id == payload['sub'],
            Mentorship.status == 'accepted'
        ).all()

        return [
            {
                "id": mentorship.id,
                "mentor_id": mentorship.mentor_id,
                "mentee_id": mentorship.mentee_id,
                "status": mentorship.status,
                "message": mentorship.message,
                "created_at": mentorship.created_at.isoformat() if mentorship.created_at else None,
                "updated_at": mentorship.updated_at.isoformat() if mentorship.updated_at else None
            }
            for mentorship in active_mentees
        ]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch active mentees: {str(e)}"
        )
