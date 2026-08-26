from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.models.schemas import ReframeRequest, ReframeResponse
from app.services.safety_service import SafetyService
from app.services.llm_service import LLMService

app = FastAPI(
    title="Silver Lining AI Backend",
    description="API for perspective reframing with 3-tier safety guardrails and Local Ollama AI",
    version="1.0.0"
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
async def reframe_thought(payload: ReframeRequest):
    """
    Main API Endpoint:
    1. Validates input text using Pydantic.
    2. Runs 3-Tier Safety Engine checks.
    3. If safe, calls Local Ollama AI to generate reframed perspective.
    """
    input_text = payload.input_text.strip()
    if not input_text:
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")

    # Step 1: Run 3-Tier Safety Engine Evaluation
    safety_result = SafetyService.evaluate_input_safety(input_text)
    if safety_result is not None:
        # Safety trigger detected (Crisis or Crime) -> Return refusal payload immediately
        return safety_result

    # Step 2: Safe input -> Call Local Ollama AI Service
    reframed_text = await LLMService.generate_reframed_perspective(input_text)

    return ReframeResponse(
        is_safe=True,
        safety_category="none",
        reframed_text=reframed_text,
        crisis_triggered=False,
        emergency_hotline=None
    )
