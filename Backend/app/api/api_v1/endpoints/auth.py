"""
Authentication endpoints for username/password authentication
"""

from datetime import timedelta
from typing import Dict, Any
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    verify_token
)
from app.core.database import get_db, User
from app.core.config import settings

router = APIRouter()

class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str
    name: str
    role: str = "student"  # student or alumni

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: Dict[str, Any]

@router.post("/login", response_model=TokenResponse)
async def login(login_request: LoginRequest, db: Session = Depends(get_db)):
    """Authenticate user with username and password"""
    try:
        # Find user by username
        user = db.query(User).filter(User.username == login_request.username).first()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid username or password"
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is disabled"
            )

        # Verify password
        if not verify_password(login_request.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid username or password"
            )

        # Create JWT token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.id, "username": user.username, "email": user.email},
            expires_delta=access_token_expires
        )

        # Convert user to dict for response
        user_data = {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "name": user.name,
            "role": user.role,
            "created_at": user.created_at.isoformat() if user.created_at else None,
            "updated_at": user.updated_at.isoformat() if user.updated_at else None
        }

        return TokenResponse(
            access_token=access_token,
            user=user_data
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Login failed: {str(e)}"
        )

@router.post("/register", response_model=TokenResponse)
async def register(register_request: RegisterRequest, db: Session = Depends(get_db)):
    """Register a new user"""
    try:
        # Check if username already exists
        existing_username = db.query(User).filter(User.username == register_request.username).first()
        if existing_username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already exists"
            )

        # Check if email already exists
        existing_email = db.query(User).filter(User.email == register_request.email).first()
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already exists"
            )

        # Validate role
        if register_request.role not in ["student", "alumni"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Role must be either 'student' or 'alumni'"
            )

        # Hash password
        password_hash = get_password_hash(register_request.password)

        # Create new user
        new_user = User(
            username=register_request.username,
            email=register_request.email,
            password_hash=password_hash,
            name=register_request.name,
            role=register_request.role
        )

        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        # Create JWT token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": new_user.id, "username": new_user.username, "email": new_user.email},
            expires_delta=access_token_expires
        )

        # Convert user to dict for response
        user_data = {
            "id": new_user.id,
            "username": new_user.username,
            "email": new_user.email,
            "name": new_user.name,
            "role": new_user.role,
            "created_at": new_user.created_at.isoformat() if new_user.created_at else None,
            "updated_at": new_user.updated_at.isoformat() if new_user.updated_at else None
        }

        return TokenResponse(
            access_token=access_token,
            user=user_data
        )

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}"
        )

@router.post("/verify")
async def verify_token_endpoint(token: str, db: Session = Depends(get_db)):
    """Verify JWT token and return user info"""
    try:
        payload = verify_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # Get user from database
        user = db.query(User).filter(User.id == payload['sub']).first()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Convert user to dict for response
        user_data = {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "name": user.name,
            "role": user.role,
            "is_active": user.is_active,
            "created_at": user.created_at.isoformat() if user.created_at else None,
            "updated_at": user.updated_at.isoformat() if user.updated_at else None
        }

        return {
            "valid": True,
            "user": user_data
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {str(e)}"
        )
