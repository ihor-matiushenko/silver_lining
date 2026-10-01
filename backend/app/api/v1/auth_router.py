from fastapi import APIRouter, Depends
from sqlmodel import Session
from app.core.database import get_session
from app.core.security import get_current_user
from app.models.schemas import DeleteAccountResponse
from app.services.user_service import UserService

auth_router = APIRouter(prefix="/auth", tags=["Authentication & User Management"])

@auth_router.delete("/delete-account", response_model=DeleteAccountResponse)
async def delete_account(
    db: Session = Depends(get_session),
    user: dict = Depends(get_current_user)
):
    """
    In-App Account Deletion Endpoint (Apple Guideline 5.1.1(v) & Google Play Data Deletion Policy).
    Permanently purges the authenticated user's account and cascades deletion to all personal
    reflection history, reports, and safety logs.
    """
    return UserService.delete_user_account(db=db, user_id=user["sub"])
