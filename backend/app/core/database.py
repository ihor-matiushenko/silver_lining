from sqlmodel import SQLModel, create_engine, Session
from sqlalchemy import text
from app.core.config import settings
from app.models.db_models import User, ReframeRecord, SafetyLog, ReportRecord

# 🐘 Create SQLModel PostgreSQL Database Engine
engine = create_engine(
    settings.DATABASE_URL,
    echo=False,
    pool_pre_ping=True,  # Auto-reconnects if PostgreSQL drops idle connections
)

def init_db():
    """Auto-creates all SQLModel database tables on startup if they don't exist."""
    SQLModel.metadata.create_all(engine)
    with engine.connect() as conn:
        conn.execute(text("ALTER TABLE reframerecord ADD COLUMN IF NOT EXISTS language VARCHAR DEFAULT 'auto';"))
        conn.commit()

def get_session():
    """FastAPI Dependency for database sessions per HTTP request."""
    with Session(engine) as session:
        yield session
