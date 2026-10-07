from typing import Optional
from sqlmodel import Session
from app.models.db_models import User, ReportRecord
from app.models.schemas import ReportRequest, ReportResponse

class ReportService:
    """
    Business Service Layer for GenAI Objectionable Content Reporting.
    Encapsulates receiving, auditing, and persisting flagged AI content
    (Apple Guideline 1.2 & Google Play Generative AI Policy).
    """

    @staticmethod
    def create_report(
        db: Session,
        payload: ReportRequest,
        user_id: Optional[str] = None
    ) -> ReportResponse:
        """
        Persists an objectionable content report submitted by an authenticated or guest user.
        """
        if user_id:
            # Auto-provision user if not already in PostgreSQL to satisfy foreign key
            existing_user = db.get(User, user_id)
            if not existing_user:
                db.add(User(id=user_id, email=f"{user_id}@example.com", auth_provider="supabase"))
                db.commit()

        record = ReportRecord(
            user_id=user_id,
            reframe_id=payload.reframe_id,
            content_snippet=payload.content_snippet,
            reason=payload.reason,
            details=payload.details
        )
        db.add(record)
        db.commit()
        db.refresh(record)

        report_id = record.id if record.id is not None else ""
        return ReportResponse(
            id=report_id,
            status="received",
            message="Report submitted successfully for safety review."
        )

