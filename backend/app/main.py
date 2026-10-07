import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.database import engine, Base
import app.models # Ensure all models are registered with Base
from app.routers import auth, users, products, orders, messages, upload, admin

# Create tables automatically
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="AgriConnect API",
    description="Empowering Farmers | Connecting Buyers | Building a Fairer Future",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS Middleware for mobile apps & web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure uploads directory exists and mount static files
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# Include Routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(products.router)
app.include_router(orders.router)
app.include_router(messages.router)
app.include_router(upload.router)
app.include_router(admin.router)

@app.get("/", tags=["Health"])
def root():
    return {
        "app": "AgriConnect API",
        "version": "1.0.0",
        "status": "online",
        "motto": "Empowering Farmers | Connecting Buyers | Building a Fairer Future",
        "docs": "/docs"
    }

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy"}
