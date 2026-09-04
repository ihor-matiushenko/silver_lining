import jwt
from typing import Optional
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.config import settings

# 🛡️ HTTPBearer automatically parses "Authorization: Bearer <token>" from HTTP headers
security = HTTPBearer(auto_error=False)

def verify_jwt_token(token: str) -> dict:
    """
    Decodes and cryptographically verifies JWT token signature using SUPABASE_JWT_SECRET.
    Throws HTTP 401 Unauthorized if the token is forged, expired, or invalid.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            options={"verify_aud": False}
        )
        return payload
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired authentication token"
        )

async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security)
) -> Optional[dict]:
    """
    FastAPI Security Dependency (Optional Auth):
    - If Authorization header is missing: returns None (Guest User).
    - If Authorization header is present: verifies JWT token and returns payload dict!
    """
    if credentials is None:
        return None  # Guest User!

    token = credentials.credentials
    return verify_jwt_token(token)

async def get_current_user(
    user: Optional[dict] = Depends(get_current_user_optional)
) -> dict:
    """
    Strict FastAPI Security Dependency (Required Auth):
    - Reuses get_current_user_optional.
    - Throws HTTP 401 Unauthorized if request is unauthenticated (Guest).
    """
    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Authentication required to access this resource"
        )
    return user
