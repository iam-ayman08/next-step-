"""
Main API router that includes all v1 endpoints
"""

from fastapi import APIRouter
from app.api.api_v1.endpoints import (
    auth, users, applications, mentorship, profiles, scholarships,
    projects, notifications, uploads, study_materials, research_collaborations
)

# Create main API router
api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(profiles.router, prefix="/profiles", tags=["profiles"])
api_router.include_router(applications.router, prefix="/applications", tags=["applications"])
api_router.include_router(mentorship.router, prefix="/mentorship", tags=["mentorship"])
api_router.include_router(scholarships.router, prefix="/scholarships", tags=["scholarships"])
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
api_router.include_router(uploads.router, prefix="/uploads", tags=["file uploads"])
api_router.include_router(study_materials.router, prefix="/study-materials", tags=["study materials"])
api_router.include_router(research_collaborations.router, prefix="/research-collaborations", tags=["research collaborations"])
