import base64
import jwt
from jwt import PyJWKClient
from typing import Optional
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.config import settings

# 🛡️ HTTPBearer automatically parses "Authorization: Bearer <token>" from HTTP headers
security = HTTPBearer(auto_error=False)

# Cached PyJWKClient instance for live Supabase ES256 asymmetric keys
_jwk_client: Optional[PyJWKClient] = None

def get_jwk_client() -> Optional[PyJWKClient]:
    global _jwk_client
    if _jwk_client is None and settings.SUPABASE_URL:
        jwks_url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/.well-known/jwks.json"
        _jwk_client = PyJWKClient(jwks_url)
    return _jwk_client

def verify_jwt_token(token: str) -> dict:
    """
    Decodes and cryptographically verifies JWT token signature.
    Supports:
    - Development bypass (token == "dev_mock_jwt_token")
    - Supabase Asymmetric ECC / ES256 via JWKS
    - Symmetric HS256 (both UTF-8 and Base64-decoded) via SUPABASE_JWT_SECRET
    Throws HTTP 401 Unauthorized if the token is forged, expired, or invalid.
    """
    # 🧪 Development / Mock mode bypass: enables seamless offline testing with MockAuthProvider
    if settings.ENVIRONMENT == "development" and token == "dev_mock_jwt_token":
        return {
            "sub": "usr_mock_logged_in_123",
            "email": "mock_user@example.com",
            "role": "authenticated"
        }

    try:
        header = jwt.get_unverified_header(token)
        alg = header.get("alg", "HS256")

        if alg == "ES256":
            client = get_jwk_client()
            if not client:
                raise HTTPException(status_code=401, detail="JWKS client not configured")
            signing_key = client.get_signing_key_from_jwt(token)
            return jwt.decode(
                token,
                signing_key.key,
                algorithms=["ES256"],
                options={"verify_aud": False}
            )

        # Standard HS256: Try raw string first, then base64 decoded bytes if needed
        try:
            return jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                options={"verify_aud": False}
            )
        except jwt.PyJWTError:
            try:
                secret_bytes = base64.b64decode(settings.SUPABASE_JWT_SECRET)
                return jwt.decode(
                    token,
                    secret_bytes,
                    algorithms=["HS256"],
                    options={"verify_aud": False}
                )
            except Exception:
                raise
    except Exception:
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
