# 🤖 AI Agent Guidelines & Developer Protocols (`AGENTS.md`)

Welcome, AI Agent / Developer! This document serves as the authoritative operational guide for any AI Coding Assistant (Antigravity, Claude, ChatGPT, Cursor, Copilot) or human developer working on the **Silver Lining AI** codebase.

---

## 🏛️ Repository Overview & Architecture Principles

Silver Lining AI is a full-stack cross-platform mobile application that provides positive psychological perspective reframing for everyday stress and struggles, strictly guarded by a 3-tier safety engine.

```
silver_lining/
├── app/                  # 📱 Flutter Mobile Application (iOS / Android / Web)
│   └── lib/
│       ├── config/       # ⚙️ AppConfig & environment feature flags
│       ├── screens/      # 📱 HomeScreen, HistoryScreen, AuthScreen (2FA Form)
│       ├── services/     # 🔐 AuthService & providers (IAuthProvider, SupabaseAuthProvider, MockAuthProvider)
│       ├── theme/        # 🎨 AppColors & AppTypography
│       └── widgets/      # 🧩 GlassCard, TypewriterText, PresetChips, ResultCard
└── backend/              # 🐍 Python FastAPI Backend Engine
    ├── app/
    │   ├── main.py       # 🔌 Ultra-clean 45-line entrypoint registering routers
    │   ├── api/v1/       # 🌐 Thin HTTP APIRouters (reframe_router, history_router)
    │   ├── core/         # ⚙️ config.py, database.py, security.py, limiter.py
    │   ├── models/       # 📄 db_models.py (SQLModel), schemas.py (Pydantic v2)
    │   └── services/     # 🧠 Business Service Layer (history_service, reframing_service, safety_service, llm_service)
```

### Core Architecture Principles:
1. **Flutter Auth Provider Strategy Pattern**:
   - **`IAuthProvider`** (`lib/services/providers/i_auth_provider.dart`): Abstract interface for authentication.
   - **`SupabaseAuthProvider`**: 100% Real production code using live `Supabase.instance.client.auth`.
   - **`MockAuthProvider`**: Isolated mock implementation for offline dev & UI testing.
   - **`AuthService`**: Clean facade delegating to the active provider.
2. **3-Tier Layered Backend Architecture**:
   - **Router Layer** (`app/api/v1/`): Thin 1-line controllers handling HTTP request/response routing.
   - **Service Layer** (`app/services/`): Pure Python business logic (`HistoryService`, `ReframingService`, `SafetyService`, `LLMService`).
   - **Database Layer** (`app/models/db_models.py`): Pure PostgreSQL `SQLModel` ORM entities (`User`, `ReframeRecord`, `SafetyLog`).
3. **Dual-Tier Guest / Authenticated Data Strategy**:
   - 🆓 **Guest Users (`user_id = None`)**: 0 database storage (local device history only using `shared_preferences`). Enforces 5 reframings/day rate limit (`slowapi`).
   - 🔓 **Authenticated Users (`user_id = "uuid"`)**: Persists reframings to PostgreSQL DB under `user_id` for cloud backup & multi-device sync!
4. **AI Provider Strategy Pattern**:
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

1. **Flutter / Dart**:
   - Use `IAuthProvider` interface pattern for auth logic.
   - Keep UI components inside `lib/widgets/` and page layouts in `lib/screens/`.
   - Ensure 0 linter warnings via `flutter analyze`.
2. **Python / FastAPI**:
   - Keep routers thin! Delegate business logic to `app/services/`.
   - Use Pydantic v2 syntax (avoid positional `Field(...)` ellipsis for required fields).
   - Use timezone-aware datetimes: `datetime.now(timezone.utc)`.
