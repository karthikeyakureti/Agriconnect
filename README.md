# 🌱 AgriConnect

> **Empowering Farmers | Connecting Buyers | Building a Fairer Future**  
> *"Direct from Farmer • Fresh for You"*

AgriConnect is a production-ready, full-stack direct Farmer-to-Buyer agricultural marketplace. It eliminates middlemen to ensure farmers earn fair profits for their harvest while buyers gain access to fresh, farm-gate agricultural produce with complete pricing transparency and direct communication.

---

## 🌟 Key Features

### 👨‍🌾 Farmer Capabilities
- **Role Selection & Authentication**: Register as a verified farmer with farm location and contact details.
- **Farmer Dashboard**:
  - Hero banner with quick profit & direct selling metrics.
  - "YOUR PRODUCTS" grid displaying produce photo, title, stock quantity (kg), price (₹/kg), and status badge.
  - Quick action controls: **View**, **Edit**, and **Delete** listings.
  - **+ Add Product** modal with category classification, pricing, quantity, and real-time image preview.
  - Incoming buyer orders overview with instant status controls (**Confirm Order**, **Mark Delivered**, **Reject**).
- **Profile & Statistics**:
  - Total products listed, active listings count, and completed orders metric.
  - Farm location and contact management.

### 🛒 Buyer Capabilities
- **Marketplace Discovery**:
  - Real-time search across product names, categories, descriptions, and locations.
  - Horizontal category scroll: `All`, `Vegetables`, `Fruits`, `Grains`, `Pulses`, `Other`.
  - Comprehensive filter modal: minimum/maximum price per kg and farm location.
- **Produce Details & Ordering**:
  - High-resolution hero produce photo, stock quantity, and farm-gate pricing.
  - Verified farmer credentials and rating badge.
  - **Contact Farmer**: Opens end-to-end direct chat with the producer.
  - **Place Order**: Interactive modal with dynamic quantity selector (kg), live total price calculation, and order confirmation.
- **Order Tracking**:
  - Tabbed order statuses: `All`, `Pending`, `Confirmed`, `Delivered`, `Cancelled`.
  - Order receipts with formatted `#AGI...` tracking numbers and status badges.
- **Direct Messaging**:
  - Real-time chat bubbles with timestamping and online indicators between farmers and buyers.

---

## 🏗️ Technology Stack

| Layer | Technologies |
|---|---|
| **Mobile App (Frontend)** | Flutter 3.38+, Dart 3.10+, Material 3, Provider State Management, HTTP Client, SharedPreferences |
| **Backend API** | FastAPI, Python 3.11, Pydantic v2, SQLAlchemy 2.0 ORM, Uvicorn, Python-Multipart |
| **Database** | PostgreSQL (Production) / SQLite (Zero-config local development auto-fallback) |
| **Authentication & Security** | JWT (JSON Web Tokens), Native Bcrypt password hashing, Role-Based Access Control (RBAC), CORS Middleware |
| **Testing & Deployment** | Pytest, Httpx, Docker, Docker-Compose (Render / Railway / AWS ready) |

---

## 📁 Project Structure

```
agriconnect/
├── backend/                        # FastAPI Backend
│   ├── app/
│   │   ├── models/                 # SQLAlchemy ORM Models
│   │   │   ├── user.py             # User & UserRole (FARMER, BUYER)
│   │   │   ├── product.py          # Product & ProductStatus
│   │   │   ├── order.py            # Order & OrderStatus
│   │   │   └── message.py          # Chat Message & Conversation
│   │   ├── schemas/                # Pydantic v2 Request/Response Schemas
│   │   │   ├── user.py
│   │   │   ├── product.py
│   │   │   ├── order.py
│   │   │   ├── message.py
│   │   │   └── token.py
│   │   ├── routers/                # REST API Endpoints
│   │   │   ├── auth.py             # /auth/register, /auth/login, /auth/me
│   │   │   ├── users.py            # /users/me, /users/{id}
│   │   │   ├── products.py         # /products CRUD, /products/search, filters
│   │   │   ├── orders.py           # /orders CRUD & status transitions
│   │   │   ├── messages.py         # /messages chat & /messages/conversations
│   │   │   └── upload.py           # /upload/image for produce photos
│   │   ├── utils/
│   │   │   ├── security.py         # Bcrypt hashing & JWT token generator
│   │   │   └── dependencies.py     # Auth & RBAC dependencies (require_farmer, etc.)
│   │   ├── database.py             # Database engine & session setup
│   │   └── main.py                 # FastAPI application & middleware
│   ├── tests/
│   │   └── test_api.py             # Pytest automated API test suite
│   ├── seed_data.py                # Pre-populates realistic demo farmers & crops
│   ├── requirements.txt            # Python dependencies
│   ├── .env                        # Local environment variables
│   ├── Dockerfile                  # Container definition for cloud deployment
│   └── docker-compose.yml          # Local PostgreSQL + FastAPI orchestration
│
├── lib/                            # Flutter Mobile Frontend
│   ├── core/
│   │   ├── constants/
│   │   │   ├── colors.dart         # Forest Green agricultural theme palette
│   │   │   └── api_constants.dart  # Platform-aware API endpoints (Android / Web / Desktop)
│   │   ├── network/
│   │   │   └── api_client.dart     # HTTP client with Bearer token injection & error parsing
│   │   ├── storage/
│   │   │   └── storage_service.dart# SharedPreferences persistent session manager
│   │   └── theme/
│   │       └── app_theme.dart      # Material 3 light theme configuration
│   ├── models/
│   │   ├── user_model.dart         # User data model
│   │   ├── product_model.dart      # Product data model
│   │   ├── order_model.dart        # Order data model
│   │   └── message_model.dart      # Chat message data model
│   ├── providers/
│   │   ├── auth_provider.dart      # Authentication & session state
│   │   ├── product_provider.dart   # Marketplace & farmer inventory state
│   │   ├── order_provider.dart     # Orders & status management state
│   │   └── chat_provider.dart      # Direct messaging state
│   ├── screens/
│   │   ├── splash/                 # Splash screen with branding & auto-navigation
│   │   ├── role_selection/         # Role chooser (Farmer vs Buyer)
│   │   ├── auth/                   # Sign In & Register screens
│   │   ├── farmer/                 # Farmer Dashboard & inventory management
│   │   ├── buyer/                  # Buyer Marketplace with search & filter
│   │   ├── products/               # Add/Edit Produce & Produce Details
│   │   ├── orders/                 # Order list with tabbed status filtering
│   │   ├── chat/                   # Direct Farmer-Buyer conversation screen
│   │   └── profile/                # Role-specific profile & account metrics
│   ├── widgets/                    # Reusable UI widgets (cards, badges, buttons)
│   └── main.dart                   # Application entry point with MultiProvider
│
└── pubspec.yaml                    # Flutter dependencies
```

---

## 🚀 Getting Started (Run Locally)

### 1. Backend Setup & Run

Open a terminal and navigate to `backend/`:

```bash
cd backend

# (Optional) Create and activate virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Populate realistic demo farmers, crops, orders, and messages
python seed_data.py

# Run automated tests to verify API integrity
python -m pytest -v

# Start the FastAPI server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Once started:
- **Interactive Swagger Documentation**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **Alternative ReDoc Documentation**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)
- **API Health Check**: [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)

---

### 2. Demo Accounts (Pre-Seeded)

| Role | Name | Email | Password | Farm Location |
|---|---|---|---|---|
| **Farmer** | Ramesh Kumar | `ramesh@agriconnect.com` | `password123` | Warangal, Telangana |
| **Farmer** | Sunita Devi | `sunita@agriconnect.com` | `password123` | Nashik, Maharashtra |
| **Buyer** | Anand Sharma | `buyer@agriconnect.com` | `password123` | Hyderabad, Telangana |
| **Buyer** | Priya Patel | `priya@agriconnect.com` | `password123` | Pune, Maharashtra |

> *Tip: The Login Screen includes quick-fill buttons to log in with one tap as either Ramesh Kumar (Farmer) or Anand Sharma (Buyer).*

---

### 3. Flutter Mobile Setup & Run

From the root project directory `agriconnect`:

```bash
# Fetch Flutter packages
flutter pub get

# Run on your preferred target (Android emulator, Web, or Windows desktop)
flutter run
```

> **Network Configuration Note:**  
> `lib/core/constants/api_constants.dart` automatically connects to `http://10.0.2.2:8000` when running inside the standard Android Emulator and `http://127.0.0.1:8000` when running on Windows desktop, macOS, or Chrome Web.

---

## 📡 API Endpoints Reference

### Authentication & Users
- `POST /auth/register` - Create a new Farmer or Buyer account (returns JWT token)
- `POST /auth/login` - Authenticate with email and password
- `GET /auth/me` - Retrieve authenticated user session details
- `GET /users/{id}` - Public user profile details

### Produce Listings (Products)
- `GET /products` - Browse listings with optional filters:
  - `?category=Vegetables`
  - `?location=Warangal`
  - `?min_price=10&max_price=30`
  - `?farmer_id=1`
- `GET /products/search?q=tomatoes` - Search produce by name, description, or location
- `GET /products/{id}` - View complete produce specifications
- `POST /products` - List a new agricultural product (*requires Farmer role*)
- `PUT /products/{id}` - Modify quantity, price, or description (*Farmer owner only*)
- `DELETE /products/{id}` - Remove produce listing (*Farmer owner only*)

### Orders
- `POST /orders` - Place direct farm purchase (*requires Buyer role*)
- `GET /orders` - View orders (Farmers see incoming sales, Buyers see purchases; supports `?status=PENDING`, etc.)
- `GET /orders/{id}` - Order invoice details
- `PUT /orders/{id}/status` - Advance lifecycle state (`CONFIRMED`, `DELIVERED`, `CANCELLED`)

### Direct Chat & Messaging
- `POST /messages` - Send direct negotiation message to counterpart
- `GET /messages/{user_id}` - Retrieve message history with user & auto-mark as read
- `GET /messages/conversations` - List active conversations with unread badges

### Media Upload
- `POST /upload/image` - Multipart image upload for product photos and user avatars

---

## ☁️ Production Deployment

### Docker & Docker-Compose
To launch the full stack with PostgreSQL and FastAPI in isolated containers:

```bash
cd backend
docker-compose up --build -d
```

### Deploying to Cloud (Render / Railway / AWS ECS)
1. **Database**: Provision a managed PostgreSQL instance (e.g. Supabase, AWS RDS, Neon, or Render PostgreSQL).
2. **Environment Variables**: Set the following in your cloud provider's dashboard:
   ```env
   DATABASE_URL=postgresql://<user>:<password>@<host>:5432/<dbname>
   SECRET_KEY=<generate-a-secure-random-key>
   ENVIRONMENT=production
   ```
3. **Container Build**: Use the provided `backend/Dockerfile` to build and deploy the container.

---

## 📄 License
This project is open-source under the MIT License.
