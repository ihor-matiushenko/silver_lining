import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, select
from app.main import app
from app.core.database import engine
from app.models.db_models import User, ReframeRecord, SafetyLog, ReportRecord

client = TestClient(app)

def test_root_discovery_endpoints():
    """Verify GET / returns documentation and public policy endpoints"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["health"] == "/health"
    assert data["privacy_policy"] == "/privacy"
    assert data["terms_of_service"] == "/terms"
    assert data["delete_account"] == "/delete-account"

def test_health_check_endpoint():
    """Verify standard cloud container liveness/readiness probe on GET /health"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "Silver Lining AI Backend"


def test_privacy_policy_page():
    """Verify GET /privacy returns HTML complying with Apple 5.1.1 & Google Play"""
    response = client.get("/privacy")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    html = response.text
    assert "Privacy Policy" in html
    assert "Guideline 5.1.1" in html
    assert "Google Play" in html
    assert "Guest Users (Local Only, 0 Cloud Storage)" in html
    assert "https://supabase.com/privacy" in html
    assert "https://www.apple.com/legal/privacy/" in html

def test_terms_of_service_page():
    """Verify GET /terms returns HTML incorporating Apple Standard EULA and wellness disclaimer"""
    response = client.get("/terms")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    html = response.text
    assert "Terms of Service & EULA" in html
    assert "Medical &amp; Wellness Disclaimer" in html or "Medical & Wellness Disclaimer" in html
    assert "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/" in html
    assert "Apple Guideline 1.2" in html
    assert "988" in html

def test_delete_account_page_localization():
    """Verify GET /delete-account renders English, Ukrainian via query param, and Spanish via header"""
    # 1. English default
    res_en = client.get("/delete-account")
    assert res_en.status_code == 200
    assert "Account &amp; Data Deletion" in res_en.text or "Account & Data Deletion" in res_en.text
    assert "Permanently Delete My Account &amp; Data" in res_en.text or "Permanently Delete My Account & Data" in res_en.text

    # 2. Ukrainian via ?lang=uk
    res_uk = client.get("/delete-account?lang=uk")
    assert res_uk.status_code == 200
    assert "Видалення Акаунту та Даних" in res_uk.text
    assert "Назавжди видалити мій акаунт і дані" in res_uk.text

    # 3. Spanish via Accept-Language header
    res_es = client.get("/delete-account", headers={"Accept-Language": "es-ES,es;q=0.9"})
    assert res_es.status_code == 200
    assert "Eliminación de Cuenta y Datos" in res_es.text
    assert "Eliminar permanentemente mi cuenta y datos" in res_es.text

def test_request_web_account_deletion_flow():
    """
    Verify POST /api/v1/auth/request-web-deletion cascades deletion
    when account exists, and handles non-existent users gracefully.
    """
    import time
    ts = int(time.time())
    test_email = f"web_delete_{ts}@example.com"
    user_id = f"usr_web_delete_{ts}"

    with Session(engine) as db:
        # Pre-seed user first to satisfy foreign key constraint
        user = User(id=user_id, email=test_email, auth_provider="email")
        db.add(user)
        db.commit()

        # Seed ReframeRecord + SafetyLog + ReportRecord
        db.add(ReframeRecord(id=f"ref_web_1_{ts}", user_id=user_id, prompt_text="Test prompt 1"))
        db.add(ReframeRecord(id=f"ref_web_2_{ts}", user_id=user_id, prompt_text="Test prompt 2"))
        db.add(SafetyLog(id=f"saf_web_1_{ts}", user_id=user_id, safety_category="test", flagged_text="Flagged"))
        db.add(ReportRecord(id=f"rep_web_1_{ts}", user_id=user_id, content_snippet="Snippet", reason="harmful"))
        db.commit()


    # 1. Trigger Web Deletion
    payload = {"email": test_email, "reason": "privacy"}
    response = client.post("/api/v1/auth/request-web-deletion", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "completed"
    assert data["account_found"] is True
    assert "2 synced reflections have been permanently erased" in data["message"]

    # 2. Verify all records purged in DB
    with Session(engine) as db:
        assert db.get(User, user_id) is None
        recs = db.exec(select(ReframeRecord).where(ReframeRecord.user_id == user_id)).all()
        assert len(recs) == 0
        logs = db.exec(select(SafetyLog).where(SafetyLog.user_id == user_id)).all()
        assert len(logs) == 0
        reps = db.exec(select(ReportRecord).where(ReportRecord.user_id == user_id)).all()
        assert len(reps) == 0

    # 3. Trigger Web Deletion for non-existent / guest email
    response_guest = client.post("/api/v1/auth/request-web-deletion", json={"email": "guest_nobody@example.com"})
    assert response_guest.status_code == 200
    guest_data = response_guest.json()
    assert guest_data["status"] == "completed"
    assert guest_data["account_found"] is False
    assert "Guest users store 0 data" in guest_data["message"]
