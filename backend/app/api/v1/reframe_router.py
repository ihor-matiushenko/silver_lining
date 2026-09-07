from typing import Optional
from fastapi import APIRouter, Depends, Request
from sqlmodel import Session

from app.core.database import get_session
from app.core.security import get_current_user_optional
from app.core.limiter import limiter, get_guest_rate_limit
from app.models.schemas import ReframeRequest, ReframeResponse
from app.services.reframing_service import ReframingService

reframe_router = APIRouter(tags=["Reframing AI"])

@reframe_router.post("/reframe", response_model=ReframeResponse)
@limiter.limit(get_guest_rate_limit)
async def reframe_thought(
    request: Request,
    payload: ReframeRequest,
    db: Session = Depends(get_session),
    user: Optional[dict] = Depends(get_current_user_optional)
):
    """
    Main Perspective Reframing API Endpoint:
    Enforces guest rate limiting and delegates to ReframingService.
    """
    return await ReframingService.process_thought(payload=payload, db=db, user=user)
