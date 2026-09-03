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
