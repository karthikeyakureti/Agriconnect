import os
import shutil
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Default to SQLite for local development or PostgreSQL if DATABASE_URL is set
BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DB_PATH = os.path.join(BACKEND_DIR, "agriconnect.db").replace("\\", "/")

# On serverless platforms like Vercel, the deployment folder is read-only.
# If no external DATABASE_URL is configured, copy SQLite to /tmp so writes succeed.
if os.getenv("VERCEL") and not os.getenv("DATABASE_URL"):
    TMP_DB_PATH = "/tmp/agriconnect.db"
    if not os.path.exists(TMP_DB_PATH) and os.path.exists(SOURCE_DB_PATH):
        try:
            shutil.copy2(SOURCE_DB_PATH, TMP_DB_PATH)
        except Exception:
            pass
    DEFAULT_DB_PATH = TMP_DB_PATH
else:
    DEFAULT_DB_PATH = SOURCE_DB_PATH

DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{DEFAULT_DB_PATH}")

# Fix postgres:// URL scheme from hosted providers (Neon, Supabase, Render, Railway) for SQLAlchemy
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

connect_args = {}
if DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
