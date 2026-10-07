from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models.user import User, UserRole
from app.models.product import Product, ProductStatus
from app.models.order import Order, OrderStatus
from app.schemas.order import OrderCreate, OrderUpdateStatus, OrderResponse
from app.utils.dependencies import get_current_user, require_buyer

router = APIRouter(prefix="/orders", tags=["Orders"])

@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    order_data: OrderCreate,
    db: Session = Depends(get_db),
    current_buyer: User = Depends(require_buyer)
):
    product = db.query(Product).filter(Product.id == order_data.product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    if product.status != ProductStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Product is not currently available for orders"
        )

    if order_data.quantity > product.quantity:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Requested quantity ({order_data.quantity} kg) exceeds available stock ({product.quantity} kg)"
        )

    total_price = round(order_data.quantity * product.price_per_kg, 2)

    # Decrement available product stock
    product.quantity -= order_data.quantity
    if product.quantity <= 0:
        product.quantity = 0
        product.status = ProductStatus.SOLD_OUT

    new_order = Order(
        buyer_id=current_buyer.id,
        farmer_id=product.farmer_id,
        product_id=product.id,
        quantity=order_data.quantity,
        total_price=total_price,
        status=OrderStatus.PENDING
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)

    # Load relationships for full response
    loaded_order = (
        db.query(Order)
        .options(
            joinedload(Order.buyer),
            joinedload(Order.farmer),
            joinedload(Order.product)
        )
        .filter(Order.id == new_order.id)
        .first()
    )
    return loaded_order

@router.get("", response_model=List[OrderResponse])
def get_orders(
    status: Optional[OrderStatus] = Query(None, description="Filter by order status"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = (
        db.query(Order)
        .options(
            joinedload(Order.buyer),
            joinedload(Order.farmer),
            joinedload(Order.product)
        )
    )

    if current_user.role == UserRole.FARMER:
        query = query.filter(Order.farmer_id == current_user.id)
    else:
        query = query.filter(Order.buyer_id == current_user.id)

    if status:
        query = query.filter(Order.status == status)

    return query.order_by(Order.created_at.desc()).all()

@router.get("/{order_id}", response_model=OrderResponse)
def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    order = (
        db.query(Order)
        .options(
            joinedload(Order.buyer),
            joinedload(Order.farmer),
            joinedload(Order.product)
        )
        .filter(Order.id == order_id)
        .first()
    )
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

    if order.buyer_id != current_user.id and order.farmer_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    return order

@router.put("/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    status_update: OrderUpdateStatus,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    order = (
        db.query(Order)
        .options(
            joinedload(Order.buyer),
            joinedload(Order.farmer),
            joinedload(Order.product)
        )
        .filter(Order.id == order_id)
        .first()
    )
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

    new_status = status_update.status

    if current_user.role == UserRole.FARMER:
        if order.farmer_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
        # Farmer can confirm, deliver, or cancel
        order.status = new_status
    elif current_user.role == UserRole.BUYER:
        if order.buyer_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
        if new_status != OrderStatus.CANCELLED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Buyers can only cancel pending orders"
            )
        if order.status != OrderStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot cancel an order that is already confirmed or delivered"
            )
        order.status = OrderStatus.CANCELLED

    # If cancelled, restore product stock
    if new_status == OrderStatus.CANCELLED and order.product:
        order.product.quantity += order.quantity
        if order.product.status == ProductStatus.SOLD_OUT:
            order.product.status = ProductStatus.ACTIVE

    db.commit()
    db.refresh(order)
    return order
