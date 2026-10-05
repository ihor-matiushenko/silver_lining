from sqlmodel import Session, select
from app.models.db_models import User, ReframeRecord, SafetyLog, ReportRecord
from app.models.schemas import DeleteAccountResponse

class UserService:
    """
    Business Service Layer for User Account Management & Compliance.
    Encapsulates account deletion and cascading data purging
    (Apple Guideline 5.1.1(v) & Google Play Data Deletion Policy).
    """

    @staticmethod
    def delete_user_account(db: Session, user_id: str) -> DeleteAccountResponse:
        """
        Permanently deletes user account and cascades deletion to all associated records:
        - ReframeRecord (personal reflection history)
        - SafetyLog (safety audit logs associated with this user)
        - ReportRecord (content reports submitted by this user)
        - User (account entity in PostgreSQL)
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

