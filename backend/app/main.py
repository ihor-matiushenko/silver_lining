import sys
import os

# Ensure backend directory is on sys.path for clean import resolution
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

try:
    from app.models.schemas import ReframeRequest, ReframeResponse
    from app.services.safety_service import SafetyService
    from app.services.llm_service import LLMService
except ImportError:
    from .models.schemas import ReframeRequest, ReframeResponse
    from .services.safety_service import SafetyService
    from .services.llm_service import LLMService

app = FastAPI(
    title="Silver Lining AI Backend",
    description="API for perspective reframing with 3-tier safety guardrails",
    version="1.0.0"
)

# Enable CORS for Flutter mobile app requests
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
        "docs_url": "http://localhost:8000/docs"
    }

@app.post("/api/v1/reframe", response_model=ReframeResponse)
async def reframe_thought(payload: ReframeRequest):
    """
    Main endpoint: 
    1. Evaluates user input against 3-tier Safety Engine.
    2. If unsafe (crisis/crime), returns refusal/hotline card.
    3. If safe, calls Gemini 1.5 Flash to generate reframed perspective.
    """
    input_text = payload.input_text.strip()
    if not input_text:
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")

    # Step 1: Run 3-Tier Safety Engine Evaluation
    safety_result = SafetyService.evaluate_input_safety(input_text)
    if safety_result is not None:
        # Safety violation detected -> return crisis or crime refusal payload immediately
        return safety_result

    # Step 2: Safe input -> Call LLM Service
    reframed_text = await LLMService.generate_reframed_perspective(input_text)
    
    return ReframeResponse(
        is_safe=True,
        safety_category="none",
        reframed_text=reframed_text,
        crisis_triggered=False,
        emergency_hotline=None
    )
