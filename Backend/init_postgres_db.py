"""
PostgreSQL database initialization script with sample data
"""

import os
import sys
from datetime import datetime, timedelta
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.core.database import Base, User, Profile, Scholarship, Project, AlumniExpertise, Notification, Application, Mentorship
import json

def init_postgresql_database():
    """Initialize PostgreSQL database with sample data"""

    # Get database URL from environment
    database_url = os.getenv(
        "DATABASE_URL",
        "postgresql://nextstep_user:nextstep_password@localhost:5432/nextstep_db"
    )

    try:
        # Create engine
        engine = create_engine(database_url)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

        # Create all tables
        Base.metadata.create_all(bind=engine)
        print("✅ PostgreSQL tables created successfully!")

        # Create session
        db = SessionLocal()

        try:
            # Create sample alumni users
            alumni_users = [
                User(
                    username="sarah.johnson",
                    email="sarah.johnson@alumni.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="Sarah Johnson",
                    role="alumni"
                ),
                User(
                    username="michael.chen",
                    email="michael.chen@alumni.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="Michael Chen",
                    role="alumni"
                ),
                User(
                    username="emily.rodriguez",
                    email="emily.rodriguez@alumni.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="Emily Rodriguez",
                    role="alumni"
                ),
                User(
                    username="david.kim",
                    email="david.kim@alumni.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="David Kim",
                    role="alumni"
                ),
                User(
                    username="lisa.thompson",
                    email="lisa.thompson@alumni.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="Lisa Thompson",
                    role="alumni"
                ),
            ]

            # Create sample student users
            student_users = [
                User(
                    username="john.doe",
                    email="john.doe@student.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="John Doe",
                    role="student"
                ),
                User(
                    username="jane.smith",
                    email="jane.smith@student.com",
                    password_hash="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Ldwt8XwO4W1vUoL7i",  # password123
                    name="Jane Smith",
                    role="student"
                ),
            ]

            # Add all users
            for user in alumni_users + student_users:
                db.add(user)

            db.commit()

            # Refresh to get IDs
            for user in alumni_users + student_users:
                db.refresh(user)

            # Create sample scholarships
            scholarships = [
                Scholarship(
                    title="Tech Excellence Scholarship",
                    description="For Computer Science students with GPA > 8.5 who demonstrate exceptional programming skills and innovation.",
                    amount=50000,
                    category="merit-based",
                    eligibility_criteria="GPA > 8.5, Computer Science major, demonstrated programming projects",
                    application_deadline=datetime.now() + timedelta(days=90),
                    max_applications=100,
                    created_by=alumni_users[0].id  # Sarah Johnson
                ),
                Scholarship(
                    title="Innovation Grant",
                    description="For students working on innovative projects that solve real-world problems using technology.",
                    amount=25000,
                    category="research",
                    eligibility_criteria="Active project work, innovation focus, technology-based solutions",
                    application_deadline=datetime.now() + timedelta(days=60),
                    max_applications=50,
                    created_by=alumni_users[1].id  # Michael Chen
                ),
                Scholarship(
                    title="Women in Tech Scholarship",
                    description="Supporting female students in STEM fields to pursue careers in technology.",
                    amount=30000,
                    category="achievement",
                    eligibility_criteria="Female students in STEM, demonstrated leadership, GPA > 8.0",
                    application_deadline=datetime.now() + timedelta(days=120),
                    max_applications=75,
                    created_by=alumni_users[2].id  # Emily Rodriguez
                ),
                Scholarship(
                    title="Financial Aid Grant",
                    description="For students with demonstrated financial need pursuing higher education.",
                    amount=15000,
                    category="need-based",
                    eligibility_criteria="Demonstrated financial need, good academic standing",
                    application_deadline=datetime.now() + timedelta(days=30),
                    max_applications=200,
                    created_by=alumni_users[3].id  # David Kim
                ),
            ]

            for scholarship in scholarships:
                db.add(scholarship)

            db.commit()

            # Create sample projects
            projects = [
                Project(
                    title="Mobile App Development",
                    description="Developing a Flutter-based mobile application for local artisans to showcase and sell their products online.",
                    category="technology",
                    funding_goal=5000,
                    funding_type="financial",
                    timeline="3 months",
                    expected_outcomes="Functional mobile app, increased sales for artisans, digital marketplace",
                    team_members=json.dumps([
                        {"name": "John Doe", "role": "Lead Developer"},
                        {"name": "Jane Smith", "role": "UI/UX Designer"}
                    ]),
                    created_by=student_users[0].id  # John Doe
                ),
                Project(
                    title="AI Research Project",
                    description="Machine learning model for healthcare diagnosis using patient data and medical imaging.",
                    category="research",
                    funding_goal=10000,
                    funding_type="financial",
                    timeline="6 months",
                    expected_outcomes="Working ML model, research paper, healthcare impact assessment",
                    team_members=json.dumps([
                        {"name": "Jane Smith", "role": "Data Scientist"},
                        {"name": "John Doe", "role": "Research Assistant"}
                    ]),
                    created_by=student_users[1].id  # Jane Smith
                ),
                Project(
                    title="Startup Business Plan",
                    description="E-commerce platform for local artisans to sell handmade products with integrated payment and shipping.",
                    category="business",
                    funding_goal=8000,
                    funding_type="mentorship",
                    timeline="4 months",
                    expected_outcomes="Business plan, prototype platform, market analysis",
                    created_by=student_users[0].id  # John Doe
                ),
            ]

            for project in projects:
                db.add(project)

            db.commit()

            # Create sample alumni expertise
            expertise_list = [
                AlumniExpertise(
                    user_id=alumni_users[0].id,  # Sarah Johnson
                    expertise_area="Software Engineering",
                    years_experience=8,
                    current_position="Senior Software Engineer",
                    company="Google",
                    skills=json.dumps(["Python", "Java", "System Design", "Machine Learning"]),
                    availability_status="available"
                ),
                AlumniExpertise(
                    user_id=alumni_users[1].id,  # Michael Chen
                    expertise_area="Product Management",
                    years_experience=6,
                    current_position="Product Manager",
                    company="Microsoft",
                    skills=json.dumps(["Product Strategy", "Agile", "Data Analysis", "User Research"]),
                    availability_status="available"
                ),
                AlumniExpertise(
                    user_id=alumni_users[2].id,  # Emily Rodriguez
                    expertise_area="Data Science",
                    years_experience=7,
                    current_position="Senior Data Scientist",
                    company="Amazon",
                    skills=json.dumps(["Python", "R", "SQL", "TensorFlow", "Statistics"]),
                    availability_status="busy"
                ),
                AlumniExpertise(
                    user_id=alumni_users[3].id,  # David Kim
                    expertise_area="Marketing",
                    years_experience=5,
                    current_position="Marketing Director",
                    company="Nike",
                    skills=json.dumps(["Digital Marketing", "Brand Strategy", "Analytics", "Social Media"]),
                    availability_status="available"
                ),
                AlumniExpertise(
                    user_id=alumni_users[4].id,  # Lisa Thompson
                    expertise_area="Healthcare Administration",
                    years_experience=10,
                    current_position="Healthcare Administrator",
                    company="Mayo Clinic",
                    skills=json.dumps(["Healthcare Management", "Policy", "Operations", "Quality Improvement"]),
                    availability_status="available"
                ),
            ]

            for expertise in expertise_list:
                db.add(expertise)

            db.commit()

            # Create sample notifications
            notifications = [
                Notification(
                    user_id=student_users[0].id,
                    title="New Scholarship Available",
                    message="Tech Excellence Scholarship is now open for applications",
                    type="scholarship",
                    priority="high",
                    is_read=False,
                    data=json.dumps({"scholarship_id": scholarships[0].id})
                ),
                Notification(
                    user_id=student_users[1].id,
                    title="Project Funding Opportunity",
                    message="Innovation Grant applications are closing soon",
                    type="project",
                    priority="normal",
                    is_read=False,
                    data=json.dumps({"project_id": projects[1].id})
                ),
                Notification(
                    user_id=alumni_users[0].id,
                    title="New Mentorship Request",
                    message="John Doe has requested mentorship for mobile app development",
                    type="mentorship",
                    priority="normal",
                    is_read=False,
                    data=json.dumps({"mentorship_request": True})
                ),
            ]

            for notification in notifications:
                db.add(notification)

            db.commit()

            print("✅ PostgreSQL database initialized successfully!")
            print(f"📊 Created {len(alumni_users)} alumni users")
            print(f"📊 Created {len(student_users)} student users")
            print(f"📊 Created {len(scholarships)} scholarships")
            print(f"📊 Created {len(projects)} projects")
            print(f"📊 Created {len(expertise_list)} alumni expertise records")
            print(f"📊 Created {len(notifications)} notifications")

            return True

        except Exception as e:
            db.rollback()
            print(f"❌ Error initializing PostgreSQL database: {e}")
            return False
        finally:
            db.close()

    except Exception as e:
        print(f"❌ PostgreSQL connection failed: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Initializing NextStep PostgreSQL database with sample data...")
    success = init_postgresql_database()
    if success:
        print("✅ PostgreSQL database setup completed successfully!")
    else:
        print("❌ PostgreSQL database setup failed!")
        sys.exit(1)
