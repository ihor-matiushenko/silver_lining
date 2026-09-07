from typing import List
from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select, desc

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.db_models import ReframeRecord

history_router = APIRouter(prefix="/history", tags=["Cloud History"])

@history_router.get("", response_model=List[ReframeRecord])
async def get_user_history(
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """
    Cloud History Endpoint:
    Fetches all saved reframing records for the authenticated user from PostgreSQL.
    Requires a valid JWT token.
    """
    user_id = user["sub"]
    statement = (
        select(ReframeRecord)
        .where(ReframeRecord.user_id == user_id)
        .order_by(desc(ReframeRecord.created_at))
    )
    records = db.exec(statement).all()
    return records

@history_router.post("/{record_id}/favorite", response_model=ReframeRecord)
async def toggle_favorite(
    record_id: str,
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """
    Toggle Heart Favorite Endpoint:
    Flips is_favorite (True <-> False) on a record in PostgreSQL.
    Enforces record ownership validation (HTTP 403 if user doesn't own the record).
    """
    user_id = user["sub"]
    record = db.get(ReframeRecord, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Reframing record not found")

    if record.user_id != user_id:
        raise HTTPException(status_code=403, detail="Forbidden: You do not own this record")

    record.is_favorite = not record.is_favorite
    db.add(record)
    db.commit()
    db.refresh(record)
    return record

@history_router.delete("/{record_id}")
async def delete_history_record(
    record_id: str,
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """
    Delete History Record Endpoint:
    Deletes a saved reframing record from PostgreSQL.
    Enforces record ownership validation (HTTP 403 if user doesn't own the record).
    """
    user_id = user["sub"]
    record = db.get(ReframeRecord, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Reframing record not found")

    if record.user_id != user_id:
        raise HTTPException(status_code=403, detail="Forbidden: You do not own this record")

    db.delete(record)
    db.commit()
    return {"detail": "Record deleted successfully", "id": record_id}
