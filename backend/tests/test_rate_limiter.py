from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings

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
    print("\n" + "=" * 55 + "\n🎉 RATE LIMITER TEST PASSED 100%! HTTP 429 TOO MANY REQUESTS VERIFIED!\n")

if __name__ == "__main__":
    run_rate_limiter_verification()
