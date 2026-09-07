# 🏛️ Full-Stack System Architecture Specification (`ARCHITECTURE.md`)

This document presents the complete technical architecture specification for the **Silver Lining AI** ecosystem.

---

## 📐 1. System Overview & Context Diagram

```mermaid
graph TD
    subgraph Mobile Application (Flutter Cross-Platform)
        UI[Flutter UI Screens] --> Storage[Local Storage: shared_preferences]
        UI --> Service[ApiReframingService]
        Service -->|HTTP POST /api/v1/reframe| API[FastAPI Backend Server]
        Service -->|HTTP GET /api/v1/history| API
    end

    subgraph Backend Services (Python FastAPI)
        API --> Limiter[slowapi Rate Limiter: 5/day Guests]
        Limiter --> Safety[SafetyService: 3-Tier Safety Engine]
        Safety -->|If Safe| Strategy[LLMService Strategy Factory]
        Strategy -->|LLM_PROVIDER=ollama| Ollama[Local Ollama AI Server]
        Strategy -->|LLM_PROVIDER=gemini| Gemini[Google Gemini 1.5 Flash API]
        API --> ORM[SQLModel ORM Layer]
    end

    subgraph Data & Auth Persistence
        ORM --> PostgreSQL[(PostgreSQL Database: port 5432)]
        API --> JWT[Supabase JWT Verification]
    end
```

---

## 🗄️ 2. Database Schema (SQLModel Entities)

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

## 📡 3. API REST Endpoint Contracts

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| `GET` | `/` | ❌ No | Health check & service metadata |
| `POST` | `/api/v1/reframe` | 🟡 Optional | Reframes thought; rate limited to 5/day for guests; saves to DB if authenticated |
| `GET` | `/api/v1/history` |  Required | Returns saved reframing records for authenticated user from PostgreSQL |
| `POST` | `/api/v1/history/{id}/favorite` |  Required | Toggles `is_favorite` boolean (`True` $\leftrightarrow$ `False`) with ownership security check |
| `DELETE` | `/api/v1/history/{id}` |  Required | Deletes saved record from PostgreSQL with ownership security check |

---

## 🤖 4. AI Provider Strategy Pattern

The application utilizes the **Strategy Design Pattern** to allow zero-code switching between local development and cloud production:

- **`BaseLLMProvider`** (`app/services/llm_providers/base_provider.py`): Abstract interface defining `generate_perspective(input_text: str)`.
- **`OllamaProvider`** (`app/services/llm_providers/ollama_provider.py`): Communicates with local Ollama (`qwen3-vl:8b`).
- **`GeminiProvider`** (`app/services/llm_providers/gemini_provider.py`): Communicates with Google Gemini 1.5 Flash API.
- **`LLMService`** (`app/services/llm_service.py`): Factory router inspecting `settings.LLM_PROVIDER`.

---

## 🛡️ 5. 3-Tier Safety Engine Logic

```
Input Prompt
   │
   ├─► Tier 1: Crisis Rule (Self-Harm / Suicide) ──────► 🚨 Crisis Shield (988 Lifeline)
   │
   ├─► Tier 2: Crime Rule (Illegal / Violence) ────────► 🛡️ Policy Refusal Card
   │
   └─► Tier 3: Safe Input ──────────────────────────────► ✨ Pass to AI Generation Engine
```
