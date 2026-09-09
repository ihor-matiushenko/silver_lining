# 🏛️ Full-Stack System Architecture Specification (`ARCHITECTURE.md`)

This document presents the complete technical architecture specification for the **Silver Lining AI** ecosystem.

---

## 📐 1. System Overview & Context Diagram

```mermaid
graph TD
    subgraph Mobile Application (Flutter Cross-Platform)
        UI[Flutter UI Screens / AuthScreen 2FA Form] --> Storage[Local Storage: shared_preferences]
        UI --> AuthService[AuthService Facade]
        AuthService --> StrategyAuth[IAuthProvider Interface]
        StrategyAuth -->|isSupabaseConfigured=true| SupabaseProvider[SupabaseAuthProvider]
        StrategyAuth -->|isSupabaseConfigured=false| MockProvider[MockAuthProvider]
        
        UI --> ApiService[ApiReframingService]
        ApiService -->|HTTP POST /api/v1/reframe + Bearer JWT| API[FastAPI Thin APIRouters]
        ApiService -->|HTTP GET /api/v1/history + Bearer JWT| API
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
        SupabaseProvider -->|OAuth / Email| SupabaseCloud[(Supabase Auth Cloud)]
        ORM --> PostgreSQL[(PostgreSQL Database: port 5432)]
        API --> JWT[Supabase JWT Verification]
    end
```

---

## 🔄 2. End-to-End Cloud History Sync Protocol

```
📱 Flutter App                         🐍 Python FastAPI                         🐘 PostgreSQL
   │                                      │                                         │
   ├── POST /api/v1/reframe ────────────► │                                         │
   │   (Header: Bearer <jwt_token>)       ├── Verify JWT Signature                  │
   │                                      ├── Extract user_id ('usr_123')           │
   │                                      ├── Generate Reframed Text                │
   │                                      └── INSERT INTO reframerecord ──────────► │
   │                                          (user_id='usr_123')                   │
   │                                                                                │
   ├── GET /api/v1/history ─────────────► │                                         │
   │   (Header: Bearer <jwt_token>)       ├── Verify JWT Signature                  │
   │                                      └── SELECT * FROM reframerecord ────────► │
   │ ◄── Returns JSON List of Records ────┤   WHERE user_id='usr_123'               │
```

---

## 🏛️ 3. Flutter Auth Provider Strategy Pattern

- **`IAuthProvider`** (`lib/services/providers/i_auth_provider.dart`): Abstract interface defining authentication contracts.
- **`SupabaseAuthProvider`**: Production implementation using live `Supabase.instance.client.auth`.
- **`MockAuthProvider`**: Isolated mock implementation for dev & offline testing.
- **`AuthService`**: Clean facade delegating to the active provider.

---

## 🗄️ 4. Database Schema (SQLModel Entities)

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

## 📡 5. API REST Endpoint Contracts

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| `GET` | `/` | ❌ No | Health check & service metadata |
| `POST` | `/api/v1/reframe` | 🟡 Optional | Reframes thought; rate limited to 5/day for guests; saves to DB if authenticated |
| `GET` | `/api/v1/history` |  Required | Returns saved reframing records for authenticated user from PostgreSQL |
| `POST` | `/api/v1/history/{id}/favorite` |  Required | Toggles `is_favorite` boolean (`True` $\leftrightarrow$ `False`) with ownership security check |
| `DELETE` | `/api/v1/history/{id}` |  Required | Deletes saved record from PostgreSQL with ownership security check |
