from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from app.models.user import UserRole

class UserBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: Optional[str] = Field(None, max_length=20)
    role: UserRole
    location: Optional[str] = Field(None, max_length=200)

class UserCreate(UserBase):
    password: str = Field(..., min_length=6)

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    location: Optional[str] = None
    profile_image: Optional[str] = None

class UserResponse(UserBase):
    id: int
    profile_image: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
