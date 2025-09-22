"""
Research Collaboration API endpoints
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import List, Optional
import json

from app.core.database import (
    ResearchCollaboration, CollaborationApplication, CollaborationParticipant,
    ResearchUpdate, User, get_db
)
from app.core.security import get_current_user

router = APIRouter()

@router.post("/create")
async def create_research_collaboration(
    title: str,
    description: str,
    research_area: str,
    objectives: str,
    methodology: str = "",
    expected_outcomes: str = "",
    timeline: str = "",
    max_collaborators: int = 10,
    budget: int = 0,
    requirements: str = "",
    deliverables: str = "",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new research collaboration project"""

    if current_user.role != "alumni":
        raise HTTPException(status_code=403, detail="Only alumni can create research collaborations")

    # Validate max_collaborators
    if max_collaborators < 5 or max_collaborators > 10:
        raise HTTPException(status_code=400, detail="Max collaborators must be between 5 and 10")

    db_collaboration = ResearchCollaboration(
        title=title,
        description=description,
        research_area=research_area,
        objectives=objectives,
        methodology=methodology,
        expected_outcomes=expected_outcomes,
        timeline=timeline,
        max_collaborators=max_collaborators,
        lead_researcher=current_user.id,
        budget=budget,
        requirements=requirements,
        deliverables=deliverables
    )

    db.add(db_collaboration)
    db.commit()
    db.refresh(db_collaboration)

    return {
        "message": "Research collaboration created successfully",
        "collaboration_id": db_collaboration.id
    }

@router.get("/")
async def get_research_collaborations(
    status: Optional[str] = None,
    research_area: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get research collaborations with optional filters"""

    query = db.query(ResearchCollaboration)

    # Apply filters
    if status:
        query = query.filter(ResearchCollaboration.status == status)

    if research_area:
        query = query.filter(ResearchCollaboration.research_area.ilike(f"%{research_area}%"))

    # Order by creation date (newest first)
    query = query.order_by(desc(ResearchCollaboration.created_at))

    # Paginate
    collaborations = query.offset(skip).limit(limit).all()

    return collaborations

@router.get("/{collaboration_id}")
async def get_research_collaboration(
    collaboration_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific research collaboration"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    return collaboration

@router.post("/{collaboration_id}/apply")
async def apply_for_collaboration(
    collaboration_id: str,
    application_letter: str,
    research_experience: str = "",
    relevant_skills: str = "",
    availability_hours: int = 10,
    proposed_contribution: str = "",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Apply for a research collaboration"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    if collaboration.status != "open":
        raise HTTPException(status_code=400, detail="Collaboration is not accepting applications")

    if collaboration.current_collaborators >= collaboration.max_collaborators:
        raise HTTPException(status_code=400, detail="Collaboration is full")

    # Check if user already applied
    existing_application = db.query(CollaborationApplication).filter(
        CollaborationApplication.collaboration_id == collaboration_id,
        CollaborationApplication.applicant_id == current_user.id
    ).first()

    if existing_application:
        raise HTTPException(status_code=400, detail="You have already applied for this collaboration")

    # Create application
    db_application = CollaborationApplication(
        collaboration_id=collaboration_id,
        applicant_id=current_user.id,
        application_letter=application_letter,
        research_experience=research_experience,
        relevant_skills=relevant_skills,
        availability_hours=availability_hours,
        proposed_contribution=proposed_contribution
    )

    db.add(db_application)
    db.commit()
    db.refresh(db_application)

    return {
        "message": "Application submitted successfully",
        "application_id": db_application.id
    }

@router.get("/{collaboration_id}/applications")
async def get_collaboration_applications(
    collaboration_id: str,
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get applications for a research collaboration (lead researcher only)"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    if collaboration.lead_researcher != current_user.id:
        raise HTTPException(status_code=403, detail="Only lead researcher can view applications")

    query = db.query(CollaborationApplication).filter(
        CollaborationApplication.collaboration_id == collaboration_id
    )

    if status:
        query = query.filter(CollaborationApplication.status == status)

    applications = query.order_by(desc(CollaborationApplication.created_at)).all()

    return applications

@router.put("/{collaboration_id}/applications/{application_id}/review")
async def review_application(
    collaboration_id: str,
    application_id: str,
    status: str,  # accepted, rejected, under_review
    review_notes: str = "",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Review a collaboration application"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    if collaboration.lead_researcher != current_user.id:
        raise HTTPException(status_code=403, detail="Only lead researcher can review applications")

    if status not in ["accepted", "rejected", "under_review"]:
        raise HTTPException(status_code=400, detail="Invalid status")

    application = db.query(CollaborationApplication).filter(
        CollaborationApplication.id == application_id,
        CollaborationApplication.collaboration_id == collaboration_id
    ).first()

    if not application:
        raise HTTPException(status_code=404, detail="Application not found")

    # Update application status
    application.status = status
    application.reviewed_by = current_user.id
    application.reviewed_at = func.now()
    application.review_notes = review_notes

    # If accepted, add as participant
    if status == "accepted":
        # Check if collaboration has space
        if collaboration.current_collaborators >= collaboration.max_collaborators:
            raise HTTPException(status_code=400, detail="Collaboration is full")

        # Add as participant
        participant = CollaborationParticipant(
            collaboration_id=collaboration_id,
            user_id=application.applicant_id,
            role="researcher"
        )

        db.add(participant)
        collaboration.current_collaborators += 1

    db.commit()

    return {
        "message": f"Application {status} successfully",
        "application_id": application_id
    }

@router.post("/{collaboration_id}/participants/{user_id}/add")
async def add_collaboration_participant(
    collaboration_id: str,
    user_id: str,
    role: str = "researcher",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add a participant to research collaboration (lead researcher only)"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    if collaboration.lead_researcher != current_user.id:
        raise HTTPException(status_code=403, detail="Only lead researcher can add participants")

    if collaboration.current_collaborators >= collaboration.max_collaborators:
        raise HTTPException(status_code=400, detail="Collaboration is full")

    # Check if user is already a participant
    existing_participant = db.query(CollaborationParticipant).filter(
        CollaborationParticipant.collaboration_id == collaboration_id,
        CollaborationParticipant.user_id == user_id
    ).first()

    if existing_participant:
        raise HTTPException(status_code=400, detail="User is already a participant")

    # Add participant
    participant = CollaborationParticipant(
        collaboration_id=collaboration_id,
        user_id=user_id,
        role=role
    )

    db.add(participant)
    collaboration.current_collaborators += 1

    db.commit()

    return {
        "message": "Participant added successfully",
        "participant_id": participant.id
    }

@router.get("/{collaboration_id}/participants")
async def get_collaboration_participants(
    collaboration_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get participants of a research collaboration"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    participants = db.query(CollaborationParticipant).filter(
        CollaborationParticipant.collaboration_id == collaboration_id
    ).all()

    return participants

@router.post("/{collaboration_id}/updates")
async def add_research_update(
    collaboration_id: str,
    title: str,
    content: str,
    update_type: str = "progress",  # progress, milestone, issue, solution
    is_public: bool = True,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add a research update"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    # Check if user is a participant or lead researcher
    is_participant = db.query(CollaborationParticipant).filter(
        CollaborationParticipant.collaboration_id == collaboration_id,
        CollaborationParticipant.user_id == current_user.id
    ).first()

    if not is_participant and collaboration.lead_researcher != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to add updates")

    if update_type not in ["progress", "milestone", "issue", "solution"]:
        raise HTTPException(status_code=400, detail="Invalid update type")

    update = ResearchUpdate(
        collaboration_id=collaboration_id,
        author_id=current_user.id,
        title=title,
        content=content,
        update_type=update_type,
        is_public=is_public
    )

    db.add(update)
    db.commit()
    db.refresh(update)

    return {
        "message": "Research update added successfully",
        "update_id": update.id
    }

@router.get("/{collaboration_id}/updates")
async def get_research_updates(
    collaboration_id: str,
    update_type: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get research updates for a collaboration"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    # Check if user is a participant or lead researcher
    is_participant = db.query(CollaborationParticipant).filter(
        CollaborationParticipant.collaboration_id == collaboration_id,
        CollaborationParticipant.user_id == current_user.id
    ).first()

    if not is_participant and collaboration.lead_researcher != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to view updates")

    query = db.query(ResearchUpdate).filter(
        ResearchUpdate.collaboration_id == collaboration_id
    )

    if update_type:
        query = query.filter(ResearchUpdate.update_type == update_type)

    # Order by creation date (newest first)
    updates = query.order_by(desc(ResearchUpdate.created_at)).offset(skip).limit(limit).all()

    return updates

@router.put("/{collaboration_id}/status")
async def update_collaboration_status(
    collaboration_id: str,
    status: str,  # open, in_progress, completed, cancelled
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update research collaboration status"""

    collaboration = db.query(ResearchCollaboration).filter(
        ResearchCollaboration.id == collaboration_id
    ).first()

    if not collaboration:
        raise HTTPException(status_code=404, detail="Research collaboration not found")

    if collaboration.lead_researcher != current_user.id:
        raise HTTPException(status_code=403, detail="Only lead researcher can update status")

    if status not in ["open", "in_progress", "completed", "cancelled"]:
        raise HTTPException(status_code=400, detail="Invalid status")

    collaboration.status = status

    db.commit()

    return {
        "message": f"Collaboration status updated to {status}",
        "collaboration_id": collaboration_id
    }

@router.get("/stats/summary")
async def get_collaborations_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get research collaborations statistics"""

    total_collaborations = db.query(func.count(ResearchCollaboration.id)).scalar()
    open_collaborations = db.query(func.count(ResearchCollaboration.id)).filter(
        ResearchCollaboration.status == "open"
    ).scalar()
    in_progress_collaborations = db.query(func.count(ResearchCollaboration.id)).filter(
        ResearchCollaboration.status == "in_progress"
    ).scalar()
    completed_collaborations = db.query(func.count(ResearchCollaboration.id)).filter(
        ResearchCollaboration.status == "completed"
    ).scalar()
    total_participants = db.query(func.count(CollaborationParticipant.id)).scalar() or 0

    return {
        "total_collaborations": total_collaborations,
        "open_collaborations": open_collaborations,
        "in_progress_collaborations": in_progress_collaborations,
        "completed_collaborations": completed_collaborations,
        "total_participants": total_participants
    }

@router.get("/areas/popular")
async def get_popular_research_areas(
    limit: int = 10,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get most popular research areas"""

    popular_areas = db.query(
        ResearchCollaboration.research_area,
        func.count(ResearchCollaboration.id).label('collaboration_count')
    ).group_by(
        ResearchCollaboration.research_area
    ).order_by(
        desc(func.count(ResearchCollaboration.id))
    ).limit(limit).all()

    return [
        {
            "research_area": research_area,
            "collaboration_count": collaboration_count
        }
        for research_area, collaboration_count in popular_areas
    ]
