from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, and_, desc
from app.database import get_db
from app.models.user import User
from app.models.message import Message
from app.schemas.message import MessageCreate, MessageResponse, ConversationSummary
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/messages", tags=["Messages"])

@router.post("", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
def send_message(
    msg_data: MessageCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    receiver = db.query(User).filter(User.id == msg_data.receiver_id).first()
    if not receiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recipient user not found")

    new_msg = Message(
        sender_id=current_user.id,
        receiver_id=msg_data.receiver_id,
        message=msg_data.message.strip(),
        read_status=False
    )
    db.add(new_msg)
    db.commit()
    db.refresh(new_msg)

    loaded_msg = (
        db.query(Message)
        .options(joinedload(Message.sender), joinedload(Message.receiver))
        .filter(Message.id == new_msg.id)
        .first()
    )
    return loaded_msg

@router.get("/conversations", response_model=List[ConversationSummary])
def get_conversations(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Find all distinct user IDs that current_user has exchanged messages with
    all_msgs = (
        db.query(Message)
        .filter(or_(Message.sender_id == current_user.id, Message.receiver_id == current_user.id))
        .order_by(desc(Message.created_at))
        .all()
    )

    partner_ids = []
    conversations = []
    
    for msg in all_msgs:
        other_id = msg.receiver_id if msg.sender_id == current_user.id else msg.sender_id
        if other_id not in partner_ids:
            partner_ids.append(other_id)
            other_user = db.query(User).filter(User.id == other_id).first()
            if other_user:
                unread = db.query(Message).filter(
                    Message.sender_id == other_id,
                    Message.receiver_id == current_user.id,
                    Message.read_status == False
                ).count()

                conversations.append(ConversationSummary(
                    user_id=other_user.id,
                    user_name=other_user.name,
                    user_role=other_user.role.value,
                    last_message=msg.message,
                    last_message_time=msg.created_at,
                    unread_count=unread
                ))

    return conversations

@router.get("/{user_id}", response_model=List[MessageResponse])
def get_conversation_thread(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    other_user = db.query(User).filter(User.id == user_id).first()
    if not other_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # Mark all incoming messages from this user as read
    db.query(Message).filter(
        Message.sender_id == user_id,
        Message.receiver_id == current_user.id,
        Message.read_status == False
    ).update({"read_status": True}, synchronize_session=False)
    db.commit()

    messages = (
        db.query(Message)
        .options(joinedload(Message.sender), joinedload(Message.receiver))
        .filter(
            or_(
                and_(Message.sender_id == current_user.id, Message.receiver_id == user_id),
                and_(Message.sender_id == user_id, Message.receiver_id == current_user.id)
            )
        )
        .order_by(Message.created_at.asc())
        .all()
    )
    return messages
