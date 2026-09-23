import jwt
from fastapi.testclient import TestClient
from sqlmodel import Session
from app.main import app
from app.core.config import settings
from app.core.database import engine
from app.models.db_models import User, ReframeRecord

client = TestClient(app)

def run_favorites_and_delete_tests():
    print("\n🧪 Running Favorites & Delete API Verification Test...\n" + "=" * 55)

    user1_id = "usr_fav_owner_1"
    user2_id = "usr_fav_hacker_2"

    # Pre-create test users and 1 test reframing record in PostgreSQL
    with Session(engine) as db:
        u1 = db.get(User, user1_id)
        if not u1:
            db.add(User(id=user1_id, email="owner@example.com", auth_provider="supabase"))
        u2 = db.get(User, user2_id)
        if not u2:
            db.add(User(id=user2_id, email="hacker@example.com", auth_provider="supabase"))
        db.commit()

        # Add 1 test record owned by user1
        rec = ReframeRecord(user_id=user1_id, prompt_text="Test prompt for favorite", reframed_text="Reframed test", is_favorite=False)
        db.add(rec)
        db.commit()
        db.refresh(rec)
        record_id = rec.id

    token_user1 = jwt.encode({"sub": user1_id}, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
    token_user2 = jwt.encode({"sub": user2_id}, settings.SUPABASE_JWT_SECRET, algorithm="HS256")

    # -------------------------------------------------------------
    # ❤️ TEST 1: Toggle Favorite (Owner Request)
    # -------------------------------------------------------------
    print("\n1️⃣ Testing POST /api/v1/history/{id}/favorite (Toggle Favorite)...")
    response_fav = client.post(
        f"/api/v1/history/{record_id}/favorite",
        headers={"Authorization": f"Bearer {token_user1}"}
    )
    assert response_fav.status_code == 200
    data_fav = response_fav.json()
    assert data_fav["is_favorite"] is True
    print(f"   ✅ Favorite Toggled to TRUE! is_favorite = {data_fav['is_favorite']}")

    # Toggle back to False
    response_unfav = client.post(
        f"/api/v1/history/{record_id}/favorite",
        headers={"Authorization": f"Bearer {token_user1}"}
    )
    assert response_unfav.status_code == 200
    assert response_unfav.json()["is_favorite"] is False
    print("   ✅ Favorite Toggled back to FALSE!")

    # -------------------------------------------------------------
    # 🛡️ TEST 2: Security Check (Attempting to modify someone else's record)
    # -------------------------------------------------------------
    print("\n2️⃣ Testing Security Check (User 2 trying to modify User 1's record)...")
    response_hack = client.post(
        f"/api/v1/history/{record_id}/favorite",
        headers={"Authorization": f"Bearer {token_user2}"}
    )
    assert response_hack.status_code == 403
    print("   ✅ Unauthorized Modification Blocked! HTTP 403 Forbidden ('You do not own this record')")

    # -------------------------------------------------------------
    # 🗑️ TEST 3: Delete Record (Owner Request)
    # -------------------------------------------------------------
    print("\n3️⃣ Testing DELETE /api/v1/history/{id} (Delete Record)...")
    response_delete = client.delete(
        f"/api/v1/history/{record_id}",
        headers={"Authorization": f"Bearer {token_user1}"}
    )
    assert response_delete.status_code == 200
    print(f"   ✅ Record Deleted! Status: HTTP 200 OK")

    # Verify deletion in PostgreSQL DB
    with Session(engine) as db:
        deleted_record = db.get(ReframeRecord, record_id)
        assert deleted_record is None
        print("   ✅ Record Deletion Verified in PostgreSQL DB!")

    print("\n" + "=" * 55 + "\n🎉 FAVORITES & DELETE API TEST PASSED 100%!\n")

if __name__ == "__main__":
    run_favorites_and_delete_tests()
