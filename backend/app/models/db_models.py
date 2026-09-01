import uuid
from datetime import datetime, timezone
from typing import Optional
from sqlmodel import SQLModel, Field

# 👤 User Account Entity
class User(SQLModel, table=True):
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    email: str = Field(unique=True, index=True)
    hashed_password: Optional[str] = Field(default=None)
    auth_provider: str = Field(default="email") # "email", "google", "apple"
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# 📚 Reframing History Entity (Stores all safe & reframed user thoughts)
class ReframeRecord(SQLModel, table=True):
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    user_id: Optional[str] = Field(default=None, foreign_key="user.id", index=True)
    prompt_text: str
    reframed_text: Optional[str] = Field(default=None)
    is_safe: bool = Field(default=True)
    safety_category: str = Field(default="none")
    is_favorite: bool = Field(default=False)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# 🛡️ Safety Engine Audit Log Entity (Audits triggered crisis/crime inputs)
class SafetyLog(SQLModel, table=True):
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    user_id: Optional[str] = Field(default=None, foreign_key="user.id")
    safety_category: str
    flagged_text: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
