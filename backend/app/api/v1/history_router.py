from typing import List
from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.db_models import ReframeRecord
from app.services.history_service import HistoryService

history_router = APIRouter(prefix="/history", tags=["Cloud History"])

@history_router.get("", response_model=List[ReframeRecord])
async def get_user_history(
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """Fetches all saved reframing records for the authenticated user from PostgreSQL."""
    return HistoryService.get_user_history(db=db, user_id=user["sub"])

@history_router.post("/{record_id}/favorite", response_model=ReframeRecord)
async def toggle_favorite(
    record_id: str,
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """Toggles is_favorite (True <-> False) on a record in PostgreSQL with ownership verification."""
    return HistoryService.toggle_favorite(db=db, record_id=record_id, user_id=user["sub"])

@history_router.delete("/{record_id}")
async def delete_history_record(
    record_id: str,
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """Deletes a saved reframing record from PostgreSQL with ownership verification."""
    return HistoryService.delete_record(db=db, record_id=record_id, user_id=user["sub"])
