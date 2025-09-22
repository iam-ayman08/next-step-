# 🧪 NextStep Testing Guide

## Overview

This guide provides comprehensive testing instructions for the NextStep application, including backend API testing, database testing, and frontend integration testing.

## 🚀 Quick Start Testing

### 1. Prerequisites Check

**Python Environment:**
```bash
python --version
pip --version
```

**Required Packages:**
```bash
pip install -r requirements.txt
```

### 2. Database Setup & Testing

**Option A: SQLite (Development)**
```bash
# Database will be created automatically
python -c "from app.core.database import create_db_and_tables; create_db_and_tables()"
```

**Option B: PostgreSQL (Production)**
```bash
# Start PostgreSQL
docker run --name nextstep-postgres -e POSTGRES_DB=nextstep_db -e POSTGRES_USER=nextstep_user -e POSTGRES_PASSWORD=nextstep_password -p 5432:5432 -d postgres:15

# Initialize database
python init_postgres_db.py
```

### 3. Backend Testing

**Run System Tests:**
```bash
python test_system.py
```

**Start Backend Server:**
```bash
python main.py
```

**Test API Endpoints:**
```bash
# Health check
curl http://localhost:8000/health

# API info
curl http://localhost:8000/api/v1/

# Login test
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "john.doe@student.com", "password": "password123"}'
```

### 4. Frontend Testing

**Install Flutter Dependencies:**
```bash
flutter pub get
```

**Run Flutter Tests:**
```bash
flutter test
```

**Start Flutter App:**
```bash
flutter run
```

## 📊 Comprehensive Testing Checklist

### ✅ Backend Testing

#### 1. Database Tests
- [ ] Database connection established
- [ ] All tables created successfully
- [ ] Sample data inserted correctly
- [ ] Foreign key relationships working
- [ ] Data integrity maintained

#### 2. API Endpoint Tests
- [ ] Health endpoint (`/health`) responds 200
- [ ] API info endpoint (`/api/v1/`) responds 200
- [ ] Authentication endpoints working
- [ ] User management endpoints working
- [ ] Scholarship endpoints working
- [ ] Project endpoints working
- [ ] Notification endpoints working

#### 3. Authentication Tests
- [ ] Login with valid credentials works
- [ ] Login with invalid credentials fails
- [ ] Registration creates new user
- [ ] JWT tokens generated correctly
- [ ] Token validation working
- [ ] Password hashing working

#### 4. Data Model Tests
- [ ] User model CRUD operations
- [ ] Scholarship model operations
- [ ] Project model operations
- [ ] Notification model operations
- [ ] Profile model operations

### ✅ Frontend Testing

#### 1. Flutter App Tests
- [ ] App starts without errors
- [ ] All pages load correctly
- [ ] Navigation working properly
- [ ] Theme switching working
- [ ] Form validation working

#### 2. API Integration Tests
- [ ] Login API integration working
- [ ] Registration API integration working
- [ ] Data fetching from APIs working
- [ ] Error handling for API failures
- [ ] Loading states displayed correctly

#### 3. UI/UX Tests
- [ ] Dark mode implementation working
- [ ] Push notifications setup working
- [ ] Loading animations working
- [ ] Error messages displayed correctly
- [ ] Responsive design working

### ✅ Integration Testing

#### 1. End-to-End Tests
- [ ] Complete user registration flow
- [ ] Complete login flow
- [ ] Data synchronization between frontend and backend
- [ ] File upload functionality
- [ ] Notification system working

#### 2. Performance Tests
- [ ] API response times acceptable
- [ ] Database queries optimized
- [ ] App startup time reasonable
- [ ] Memory usage within limits

## 🛠️ Manual Testing Steps

### Step 1: Backend Setup
1. **Navigate to Backend directory**
   ```bash
   cd Backend
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables**
   ```bash
   # Create .env file with:
   DATABASE_URL=postgresql://nextstep_user:nextstep_password@localhost:5432/nextstep_db
   SECRET_KEY=your-secret-key-here
   ```

4. **Initialize database**
   ```bash
   python init_postgres_db.py
   ```

5. **Start backend server**
   ```bash
   python main.py
   ```

### Step 2: Frontend Setup
1. **Navigate to Flutter directory**
   ```bash
   cd ..
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Start Flutter app**
   ```bash
   flutter run
   ```

### Step 3: Testing Scenarios

#### Test Scenario 1: User Registration
1. Open the app
2. Tap "Create Account"
3. Fill registration form
4. Submit registration
5. Verify account created successfully

#### Test Scenario 2: User Login
1. Open the app
2. Enter credentials:
   - Email: `john.doe@student.com`
   - Password: `password123`
3. Tap "Sign In"
4. Verify successful login and navigation to dashboard

#### Test Scenario 3: Browse Features
1. Login as student
2. Navigate through different sections:
   - Scholarships
   - Projects
   - Mentorship
   - Applications
3. Verify all data loads correctly

#### Test Scenario 4: Dark Mode
1. Login to the app
2. Look for theme toggle button
3. Toggle between light and dark modes
4. Verify theme changes applied correctly

#### Test Scenario 5: Push Notifications
1. Login to the app
2. Grant notification permissions
3. Test notification display
4. Verify notification interactions

## 🐛 Troubleshooting

### Common Issues & Solutions

#### Issue 1: Database Connection Failed
**Symptoms:** Database tests fail
**Solutions:**
- Check if PostgreSQL is running
- Verify database credentials
- Ensure database exists
- Check firewall settings

#### Issue 2: API Endpoints Not Working
**Symptoms:** Backend server starts but endpoints return errors
**Solutions:**
- Check if all dependencies are installed
- Verify database connection
- Check for import errors
- Review server logs

#### Issue 3: Flutter App Won't Start
**Symptoms:** Flutter app fails to build or run
**Solutions:**
- Run `flutter doctor` to check environment
- Run `flutter pub get` to install dependencies
- Check for syntax errors in Dart files
- Verify Flutter SDK installation

#### Issue 4: Authentication Issues
**Symptoms:** Login fails with valid credentials
**Solutions:**
- Check database for user records
- Verify password hashing
- Check JWT token generation
- Review authentication middleware

#### Issue 5: Theme Issues
**Symptoms:** Dark mode not working properly
**Solutions:**
- Check theme service implementation
- Verify shared preferences
- Test theme switching logic
- Check for UI component theme support

## 📈 Test Results Documentation

### Test Report Format

```
NEXTSTEP TESTING REPORT
======================

Date: [YYYY-MM-DD]
Time: [HH:MM:SS]
Environment: [Development/Production]

BACKEND TESTS
-------------
✅ Database Connection: PASSED
✅ API Endpoints: PASSED
✅ Authentication: PASSED
✅ Sample Data: PASSED

FRONTEND TESTS
--------------
✅ Flutter App Startup: PASSED
✅ Login Flow: PASSED
✅ Navigation: PASSED
✅ Dark Mode: PASSED

INTEGRATION TESTS
-----------------
✅ API Integration: PASSED
✅ Data Synchronization: PASSED
✅ File Upload: PASSED

OVERALL RESULT: ✅ ALL TESTS PASSED
```

## 🚨 Critical Test Cases

### Must-Test Scenarios

1. **Database Integrity**
   - All foreign key relationships working
   - Data consistency maintained
   - Rollback functionality working

2. **Authentication Security**
   - Password hashing working correctly
   - JWT tokens properly validated
   - Session management working

3. **API Security**
   - Input validation working
   - SQL injection prevention
   - Rate limiting functional

4. **Data Persistence**
   - User data saved correctly
   - File uploads working
   - Database transactions working

5. **Error Handling**
   - Network errors handled gracefully
   - Database errors handled properly
   - User-friendly error messages displayed

## 🎯 Success Criteria

### Backend Success
- [ ] All API endpoints respond correctly
- [ ] Database operations work without errors
- [ ] Authentication system functional
- [ ] Sample data created successfully

### Frontend Success
- [ ] App starts without crashes
- [ ] All pages load correctly
- [ ] User interactions work smoothly
- [ ] Theme switching functional

### Integration Success
- [ ] Frontend-backend communication working
- [ ] Data flows correctly between systems
- [ ] Real-time features functional
- [ ] File upload/download working

## 📞 Support & Issues

If you encounter any issues during testing:

1. **Check the logs** - Both backend and frontend logs
2. **Review error messages** - Detailed error information
3. **Test individual components** - Isolate problematic areas
4. **Check dependencies** - Verify all packages installed correctly
5. **Review configuration** - Check environment variables and settings

## 🎉 Testing Complete!

Once all tests pass, your NextStep application is ready for production deployment!

**Next Steps:**
1. ✅ Complete testing checklist
2. 🚀 Prepare for deployment
3. 📱 Test on real devices
4. 📊 Gather user feedback
5. 🔄 Iterate and improve

---

**Happy Testing!** 🧪✨
