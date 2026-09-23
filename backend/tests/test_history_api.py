import jwt
from fastapi.testclient import TestClient
from sqlmodel import Session
from app.main import app
from app.core.config import settings
from app.core.database import engine
from app.models.db_models import User, ReframeRecord

client = TestClient(app)

def run_history_api_tests():
    print("\n🧪 Running Cloud History API Verification Test...\n" + "=" * 55)

    test_user_id = "usr_history_test_123"

    # Pre-create test user and 2 test reframing records in PostgreSQL
    with Session(engine) as db:
        user = db.get(User, test_user_id)
        if not user:
            db.add(User(id=test_user_id, email="history_test@example.com", auth_provider="supabase"))
            db.commit()

        # Add 2 test records for this user
        rec1 = ReframeRecord(user_id=test_user_id, prompt_text="Test prompt 1", reframed_text="Reframed perspective 1")
        rec2 = ReframeRecord(user_id=test_user_id, prompt_text="Test prompt 2", reframed_text="Reframed perspective 2")
        db.add(rec1)
        db.add(rec2)
        db.commit()

    # -------------------------------------------------------------
    # 🛡️ TEST 1: Unauthenticated GET /api/v1/history (No Token)
    # -------------------------------------------------------------
    print("\n1️⃣ Testing Unauthenticated GET /api/v1/history (No Token)...")
    response_no_token = client.get("/api/v1/history")
    assert response_no_token.status_code == 401, f"Expected 401, got {response_no_token.status_code}"
    print("   ✅ Unauthenticated Access Blocked! HTTP 401 Unauthorized")

    # -------------------------------------------------------------
    # 🔓 TEST 2: Authenticated GET /api/v1/history (Valid Token)
    # -------------------------------------------------------------
    print("\n2️⃣ Testing Authenticated GET /api/v1/history (Valid JWT Token)...")
    test_token = jwt.encode(
        {"sub": test_user_id, "email": "history_test@example.com"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )

    response_auth = client.get(
        "/api/v1/history",
        headers={"Authorization": f"Bearer {test_token}"}
    )

    assert response_auth.status_code == 200, f"Expected 200, got {response_auth.status_code}"
    records = response_auth.json()
    assert isinstance(records, list)
    assert len(records) >= 2
    print(f"   ✅ Authenticated History Request Succeeded! Retrieved {len(records)} records from PostgreSQL for user '{test_user_id}'.")
    print(f"   Latest Record Prompt: '{records[0]['prompt_text']}'")

    print("\n" + "=" * 55 + "\n🎉 CLOUD HISTORY API TEST PASSED 100%!\n")

if __name__ == "__main__":
    run_history_api_tests()
