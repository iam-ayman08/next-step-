"""
User profile management endpoints
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.core.database import get_db, Profile
from app.core.security import verify_token

router = APIRouter()

class ProfileCreate(BaseModel):
    bio: Optional[str] = None
    skills: Optional[List[str]] = None
    interests: Optional[List[str]] = None
    location: Optional[str] = None
    phone: Optional[str] = None
    linkedin_url: Optional[str] = None
    github_url: Optional[str] = None
    portfolio_url: Optional[str] = None
    graduation_year: Optional[str] = None
    company: Optional[str] = None

class ProfileUpdate(BaseModel):
    bio: Optional[str] = None
    skills: Optional[List[str]] = None
    interests: Optional[List[str]] = None
    location: Optional[str] = None
    phone: Optional[str] = None
    linkedin_url: Optional[str] = None
    github_url: Optional[str] = None
    portfolio_url: Optional[str] = None
    graduation_year: Optional[str] = None
    company: Optional[str] = None

class ProfileResponse(BaseModel):
    id: str
    bio: Optional[str]
    skills: Optional[str]  # JSON string
    interests: Optional[str]  # JSON string
    location: Optional[str]
    phone: Optional[str]
    linkedin_url: Optional[str]
    github_url: Optional[str]
    portfolio_url: Optional[str]
    graduation_year: Optional[str]
    company: Optional[str]
    created_at: str
    updated_at: str

@router.get("/", response_model=ProfileResponse)
async def get_profile(token: str, db: Session = Depends(get_db)):
    """Get current user's profile"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get profile from database
        profile = db.query(Profile).filter(Profile.id == payload['sub']).first()

        if not profile:
            # Return empty profile if not found
            return {
                "id": payload['sub'],
                "bio": None,
                "skills": None,
                "interests": None,
                "location": None,
                "phone": None,
                "linkedin_url": None,
                "github_url": None,
                "portfolio_url": None,
                "graduation_year": None,
                "company": None,
                "created_at": None,
                "updated_at": None
            }

        return {
            "id": profile.id,
            "bio": profile.bio,
            "skills": profile.skills,
            "interests": profile.interests,
            "location": profile.location,
            "phone": profile.phone,
            "linkedin_url": profile.linkedin_url,
            "github_url": profile.github_url,
            "portfolio_url": profile.portfolio_url,
            "graduation_year": profile.graduation_year,
            "company": profile.company,
            "created_at": profile.created_at.isoformat() if profile.created_at else None,
            "updated_at": profile.updated_at.isoformat() if profile.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch profile: {str(e)}"
        )

@router.post("/", response_model=ProfileResponse)
async def create_profile(profile_data: ProfileCreate, token: str, db: Session = Depends(get_db)):
    """Create or update user's profile"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if profile already exists
        existing_profile = db.query(Profile).filter(Profile.id == payload['sub']).first()

        if existing_profile:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Profile already exists. Use PUT to update."
            )

        # Create new profile
        new_profile = Profile(
            id=payload['sub'],
            bio=profile_data.bio,
            skills=str(profile_data.skills) if profile_data.skills else None,
            interests=str(profile_data.interests) if profile_data.interests else None,
            location=profile_data.location,
            phone=profile_data.phone,
            linkedin_url=profile_data.linkedin_url,
            github_url=profile_data.github_url,
            portfolio_url=profile_data.portfolio_url,
            graduation_year=profile_data.graduation_year,
            company=profile_data.company
        )

        db.add(new_profile)
        db.commit()
        db.refresh(new_profile)

        return {
            "id": new_profile.id,
            "bio": new_profile.bio,
            "skills": new_profile.skills,
            "interests": new_profile.interests,
            "location": new_profile.location,
            "phone": new_profile.phone,
            "linkedin_url": new_profile.linkedin_url,
            "github_url": new_profile.github_url,
            "portfolio_url": new_profile.portfolio_url,
            "graduation_year": new_profile.graduation_year,
            "company": new_profile.company,
            "created_at": new_profile.created_at.isoformat() if new_profile.created_at else None,
            "updated_at": new_profile.updated_at.isoformat() if new_profile.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create profile: {str(e)}"
        )

@router.put("/", response_model=ProfileResponse)
async def update_profile(profile_update: ProfileUpdate, token: str, db: Session = Depends(get_db)):
    """Update user's profile"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if profile exists
        profile = db.query(Profile).filter(Profile.id == payload['sub']).first()

        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found. Use POST to create."
            )

        # Update profile fields
        if profile_update.bio is not None:
            profile.bio = profile_update.bio
        if profile_update.skills is not None:
            profile.skills = str(profile_update.skills) if profile_update.skills else None
        if profile_update.interests is not None:
            profile.interests = str(profile_update.interests) if profile_update.interests else None
        if profile_update.location is not None:
            profile.location = profile_update.location
        if profile_update.phone is not None:
            profile.phone = profile_update.phone
        if profile_update.linkedin_url is not None:
            profile.linkedin_url = profile_update.linkedin_url
        if profile_update.github_url is not None:
            profile.github_url = profile_update.github_url
        if profile_update.portfolio_url is not None:
            profile.portfolio_url = profile_update.portfolio_url
        if profile_update.graduation_year is not None:
            profile.graduation_year = profile_update.graduation_year
        if profile_update.company is not None:
            profile.company = profile_update.company

        db.commit()
        db.refresh(profile)

        return {
            "id": profile.id,
            "bio": profile.bio,
            "skills": profile.skills,
            "interests": profile.interests,
            "location": profile.location,
            "phone": profile.phone,
            "linkedin_url": profile.linkedin_url,
            "github_url": profile.github_url,
            "portfolio_url": profile.portfolio_url,
            "graduation_year": profile.graduation_year,
            "company": profile.company,
            "created_at": profile.created_at.isoformat() if profile.created_at else None,
            "updated_at": profile.updated_at.isoformat() if profile.updated_at else None
        }

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )

@router.delete("/")
async def delete_profile(token: str, db: Session = Depends(get_db)):
    """Delete user's profile"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Check if profile exists
        profile = db.query(Profile).filter(Profile.id == payload['sub']).first()

        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found"
            )

        # Delete profile
        db.delete(profile)
        db.commit()

        return {"message": "Profile deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete profile: {str(e)}"
        )
