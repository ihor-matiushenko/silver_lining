from typing import Optional
from fastapi import APIRouter, Depends
from sqlmodel import Session
from app.core.database import get_session
from app.core.security import get_current_user_optional
from app.models.schemas import ReportRequest, ReportResponse
from app.services.report_service import ReportService

report_router = APIRouter(prefix="/reports", tags=["Safety & Content Moderation"])

@report_router.post("", response_model=ReportResponse)
async def submit_content_report(
    payload: ReportRequest,
    db: Session = Depends(get_session),
    user: Optional[dict] = Depends(get_current_user_optional)
):
    """
    Submits an objectionable or harmful AI content report (Apple Guideline 1.2 & Google GenAI Policy).
    Allows both authenticated and guest users to flag inappropriate AI responses for safety review.
    """
    user_id = user["sub"] if user else None
    return ReportService.create_report(db=db, payload=payload, user_id=user_id)
