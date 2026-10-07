import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Text, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.database import Base

class ProductStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    SOLD_OUT = "SOLD_OUT"
    ARCHIVED = "ARCHIVED"

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    farmer_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    name = Column(String(150), nullable=False, index=True)
    category = Column(String(100), nullable=False, index=True) # Vegetables, Fruits, Grains, Pulses, Other
    quantity = Column(Float, nullable=False, default=0.0) # in kg
    price_per_kg = Column(Float, nullable=False, default=0.0) # in INR
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    location = Column(String(200), nullable=True)
    status = Column(Enum(ProductStatus), nullable=False, default=ProductStatus.ACTIVE)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    farmer = relationship("User", back_populates="products")
    orders = relationship("Order", back_populates="product", cascade="all, delete-orphan")
