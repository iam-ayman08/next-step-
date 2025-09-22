"""
Project Aid & Support management endpoints
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import desc, and_
from app.core.database import get_db, Project, ProjectSupport, User, AlumniExpertise
from app.core.security import verify_token

router = APIRouter()

# Pydantic models for API requests/responses
class ProjectCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str = Field(..., min_length=10, max_length=1000)
    category: str = Field(..., pattern="^(technology|research|social-impact|healthcare|education|environment|business|arts-culture)$")
    funding_goal: int = Field(..., gt=0)
    funding_type: str = Field(..., pattern="^(financial|mentorship|technical|resources|networking|all)$")
    timeline: str = Field(..., min_length=1, max_length=255)
    expected_outcomes: str = Field(..., min_length=10, max_length=500)
    team_members: Optional[str] = None

class ProjectResponse(BaseModel):
    id: str
    title: str
    description: str
    category: str
    funding_goal: int
    current_funding: int
    funding_type: str
    timeline: str
    expected_outcomes: str
    team_members: Optional[str]
    status: str
    created_by: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ProjectSupportCreate(BaseModel):
    project_id: str
    support_type: str = Field(..., pattern="^(financial|mentorship|technical|resources|networking)$")
    support_amount: Optional[int] = Field(default=0, ge=0)
    support_description: str = Field(..., min_length=10, max_length=500)

class ProjectSupportResponse(BaseModel):
    id: str
    project_id: str
    supporter_id: str
    support_type: str
    support_amount: Optional[int]
    support_description: str
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ProjectListResponse(BaseModel):
    projects: List[ProjectResponse]
    total: int

class AlumniExpertiseCreate(BaseModel):
    expertise_area: str = Field(..., min_length=1, max_length=255)
    years_experience: Optional[int] = Field(default=0, ge=0)
    current_position: Optional[str] = None
    company: Optional[str] = None
    skills: Optional[str] = None
    availability_status: str = Field(default="available", pattern="^(available|busy|unavailable)$")

class AlumniExpertiseResponse(BaseModel):
    id: str
    user_id: str
    expertise_area: str
    years_experience: int
    current_position: Optional[str]
    company: Optional[str]
    skills: Optional[str]
    availability_status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Project CRUD endpoints
@router.post("/projects", response_model=ProjectResponse)
async def create_project(
    project_data: ProjectCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Create a new project (Students only)"""
    try:
        # Verify user is student
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "student":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only students can create projects"
            )

        # Create project
        new_project = Project(
            title=project_data.title,
            description=project_data.description,
            category=project_data.category,
            funding_goal=project_data.funding_goal,
            funding_type=project_data.funding_type,
            timeline=project_data.timeline,
            expected_outcomes=project_data.expected_outcomes,
            team_members=project_data.team_members,
            created_by=user.id
        )

        db.add(new_project)
        db.commit()
        db.refresh(new_project)

        return new_project

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create project: {str(e)}"
        )

@router.get("/projects", response_model=ProjectListResponse)
async def get_projects(
    skip: int = 0,
    limit: int = 10,
    category: Optional[str] = None,
    status: str = "pending",
    funding_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all projects with optional filtering"""
    try:
        query = db.query(Project).filter(Project.status == status)

        if category:
            query = query.filter(Project.category == category)

        if funding_type:
            query = query.filter(Project.funding_type == funding_type)

        total = query.count()
        projects = query.order_by(desc(Project.created_at)).offset(skip).limit(limit).all()

        return ProjectListResponse(
            projects=projects,
            total=total
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch projects: {str(e)}"
        )

@router.get("/projects/{project_id}", response_model=ProjectResponse)
async def get_project(
    project_id: str,
    db: Session = Depends(get_db)
):
    """Get a specific project by ID"""
    try:
        project = db.query(Project).filter(Project.id == project_id).first()

        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )

        return project

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch project: {str(e)}"
        )

@router.put("/projects/{project_id}", response_model=ProjectResponse)
async def update_project(
    project_id: str,
    project_data: ProjectCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Update a project (Project owner only)"""
    try:
        # Verify user owns the project
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User not found"
            )

        project = db.query(Project).filter(
            and_(Project.id == project_id, Project.created_by == user.id)
        ).first()

        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found or access denied"
            )

        # Update fields
        for field, value in project_data.dict().items():
            if hasattr(project, field):
                setattr(project, field, value)

        db.commit()
        db.refresh(project)

        return project

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update project: {str(e)}"
        )

@router.delete("/projects/{project_id}")
async def delete_project(
    project_id: str,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Delete a project (Project owner only)"""
    try:
        # Verify user owns the project
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User not found"
            )

        project = db.query(Project).filter(
            and_(Project.id == project_id, Project.created_by == user.id)
        ).first()

        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found or access denied"
            )

        db.delete(project)
        db.commit()

        return {"message": "Project deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete project: {str(e)}"
        )

# Project Support endpoints
@router.post("/projects/{project_id}/support", response_model=ProjectSupportResponse)
async def provide_project_support(
    project_id: str,
    support_data: ProjectSupportCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Provide support for a project (Alumni only)"""
    try:
        # Verify user is alumni
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can provide project support"
            )

        # Check if project exists and is active
        project = db.query(Project).filter(
            and_(Project.id == project_id, Project.status.in_(["pending", "in_progress"]))
        ).first()

        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found or not accepting support"
            )

        # Check if alumni already provided support for this project
        existing_support = db.query(ProjectSupport).filter(
            and_(
                ProjectSupport.project_id == project_id,
                ProjectSupport.supporter_id == user.id
            )
        ).first()

        if existing_support:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You have already provided support for this project"
            )

        # Create support record
        new_support = ProjectSupport(
            project_id=project_id,
            supporter_id=user.id,
            support_type=support_data.support_type,
            support_amount=support_data.support_amount,
            support_description=support_data.support_description
        )

        # Update project funding if financial support
        if support_data.support_type == "financial" and support_data.support_amount:
            project.current_funding += support_data.support_amount

            # Check if project is fully funded
            if project.current_funding >= project.funding_goal:
                project.status = "funded"

        db.add(new_support)
        db.commit()
        db.refresh(new_support)

        return new_support

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to provide support: {str(e)}"
        )

@router.get("/projects/{project_id}/support")
async def get_project_supporters(
    project_id: str,
    db: Session = Depends(get_db)
):
    """Get all supporters for a project"""
    try:
        project = db.query(Project).filter(Project.id == project_id).first()

        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )

        supporters = db.query(ProjectSupport).filter(
            ProjectSupport.project_id == project_id
        ).all()

        return supporters

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch supporters: {str(e)}"
        )

@router.get("/projects/my-supports")
async def get_my_project_supports(
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get projects supported by current user (Alumni only)"""
    try:
        # Verify user is alumni
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can view their supports"
            )

        supports = db.query(ProjectSupport).filter(
            ProjectSupport.supporter_id == user.id
        ).all()

        return supports

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch supports: {str(e)}"
        )

# Alumni Expertise endpoints
@router.post("/alumni/expertise", response_model=AlumniExpertiseResponse)
async def add_alumni_expertise(
    expertise_data: AlumniExpertiseCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Add or update alumni expertise (Alumni only)"""
    try:
        # Verify user is alumni
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can add expertise"
            )

        # Check if expertise already exists
        existing_expertise = db.query(AlumniExpertise).filter(
            AlumniExpertise.user_id == user.id
        ).first()

        if existing_expertise:
            # Update existing
            for field, value in expertise_data.dict().items():
                if hasattr(existing_expertise, field):
                    setattr(existing_expertise, field, value)
            db.commit()
            db.refresh(existing_expertise)
            return existing_expertise
        else:
            # Create new
            new_expertise = AlumniExpertise(
                user_id=user.id,
                **expertise_data.dict()
            )
            db.add(new_expertise)
            db.commit()
            db.refresh(new_expertise)
            return new_expertise

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to add expertise: {str(e)}"
        )

@router.get("/alumni/expertise")
async def get_alumni_expertise(
    expertise_area: Optional[str] = None,
    availability_status: str = "available",
    skip: int = 0,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """Get alumni expertise with optional filtering"""
    try:
        query = db.query(AlumniExpertise).filter(
            AlumniExpertise.availability_status == availability_status
        )

        if expertise_area:
            query = query.filter(AlumniExpertise.expertise_area == expertise_area)

        total = query.count()
        expertise_list = query.offset(skip).limit(limit).all()

        return {
            "expertise": expertise_list,
            "total": total
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch expertise: {str(e)}"
        )

@router.get("/alumni/expertise/{expertise_id}", response_model=AlumniExpertiseResponse)
async def get_alumni_expertise_by_id(
    expertise_id: str,
    db: Session = Depends(get_db)
):
    """Get specific alumni expertise by ID"""
    try:
        expertise = db.query(AlumniExpertise).filter(
            AlumniExpertise.id == expertise_id
        ).first()

        if not expertise:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expertise not found"
            )

        return expertise

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch expertise: {str(e)}"
        )

@router.put("/alumni/expertise/{expertise_id}", response_model=AlumniExpertiseResponse)
async def update_alumni_expertise(
    expertise_id: str,
    expertise_data: AlumniExpertiseCreate,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Update alumni expertise (Owner only)"""
    try:
        # Verify user owns the expertise
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can update expertise"
            )

        expertise = db.query(AlumniExpertise).filter(
            and_(AlumniExpertise.id == expertise_id, AlumniExpertise.user_id == user.id)
        ).first()

        if not expertise:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expertise not found or access denied"
            )

        # Update fields
        for field, value in expertise_data.dict().items():
            if hasattr(expertise, field):
                setattr(expertise, field, value)

        db.commit()
        db.refresh(expertise)

        return expertise

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update expertise: {str(e)}"
        )

@router.delete("/alumni/expertise/{expertise_id}")
async def delete_alumni_expertise(
    expertise_id: str,
    token: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Delete alumni expertise (Owner only)"""
    try:
        # Verify user owns the expertise
        user = db.query(User).filter(User.id == token['sub']).first()
        if not user or user.role != "alumni":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only alumni can delete expertise"
            )

        expertise = db.query(AlumniExpertise).filter(
            and_(AlumniExpertise.id == expertise_id, AlumniExpertise.user_id == user.id)
        ).first()

        if not expertise:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expertise not found or access denied"
            )

        db.delete(expertise)
        db.commit()

        return {"message": "Expertise deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete expertise: {str(e)}"
        )
