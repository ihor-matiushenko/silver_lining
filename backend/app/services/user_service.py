import logging
import httpx
from sqlmodel import Session, select
from app.core.config import settings
from app.models.db_models import User, ReframeRecord, SafetyLog, ReportRecord
from app.models.schemas import DeleteAccountResponse

logger = logging.getLogger("silver_lining.user_service")

class UserService:
    """
    Business Service Layer for User Account Management & Compliance.
    Encapsulates account deletion and cascading data purging
    (Apple Guideline 5.1.1(v) & Google Play Data Deletion Policy).
    """

    @staticmethod
    def _delete_from_supabase_auth(user_id: str) -> bool:
        """
        Deletes the user from Supabase's internal auth.users table using the Admin API.
        Requires SUPABASE_SERVICE_ROLE_KEY and SUPABASE_URL to be configured.
        """
        if not settings.SUPABASE_SERVICE_ROLE_KEY or not settings.SUPABASE_URL:
            return False

        try:
            url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/admin/users/{user_id}"
            headers = {
                "apikey": settings.SUPABASE_SERVICE_ROLE_KEY,
                "Authorization": f"Bearer {settings.SUPABASE_SERVICE_ROLE_KEY}",
            }
            with httpx.Client(timeout=10.0) as client:
                resp = client.delete(url, headers=headers)
                if resp.status_code in (200, 204):
                    logger.info(f"✅ User {user_id} successfully deleted from Supabase Auth.")
                    return True
                else:
                    logger.warning(
                        f"⚠️ Supabase Auth admin deletion returned status {resp.status_code}: {resp.text}"
                    )
                    return False
        except Exception as e:
            logger.warning(f"⚠️ Failed to call Supabase Auth admin deletion: {e}")
            return False

    @staticmethod
    def delete_user_account(db: Session, user_id: str) -> DeleteAccountResponse:
        """
        Permanently deletes user account and cascades deletion to all associated records:
        - ReframeRecord (personal reflection history)
        - SafetyLog (safety audit logs associated with this user)
        - ReportRecord (content reports submitted by this user)
        - User (account entity in PostgreSQL)
        - Supabase Auth (purged from auth.users via Admin API if service role key provided)
        """
        # Count and delete personal ReframeRecords
        records = db.exec(select(ReframeRecord).where(ReframeRecord.user_id == user_id)).all()
        records_count = len(records)
        for r in records:
            db.delete(r)

        # Purge personal SafetyLogs
        safety_logs = db.exec(select(SafetyLog).where(SafetyLog.user_id == user_id)).all()
        for sl in safety_logs:
            db.delete(sl)

        # Purge personal ReportRecords
        report_records = db.exec(select(ReportRecord).where(ReportRecord.user_id == user_id)).all()
        for rep in report_records:
            db.delete(rep)

        # Purge User entity if exists in PostgreSQL DB
        user = db.get(User, user_id)
        if user:
            db.delete(user)

        db.commit()

        # Attempt Supabase Auth admin deletion
        UserService._delete_from_supabase_auth(user_id)

        return DeleteAccountResponse(
            detail="Account and all associated personal data permanently deleted.",
            user_id=user_id,
            deleted_records_count=records_count
        )

    @staticmethod
    def delete_user_by_email(db: Session, email: str) -> tuple[bool, int]:
        """
        Web-initiated account deletion request (Google Play Data Safety Mandate).
        Searches for registered user by email and cascades deletion to all personal data.
        Returns a tuple of (account_found: bool, deleted_records_count: int).
        """
        clean_email = email.strip().lower()
        user = db.exec(select(User).where(User.email == clean_email)).first()
        if not user or not user.id:
            return False, 0

        res = UserService.delete_user_account(db=db, user_id=user.id)
        return True, res.deleted_records_count

