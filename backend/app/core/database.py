from sqlmodel import SQLModel, create_engine, Session
from app.core.config import settings
from app.models.db_models import User, ReframeRecord, SafetyLog

# Check if using SQLite to add connect_args
connect_args = {"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {}

# Create SQLModel Database Engine
engine = create_engine(
    settings.DATABASE_URL,
    echo=False,
    connect_args=connect_args,
)

def init_db():
    """Auto-creates all SQLModel database tables on startup if they don't exist."""
    SQLModel.metadata.create_all(engine)

def get_session():
    """FastAPI Dependency for database sessions per HTTP request."""
    with Session(engine) as session:
        yield session
