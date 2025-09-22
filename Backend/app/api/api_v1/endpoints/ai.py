"""
AI chat endpoints that proxy requests to Lightning AI API
"""

import requests
import json
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

router = APIRouter()

# Lightning AI API configuration
LIGHTNING_API_URL = "https://lightning.ai/api/v1/chat/completions"
LIGHTNING_API_KEY = "d9601d2b-481b-494c-93e9-3e273eea4021/aymanmohamed1937/vision-model"
DEFAULT_MODEL = "lightning-ai/llama-3.3-70b"

class ChatMessage(BaseModel):
    role: str = Field(..., pattern="^(user|assistant|system)$")
    content: str  # Lightning API expects array of objects, but for simplicity we'll use string

class ChatCompletionRequest(BaseModel):
    messages: List[ChatMessage] = Field(..., min_items=1)
    model: Optional[str] = DEFAULT_MODEL
    max_tokens: Optional[int] = 150
    temperature: Optional[float] = 0.7

class ChatCompletionResponse(BaseModel):
    id: str
    choices: List[Dict[str, Any]]
    created: int
    model: str
    object: str = "chat.completion"

@router.post("/chat/completions", response_model=ChatCompletionResponse)
async def chat_completion(request: ChatCompletionRequest):
    """Proxy chat completion requests to Lightning AI API"""
    try:
        # Prepare the request data for Lightning API
        # Lightning expects content as array of objects, but we'll keep it simple
        lightning_messages = []
        for msg in request.messages:
            lightning_messages.append({
                "role": msg.role,
                "content": [{"type": "text", "text": msg.content}]
            })

        payload = {
            "model": request.model or DEFAULT_MODEL,
            "messages": lightning_messages
        }

        # Add optional parameters if provided
        if request.max_tokens:
            payload["max_tokens"] = request.max_tokens
        if request.temperature is not None:
            payload["temperature"] = request.temperature

        # Make request to Lightning AI
        headers = {
            "Authorization": f"Bearer {LIGHTNING_API_KEY}",
            "Content-Type": "application/json"
        }

        response = requests.post(
            LIGHTNING_API_URL,
            headers=headers,
            data=json.dumps(payload),
            timeout=30  # 30 second timeout
        )

        if response.status_code == 200:
            # Parse and return the Lightning response
            data = response.json()

            # Ensure we have the expected structure
            if not isinstance(data, dict):
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="Invalid response format from Lightning AI"
                )

            return ChatCompletionResponse(**data)

        elif response.status_code == 401:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Lightning AI authentication failed"
            )
        elif response.status_code == 429:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded for Lightning AI"
            )
        else:
            # Try to get error details
            try:
                error_data = response.json()
                error_message = error_data.get('error', {}).get('message', f'HTTP {response.status_code}')
            except:
                error_message = f'HTTP {response.status_code}: {response.text[:200]}'

            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Lightning AI API error: {error_message}"
            )

    except requests.exceptions.Timeout:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="Request to Lightning AI timed out"
        )
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Failed to connect to Lightning AI: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )
