import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from app.main import app
from app.database import Base, get_db

# Use an in-memory SQLite database with StaticPool so all connections share the same memory DB
TEST_DB_URL = "sqlite:///:memory:"
test_engine = create_engine(
    TEST_DB_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="function", autouse=True)
def setup_database():
    Base.metadata.create_all(bind=test_engine)
    yield
    Base.metadata.drop_all(bind=test_engine)

@pytest.fixture
def client():
    return TestClient(app)

def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_farmer_registration_and_login(client):
    # 1. Register Farmer
    reg_data = {
        "name": "Ramesh Kumar",
        "email": "ramesh@example.com",
        "phone": "+91 9876543210",
        "password": "secretpassword",
        "role": "FARMER",
        "location": "Warangal, Telangana"
    }
    reg_res = client.post("/auth/register", json=reg_data)
    assert reg_res.status_code == 201
    reg_json = reg_res.json()
    assert "access_token" in reg_json
    assert reg_json["role"] == "FARMER"

    # 2. Login Farmer
    login_data = {
        "email": "ramesh@example.com",
        "password": "secretpassword"
    }
    login_res = client.post("/auth/login", json=login_data)
    assert login_res.status_code == 200
    login_json = login_res.json()
    assert "access_token" in login_json
    token = login_json["access_token"]

    # 3. Check /auth/me
    headers = {"Authorization": f"Bearer {token}"}
    me_res = client.get("/auth/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["name"] == "Ramesh Kumar"

def test_product_crud_and_order_flow(client):
    # 1. Register Farmer & Buyer
    farmer_res = client.post("/auth/register", json={
        "name": "Farmer Joe",
        "email": "farmer@example.com",
        "phone": "+91 9999999999",
        "password": "password123",
        "role": "FARMER",
        "location": "Punjab"
    })
    farmer_token = farmer_res.json()["access_token"]

    buyer_res = client.post("/auth/register", json={
        "name": "Buyer Bob",
        "email": "buyer@example.com",
        "phone": "+91 8888888888",
        "password": "password123",
        "role": "BUYER",
        "location": "Delhi"
    })
    buyer_token = buyer_res.json()["access_token"]

    farmer_headers = {"Authorization": f"Bearer {farmer_token}"}
    buyer_headers = {"Authorization": f"Bearer {buyer_token}"}

    # 2. Farmer creates product
    prod_data = {
        "name": "Fresh Organic Tomatoes",
        "category": "Vegetables",
        "quantity": 500.0,
        "price_per_kg": 25.0,
        "description": "Juicy red farm fresh tomatoes",
        "image_url": "https://example.com/tomatoes.jpg",
        "location": "Punjab"
    }
    create_prod_res = client.post("/products", json=prod_data, headers=farmer_headers)
    assert create_prod_res.status_code == 201
    prod_id = create_prod_res.json()["id"]

    # 3. Buyer searches products
    search_res = client.get("/products/search?q=Tomatoes")
    assert search_res.status_code == 200
    assert len(search_res.json()) >= 1

    # 4. Buyer places order
    order_data = {
        "product_id": prod_id,
        "quantity": 50.0
    }
    order_res = client.post("/orders", json=order_data, headers=buyer_headers)
    assert order_res.status_code == 201
    order_json = order_res.json()
    assert order_json["total_price"] == 1250.0
    assert order_json["status"] == "PENDING"
    order_id = order_json["id"]

    # 5. Farmer views incoming orders and confirms order
    farmer_orders_res = client.get("/orders", headers=farmer_headers)
    assert farmer_orders_res.status_code == 200
    assert len(farmer_orders_res.json()) == 1

    update_res = client.put(f"/orders/{order_id}/status", json={"status": "CONFIRMED"}, headers=farmer_headers)
    assert update_res.status_code == 200
    assert update_res.json()["status"] == "CONFIRMED"

    # 6. Chat messaging between buyer and farmer
    msg_res = client.post("/messages", json={
        "receiver_id": farmer_res.json()["user_id"],
        "message": "Hello, can we arrange pickup on Friday?"
    }, headers=buyer_headers)
    assert msg_res.status_code == 201

    thread_res = client.get(f"/messages/{farmer_res.json()['user_id']}", headers=buyer_headers)
    assert thread_res.status_code == 200
    assert len(thread_res.json()) == 1
