from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models.user import User
from app.models.product import Product, ProductStatus
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.utils.dependencies import get_current_user, require_farmer

router = APIRouter(prefix="/products", tags=["Products"])

@router.get("/search", response_model=List[ProductResponse])
def search_products(
    q: str = Query(..., min_length=1, description="Search query string"),
    db: Session = Depends(get_db)
):
    search_term = f"%{q}%"
    products = (
        db.query(Product)
        .options(joinedload(Product.farmer))
        .filter(
            Product.status == ProductStatus.ACTIVE,
            (Product.name.ilike(search_term) |
             Product.category.ilike(search_term) |
             Product.description.ilike(search_term) |
             Product.location.ilike(search_term))
        )
        .order_by(Product.created_at.desc())
        .all()
    )
    return products

@router.get("", response_model=List[ProductResponse])
def get_products(
    category: Optional[str] = Query(None, description="Category filter"),
    location: Optional[str] = Query(None, description="Location filter"),
    min_price: Optional[float] = Query(None, ge=0, description="Minimum price per kg"),
    max_price: Optional[float] = Query(None, ge=0, description="Maximum price per kg"),
    farmer_id: Optional[int] = Query(None, description="Filter by farmer ID"),
    status: Optional[ProductStatus] = Query(ProductStatus.ACTIVE, description="Product status"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    query = db.query(Product).options(joinedload(Product.farmer))
    
    if status is not None:
        query = query.filter(Product.status == status)
    if category and category.lower() != "all":
        query = query.filter(Product.category.ilike(f"%{category}%"))
    if location:
        query = query.filter(Product.location.ilike(f"%{location}%"))
    if min_price is not None:
        query = query.filter(Product.price_per_kg >= min_price)
    if max_price is not None:
        query = query.filter(Product.price_per_kg <= max_price)
    if farmer_id is not None:
        query = query.filter(Product.farmer_id == farmer_id)

    return query.order_by(Product.created_at.desc()).offset(skip).limit(limit).all()

@router.get("/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = (
        db.query(Product)
        .options(joinedload(Product.farmer))
        .filter(Product.id == product_id)
        .first()
    )
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return product

@router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    product_data: ProductCreate,
    db: Session = Depends(get_db),
    current_farmer: User = Depends(require_farmer)
):
    new_product = Product(
        farmer_id=current_farmer.id,
        name=product_data.name,
        category=product_data.category,
        quantity=product_data.quantity,
        price_per_kg=product_data.price_per_kg,
        description=product_data.description,
        image_url=product_data.image_url,
        location=product_data.location or current_farmer.location,
        status=ProductStatus.ACTIVE
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    new_product.farmer = current_farmer
    return new_product

@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_data: ProductUpdate,
    db: Session = Depends(get_db),
    current_farmer: User = Depends(require_farmer)
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    
    if product.farmer_id != current_farmer.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to update this product listing"
        )

    for field, value in product_data.model_dump(exclude_unset=True).items():
        setattr(product, field, value)

    db.commit()
    db.refresh(product)
    product.farmer = current_farmer
    return product

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_farmer: User = Depends(require_farmer)
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    
    if product.farmer_id != current_farmer.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to delete this product listing"
        )

    db.delete(product)
    db.commit()
    return None
