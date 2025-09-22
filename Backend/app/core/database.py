"""
Database configuration and initialization using PostgreSQL
"""

import os
from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, Boolean, ForeignKey, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from app.core.config import settings
from typing import Generator
import uuid

# Database setup - SQLite for development, PostgreSQL for production
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./Database/app.db"  # Default to SQLite for development
)

# Override with PostgreSQL if explicitly set
if os.getenv("DATABASE_URL") and "postgresql" in os.getenv("DATABASE_URL"):
    DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(
    DATABASE_URL,
    connect_args={
        "check_same_thread": False
    } if "sqlite" in DATABASE_URL else {}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database Models
class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    username = Column(String(255), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    role = Column(String(50), default="student")  # student or alumni
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class Profile(Base):
    __tablename__ = "profiles"

    id = Column(String, ForeignKey("users.id"), primary_key=True)
    bio = Column(Text)
    skills = Column(Text)  # JSON string
    interests = Column(Text)  # JSON string
    location = Column(String(255))
    phone = Column(String(50))
    linkedin_url = Column(Text)
    github_url = Column(Text)
    portfolio_url = Column(Text)
    graduation_year = Column(String(10))
    company = Column(String(255))
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class Application(Base):
    __tablename__ = "applications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    company = Column(String(255), nullable=False)
    position = Column(String(255), nullable=False)
    status = Column(String(50), default="applied")
    job_description = Column(Text)
    application_date = Column(DateTime, default=func.now())
    notes = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class Mentorship(Base):
    __tablename__ = "mentorships"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    mentor_id = Column(String, ForeignKey("users.id"), nullable=False)
    mentee_id = Column(String, ForeignKey("users.id"), nullable=False)
    status = Column(String(50), default="pending")
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class Scholarship(Base):
    __tablename__ = "scholarships"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    amount = Column(Integer, nullable=False)  # Amount in rupees
    category = Column(String(100), nullable=False)  # merit-based, need-based, research, achievement
    eligibility_criteria = Column(Text)
    application_deadline = Column(DateTime, nullable=False)
    max_applications = Column(Integer, default=100)
    current_applications = Column(Integer, default=0)
    status = Column(String(50), default="active")  # active, closed, draft
    created_by = Column(String, ForeignKey("users.id"), nullable=False)  # Alumni who created it
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class ScholarshipApplication(Base):
    __tablename__ = "scholarship_applications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    scholarship_id = Column(String, ForeignKey("scholarships.id"), nullable=False)
    applicant_id = Column(String, ForeignKey("users.id"), nullable=False)
    personal_statement = Column(Text, nullable=False)
    academic_achievements = Column(Text)
    financial_need_statement = Column(Text)
    status = Column(String(50), default="pending")  # pending, approved, rejected, under_review
    reviewed_by = Column(String, ForeignKey("users.id"))  # Alumni who reviewed
    reviewed_at = Column(DateTime)
    review_notes = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class Project(Base):
    __tablename__ = "projects"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(100), nullable=False)  # technology, research, social-impact, healthcare, etc.
    funding_goal = Column(Integer, nullable=False)  # Amount needed in rupees
    current_funding = Column(Integer, default=0)
    funding_type = Column(String(100), nullable=False)  # financial, mentorship, technical, resources, networking
    timeline = Column(String(255), nullable=False)  # Project duration
    expected_outcomes = Column(Text, nullable=False)
    team_members = Column(Text)  # JSON string of team member details
    status = Column(String(50), default="pending")  # pending, funded, in_progress, completed, rejected
    created_by = Column(String, ForeignKey("users.id"), nullable=False)  # Student who created it
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class ProjectSupport(Base):
    __tablename__ = "project_supports"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    project_id = Column(String, ForeignKey("projects.id"), nullable=False)
    supporter_id = Column(String, ForeignKey("users.id"), nullable=False)  # Alumni providing support
    support_type = Column(String(100), nullable=False)  # financial, mentorship, technical, resources, networking
    support_amount = Column(Integer, default=0)  # Amount if financial support
    support_description = Column(Text)  # Description of support provided
    status = Column(String(50), default="active")  # active, completed, cancelled
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class AlumniExpertise(Base):
    __tablename__ = "alumni_expertise"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    expertise_area = Column(String(255), nullable=False)
    years_experience = Column(Integer, default=0)
    current_position = Column(String(255))
    company = Column(String(255))
    skills = Column(Text)  # JSON string of skills
    availability_status = Column(String(50), default="available")  # available, busy, unavailable
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(100), nullable=False)  # scholarship, project, mentorship, system
    priority = Column(String(50), default="normal")  # low, normal, high, urgent
    is_read = Column(Boolean, default=False)
    data = Column(Text)  # JSON string for additional data
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

# New Models for Study Materials and Research Collaboration

class StudyMaterial(Base):
    __tablename__ = "study_materials"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    description = Column(Text)
    subject_code = Column(String(50), nullable=False)
    subject_name = Column(String(255), nullable=False)
    file_path = Column(Text, nullable=False)  # Path to uploaded file
    file_type = Column(String(50), nullable=False)  # pdf, doc, ppt, etc.
    file_size = Column(Integer)  # File size in bytes
    uploaded_by = Column(String, ForeignKey("users.id"), nullable=False)
    is_approved = Column(Boolean, default=False)
    approved_by = Column(String, ForeignKey("users.id"))  # Alumni who approved
    approved_at = Column(DateTime)
    download_count = Column(Integer, default=0)
    rating = Column(Integer, default=0)  # Average rating 1-5
    rating_count = Column(Integer, default=0)
    tags = Column(Text)  # JSON string of tags
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class StudyMaterialDownload(Base):
    __tablename__ = "study_material_downloads"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    material_id = Column(String, ForeignKey("study_materials.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    downloaded_at = Column(DateTime, default=func.now())

class StudyMaterialRating(Base):
    __tablename__ = "study_material_ratings"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    material_id = Column(String, ForeignKey("study_materials.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    rating = Column(Integer, nullable=False)  # 1-5 stars
    review = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class ResearchCollaboration(Base):
    __tablename__ = "research_collaborations"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    research_area = Column(String(255), nullable=False)
    objectives = Column(Text, nullable=False)
    methodology = Column(Text)
    expected_outcomes = Column(Text)
    timeline = Column(String(255), nullable=False)  # Duration of project
    max_collaborators = Column(Integer, default=10)  # Max 5-10 alumni
    current_collaborators = Column(Integer, default=0)
    status = Column(String(50), default="open")  # open, in_progress, completed, cancelled
    lead_researcher = Column(String, ForeignKey("users.id"), nullable=False)  # Alumni leading
    budget = Column(Integer, default=0)  # Research budget if any
    requirements = Column(Text)  # Skills/experience required
    deliverables = Column(Text)  # Expected deliverables
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class CollaborationApplication(Base):
    __tablename__ = "collaboration_applications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    collaboration_id = Column(String, ForeignKey("research_collaborations.id"), nullable=False)
    applicant_id = Column(String, ForeignKey("users.id"), nullable=False)
    application_letter = Column(Text, nullable=False)
    research_experience = Column(Text)
    relevant_skills = Column(Text)  # JSON string of skills
    availability_hours = Column(Integer, default=10)  # Hours per week available
    proposed_contribution = Column(Text)
    status = Column(String(50), default="pending")  # pending, accepted, rejected, under_review
    reviewed_by = Column(String, ForeignKey("users.id"))  # Lead researcher who reviewed
    reviewed_at = Column(DateTime)
    review_notes = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class CollaborationParticipant(Base):
    __tablename__ = "collaboration_participants"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    collaboration_id = Column(String, ForeignKey("research_collaborations.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    role = Column(String(100), nullable=False)  # researcher, assistant, contributor, etc.
    joined_at = Column(DateTime, default=func.now())
    contribution_hours = Column(Integer, default=0)
    status = Column(String(50), default="active")  # active, inactive, completed
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

class ResearchUpdate(Base):
    __tablename__ = "research_updates"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    collaboration_id = Column(String, ForeignKey("research_collaborations.id"), nullable=False)
    author_id = Column(String, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=False)
    update_type = Column(String(50), default="progress")  # progress, milestone, issue, solution
    is_public = Column(Boolean, default=True)  # Whether visible to all participants
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

def get_db() -> Generator[Session, None, None]:
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_db_and_tables():
    """Initialize database and create tables if needed"""
    try:
        # Create tables
        Base.metadata.create_all(bind=engine)
        print("Database and tables created successfully")
    except Exception as e:
        print(f"Database initialization failed: {e}")

def get_database_session() -> Session:
    """Get database session instance"""
    return SessionLocal()
