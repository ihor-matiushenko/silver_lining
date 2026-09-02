from sqlmodel import SQLModel, create_engine, Session
from app.core.config import settings
from app.models.db_models import User, ReframeRecord, SafetyLog

# 🐘 Create SQLModel PostgreSQL Database Engine
engine = create_engine(
    settings.DATABASE_URL,
    echo=False,
    pool_pre_ping=True,  # Auto-reconnects if PostgreSQL drops idle connections
)

def init_db():
    """Auto-creates all SQLModel database tables on startup if they don't exist."""
    SQLModel.metadata.create_all(engine)

def get_session():
    """FastAPI Dependency for database sessions per HTTP request."""
    with Session(engine) as session:
        yield session
