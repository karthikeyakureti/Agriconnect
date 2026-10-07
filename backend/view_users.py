"""
AgriConnect User Viewer
Run: python view_users.py
"""
import sys
from app.database import SessionLocal
from app.models.user import User

def show_users():
    db = SessionLocal()
    try:
        users = db.query(User).all()
        print("\n" + "=" * 85)
        print("AGRICONNECT REGISTERED USERS")
        print("=" * 85)
        if not users:
            print("No users found in database.")
        else:
            header = f"{'ID':<4} | {'ROLE':<8} | {'NAME':<20} | {'EMAIL':<26} | {'LOCATION'}"
            print(header)
            print("-" * 85)
            for u in users:
                loc = u.location or 'N/A'
                print(f"{u.id:<4} | {u.role.value:<8} | {u.name:<20} | {u.email:<26} | {loc}")
        print("=" * 85 + "\n")
    finally:
        db.close()

if __name__ == "__main__":
    show_users()
