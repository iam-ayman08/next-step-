# NextStep Backend - PostgreSQL Setup Guide

## 🚀 Overview

NextStep is a comprehensive career development platform built with FastAPI and PostgreSQL. This guide will help you set up the PostgreSQL database and get the application running.

## 📋 Prerequisites

- Python 3.9+
- PostgreSQL 12+
- pip package manager

## 🛠️ Installation

### 1. Install Dependencies

```bash
cd Backend
pip install -r requirements.txt
```

### 2. PostgreSQL Setup

#### Option A: Using Docker (Recommended)

```bash
# Install Docker and Docker Compose
# Then run:
docker run --name nextstep-postgres \
  -e POSTGRES_DB=nextstep_db \
  -e POSTGRES_USER=nextstep_user \
  -e POSTGRES_PASSWORD=nextstep_password \
  -p 5432:5432 \
  -d postgres:15
```

#### Option B: Local PostgreSQL Installation

1. **Install PostgreSQL:**
   - Ubuntu/Debian: `sudo apt install postgresql postgresql-contrib`
   - macOS: `brew install postgresql`
   - Windows: Download from [postgresql.org](https://www.postgresql.org/download/)

2. **Create Database and User:**

```sql
-- Connect to PostgreSQL as superuser
sudo -u postgres psql

-- Create database
CREATE DATABASE nextstep_db;

-- Create user
CREATE USER nextstep_user WITH PASSWORD 'nextstep_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE nextstep_db TO nextstep_user;

-- Grant schema permissions
\c nextstep_db;
GRANT ALL ON SCHEMA public TO nextstep_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nextstep_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO nextstep_user;

-- Exit
\q
```

### 3. Environment Configuration

Create a `.env` file in the Backend directory:

```env
# Database Configuration
DATABASE_URL=postgresql://nextstep_user:nextstep_password@localhost:5432/nextstep_db

# JWT Configuration
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Server Configuration
HOST=0.0.0.0
PORT=8000

# Environment
ENVIRONMENT=development

# Firebase Configuration (for notifications)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

### 4. Initialize Database

```bash
# Initialize PostgreSQL database with sample data
python init_postgres_db.py
```

### 5. Start the Server

```bash
# Development mode
python main.py

# Or using uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 📊 Database Schema

### Core Tables

- **users** - User accounts (students and alumni)
- **profiles** - Extended user profile information
- **scholarships** - Scholarship opportunities created by alumni
- **scholarship_applications** - Student applications for scholarships
- **projects** - Student projects seeking support
- **project_supports** - Alumni support for projects
- **alumni_expertise** - Alumni areas of expertise
- **mentorships** - Mentorship relationships
- **applications** - Job applications tracking
- **notifications** - System notifications

### Sample Data

The initialization script creates:
- 5 Alumni users with different expertise areas
- 2 Student users
- 4 Sample scholarships
- 3 Sample projects
- 5 Alumni expertise records
- Sample notifications

## 🔐 Authentication

### Login Credentials (Sample Data)

**Alumni Users:**
- Email: `sarah.johnson@alumni.com` | Password: `password123`
- Email: `michael.chen@alumni.com` | Password: `password123`
- Email: `emily.rodriguez@alumni.com` | Password: `password123`
- Email: `david.kim@alumni.com` | Password: `password123`
- Email: `lisa.thompson@alumni.com` | Password: `password123`

**Student Users:**
- Email: `john.doe@student.com` | Password: `password123`
- Email: `jane.smith@student.com` | Password: `password123`

## 🧪 Testing

### Run Tests

```bash
# Run all tests
python test_backend.py

# Run specific test
python -m pytest tests/test_auth.py -v
```

### API Testing with curl

```bash
# Login
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "john.doe@student.com", "password": "password123"}'

# Get current user
curl -X GET "http://localhost:8000/api/v1/users/me" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Get scholarships
curl -X GET "http://localhost:8000/api/v1/scholarships/" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🔧 Configuration Options

### Database Configuration

```python
# For production
DATABASE_URL = "postgresql://user:password@host:port/database"

# For development (SQLite fallback)
DATABASE_URL = "sqlite:///./Database/app.db"
```

### JWT Configuration

```python
# Generate a secure secret key
import secrets
secret_key = secrets.token_urlsafe(32)
```

## 🚀 Deployment

### Production Setup

1. **Environment Variables:**
   ```env
   ENVIRONMENT=production
   DATABASE_URL=postgresql://prod_user:prod_pass@prod_host:5432/prod_db
   SECRET_KEY=your-production-secret-key
   ```

2. **Database Migration:**
   ```bash
   # Create production database
   python init_postgres_db.py
   ```

3. **Run with Gunicorn:**
   ```bash
   gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
   ```

### Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 📈 Monitoring

### Health Check

```bash
curl http://localhost:8000/health
```

### Database Status

```bash
curl http://localhost:8000/api/v1/health/database
```

## 🐛 Troubleshooting

### Common Issues

1. **PostgreSQL Connection Failed:**
   - Check if PostgreSQL is running: `sudo systemctl status postgresql`
   - Verify credentials in `.env` file
   - Ensure database exists: `psql -U nextstep_user -d nextstep_db`

2. **Port Already in Use:**
   ```bash
   # Find process using port 8000
   lsof -i :8000
   # Kill the process
   kill -9 PID
   ```

3. **Import Errors:**
   ```bash
   # Reinstall dependencies
   pip uninstall -y -r requirements.txt
   pip install -r requirements.txt
   ```

### Logs

- Application logs are printed to console
- Database logs can be found in PostgreSQL logs
- Check `/var/log/postgresql/` for PostgreSQL logs

## 📚 API Documentation

Once the server is running, visit:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **OpenAPI Schema:** http://localhost:8000/openapi.json

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support, please contact the development team or create an issue in the repository.

---

**NextStep Backend** - Empowering students and alumni through technology! 🎓🚀
