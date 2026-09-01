from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session
from app.core.database import init_db, get_session
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
    description="API for perspective reframing with 3-tier safety guardrails, SQLModel DB, and Local Ollama AI",
    version="1.0.0",
    lifespan=lifespan,
)

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
async def reframe_thought(payload: ReframeRequest, db: Session = Depends(get_session)):
    """
    Main API Endpoint:
    1. Validates input text using Pydantic.
    2. Runs 3-Tier Safety Engine checks.
    3. If safe, calls Local Ollama AI to generate reframed perspective.
    4. Persists record in SQLModel Database.
    """
    input_text = payload.input_text.strip()
    if not input_text:
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")

    # Step 1: Run 3-Tier Safety Engine Evaluation
    safety_result = SafetyService.evaluate_input_safety(input_text)
    if safety_result is not None:
        # Log safety trigger to database audit log
        safety_log = SafetyLog(
            safety_category=safety_result.safety_category,
            flagged_text=input_text,
        )
        db.add(safety_log)
        db.commit()
        return safety_result

    # Step 2: Safe input -> Call Local Ollama AI Service
    reframed_text = await LLMService.generate_reframed_perspective(input_text)

    # Step 3: Save safe reframed record to SQLModel database
    record = ReframeRecord(
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
