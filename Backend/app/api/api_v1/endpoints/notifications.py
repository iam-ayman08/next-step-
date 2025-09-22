"""
Notifications API endpoints for real-time notifications
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import json

from app.core.database import get_db, User, Notification
from app.core.security import get_current_user
from pydantic import BaseModel

router = APIRouter()

# Pydantic models
class NotificationCreate(BaseModel):
    title: str
    message: str
    type: str  # scholarship, project, mentorship, system
    priority: str = "normal"  # low, normal, high, urgent
    data: Optional[dict] = None

class NotificationResponse(BaseModel):
    id: str
    user_id: str
    title: str
    message: str
    type: str
    priority: str
    is_read: bool
    data: Optional[dict]
    created_at: datetime

    class Config:
        from_attributes = True

class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None

# Notification endpoints
@router.post("/", response_model=NotificationResponse)
async def create_notification(
    notification: NotificationCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a notification for a user"""
    try:
        db_notification = Notification(
            user_id=current_user.id,
            title=notification.title,
            message=notification.message,
            type=notification.type,
            priority=notification.priority,
            data=json.dumps(notification.data) if notification.data else None,
            is_read=False,
            created_at=datetime.utcnow()
        )

        db.add(db_notification)
        db.commit()
        db.refresh(db_notification)

        # Send real-time notification (background task)
        background_tasks.add_task(send_push_notification, db_notification)

        return db_notification

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create notification: {str(e)}")

@router.get("/", response_model=List[NotificationResponse])
async def get_notifications(
    skip: int = 0,
    limit: int = 50,
    unread_only: bool = False,
    type_filter: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get notifications for current user"""
    query = db.query(Notification).filter(Notification.user_id == current_user.id)

    if unread_only:
        query = query.filter(Notification.is_read == False)

    if type_filter:
        query = query.filter(Notification.type == type_filter)

    notifications = query.order_by(Notification.created_at.desc()).offset(skip).limit(limit).all()
    return notifications

@router.get("/{notification_id}", response_model=NotificationResponse)
async def get_notification(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific notification"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    return notification

@router.put("/{notification_id}", response_model=NotificationResponse)
async def update_notification(
    notification_id: str,
    update: NotificationUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update notification (mark as read/unread)"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    if update.is_read is not None:
        notification.is_read = update.is_read

    db.commit()
    db.refresh(notification)
    return notification

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a notification"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    db.delete(notification)
    db.commit()
    return {"message": "Notification deleted successfully"}

@router.post("/mark-all-read")
async def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark all notifications as read"""
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})

    db.commit()
    return {"message": "All notifications marked as read"}

@router.get("/stats/summary")
async def get_notification_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get notification statistics"""
    total_count = db.query(Notification).filter(Notification.user_id == current_user.id).count()
    unread_count = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).count()

    # Count by type
    type_counts = {}
    for notification_type in ['scholarship', 'project', 'mentorship', 'system']:
        count = db.query(Notification).filter(
            Notification.user_id == current_user.id,
            Notification.type == notification_type
        ).count()
        type_counts[notification_type] = count

    return {
        "total": total_count,
        "unread": unread_count,
        "by_type": type_counts
    }

# Background task for sending push notifications
async def send_push_notification(notification: Notification):
    """Send push notification to user device"""
    try:
        # Here you would integrate with Firebase Cloud Messaging (FCM)
        # or another push notification service

        print(f"Sending push notification to user {notification.user_id}:")
        print(f"Title: {notification.title}")
        print(f"Message: {notification.message}")
        print(f"Type: {notification.type}")
        print(f"Priority: {notification.priority}")

        # TODO: Implement actual FCM integration
        # For now, just log the notification

    except Exception as e:
        print(f"Failed to send push notification: {e}")

# Notification helper functions
def create_scholarship_notification(user_id: str, scholarship_title: str, action: str = "created"):
    """Helper to create scholarship-related notifications"""
    messages = {
        "created": f"New scholarship opportunity: {scholarship_title}",
        "applied": f"Your application for {scholarship_title} has been submitted",
        "approved": f"Congratulations! Your application for {scholarship_title} has been approved",
        "rejected": f"Your application for {scholarship_title} has been rejected",
        "deadline": f"Reminder: {scholarship_title} application deadline is approaching"
    }

    return NotificationCreate(
        title="Scholarship Update",
        message=messages.get(action, f"Scholarship update: {scholarship_title}"),
        type="scholarship",
        priority="normal" if action != "deadline" else "high",
        data={"scholarship_title": scholarship_title, "action": action}
    )

def create_project_notification(user_id: str, project_title: str, action: str = "created"):
    """Helper to create project-related notifications"""
    messages = {
        "created": f"New project opportunity: {project_title}",
        "supported": f"Your project {project_title} has received support",
        "funded": f"Congratulations! Your project {project_title} has been fully funded",
        "mentored": f"You have been assigned a mentor for {project_title}",
        "completed": f"Your project {project_title} has been completed"
    }

    return NotificationCreate(
        title="Project Update",
        message=messages.get(action, f"Project update: {project_title}"),
        type="project",
        priority="normal",
        data={"project_title": project_title, "action": action}
    )

def create_mentorship_notification(user_id: str, mentor_name: str, action: str = "requested"):
    """Helper to create mentorship-related notifications"""
    messages = {
        "requested": f"{mentor_name} has requested mentorship",
        "accepted": f"{mentor_name} has accepted your mentorship request",
        "declined": f"{mentor_name} has declined your mentorship request",
        "scheduled": f"Mentorship session with {mentor_name} has been scheduled",
        "reminder": f"Reminder: Mentorship session with {mentor_name} in 1 hour"
    }

    return NotificationCreate(
        title="Mentorship Update",
        message=messages.get(action, f"Mentorship update with {mentor_name}"),
        type="mentorship",
        priority="normal" if action != "reminder" else "high",
        data={"mentor_name": mentor_name, "action": action}
    )
