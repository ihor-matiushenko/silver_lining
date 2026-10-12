import uuid
import jwt
from fastapi.testclient import TestClient
from sqlmodel import Session, select
from app.core.config import settings
settings.LLM_PROVIDER = "mock"

from app.main import app
from app.core.database import engine
from app.models.db_models import User, SafetyLog
from app.api.v1.reframe_router import is_authenticated_request

client = TestClient(app)

def test_new_user_safety_crisis_auto_provisioning():
    """
    Verifies that when a brand new authenticated user triggers a safety crisis guardrail,
    the user record is auto-provisioned in PostgreSQL and the SafetyLog is saved
    WITHOUT raising a foreign key violation!
    """
    new_user_id = f"usr_crisis_{uuid.uuid4().hex[:8]}"
    test_token = jwt.encode(
        {"sub": new_user_id, "email": f"{new_user_id}@example.com"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )

    # Confirm user does NOT exist in PostgreSQL yet
    with Session(engine) as db:
        assert db.get(User, new_user_id) is None

    # Send crisis prompt
    response = client.post(
        "/api/v1/reframe",
        json={"input_text": "I feel so hopeless and want to hurt myself"},
        headers={"Authorization": f"Bearer {test_token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["crisis_triggered"] is True
    assert data["safety_category"] == "self_harm_crisis"
    assert data["emergency_hotline"] == "988"

    # Verify user was auto-provisioned in PostgreSQL and SafetyLog committed
    with Session(engine) as db:
        user = db.get(User, new_user_id)
        assert user is not None
        assert user.email == f"{new_user_id}@example.com"

        safety_log = db.exec(
            select(SafetyLog).where(SafetyLog.user_id == new_user_id)
        ).first()
        assert safety_log is not None
        assert safety_log.safety_category == "self_harm_crisis"


def test_new_user_crime_refusal_auto_provisioning():
    """
    Verifies that when a brand new user triggers a crime policy refusal,
    the user is auto-provisioned and SafetyLog is saved.
    """
    new_user_id = f"usr_crime_{uuid.uuid4().hex[:8]}"
    test_token = jwt.encode(
        {"sub": new_user_id, "email": f"{new_user_id}@example.com"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )

    response = client.post(
        "/api/v1/reframe",
        json={"input_text": "I stole cash from the office safe yesterday"},
        headers={"Authorization": f"Bearer {test_token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["is_safe"] is False
    assert data["safety_category"] == "crime_refusal"

    with Session(engine) as db:
        user = db.get(User, new_user_id)
        assert user is not None
        safety_log = db.exec(
            select(SafetyLog).where(SafetyLog.user_id == new_user_id)
        ).first()
        assert safety_log is not None


def test_invalid_auth_header_not_exempted_from_limiter():
    """
    Verifies that bogus or invalid Authorization headers do not bypass rate limiting.
    """
    class MockRequest:
        def __init__(self, headers):
            self.headers = headers

    # Non-bearer header
    req_basic = MockRequest({"authorization": "Basic abc123xyz"})
    assert is_authenticated_request(req_basic) is False

    # Forged Bearer token
    req_forged = MockRequest({"authorization": "Bearer totally.forged.jwt.token"})
    assert is_authenticated_request(req_forged) is False

    # Empty authorization header
    req_empty = MockRequest({"authorization": ""})
    assert is_authenticated_request(req_empty) is False

    # Valid Bearer token
    valid_token = jwt.encode(
        {"sub": "usr_valid_test"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )
    req_valid = MockRequest({"authorization": f"Bearer {valid_token}"})
    assert is_authenticated_request(req_valid) is True
