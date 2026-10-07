"""
🌱 Reviewer Demo Account Provisioning Script (App Store Guideline 2.1)
Pre-seeds the official App Store and Google Play Reviewer demo account ('demo@silverlining.app')
in PostgreSQL with realistic reflection history and favorites so the review team can immediately
test cloud sync, favorites, and history operations upon first login.
"""

from sqlmodel import Session, select
from datetime import datetime, timezone, timedelta
from app.core.database import engine, init_db
from app.models.db_models import User, ReframeRecord

REVIEWER_EMAIL = "demo@silverlining.app"
REVIEWER_USER_ID = "usr_demo_reviewer_01"

SAMPLE_REFRAMINGS = [
    {
        "id": "ref_demo_01",
        "prompt": "I received critical feedback on my presentation today and felt completely overwhelmed.",
        "reframed": "Receiving detailed critique is a sign that colleagues are deeply engaged with your work. Constructive feedback gives you an exact roadmap to elevate your impact and sharpen your professional presentation skills.",
        "is_favorite": True,
        "category": "none",
        "days_ago": 3,
    },
    {
        "id": "ref_demo_02",
        "prompt": "I have too many deadlines this week and I feel like I'm falling behind everyone else.",
        "reframed": "A heavy workload often reflects that people trust your capability. By stepping back to tackle just one priority at a time, you transform chaos into focused momentum while remembering that everyone moves at their own pace.",
        "is_favorite": False,
        "category": "none",
        "days_ago": 2,
    },
    {
        "id": "ref_demo_03",
        "prompt": "My flight was delayed by four hours and my travel plans for the weekend are disrupted.",
        "reframed": "An unexpected travel delay gives you an impromptu pocket of stillness. You now have guilt-free time to read, listen to your favorite music, or relax without the pressure of an immediate schedule.",
        "is_favorite": True,
        "category": "none",
        "days_ago": 1,
    },
    {
        "id": "ref_demo_04",
        "prompt": "I made a careless mistake on a client email and feel terrible about it.",
        "reframed": "A quick, transparent correction builds greater long-term trust than pretend perfection. Acknowledging mistakes with grace demonstrates integrity and calm composure under pressure.",
        "is_favorite": False,
        "category": "none",
        "days_ago": 0,
    },
]

def seed_reviewer_account():
    init_db()
    with Session(engine) as db:
        print(f"🔍 Checking for reviewer user: {REVIEWER_EMAIL}...")
        user = db.exec(select(User).where(User.email == REVIEWER_EMAIL)).first()

        if not user:
            print("👤 Creating demo reviewer user record...")
            user = User(
                id=REVIEWER_USER_ID,
                email=REVIEWER_EMAIL,
                auth_provider="email",
            )
            db.add(user)
            db.commit()
            db.refresh(user)
            print(f"✅ User created! ID: {user.id}")
        else:
            print(f"ℹ️ User already exists with ID: {user.id}")

        # Seed sample reflections
        added_count = 0
        for item in SAMPLE_REFRAMINGS:
            existing_ref = db.get(ReframeRecord, item["id"])
            if not existing_ref:
                created_time = datetime.now(timezone.utc) - timedelta(days=item["days_ago"])
                record = ReframeRecord(
                    id=item["id"],
                    user_id=user.id,
                    prompt_text=item["prompt"],
                    reframed_text=item["reframed"],
                    language="en",
                    is_safe=True,
                    safety_category=item["category"],
                    is_favorite=item["is_favorite"],
                    created_at=created_time,
                )
                db.add(record)
                added_count += 1

        db.commit()
        print(f"✨ Seeded {added_count} sample reflections for {REVIEWER_EMAIL}!")

        # Print App Store Reviewer Submission Credentials
        print("\n" + "=" * 60)
        print("📱 APP STORE & GOOGLE PLAY REVIEWER CREDENTIALS")
        print("=" * 60)
        print(f"• Email:    {REVIEWER_EMAIL}")
        print("• Method:   Supabase Magic Link / OTP / Password Login")
        print("• User ID:  usr_demo_reviewer_01")
        print("• Purpose:  Demonstrates authenticated cloud sync & favorites")
        print("=" * 60 + "\n")

if __name__ == "__main__":
    seed_reviewer_account()
