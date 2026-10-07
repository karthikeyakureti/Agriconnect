"""
Seed script to populate AgriConnect database with realistic agricultural demo data.
Run: python seed_data.py
"""

from app.database import SessionLocal, engine, Base
from app.models.user import User, UserRole
from app.models.product import Product, ProductStatus
from app.models.order import Order, OrderStatus
from app.models.message import Message
from app.utils.security import get_password_hash

def seed_database():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # Check if already seeded
        if db.query(User).count() > 0:
            print("Database already contains records. Clearing existing demo data...")
            db.query(Message).delete()
            db.query(Order).delete()
            db.query(Product).delete()
            db.query(User).delete()
            db.commit()

        print("Seeding Users...")
        # 1. Farmers
        farmer1 = User(
            name="Ramesh Kumar",
            email="ramesh@agriconnect.com",
            phone="+91 98765 43210",
            password_hash=get_password_hash("password123"),
            role=UserRole.FARMER,
            location="Warangal, Telangana",
            profile_image="https://images.unsplash.com/photo-1544717305-2782549b5136?w=400&q=80"
        )
        farmer2 = User(
            name="Sunita Devi",
            email="sunita@agriconnect.com",
            phone="+91 98451 23456",
            password_hash=get_password_hash("password123"),
            role=UserRole.FARMER,
            location="Nashik, Maharashtra",
            profile_image="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&q=80"
        )
        
        # 2. Buyers
        buyer1 = User(
            name="Anand Sharma",
            email="buyer@agriconnect.com",
            phone="+91 91234 56789",
            password_hash=get_password_hash("password123"),
            role=UserRole.BUYER,
            location="Hyderabad, Telangana",
            profile_image="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80"
        )
        buyer2 = User(
            name="Priya Patel",
            email="priya@agriconnect.com",
            phone="+91 99887 76655",
            password_hash=get_password_hash("password123"),
            role=UserRole.BUYER,
            location="Pune, Maharashtra",
            profile_image="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80"
        )

        db.add_all([farmer1, farmer2, buyer1, buyer2])
        db.commit()
        db.refresh(farmer1)
        db.refresh(farmer2)
        db.refresh(buyer1)
        db.refresh(buyer2)

        print("Seeding Agricultural Products...")
        products = [
            Product(
                farmer_id=farmer1.id,
                name="Tomatoes",
                category="Vegetables",
                quantity=500.0,
                price_per_kg=18.0,
                description="Fresh, vine-ripened organic red tomatoes harvested early this morning. Rich in flavor and vitamins, ideal for home cooking and wholesale.",
                image_url="https://images.unsplash.com/photo-1546470427-0d4db154ceb7?w=600&q=80",
                location="Warangal, Telangana",
                status=ProductStatus.ACTIVE
            ),
            Product(
                farmer_id=farmer1.id,
                name="Onions",
                category="Vegetables",
                quantity=300.0,
                price_per_kg=16.0,
                description="High grade Nashik red onions with long shelf life. Uniform size and dry outer skin, perfect for retail and bulk purchase.",
                image_url="https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&q=80",
                location="Warangal, Telangana",
                status=ProductStatus.ACTIVE
            ),
            Product(
                farmer_id=farmer1.id,
                name="Potatoes",
                category="Vegetables",
                quantity=1000.0,
                price_per_kg=15.0,
                description="Premium crop new harvest potatoes. Clean, firm, and excellent for chips, curries, and daily kitchen consumption.",
                image_url="https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&q=80",
                location="Warangal, Telangana",
                status=ProductStatus.ACTIVE
            ),
            Product(
                farmer_id=farmer1.id,
                name="Green Chillies",
                category="Vegetables",
                quantity=200.0,
                price_per_kg=20.0,
                description="Spicy and fresh G4 green chillies picked fresh from our field. Rich green color and great punch.",
                image_url="https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&q=80",
                location="Warangal, Telangana",
                status=ProductStatus.ACTIVE
            ),
            Product(
                farmer_id=farmer2.id,
                name="Fresh Pomegranates",
                category="Fruits",
                quantity=450.0,
                price_per_kg=85.0,
                description="Bhagwa variety sweet ruby-red pomegranates. Juicy arils, export quality, grown using eco-friendly farm practices.",
                image_url="https://images.unsplash.com/photo-1541344999736-83eca872f242?w=600&q=80",
                location="Nashik, Maharashtra",
                status=ProductStatus.ACTIVE
            ),
            Product(
                farmer_id=farmer2.id,
                name="Basmati Rice",
                category="Grains",
                quantity=800.0,
                price_per_kg=65.0,
                description="Aromatic 1121 traditional Basmati rice. Extra-long grain with exquisite fragrance after cooking.",
                image_url="https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&q=80",
                location="Nashik, Maharashtra",
                status=ProductStatus.ACTIVE
            ),
            Product(
                farmer_id=farmer1.id,
                name="Organic Toor Dal",
                category="Pulses",
                quantity=350.0,
                price_per_kg=110.0,
                description="Unpolished yellow pigeon pea (Toor Dal) with no chemical polishing. High protein and delicious taste.",
                image_url="https://images.unsplash.com/photo-1585735232971-550972744888?w=600&q=80",
                location="Warangal, Telangana",
                status=ProductStatus.ACTIVE
            )
        ]

        db.add_all(products)
        db.commit()
        for p in products:
            db.refresh(p)

        print("Seeding Sample Orders...")
        order1 = Order(
            buyer_id=buyer1.id,
            farmer_id=farmer1.id,
            product_id=products[0].id, # Tomatoes
            quantity=50.0,
            total_price=900.0,
            status=OrderStatus.PENDING
        )
        order2 = Order(
            buyer_id=buyer1.id,
            farmer_id=farmer1.id,
            product_id=products[1].id, # Onions
            quantity=100.0,
            total_price=1600.0,
            status=OrderStatus.CONFIRMED
        )
        order3 = Order(
            buyer_id=buyer2.id,
            farmer_id=farmer1.id,
            product_id=products[2].id, # Potatoes
            quantity=80.0,
            total_price=1200.0,
            status=OrderStatus.DELIVERED
        )
        db.add_all([order1, order2, order3])
        db.commit()

        print("Seeding Messages...")
        msg1 = Message(
            sender_id=buyer1.id,
            receiver_id=farmer1.id,
            message="Hello, I am interested in your tomatoes. Can you tell me the minimum quantity available?",
            read_status=True
        )
        msg2 = Message(
            sender_id=farmer1.id,
            receiver_id=buyer1.id,
            message="Hello! I have 500 kg available. You can take as much as you need.",
            read_status=True
        )
        msg3 = Message(
            sender_id=buyer1.id,
            receiver_id=farmer1.id,
            message="Great! Can we fix a deal today?",
            read_status=False
        )
        db.add_all([msg1, msg2, msg3])
        db.commit()

        print("\n=== Seed Data Successfully Populated! ===")
        print("Demo Accounts:")
        print("  Farmer: ramesh@agriconnect.com | password123")
        print("  Farmer: sunita@agriconnect.com | password123")
        print("  Buyer:  buyer@agriconnect.com  | password123")
        print("  Buyer:  priya@agriconnect.com  | password123")
        print("=========================================\n")

    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
