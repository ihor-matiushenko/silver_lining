from fastapi.testclient import TestClient
from sqlmodel import Session, select
import jwt

from app.core.config import settings
settings.LLM_PROVIDER = "mock"

from app.main import app
from app.core.database import engine
from app.models.db_models import ReportRecord

client = TestClient(app)

def generate_test_token(user_id: str, email: str) -> str:
    payload = {
        "sub": user_id,
        "email": email,
        "role": "authenticated"
    }
    return jwt.encode(payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")

def test_genai_content_reporting():
    print("\n🧪 Running Store Compliance Test: GenAI Content Reporting (Apple 1.2 & Google GenAI)...")
    print("=" * 65)

    # 1. Test guest user reporting objectionable AI content
    print("\n1️⃣ Testing Guest User POST /api/v1/reports...")
    guest_report = {
        "content_snippet": "This reframing was offensive and made me uncomfortable.",
        "reason": "offensive",
        "details": "The AI response contained inappropriate assumptions."
    }
    resp = client.post("/api/v1/reports", json=guest_report)
    assert resp.status_code == 200, f"Expected 200, got {resp.status_code}: {resp.text}"
    data = resp.json()
    assert data["status"] == "received"
    assert "id" in data
    guest_report_id = data["id"]
    print(f"   ✅ Guest Report successfully submitted! Report ID: {guest_report_id}")

    # 2. Test authenticated user reporting content with reframe_id
    print("\n2️⃣ Testing Authenticated User POST /api/v1/reports...")
    user_id = "usr_reporter_777"
    token = generate_test_token(user_id=user_id, email="reporter@example.com")
    auth_report = {
        "content_snippet": "Harmful advice received from AI engine.",
        "reason": "harmful",
        "details": "Response seemed to minimize danger.",
        "reframe_id": "rec_12345"
    }
    auth_resp = client.post(
        "/api/v1/reports",
        json=auth_report,
        headers={"Authorization": f"Bearer {token}"}
    )
    assert auth_resp.status_code == 200, f"Expected 200, got {auth_resp.status_code}: {auth_resp.text}"
    auth_data = auth_resp.json()
    auth_report_id = auth_data["id"]
    print(f"   ✅ Authenticated Report submitted! Report ID: {auth_report_id}")

    # 3. Verify in PostgreSQL DB
    print("\n3️⃣ Verifying Report Records in PostgreSQL Database...")
    with Session(engine) as db:
        guest_rec = db.get(ReportRecord, guest_report_id)
        assert guest_rec is not None
        assert guest_rec.user_id is None
        assert guest_rec.reason == "offensive"

        auth_rec = db.get(ReportRecord, auth_report_id)
        assert auth_rec is not None
        assert auth_rec.user_id == user_id
        assert auth_rec.reason == "harmful"
        assert auth_rec.reframe_id == "rec_12345"

    print("   ✅ Verified persistence of reports in PostgreSQL with full audit trail!")
    print("=" * 65)
    print("🎉 GENAI CONTENT REPORTING TEST PASSED 100%!\n")

if __name__ == "__main__":
    test_genai_content_reporting()
