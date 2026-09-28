from fastapi.testclient import TestClient
from app.core.config import settings
settings.LLM_PROVIDER = "mock"

from app.main import app

client = TestClient(app)

def run_rate_limiter_verification():
    print("\n🧪 Running Guest Rate Limiter Verification Test...\n" + "=" * 55)

    print(f"📊 Current Guest Rate Limit Setting: {settings.GUEST_DAILY_LIMIT}/day")

    # Send requests up to limit
    for i in range(1, settings.GUEST_DAILY_LIMIT + 1):
        response = client.post(
            "/api/v1/reframe",
            json={"input_text": f"Test prompt number {i}"}
        )
        print(f"   Request {i}: HTTP Status {response.status_code}")
        assert response.status_code == 200

    print("\n⚠️ Sending Request Exceeding Limit...")
    response_exceeded = client.post(
        "/api/v1/reframe",
        json={"input_text": "Excess prompt beyond limit"}
    )

    print(f"   Request Exceeded Status: HTTP {response_exceeded.status_code}")
    print(f"   Response Payload: {response_exceeded.text}")

    assert response_exceeded.status_code == 429
    print("   ✅ Guest Request 6 Blocked as expected! HTTP 429 Too Many Requests")

    print("\n🔓 Testing Authenticated Request from same IP (Exemption Check)...")
    response_auth = client.post(
        "/api/v1/reframe",
        json={"input_text": "Authenticated prompt should bypass guest limit"},
        headers={"Authorization": "Bearer dev_mock_jwt_token"}
    )
    print(f"   Authenticated Request Status: HTTP {response_auth.status_code}")
    assert response_auth.status_code == 200
    print("   ✅ Authenticated User Successfully Exempted from Guest Limit! HTTP 200 OK")

    print("\n" + "=" * 55 + "\n🎉 RATE LIMITER & AUTH EXEMPTION TEST PASSED 100%!\n")

if __name__ == "__main__":
    run_rate_limiter_verification()
