# 🤖 AI Agent Guidelines & Developer Protocols (`AGENTS.md`)

Welcome, AI Agent / Developer! This document serves as the authoritative operational guide for any AI Coding Assistant (Antigravity, Claude, ChatGPT, Cursor, Copilot) or human developer working on the **Silver Lining AI** codebase.

---

## 🏛️ Repository Overview & Architecture Principles

Silver Lining AI is a full-stack cross-platform mobile application that provides positive psychological perspective reframing for everyday stress and struggles, strictly guarded by a 3-tier safety engine.

```
/Users/ihormatiushenko/Workspace/silver_lining/
├── app/                  # 📱 Flutter Mobile Application (iOS / Android / Web)
└── backend/              # 🐍 Python FastAPI Backend & AI Strategy Engine
```

### Core Architecture Principles:
1. **Dual-Tier Guest / Authenticated Data Strategy**:
   - 🆓 **Guest Users (`user_id = None`)**: 0 database storage (local device history only using `shared_preferences`). Enforces 5 reframings/day rate limit (`slowapi`).
   - 🔓 **Authenticated Users (`user_id = "uuid"`)**: Persists reframings to PostgreSQL DB under `user_id` for cloud backup & multi-device sync!
2. **AI Provider Strategy Pattern**:
   - Local Dev: 100% Free Local Ollama (`qwen3-vl:8b`).
   - Cloud / Prod: Google Gemini 1.5 Flash.
   - Switch via `.env`: `LLM_PROVIDER=ollama` vs `LLM_PROVIDER=gemini`.
3. **3-Tier Safety Engine First**:
   - All prompts pass through `SafetyService` before touching any AI model!
   - Tier 1: 🚨 **Self-Harm Crisis Shield** (Triggers 988 Lifeline button).
   - Tier 2: 🛡️ **Crime Policy Refusal** (Refuses illegal/harmful prompts).
   - Tier 3: ✨ **Safe Reframing** (Calls AI engine).

---

## 🛠️ Environment & Setup Instructions

### 1. Python Backend Setup (`/backend`)
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

#### Environment Variables (`backend/.env`):
```env
DATABASE_URL=postgresql://ihormatiushenko@127.0.0.1:5432/silver_lining
SUPABASE_JWT_SECRET=dev-secret-key-must-be-at-least-32-bytes-long-for-jwt-security
GUEST_DAILY_LIMIT=5
LLM_PROVIDER=ollama
OLLAMA_URL=http://localhost:11434/api/generate
OLLAMA_MODEL=qwen3-vl:8b
```

#### Running Backend Server:
```bash
.venv/bin/python -m uvicorn app.main:app --port 8000 --reload
```

---

### 2. Flutter App Setup (`/app`)
```bash
cd app
flutter pub get
flutter run -d chrome
```

---

## 🧪 Verification & Testing Protocol

Before committing any changes, AI agents MUST run all automated verification suites:

### 1. Backend Verification:
```bash
cd backend
.venv/bin/python test_auth_flow.py
.venv/bin/python test_history_api.py
.venv/bin/python test_favorites_and_delete.py
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
   - Use Pydantic v2 syntax (avoid positional `Field(...)` ellipsis for required fields).
   - Use timezone-aware datetimes: `datetime.now(timezone.utc)`.
   - Use `asynccontextmanager` `lifespan` handler instead of deprecated `@app.on_event("startup")`.
   - Keep `main.py` clean by registering endpoints inside modular `APIRouter` files (`app/api/v1/`).
2. **Flutter / Dart**:
   - Follow standard BLoC / Service Interface pattern.
   - Use `ReframeResponse.fromJson` for strongly-typed API parsing.
   - Keep UI components inside `lib/widgets/` and page layouts in `lib/screens/`.

---

## 🤝 Inter-Agent Communication Notes

If you are another AI agent (Claude, Gemini, ChatGPT) reading this:
- The project tracker is maintained at `PROJECT_TRACKER.md`.
- All backend models are defined in `backend/app/models/db_models.py` (SQLModel) and `backend/app/models/schemas.py` (Pydantic v2).
- The safety policy rules are specified in `SAFETY_POLICIES.md`.
