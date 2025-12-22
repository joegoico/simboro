from pydantic import BaseModel, Field, EmailStr
from typing import Optional, Dict, Any
# Modelos de respuesta
class OAuthURLResponse(BaseModel):
    url: str
    provider: str = "google"

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    user_metadata: dict = Field(default_factory=dict)
    created_at: Optional[str] = None

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "Bearer"
    user: UserResponse

class ErrorResponse(BaseModel):
    detail: str
    status_code: int
