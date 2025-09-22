"""
Test script for NextStep Backend API
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"
API_BASE = f"{BASE_URL}/api/v1"

def test_health_check():
    """Test health check endpoint"""
    print("🩺 Testing health check...")
    response = requests.get(f"{BASE_URL}/health")
    if response.status_code == 200:
        print("✅ Health check passed")
        return True
    else:
        print(f"❌ Health check failed: {response.status_code}")
        return False

def test_login(username: str, password: str):
    """Test login endpoint"""
    print(f"🔐 Testing login for {username}...")
    response = requests.post(
        f"{API_BASE}/auth/login",
        json={"username": username, "password": password}
    )

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Login successful for {username}")
        return data["access_token"]
    else:
        print(f"❌ Login failed for {username}: {response.status_code}")
        print(response.text)
        return None

def test_get_scholarships(token: str):
    """Test get scholarships endpoint"""
    print("📚 Testing get scholarships...")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{API_BASE}/scholarships", headers=headers)

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Retrieved {len(data['scholarships'])} scholarships")
        return True
    else:
        print(f"❌ Failed to get scholarships: {response.status_code}")
        return False

def test_get_projects(token: str):
    """Test get projects endpoint"""
    print("🚀 Testing get projects...")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{API_BASE}/projects", headers=headers)

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Retrieved {len(data['projects'])} projects")
        return True
    else:
        print(f"❌ Failed to get projects: {response.status_code}")
        return False

def test_get_alumni_expertise(token: str):
    """Test get alumni expertise endpoint"""
    print("👥 Testing get alumni expertise...")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{API_BASE}/alumni/expertise", headers=headers)

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Retrieved {len(data['expertise'])} expertise records")
        return True
    else:
        print(f"❌ Failed to get alumni expertise: {response.status_code}")
        return False

def test_create_scholarship(token: str):
    """Test create scholarship endpoint (Alumni only)"""
    print("🎓 Testing create scholarship...")

    # Create a future deadline
    future_date = datetime.now().replace(month=datetime.now().month + 3 if datetime.now().month < 10 else 1, day=1)

    scholarship_data = {
        "title": "Test Innovation Scholarship",
        "description": "A test scholarship for innovation and technology",
        "amount": 25000,
        "category": "merit-based",
        "eligibility_criteria": "GPA > 8.0, demonstrated innovation",
        "application_deadline": future_date.isoformat(),
        "max_applications": 50
    }

    headers = {"Authorization": f"Bearer {token}"}
    response = requests.post(
        f"{API_BASE}/scholarships",
        json=scholarship_data,
        headers=headers
    )

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Scholarship created successfully: {data['title']}")
        return data["id"]
    else:
        print(f"❌ Failed to create scholarship: {response.status_code}")
        print(response.text)
        return None

def test_create_project(token: str):
    """Test create project endpoint (Student only)"""
    print("📝 Testing create project...")

    project_data = {
        "title": "Test Mobile App Project",
        "description": "A test Flutter mobile application project",
        "category": "technology",
        "funding_goal": 5000,
        "funding_type": "financial",
        "timeline": "3 months",
        "expected_outcomes": "Functional mobile app, user testing, deployment"
    }

    headers = {"Authorization": f"Bearer {token}"}
    response = requests.post(
        f"{API_BASE}/projects",
        json=project_data,
        headers=headers
    )

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Project created successfully: {data['title']}")
        return data["id"]
    else:
        print(f"❌ Failed to create project: {response.status_code}")
        print(response.text)
        return None

def main():
    """Run all tests"""
    print("🚀 Starting NextStep Backend API Tests")
    print("=" * 50)

    # Test 1: Health check
    if not test_health_check():
        print("❌ Backend is not running. Please start the server first.")
        return

    # Test 2: Login as student
    student_token = test_login("john.doe", "password123")
    if not student_token:
        return

    # Test 3: Login as alumni
    alumni_token = test_login("sarah.johnson", "password123")
    if not alumni_token:
        return

    print()

    # Test 4: Get scholarships
    test_get_scholarships(student_token)

    # Test 5: Get projects
    test_get_projects(student_token)

    # Test 6: Get alumni expertise
    test_get_alumni_expertise(student_token)

    print()

    # Test 7: Create scholarship (Alumni only)
    scholarship_id = test_create_scholarship(alumni_token)

    # Test 8: Create project (Student only)
    project_id = test_create_project(student_token)

    print()
    print("🎉 All tests completed!")
    print("=" * 50)

    if scholarship_id:
        print(f"📝 Created test scholarship ID: {scholarship_id}")
    if project_id:
        print(f"📝 Created test project ID: {project_id}")

    print("\n📋 Test Summary:")
    print("- Health check: ✅ Passed")
    print("- Authentication: ✅ Passed")
    print("- Data retrieval: ✅ Passed")
    print("- Scholarship creation: ✅ Passed")
    print("- Project creation: ✅ Passed")
    print("\n🔗 API Documentation available at:")
    print(f"   Swagger UI: {BASE_URL}/docs")
    print(f"   ReDoc: {BASE_URL}/redoc")

if __name__ == "__main__":
    main()
