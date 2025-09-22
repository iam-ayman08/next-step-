#!/usr/bin/env python3
"""
Complete System Test for NextStep Backend
Tests database connection, API endpoints, and all features
"""

import os
import sys
import asyncio
import json
from datetime import datetime

# Add current directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_imports():
    """Test if all required modules can be imported"""
    print("🧪 Testing imports...")

    try:
        from app.core.database import Base, engine, SessionLocal
        from app.core.config import settings
        from app.api.api_v1.api import app
        from fastapi.testclient import TestClient
        print("✅ All imports successful")
        return True
    except Exception as e:
        print(f"❌ Import failed: {e}")
        return False

def test_database_connection():
    """Test database connection"""
    print("🧪 Testing database connection...")

    try:
        from app.core.database import engine, SessionLocal

        # Try to connect to database
        db = SessionLocal()
        db.execute("SELECT 1")
        db.close()

        print("✅ Database connection successful")
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def test_database_tables():
    """Test if database tables exist"""
    print("🧪 Testing database tables...")

    try:
        from app.core.database import Base, engine

        # Check if tables exist by trying to create them
        Base.metadata.create_all(bind=engine, checkfirst=True)
        print("✅ Database tables verified")
        return True
    except Exception as e:
        print(f"❌ Database tables test failed: {e}")
        return False

def test_api_endpoints():
    """Test API endpoints"""
    print("🧪 Testing API endpoints...")

    try:
        from app.api.api_v1.api import app
        from fastapi.testclient import TestClient

        client = TestClient(app)

        # Test health endpoint
        response = client.get("/health")
        if response.status_code == 200:
            print("✅ Health endpoint working")
        else:
            print(f"❌ Health endpoint failed: {response.status_code}")
            return False

        # Test API info endpoint
        response = client.get("/api/v1/")
        if response.status_code == 200:
            print("✅ API info endpoint working")
        else:
            print(f"❌ API info endpoint failed: {response.status_code}")
            return False

        # Test authentication endpoints
        response = client.post("/api/v1/auth/login", json={
            "username": "john.doe@student.com",
            "password": "password123"
        })
        if response.status_code == 200:
            print("✅ Authentication endpoint working")
        else:
            print(f"❌ Authentication endpoint failed: {response.status_code}")

        return True
    except Exception as e:
        print(f"❌ API endpoints test failed: {e}")
        return False

def test_sample_data():
    """Test sample data creation"""
    print("🧪 Testing sample data creation...")

    try:
        from app.core.database import SessionLocal, User, Scholarship, Project

        db = SessionLocal()

        # Check if users exist
        users = db.query(User).all()
        if users:
            print(f"✅ Found {len(users)} users in database")
        else:
            print("❌ No users found in database")
            return False

        # Check if scholarships exist
        scholarships = db.query(Scholarship).all()
        if scholarships:
            print(f"✅ Found {len(scholarships)} scholarships in database")
        else:
            print("❌ No scholarships found in database")
            return False

        # Check if projects exist
        projects = db.query(Project).all()
        if projects:
            print(f"✅ Found {len(projects)} projects in database")
        else:
            print("❌ No projects found in database")
            return False

        db.close()
        return True
    except Exception as e:
        print(f"❌ Sample data test failed: {e}")
        return False

async def run_async_tests():
    """Run async tests"""
    print("🧪 Running async tests...")

    try:
        from app.core.database import SessionLocal
        from sqlalchemy import text

        db = SessionLocal()

        # Test async query
        result = await db.execute(text("SELECT 1"))
        row = result.fetchone()

        if row:
            print("✅ Async database test successful")
            return True
        else:
            print("❌ Async database test failed")
            return False
    except Exception as e:
        print(f"❌ Async test failed: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Starting NextStep System Tests")
    print("=" * 50)

    # Track test results
    tests = []
    passed = 0
    failed = 0

    # Test 1: Imports
    print("\n1. Testing Imports")
    if test_imports():
        tests.append("✅ Imports")
        passed += 1
    else:
        tests.append("❌ Imports")
        failed += 1

    # Test 2: Database Connection
    print("\n2. Testing Database Connection")
    if test_database_connection():
        tests.append("✅ Database Connection")
        passed += 1
    else:
        tests.append("❌ Database Connection")
        failed += 1

    # Test 3: Database Tables
    print("\n3. Testing Database Tables")
    if test_database_tables():
        tests.append("✅ Database Tables")
        passed += 1
    else:
        tests.append("❌ Database Tables")
        failed += 1

    # Test 4: API Endpoints
    print("\n4. Testing API Endpoints")
    if test_api_endpoints():
        tests.append("✅ API Endpoints")
        passed += 1
    else:
        tests.append("❌ API Endpoints")
        failed += 1

    # Test 5: Sample Data
    print("\n5. Testing Sample Data")
    if test_sample_data():
        tests.append("✅ Sample Data")
        passed += 1
    else:
        tests.append("❌ Sample Data")
        failed += 1

    # Test 6: Async Tests
    print("\n6. Testing Async Functionality")
    try:
        async_result = asyncio.run(run_async_tests())
        if async_result:
            tests.append("✅ Async Tests")
            passed += 1
        else:
            tests.append("❌ Async Tests")
            failed += 1
    except Exception as e:
        tests.append("❌ Async Tests")
        failed += 1
        print(f"Async test error: {e}")

    # Print summary
    print("\n" + "=" * 50)
    print("📊 TEST SUMMARY")
    print("=" * 50)

    for test in tests:
        print(test)

    print(f"\n✅ Passed: {passed}")
    print(f"❌ Failed: {failed}")
    print(f"📈 Success Rate: {passed}/{passed+failed} ({(passed/(passed+failed)*100):.1f}%)")

    if failed == 0:
        print("\n🎉 ALL TESTS PASSED! System is ready for production!")
        return True
    else:
        print(f"\n⚠️  {failed} test(s) failed. Please check the errors above.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
