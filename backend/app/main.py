from contextlib import asynccontextmanager
from typing import Optional, List
from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select
from slowapi.errors import RateLimitExceeded

from app.core.database import init_db, get_session
from app.core.security import get_current_user_optional, get_current_user
from app.core.limiter import limiter, get_guest_rate_limit, custom_rate_limit_exceeded_handler
from app.models.db_models import ReframeRecord, SafetyLog
from app.models.schemas import ReframeRequest, ReframeResponse
from app.services.safety_service import SafetyService
from app.services.llm_service import LLMService

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Modern FastAPI Lifespan Handler: Auto-creates DB tables on startup"""
    init_db()
    yield

app = FastAPI(
    title="Silver Lining AI Backend",
    description="API for perspective reframing with 3-tier safety guardrails, SQLModel DB, JWT Auth, and Rate Limiter",
    version="1.0.0",
    lifespan=lifespan,
)

# 🛡️ Configure slowapi Rate Limiter state & custom type-safe 429 exception handler
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, custom_rate_limit_exceeded_handler)

# Enable CORS (Cross-Origin Resource Sharing) for Flutter mobile app requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "status": "online",
        "service": "Silver Lining AI Backend",
        "docs": "http://localhost:8000/docs"
    }

@app.post("/api/v1/reframe", response_model=ReframeResponse)
@limiter.limit(get_guest_rate_limit)
async def reframe_thought(
    request: Request,
    payload: ReframeRequest,
    db: Session = Depends(get_session),
    user: Optional[dict] = Depends(get_current_user_optional)
):
    """
    Main API Endpoint:
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

@app.get("/api/v1/history", response_model=List[ReframeRecord])
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
        .order_by(ReframeRecord.created_at.desc())
    )
    records = db.exec(statement).all()
    return records
