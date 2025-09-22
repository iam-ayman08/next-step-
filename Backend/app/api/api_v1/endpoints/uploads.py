"""
File upload API endpoints for document submission
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import os
import uuid
import aiofiles
from pathlib import Path

from app.core.database import get_db, User
from app.core.security import get_current_user
from pydantic import BaseModel

router = APIRouter()

# Configuration
UPLOAD_DIR = Path("uploads")
ALLOWED_EXTENSIONS = {'.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png', '.gif', '.txt'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# Pydantic models
class FileUploadResponse(BaseModel):
    filename: str
    original_filename: str
    file_path: str
    file_size: int
    file_type: str
    uploaded_at: datetime
    uploaded_by: str

    class Config:
        from_attributes = True

class FileInfo(BaseModel):
    filename: str
    size: int
    type: str
    uploaded_at: datetime

# Create upload directory if it doesn't exist
UPLOAD_DIR.mkdir(exist_ok=True)

def validate_file_extension(filename: str) -> bool:
    """Validate file extension"""
    file_ext = Path(filename).suffix.lower()
    return file_ext in ALLOWED_EXTENSIONS

def generate_unique_filename(original_filename: str) -> str:
    """Generate unique filename with UUID"""
    file_ext = Path(original_filename).suffix
    unique_id = str(uuid.uuid4())
    return f"{unique_id}{file_ext}"

async def save_uploaded_file(file: UploadFile, filename: str) -> str:
    """Save uploaded file to disk"""
    file_path = UPLOAD_DIR / filename

    async with aiofiles.open(file_path, 'wb') as f:
        content = await file.read()
        await f.write(content)

    return str(file_path)

# File upload endpoints
@router.post("/upload", response_model=FileUploadResponse)
async def upload_file(
    file: UploadFile = File(...),
    file_type: str = Form(..., description="Type of file: resume, transcript, certificate, etc."),
    description: Optional[str] = Form(None, description="Optional description of the file"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload a file (document, image, etc.)"""
    try:
        # Validate file extension
        if not validate_file_extension(file.filename):
            raise HTTPException(
                status_code=400,
                detail=f"File type not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
            )

        # Check file size
        file_size = 0
        content = await file.read()
        file_size = len(content)

        if file_size > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail=f"File size too large. Maximum size: {MAX_FILE_SIZE / (1024*1024)}MB"
            )

        # Generate unique filename
        unique_filename = generate_unique_filename(file.filename)

        # Save file
        file_path = await save_uploaded_file(file, unique_filename)

        # Create file record in database (if we had a File model)
        # For now, just return the file info

        return FileUploadResponse(
            filename=unique_filename,
            original_filename=file.filename,
            file_path=file_path,
            file_size=file_size,
            file_type=file_type,
            uploaded_at=datetime.utcnow(),
            uploaded_by=current_user.username
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload file: {str(e)}")

@router.post("/upload/multiple", response_model=List[FileUploadResponse])
async def upload_multiple_files(
    files: List[UploadFile] = File(...),
    file_type: str = Form(..., description="Type of files being uploaded"),
    description: Optional[str] = Form(None, description="Optional description"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload multiple files at once"""
    if len(files) > 10:  # Limit to 10 files at once
        raise HTTPException(status_code=400, detail="Maximum 10 files allowed at once")

    uploaded_files = []

    for file in files:
        try:
            # Validate file extension
            if not validate_file_extension(file.filename):
                continue  # Skip invalid files

            # Check file size
            content = await file.read()
            file_size = len(content)

            if file_size > MAX_FILE_SIZE:
                continue  # Skip oversized files

            # Generate unique filename
            unique_filename = generate_unique_filename(file.filename)

            # Save file
            file_path = await save_uploaded_file(file, unique_filename)

            # Create response
            file_response = FileUploadResponse(
                filename=unique_filename,
                original_filename=file.filename,
                file_path=file_path,
                file_size=file_size,
                file_type=file_type,
                uploaded_at=datetime.utcnow(),
                uploaded_by=current_user.username
            )

            uploaded_files.append(file_response)

        except Exception as e:
            print(f"Failed to upload file {file.filename}: {e}")
            continue

    return uploaded_files

@router.get("/files/{filename}")
async def get_file_info(
    filename: str,
    current_user: User = Depends(get_current_user)
):
    """Get information about an uploaded file"""
    file_path = UPLOAD_DIR / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")

    # Get file stats
    stat = file_path.stat()

    return {
        "filename": filename,
        "size": stat.st_size,
        "modified": datetime.fromtimestamp(stat.st_mtime),
        "exists": True
    }

@router.delete("/files/{filename}")
async def delete_file(
    filename: str,
    current_user: User = Depends(get_current_user)
):
    """Delete an uploaded file"""
    file_path = UPLOAD_DIR / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")

    try:
        file_path.unlink()  # Delete the file
        return {"message": "File deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete file: {str(e)}")

@router.get("/files")
async def list_uploaded_files(
    current_user: User = Depends(get_current_user)
):
    """List all uploaded files for the current user"""
    try:
        files = []
        for file_path in UPLOAD_DIR.glob("*"):
            if file_path.is_file():
                stat = file_path.stat()
                files.append({
                    "filename": file_path.name,
                    "size": stat.st_size,
                    "modified": datetime.fromtimestamp(stat.st_mtime),
                    "type": Path(file_path.name).suffix.lower()
                })

        return {"files": files}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list files: {str(e)}")

# Helper functions for different file types
async def upload_resume(file: UploadFile, user_id: str):
    """Upload a resume file"""
    return await upload_file(
        file=file,
        file_type="resume",
        description=f"Resume uploaded by user {user_id}"
    )

async def upload_transcript(file: UploadFile, user_id: str):
    """Upload an academic transcript"""
    return await upload_file(
        file=file,
        file_type="transcript",
        description=f"Academic transcript uploaded by user {user_id}"
    )

async def upload_certificate(file: UploadFile, user_id: str, cert_type: str = "general"):
    """Upload a certificate"""
    return await upload_file(
        file=file,
        file_type=f"certificate_{cert_type}",
        description=f"Certificate ({cert_type}) uploaded by user {user_id}"
    )

async def upload_project_document(file: UploadFile, user_id: str, project_name: str):
    """Upload a project-related document"""
    return await upload_file(
        file=file,
        file_type="project_document",
        description=f"Project document for {project_name} uploaded by user {user_id}"
    )
