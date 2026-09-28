# 🏛️ Full-Stack System Architecture Specification (`ARCHITECTURE.md`)

This document presents the complete technical architecture specification for the **Silver Lining AI** ecosystem, including authentication, 3-tier safety engine, pure PostgreSQL database storage, AI strategy pattern, and dynamic multi-language localization.

---

## 📐 1. System Overview & Context Diagram

```mermaid
graph TD
    subgraph Mobile Application (Flutter Cross-Platform)
        UI[Flutter UI Screens / AuthScreen] --> Storage[Local Storage: shared_preferences]
        UI --> AuthService[AuthService Facade]
        AuthService --> StrategyAuth[IAuthProvider Interface]
        StrategyAuth -->|isSupabaseConfigured=true| SupabaseProvider[SupabaseAuthProvider]
        StrategyAuth -->|isSupabaseConfigured=false| MockProvider[MockAuthProvider]
        
        UI --> DynamicL10n[DynamicLocalizationService]
        DynamicL10n -->|HTTP GET /api/v1/l10n/lang| L10nAPI[Localization Router]

        UI --> ApiService[ApiReframingService]
        ApiService -->|HTTP POST /api/v1/reframe + target_language| API[FastAPI Thin APIRouters]
        ApiService -->|HTTP GET /api/v1/history + Bearer JWT| API
    end

    subgraph Backend Services (3-Tier Layered Python Services)
        API --> Limiter[slowapi Rate Limiter: 5/day Guests]
        Limiter --> ReframingService[ReframingService]
        API --> HistoryService[HistoryService]
        L10nAPI --> LocalizationService[LocalizationService]
        
        ReframingService --> Safety[SafetyService: 3-Tier Safety Engine]
        ReframingService -->|If Safe| Strategy[LLMService Strategy Factory]
        Strategy -->|LLM_PROVIDER=ollama| Ollama[Local Ollama AI Server]
        Strategy -->|LLM_PROVIDER=gemini| Gemini[Google Gemini 1.5 Flash API]
        Strategy -->|LLM_PROVIDER=mock| MockLLM[MockLLMProvider: Instant <1ms Zero-CPU Tests]

        LocalizationService -->|AI Auto-Translation Pass| Strategy
        
        ReframingService --> ORM[SQLModel ORM Layer]
        HistoryService --> ORM
    end

    subgraph Data & Auth Persistence
        SupabaseProvider -->|OAuth / Email| SupabaseCloud[(Supabase Auth Cloud)]
        ORM --> PostgreSQL[(PostgreSQL Database: ReframeRecord + language col)]
        API --> JWT[Supabase JWT Verification]
    end
```

---

## 🐍 2. Backend Architecture & File-by-File Specification

The backend adheres strictly to a **3-Tier Layered Architecture** (Controller $\rightarrow$ Business Service $\rightarrow$ Data Persistence):

```
       [ Client: Flutter Mobile App / Web / Curl ]
                           │ HTTP Request
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. ROUTER / API LAYER (app/api/v1/)                         │
│    - Thin HTTP Controllers (1–3 lines per endpoint)         │
│    - Handles HTTP status codes, query params, request bodies│
│    - Injects dependencies (Auth, DB session, Rate Limiter)  │
└──────────────────────────┬──────────────────────────────────┘
                           │ Pure Python Calls
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. SERVICE / BUSINESS LOGIC LAYER (app/services/)           │
│    - Pure domain logic, completely decoupled from HTTP       │
│    - ReframingService, SafetyService, HistoryService        │
│    - LLM Strategy Pattern (Ollama, Gemini, Mock)           │
│    - LocalizationService (UI translations)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │ ORM Models & Queries
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. DATA & PERSISTENCE LAYER (app/models/ & app/core/)       │
│    - SQLModel ORM (PostgreSQL tables: User, ReframeRecord)  │
│    - Pydantic DTO Schemas (Request/Response validation)     │
│    - Engine, Connection Pool, Supabase JWT verification     │
└─────────────────────────────────────────────────────────────┘
```

### Complete Backend Directory Anatomy & File Purposes

```
backend/
├── app/
│   ├── main.py                  # 🔌 Application Entry Point & Lifespan
│   ├── core/                    # ⚙️ Infrastructure & Cross-Cutting Concerns
│   │   ├── config.py            # Strongly-typed environment settings (BaseSettings)
│   │   ├── database.py          # PostgreSQL engine, pool & session generator
│   │   ├── security.py          # Supabase JWT signature verification & Auth dependencies
│   │   └── limiter.py           # slowapi rate limiter configuration (5/day guests)
│   ├── models/                  # 📄 Data Structures & Entities
│   │   ├── db_models.py         # PostgreSQL Database Tables via SQLModel (ORM)
│   │   └── schemas.py           # HTTP Request & Response Schemas via Pydantic (DTOs)
│   ├── api/v1/                  # 🌐 Thin HTTP APIRouters (Controllers)
│   │   ├── reframe_router.py    # POST /api/v1/reframe controller
│   │   ├── history_router.py    # GET/POST/DELETE /api/v1/history controllers
│   │   └── localization_router.py# GET /api/v1/l10n/{lang_code} controller
│   └── services/                # 🧠 Pure Business Logic Services
│       ├── reframing_service.py # Orchestrates safety + LLM strategy + DB persistence
│       ├── safety_service.py    # 3-tier guardrails (self-harm crisis / crime refusal)
│       ├── history_service.py   # Cloud history retrieval, favorites, ownership checks
│       ├── localization_service.py# In-memory dictionary + on-demand AI translation
│       ├── llm_service.py       # Factory method for AI Provider strategy
│       └── llm_providers/       # Strategy Pattern implementations
│           ├── base_provider.py # Abstract Base Class (ABC) interface & system prompt
│           ├── ollama_provider.py # Free local Ollama integration (qwen3-vl:8b)
│           ├── gemini_provider.py # Google Gemini 1.5 Flash cloud API integration
│           └── mock_provider.py # Instant <1ms zero-CPU provider for test suites
├── tests/                       # 🧪 Automated Test Verification Suites
└── requirements.txt             # 📦 Backend Dependencies
```

### Why Each File Exists:

1. **`app/main.py`**: Minimal 50-line bootstrap using FastAPI's `@asynccontextmanager` `lifespan` handler to auto-create tables on startup, register CORS for Flutter, bind `slowapi` exception handlers, and mount modular routers.
2. **`app/core/config.py`**: Pydantic `BaseSettings` singleton validating all environment variables at startup (fail-fast principle). Auto-parses `.env`.
3. **`app/core/database.py`**: Sets up SQLAlchemy connection pooling (`pool_pre_ping=True` to auto-heal dropped connections) and exposes the `get_session()` generator dependency to automatically open and close database sessions per request.
4. **`app/core/security.py`**: Validates Supabase JWTs via `HS256`. Exposes `get_current_user_optional` (allowing guest access) and `get_current_user` (requiring authentication).
5. **`app/core/limiter.py`**: Protects AI resources and costs by enforcing the guest daily limit (5/day) using `slowapi`.
6. **`app/models/schemas.py`**: Pydantic DTO models (`ReframeRequest`, `ReframeResponse`) ensuring strict incoming payload validation and automatic OpenAPI Swagger docs generation at `/docs`.
7. **`app/models/db_models.py`**: SQLModel ORM models (`User`, `ReframeRecord`, `SafetyLog`) defining table schemas, indices, and foreign keys.
8. **`app/api/v1/reframe_router.py`**: HTTP controller for thought reframing, delegating work directly to `ReframingService`.
9. **`app/api/v1/history_router.py`**: HTTP controllers for user history, favorite toggles, and deletions with ownership validation.
10. **`app/api/v1/localization_router.py`**: HTTP controller returning UI translation key-value maps.
11. **`app/services/reframing_service.py`**: Encapsulates the entire reframing business flow: validation $\rightarrow$ safety check $\rightarrow$ AI generation $\rightarrow$ conditional PostgreSQL save for authenticated users.
12. **`app/services/safety_service.py`**: Zero-tolerance guardrail engine evaluating crisis/self-harm and criminal policy violations.
13. **`app/services/history_service.py`**: PostgreSQL query logic ensuring users can only read, favorite, or delete their own records.
14. **`app/services/localization_service.py`**: Dynamic translation engine combining base English strings, cached common languages, and on-demand AI translation for any ISO code.
15. **`app/services/llm_service.py` & `llm_providers/`**: Implements the Strategy Pattern. Decouples the application from any single AI vendor (seamlessly switching between Ollama, Gemini, and Mock providers).

---

## 🌐 3. Dynamic Universal Multi-Language Architecture

The system implements a **zero-hardcoding universal multi-language architecture**:

1. **AI Reframing Engine**: The LLM system prompt instructs AI providers (`OllamaProvider`, `GeminiProvider`, `MockLLMProvider`) to auto-detect input prompt language and reframe natively in that exact language (or honor explicit `target_language` parameters), falling back to English (`en`) if ambiguous.
2. **PostgreSQL Storage**: `ReframeRecord` stores `language` (`"auto"`, `"uk"`, `"es"`, `"en"`, etc.) with index for clean filtering and analytics.
3. **Dynamic UI String Localization Endpoint (`GET /api/v1/l10n/{lang_code}`)**:
   * Returns UI string dictionaries for ANY requested ISO language code.
   * If the requested language is missing from memory, uses AI Strategy to auto-translate the 10 UI dictionary keys on demand and caches the result.
   * Guarantees fallback to English (`en`) if network or translation fails.
4. **Flutter Mobile Integration**: `DynamicLocalizationService` fetches string maps dynamically and translates keys with zero `.arb` files or hardcoded static language arrays in mobile code.

---

## 🔒 4. Authentication & PostgreSQL Database Schema

### `User` Table Model
* `id`: String (UUID primary key)
* `email`: String (indexed)
* `hashed_password`: Optional String
* `auth_provider`: String ("email", "google", "apple", "supabase")
* `created_at`: Datetime UTC

### `ReframeRecord` Table Model
* `id`: String (UUID primary key)
* `user_id`: Optional String (foreign key to `user.id`, indexed)
* `prompt_text`: String
* `reframed_text`: Optional String
* `language`: String (default `"auto"`, indexed)
* `is_safe`: Boolean (default `True`)
* `safety_category`: String (default `"none"`)
* `is_favorite`: Boolean (default `False`)
* `created_at`: Datetime UTC

---

## 🧪 5. Automated Verification & Testing

All backend unit and API test suites use `settings.LLM_PROVIDER = "mock"` to ensure **instant test execution (<3 seconds total)** with **0% extra CPU load**:
1. `tests/test_auth_flow.py`: 100% Pass
2. `tests/test_history_api.py`: 100% Pass
3. `tests/test_favorites_and_delete.py`: 100% Pass
4. `tests/test_rate_limiter.py`: 100% Pass
5. `tests/test_multi_lang.py`: 100% Pass (Verifies auto-detect, explicit language target, DB storage, and `/api/v1/l10n` endpoint).
