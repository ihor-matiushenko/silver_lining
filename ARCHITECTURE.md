# 🏛️ Full-Stack System Architecture Specification (`ARCHITECTURE.md`)

This document presents the complete technical architecture specification for the **Silver Lining AI** ecosystem.

---

## 📐 1. System Overview & Context Diagram

```mermaid
graph TD
    subgraph Mobile Application (Flutter Cross-Platform)
        UI[Flutter UI Screens] --> Storage[Local Storage: shared_preferences]
        UI --> Service[ApiReframingService]
        Service -->|HTTP POST /api/v1/reframe| API[FastAPI Thin APIRouters]
        Service -->|HTTP GET /api/v1/history| API
    end

    subgraph Backend Services (3-Tier Layered Python Services)
        API --> Limiter[slowapi Rate Limiter: 5/day Guests]
        Limiter --> ReframingService[ReframingService]
        API --> HistoryService[HistoryService]
        
        ReframingService --> Safety[SafetyService: 3-Tier Safety Engine]
        ReframingService -->|If Safe| Strategy[LLMService Strategy Factory]
        Strategy -->|LLM_PROVIDER=ollama| Ollama[Local Ollama AI Server]
        Strategy -->|LLM_PROVIDER=gemini| Gemini[Google Gemini 1.5 Flash API]
        
        ReframingService --> ORM[SQLModel ORM Layer]
        HistoryService --> ORM
    end

    subgraph Data & Auth Persistence
        ORM --> PostgreSQL[(PostgreSQL Database: port 5432)]
        API --> JWT[Supabase JWT Verification]
    end
```

---

## 🏛️ 2. 3-Tier Layered Architecture Pattern

- **Router Layer** (`app/api/v1/`): Thin 1-line controllers handling HTTP request/response routing.
- **Service Layer** (`app/services/`): Pure Python business logic (`ReframingService`, `HistoryService`, `SafetyService`, `LLMService`).
- **Database Layer** (`app/models/db_models.py`): Pure PostgreSQL `SQLModel` ORM entities (`User`, `ReframeRecord`, `SafetyLog`).

---

## 🗄️ 3. Database Schema (SQLModel Entities)

Defined in `backend/app/models/db_models.py`:

```python
# 1. User Account Entity
class User(SQLModel, table=True):
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    email: str = Field(unique=True, index=True)
    hashed_password: Optional[str] = Field(default=None)
    auth_provider: str = Field(default="email") # "email", "google", "apple"
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# 2. Reframing History Entity (Only persisted for authenticated users!)
class ReframeRecord(SQLModel, table=True):
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    user_id: Optional[str] = Field(default=None, foreign_key="user.id", index=True)
    prompt_text: str
    reframed_text: Optional[str] = Field(default=None)
    is_safe: bool = Field(default=True)
    safety_category: str = Field(default="none")
    is_favorite: bool = Field(default=False)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# 3. Safety Audit Log Entity
class SafetyLog(SQLModel, table=True):
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    user_id: Optional[str] = Field(default=None, foreign_key="user.id")
    safety_category: str
    flagged_text: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
```

---

## 📡 4. API REST Endpoint Contracts

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| `GET` | `/` | ❌ No | Health check & service metadata |
| `POST` | `/api/v1/reframe` | 🟡 Optional | Reframes thought; rate limited to 5/day for guests; saves to DB if authenticated |
| `GET` | `/api/v1/history` |  Required | Returns saved reframing records for authenticated user from PostgreSQL |
| `POST` | `/api/v1/history/{id}/favorite` |  Required | Toggles `is_favorite` boolean (`True` $\leftrightarrow$ `False`) with ownership security check |
| `DELETE` | `/api/v1/history/{id}` |  Required | Deletes saved record from PostgreSQL with ownership security check |
