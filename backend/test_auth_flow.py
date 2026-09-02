import jwt
from fastapi.testclient import TestClient
from sqlmodel import Session, select
from app.main import app
from app.core.config import settings
from app.core.database import engine
from app.models.db_models import User, ReframeRecord

client = TestClient(app)

def run_auth_verification_tests():
    print("\n🧪 Running Option A: Auth & JWT Verification Tests...\n" + "=" * 55)

    test_user_id = "usr_9999_test"

    # Pre-create test user in PostgreSQL to satisfy Foreign Key constraint
    with Session(engine) as db:
        existing_user = db.get(User, test_user_id)
        if not existing_user:
            db.add(User(id=test_user_id, email="ihor@example.com", auth_provider="supabase"))
            db.commit()

    # -------------------------------------------------------------
    # 🆓 TEST 1: Guest Mode Request (No Authorization Header)
    # -------------------------------------------------------------
    print("\n1️⃣ Testing Guest Request (No Authorization Header)...")
    response_guest = client.post(
        "/api/v1/reframe",
        json={"input_text": "I feel overwhelmed with work deadlines"}
    )

    assert response_guest.status_code == 200, f"Expected 200, got {response_guest.status_code}"
    data_guest = response_guest.json()
    assert data_guest["is_safe"] is True
    print("   ✅ Guest Request Succeeded! HTTP 200 OK")

    # -------------------------------------------------------------
    # 🔓 TEST 2: Authenticated Request (Valid JWT Token)
    # -------------------------------------------------------------
    print("\n2️⃣ Testing Authenticated Request (Valid JWT Token)...")
    test_token = jwt.encode(
        {"sub": test_user_id, "email": "ihor@example.com"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )

    response_auth = client.post(
        "/api/v1/reframe",
        json={"input_text": "Failed my driving test today"},
        headers={"Authorization": f"Bearer {test_token}"}
    )

    assert response_auth.status_code == 200, f"Expected 200, got {response_auth.status_code}"
    data_auth = response_auth.json()
    assert data_auth["is_safe"] is True
    print(f"   ✅ Authenticated Request Succeeded! User ID: {test_user_id}")

    # -------------------------------------------------------------
    # 🛡️ TEST 3: Invalid Request (Forged JWT Token)
    # -------------------------------------------------------------
    print("\n3️⃣ Testing Invalid Request (Forged / Corrupted JWT Token)...")
    forged_token = "invalid.forged.jwt.token.string"

    response_forged = client.post(
        "/api/v1/reframe",
        json={"input_text": "Some text"},
        headers={"Authorization": f"Bearer {forged_token}"}
    )

    assert response_forged.status_code == 401, f"Expected 401, got {response_forged.status_code}"
    print("   ✅ Forged Token Blocked! HTTP 401 Unauthorized ('Invalid or expired authentication token')")

    # -------------------------------------------------------------
    # 🐘 TEST 4: PostgreSQL Database Record Verification
    # -------------------------------------------------------------
    print("\n4️⃣ Querying PostgreSQL Database Records...")
    with Session(engine) as db:
        guest_record = db.exec(
            select(ReframeRecord).where(ReframeRecord.prompt_text == "I feel overwhelmed with work deadlines")
        ).first()

        auth_record = db.exec(
            select(ReframeRecord).where(ReframeRecord.prompt_text == "Failed my driving test today")
        ).first()

        assert guest_record is not None
        assert guest_record.user_id is None, f"Expected guest user_id to be None, got {guest_record.user_id}"
        print("   ✅ Guest Record Verified in PostgreSQL! user_id = None")

        assert auth_record is not None
        assert auth_record.user_id == test_user_id, f"Expected user_id {test_user_id}, got {auth_record.user_id}"
        print(f"   ✅ Authenticated Record Verified in PostgreSQL! user_id = '{test_user_id}'")

    print("\n" + "=" * 55 + "\n🎉 ALL 4 AUTHENTICATION & SECURITY TESTS PASSED 100%!\n")

if __name__ == "__main__":
    run_auth_verification_tests()
