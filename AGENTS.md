# 🤖 AI Agent Guidelines & Developer Protocols (`AGENTS.md`)

Welcome, AI Agent / Developer! This document serves as the authoritative operational guide for any AI Coding Assistant (Antigravity, Claude, ChatGPT, Cursor, Copilot) or human developer working on the **Silver Lining AI** codebase.

---

## 🏛️ Repository Overview & Architecture Principles

Silver Lining AI is a full-stack cross-platform mobile application that provides positive psychological perspective reframing for everyday stress and struggles, strictly guarded by a 3-tier safety engine.

```
silver_lining/
├── app/                  # 📱 Flutter Mobile Application (iOS / Android / Web)
└── backend/              # 🐍 Python FastAPI Backend Engine
    ├── app/
    │   ├── main.py       # 🔌 Ultra-clean 45-line entrypoint registering routers
    │   ├── api/v1/       # 🌐 Thin HTTP APIRouters (reframe_router, history_router)
    │   ├── core/         # ⚙️ config.py, database.py, security.py, limiter.py
    │   ├── models/       # 📄 db_models.py (SQLModel), schemas.py (Pydantic v2)
    │   └── services/     # 🧠 Business Service Layer (history_service, reframing_service, safety_service, llm_service)
```

### Core Architecture Principles:
1. **3-Tier Layered Backend Architecture**:
   - **Router Layer** (`app/api/v1/`): Thin 1-line controllers that handle HTTP request/response routing.
   - **Service Layer** (`app/services/`): Encapsulates 100% of business logic (`HistoryService`, `ReframingService`, `SafetyService`, `LLMService`).
   - **Database Layer** (`app/models/db_models.py`): Pure PostgreSQL `SQLModel` ORM entities (`User`, `ReframeRecord`, `SafetyLog`).
2. **Dual-Tier Guest / Authenticated Data Strategy**:
   - 🆓 **Guest Users (`user_id = None`)**: 0 database storage (local device history only using `shared_preferences`). Enforces 5 reframings/day rate limit (`slowapi`).
   - 🔓 **Authenticated Users (`user_id = "uuid"`)**: Persists reframings to PostgreSQL DB under `user_id` for cloud backup & multi-device sync!
3. **AI Provider Strategy Pattern**:
   - Local Dev: 100% Free Local Ollama (`qwen3-vl:8b`).
   - Cloud / Prod: Google Gemini 1.5 Flash.
   - Switch via `.env`: `LLM_PROVIDER=ollama` vs `LLM_PROVIDER=gemini`.

---

## 🧪 Verification & Testing Protocol

Before committing any changes, AI agents MUST run all automated verification suites:

### 1. Backend Verification:
```bash
cd backend
.venv/bin/python test_auth_flow.py
.venv/bin/python test_history_api.py
.venv/bin/python test_favorites_and_delete.py
.venv/bin/python test_rate_limiter.py
```

### 2. Flutter Mobile Verification:
```bash
cd app
flutter analyze
flutter test
```

---

## 📜 Coding Conventions for AI Agents

1. **Python / FastAPI**:
   - Keep routers thin! Delegate business logic to `app/services/`.
   - Use Pydantic v2 syntax (avoid positional `Field(...)` ellipsis for required fields).
   - Use timezone-aware datetimes: `datetime.now(timezone.utc)`.
   - Use `asynccontextmanager` `lifespan` handler instead of deprecated `@app.on_event("startup")`.
2. **Flutter / Dart**:
   - Follow standard BLoC / Service Interface pattern.
   - Use `ReframeResponse.fromJson` for strongly-typed API parsing.
   - Keep UI components inside `lib/widgets/` and page layouts in `lib/screens/`.
