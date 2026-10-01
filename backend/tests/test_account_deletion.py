import os
import jwt
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.core.config import settings
settings.LLM_PROVIDER = "mock"

from app.main import app
from app.core.database import engine, init_db
from app.models.db_models import User, ReframeRecord, SafetyLog, ReportRecord


client = TestClient(app)

def generate_test_token(user_id: str, email: str) -> str:
    payload = {
        "sub": user_id,
        "email": email,
        "role": "authenticated"
    }
    return jwt.encode(payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")

def test_account_deletion_flow():
    init_db()
    print("\n🧪 Running Store Compliance Test: In-App Account Deletion Flow...")
    print("=" * 65)

    import time
    ts = int(time.time())
    test_user_id = f"usr_deletion_test_{ts}"
    test_email = f"delete_{ts}@example.com"
    token = generate_test_token(user_id=test_user_id, email=test_email)

    with Session(engine) as db:
        # Pre-seed user first to satisfy foreign key constraint
        user = User(id=test_user_id, email=test_email)
        db.add(user)
        db.commit()

        # Add child records
        db.add(ReframeRecord(user_id=test_user_id, prompt_text="Stressful work issue", reframed_text="A growth opportunity"))
        db.add(ReframeRecord(user_id=test_user_id, prompt_text="Another problem", reframed_text="Reframed perspective"))
        db.add(SafetyLog(user_id=test_user_id, safety_category="crime", flagged_text="Flagged input text"))
        db.add(ReportRecord(user_id=test_user_id, content_snippet="Snippet text", reason="inaccurate"))
        db.commit()

    # 1. Test unauthenticated request blocked
    print("\n1️⃣ Testing unauthenticated DELETE /api/v1/auth/delete-account...")
    unauth_resp = client.delete("/api/v1/auth/delete-account")
    assert unauth_resp.status_code == 401
    print("   ✅ Unauthenticated request correctly rejected with HTTP 401 Unauthorized")

    # 2. Test authenticated account deletion
    print("\n2️⃣ Testing authenticated DELETE /api/v1/auth/delete-account...")
    resp = client.delete(
        "/api/v1/auth/delete-account",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 200, f"Expected 200, got {resp.status_code}: {resp.text}"
    data = resp.json()
    assert data["user_id"] == test_user_id
    assert data["deleted_records_count"] == 2
    print(f"   ✅ Account deletion response received: {data['detail']}")
    print(f"   ✅ Purged records count: {data['deleted_records_count']}")

    # 3. Verify in PostgreSQL that all records for this user were wiped
    print("\n3️⃣ Verifying PostgreSQL database cascading deletion...")
    with Session(engine) as db:
        remaining_user = db.get(User, test_user_id)
        assert remaining_user is None, "User entity was not deleted!"

        remaining_records = db.exec(select(ReframeRecord).where(ReframeRecord.user_id == test_user_id)).all()
        assert len(remaining_records) == 0, "ReframeRecords were not purged!"

        remaining_safety = db.exec(select(SafetyLog).where(SafetyLog.user_id == test_user_id)).all()
        assert len(remaining_safety) == 0, "SafetyLogs were not purged!"

        remaining_reports = db.exec(select(ReportRecord).where(ReportRecord.user_id == test_user_id)).all()
        assert len(remaining_reports) == 0, "ReportRecords were not purged!"

    print("   ✅ Verified 100% complete data wipe in PostgreSQL DB (0 orphaned rows)!")
    print("=" * 65)
    print("🎉 IN-APP ACCOUNT DELETION TEST PASSED 100%!\n")

if __name__ == "__main__":
    test_account_deletion_flow()
