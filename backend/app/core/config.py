import os
from pydantic_settings import BaseSettings

# ⚙️ Application Settings loaded automatically from environment variables / .env file
class Settings(BaseSettings):
    APP_NAME: str = "Silver Lining AI Backend"
    ENVIRONMENT: str = "development"
    
    # 🐘 Generic PostgreSQL Database Connection URL (Overridden by .env)
    DATABASE_URL: str = "postgresql://postgres:postgres@127.0.0.1:5432/silver_lining"
    
    # 🤖 AI Provider Strategy Configuration ("ollama" or "gemini")
    LLM_PROVIDER: str = "ollama"
    
    # Local Ollama Settings
    OLLAMA_URL: str = "http://localhost:11434/api/generate"
    OLLAMA_MODEL: str = "qwen3-vl:8b"
    
    # Google Gemini Settings
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-1.5-flash"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

# Global singleton settings instance
settings = Settings()
