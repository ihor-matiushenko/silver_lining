from typing import Optional
from fastapi import APIRouter, HTTPException, Depends, Request
from sqlmodel import Session

from app.core.database import get_session
from app.core.security import get_current_user_optional
from app.core.limiter import limiter, get_guest_rate_limit
from app.models.db_models import ReframeRecord, SafetyLog
from app.models.schemas import ReframeRequest, ReframeResponse
from app.services.safety_service import SafetyService
from app.services.llm_service import LLMService

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
    1. Enforces rate limits dynamically via slowapi (default 5/day for guests).
    2. Validates input text using Pydantic.
    3. Runs 3-Tier Safety Engine checks.
    4. If safe, calls Local Ollama AI to generate reframed perspective.
    5. Persists record in SQLModel Database ONLY for authenticated users.
    """
    input_text = payload.input_text.strip()
    if not input_text:
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")

    # Extract user_id if request is authenticated (or None for Guest)
    user_id = user.get("sub") if user else None

    # Step 1: Run 3-Tier Safety Engine Evaluation
    safety_result = SafetyService.evaluate_input_safety(input_text)
    if safety_result is not None:
        # Log safety trigger to database audit log
        safety_log = SafetyLog(
            user_id=user_id,
            safety_category=safety_result.safety_category,
            flagged_text=input_text,
        )
        db.add(safety_log)
        db.commit()
        return safety_result

    # Step 2: Safe input -> Call Local Ollama AI Service
    reframed_text = await LLMService.generate_reframed_perspective(input_text)

    # Step 3: ONLY save reframed record to PostgreSQL if the user is logged in!
    if user_id:
        record = ReframeRecord(
            user_id=user_id,
            prompt_text=input_text,
            reframed_text=reframed_text,
            is_safe=True,
            safety_category="none",
        )
        db.add(record)
        db.commit()

    return ReframeResponse(
        is_safe=True,
        safety_category="none",
        reframed_text=reframed_text,
        crisis_triggered=False,
        emergency_hotline=None
    )
