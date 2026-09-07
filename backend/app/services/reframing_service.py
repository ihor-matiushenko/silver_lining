from typing import Optional
from fastapi import HTTPException
from sqlmodel import Session

from app.models.db_models import ReframeRecord, SafetyLog
from app.models.schemas import ReframeRequest, ReframeResponse
from app.services.safety_service import SafetyService
from app.services.llm_service import LLMService

class ReframingService:
    """
    Business Service Layer for Perspective Reframing.
    Encapsulates input validation, 3-tier safety checks, AI generation, and database persistence.
    """

    @staticmethod
    async def process_thought(
        payload: ReframeRequest,
        db: Session,
        user: Optional[dict] = None
    ) -> ReframeResponse:
        """
        Processes a perspective reframing request:
        1. Validates non-empty input.
        2. Runs 3-Tier Safety Engine checks.
        3. If safe, calls AI Strategy Engine (Ollama/Gemini).
        4. Persists record in PostgreSQL ONLY if the request is authenticated.
        """
        input_text = payload.input_text.strip()
        if not input_text:
            raise HTTPException(status_code=400, detail="Input text cannot be empty.")

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

        # Step 2: Safe input -> Call Local Ollama / Gemini AI Strategy Provider
        reframed_text = await LLMService.generate_reframed_perspective(input_text)

        # Step 3: ONLY save reframed record to PostgreSQL if the user is authenticated!
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
