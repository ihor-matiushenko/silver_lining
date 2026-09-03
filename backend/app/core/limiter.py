from fastapi import Request
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.util import get_remote_address
from app.core.config import settings

# 🛡️ Global Limiter instance identifying requests by client IP address
limiter = Limiter(key_func=get_remote_address)

def get_guest_rate_limit() -> str:
    """
    Dynamic rate limit generator reading GUEST_DAILY_LIMIT setting from .env.
    Example: Returns '5/day' when settings.GUEST_DAILY_LIMIT == 5.
    """
    return f"{settings.GUEST_DAILY_LIMIT}/day"

async def custom_rate_limit_exceeded_handler(request: Request, exc: Exception) -> JSONResponse:
    """Type-safe exception handler for Pyright/VSCode returning brand-aligned 429 JSON error"""
    return JSONResponse(
        status_code=429,
        content={
            "detail": f"Guest daily limit reached ({settings.GUEST_DAILY_LIMIT}/day). Create a free account for unlimited reframings!"
        }
    )
