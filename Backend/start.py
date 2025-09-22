#!/usr/bin/env python3
"""
Simple startup script for the backend
"""

import uvicorn
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

if __name__ == "__main__":
    # Get configuration from environment
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    debug = os.getenv("DEBUG", "True").lower() == "true"

    print("🚀 Starting Flutter App Backend API...")
    print(f"📍 Host: {host}")
    print(f"🔌 Port: {port}")
    print(f"🐛 Debug: {debug}")
    print(f"📚 API Docs: http://{host}:{port}/docs")
    print(f"❤️  Health Check: http://{host}:{port}/health")
    print("-" * 50)

    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="info"
    )
