from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.schemas.user import UserResponse

class MessageCreate(BaseModel):
    receiver_id: int
    message: str = Field(..., min_length=1)

class MessageResponse(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    message: str
    created_at: datetime
    read_status: bool
    sender: Optional[UserResponse] = None
    receiver: Optional[UserResponse] = None
    model_config = ConfigDict(from_attributes=True)

class ConversationSummary(BaseModel):
    user_id: int
    user_name: str
    user_role: str
    last_message: str
    last_message_time: datetime
    unread_count: int
    model_config = ConfigDict(from_attributes=True)
