from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.order import OrderStatus
from app.schemas.user import UserResponse
from app.schemas.product import ProductResponse

class OrderCreate(BaseModel):
    product_id: int
    quantity: float = Field(..., gt=0) # in kg

class OrderUpdateStatus(BaseModel):
    status: OrderStatus

class OrderResponse(BaseModel):
    id: int
    buyer_id: int
    farmer_id: int
    product_id: int
    quantity: float
    total_price: float
    status: OrderStatus
    created_at: datetime
    updated_at: datetime
    buyer: Optional[UserResponse] = None
    farmer: Optional[UserResponse] = None
    product: Optional[ProductResponse] = None
    model_config = ConfigDict(from_attributes=True)
