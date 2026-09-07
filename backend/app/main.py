from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi.errors import RateLimitExceeded

from app.core.database import init_db
from app.core.limiter import limiter, custom_rate_limit_exceeded_handler
from app.api.v1.reframe_router import reframe_router
from app.api.v1.history_router import history_router

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

# 🛡️ Configure slowapi Rate Limiter state & custom 429 exception handler
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

# 🔌 Register Modular API Routers
app.include_router(reframe_router, prefix="/api/v1")
app.include_router(history_router, prefix="/api/v1")

@app.get("/")
async def root():
    return {
        "status": "online",
        "service": "Silver Lining AI Backend",
        "docs": "http://localhost:8000/docs"
    }
