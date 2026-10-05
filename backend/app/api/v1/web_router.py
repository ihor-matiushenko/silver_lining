from typing import Optional
from fastapi import APIRouter, Depends, Header, Query
from fastapi.responses import HTMLResponse
from sqlmodel import Session

from app.core.database import get_session
from app.models.schemas import WebDeleteAccountRequest, WebDeleteAccountResponse
from app.services.user_service import UserService
from app.web.pages import render_privacy_page, render_terms_page, render_delete_account_page

web_router = APIRouter(tags=["Public Web Policies & Compliance"])

def _resolve_lang(lang: Optional[str], accept_language: Optional[str]) -> str:
    """Resolves target language from query parameter or Accept-Language header"""
    if lang:
        clean = lang.lower().strip().split("-")[0]
        if clean in ["en", "uk", "es", "de", "fr"]:
            return clean

    if accept_language:
        # e.g., 'uk,en-US;q=0.9,en;q=0.8'
        for part in accept_language.split(","):
            code = part.split(";")[0].strip().lower().split("-")[0]
            if code in ["en", "uk", "es", "de", "fr"]:
                return code

    return "en"


@web_router.get("/privacy", response_class=HTMLResponse)
async def get_privacy_policy(
    lang: Optional[str] = Query(default=None, description="ISO Language code (en, uk, es, de, fr)"),
    accept_language: Optional[str] = Header(default=None)
):
    """
    Public Privacy Policy URL (Apple Guideline 5.1.1 & Google Play Data Safety).
    Details data handling, zero-retention guest mode, and cloud database encryption.
    """
    selected_lang = _resolve_lang(lang, accept_language)
    html_content = render_privacy_page(lang=selected_lang)
    return HTMLResponse(content=html_content, status_code=200)


@web_router.get("/terms", response_class=HTMLResponse)
async def get_terms_and_eula(
    lang: Optional[str] = Query(default=None, description="ISO Language code (en, uk, es, de, fr)"),
    accept_language: Optional[str] = Header(default=None)
):
    """
    Public Terms of Service & EULA (Apple Guideline 1.2 & Google Play GenAI Policy).
    Incorporates Apple's Standard EULA, wellness disclaimers, and 3-tier safety guardrails.
    """
    selected_lang = _resolve_lang(lang, accept_language)
    html_content = render_terms_page(lang=selected_lang)
    return HTMLResponse(content=html_content, status_code=200)


@web_router.get("/delete-account", response_class=HTMLResponse)
async def get_account_deletion_page(
    lang: Optional[str] = Query(default=None, description="ISO Language code (en, uk, es, de, fr)"),
    accept_language: Optional[str] = Header(default=None)
):
    """
    Public Web Account Deletion Portal (Google Play Data Safety Mandate).
    Provides self-service mechanism for users who have uninstalled the app to delete accounts.
    """
    selected_lang = _resolve_lang(lang, accept_language)
    html_content = render_delete_account_page(lang=selected_lang)
    return HTMLResponse(content=html_content, status_code=200)


@web_router.post("/api/v1/auth/request-web-deletion", response_model=WebDeleteAccountResponse)
async def request_web_account_deletion(
    payload: WebDeleteAccountRequest,
    db: Session = Depends(get_session)
):
    """
    Processes self-service web account deletion requests.
    Permanently purges PostgreSQL rows if account exists, or confirms zero-data state for guests.
    """
    found, purged_count = UserService.delete_user_by_email(db=db, email=payload.email)
    
    if found:
        return WebDeleteAccountResponse(
            status="completed",
            account_found=True,
            message=f"Account associated with '{payload.email}' and {purged_count} synced reflections have been permanently erased."
        )
    else:
        return WebDeleteAccountResponse(
            status="completed",
            account_found=False,
            message=f"Request recorded for '{payload.email}'. If an account was associated with this email, all records were purged. (Note: Guest users store 0 data on our servers)."
        )
