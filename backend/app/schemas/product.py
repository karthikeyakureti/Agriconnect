from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.product import ProductStatus
from app.schemas.user import UserResponse

class ProductBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=150)
    category: str = Field(..., min_length=2, max_length=100) # Vegetables, Fruits, Grains, Pulses, Other
    quantity: float = Field(..., gt=0) # in kg
    price_per_kg: float = Field(..., gt=0) # in INR
    description: Optional[str] = None
    image_url: Optional[str] = None
    location: Optional[str] = None

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    quantity: Optional[float] = Field(None, gt=0)
    price_per_kg: Optional[float] = Field(None, gt=0)
    description: Optional[str] = None
    image_url: Optional[str] = None
    location: Optional[str] = None
    status: Optional[ProductStatus] = None

class ProductResponse(ProductBase):
    id: int
    farmer_id: int
    status: ProductStatus
    created_at: datetime
    updated_at: datetime
    farmer: Optional[UserResponse] = None
    model_config = ConfigDict(from_attributes=True)

class ProductFilter(BaseModel):
    category: Optional[str] = None
    location: Optional[str] = None
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    farmer_id: Optional[int] = None
