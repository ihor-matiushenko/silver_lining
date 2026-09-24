import os
import sys
import jwt
from fastapi.testclient import TestClient
from sqlmodel import Session, select

# Add backend directory to PYTHONPATH
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.core.config import settings
settings.LLM_PROVIDER = "mock"

from app.main import app
from app.core.database import engine, init_db
from app.models.db_models import User, ReframeRecord

client = TestClient(app)

def run_multi_lang_tests():
    print("\n🧪 Running Instant Multi-Language API & Database Verification Test (MOCK LLM)...")
    print("=======================================================")

    init_db()

    test_user_id = "usr_multilang_test"

    # Pre-create test user in PostgreSQL
    with Session(engine) as db:
        existing_user = db.get(User, test_user_id)
        if not existing_user:
            db.add(User(id=test_user_id, email="multilang@example.com", auth_provider="supabase"))
            db.commit()

    token = jwt.encode(
        {"sub": test_user_id, "email": "multilang@example.com"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Test Auto-Detect (Default)
    print("\n1️⃣ Testing POST /api/v1/reframe with target_language='auto'...")
    payload_auto = {
        "input_text": "Я почуваюся виснаженим сьогодні.",
        "target_language": "auto"
    }

    resp1 = client.post("/api/v1/reframe", json=payload_auto, headers=headers)
    assert resp1.status_code == 200, f"Expected 200, got {resp1.status_code}: {resp1.text}"
    data1 = resp1.json()
    assert data1["is_safe"] is True
    assert data1["language"] == "auto"
    print(f"   ✅ Instant auto-detect request succeeded! Returned language: '{data1['language']}'")

    # 2. Test Explicit Target Language ("uk")
    print("\n2️⃣ Testing POST /api/v1/reframe with explicit target_language='uk'...")
    payload_uk = {
        "input_text": "I feel stressed about my exams.",
        "target_language": "uk"
    }

    resp2 = client.post("/api/v1/reframe", json=payload_uk, headers=headers)
    assert resp2.status_code == 200, f"Expected 200, got {resp2.status_code}: {resp2.text}"
    data2 = resp2.json()
    assert data2["is_safe"] is True
    assert data2["language"] == "uk"
    assert "Кожен виклик" in data2["reframed_text"]
    print(f"   ✅ Instant 'uk' request succeeded! Reframed text: '{data2['reframed_text']}'")

    # 3. Verify PostgreSQL Database Records
    print("\n3️⃣ Verifying language column in PostgreSQL database...")
    with Session(engine) as db:
        statement = select(ReframeRecord).where(ReframeRecord.user_id == "usr_multilang_test")
        records = db.exec(statement).all()
        assert len(records) >= 2
        langs = [r.language for r in records]
        assert "auto" in langs
        assert "uk" in langs
    # 4. Verify Dynamic UI Localization Endpoint
    print("\n4️⃣ Testing GET /api/v1/l10n/{lang_code} dynamic endpoint...")
    resp_l10n_uk = client.get("/api/v1/l10n/uk")
    assert resp_l10n_uk.status_code == 200
    strings_uk = resp_l10n_uk.json()["strings"]
    assert strings_uk["appTitle"] == "Світла Сторона"
    print("   ✅ Ukrainian UI strings endpoint verified!")

    resp_l10n_fallback = client.get("/api/v1/l10n/unknown_lang")
    assert resp_l10n_fallback.status_code == 200
    strings_fallback = resp_l10n_fallback.json()["strings"]
    assert strings_fallback["appTitle"] == "Silver Lining"
    print("   ✅ Unknown language English ('en') fallback verified!")

    print("\n=======================================================")
    print("🎉 INSTANT MULTI-LANGUAGE BACKEND TESTS PASSED 100%! (0% CPU LOAD)")

if __name__ == "__main__":
    run_multi_lang_tests()
