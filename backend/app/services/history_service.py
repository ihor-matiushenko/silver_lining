from typing import List
from fastapi import HTTPException
from sqlmodel import Session, select, desc
from app.models.db_models import ReframeRecord

class HistoryService:
    """
    Business Service Layer for Cloud History & Favorites management.
    Encapsulates all PostgreSQL database queries and record ownership validations.
    """

    @staticmethod
    def get_user_history(db: Session, user_id: str) -> List[ReframeRecord]:
        """Fetches all saved reframing records for a user from PostgreSQL, sorted by created_at DESC."""
        statement = (
            select(ReframeRecord)
            .where(ReframeRecord.user_id == user_id)
            .order_by(desc(ReframeRecord.created_at))
        )
        return db.exec(statement).all()

    @staticmethod
    def toggle_favorite(db: Session, record_id: str, user_id: str) -> ReframeRecord:
        """
        Toggles is_favorite boolean on a record in PostgreSQL.
        Enforces ownership validation (throws HTTP 403 if user does not own the record).
        """
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

    @staticmethod
    def delete_record(db: Session, record_id: str, user_id: str) -> dict:
        """
        Deletes a saved reframing record from PostgreSQL.
        Enforces ownership validation (throws HTTP 403 if user does not own the record).
        """
        record = db.get(ReframeRecord, record_id)
        if not record:
            raise HTTPException(status_code=404, detail="Reframing record not found")

        if record.user_id != user_id:
            raise HTTPException(status_code=403, detail="Forbidden: You do not own this record")

        db.delete(record)
        db.commit()
        return {"detail": "Record deleted successfully", "id": record_id}
