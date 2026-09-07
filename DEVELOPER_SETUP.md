# 🚀 Developer & AI Agent Setup Guide (`DEVELOPER_SETUP.md`)

Welcome to **Silver Lining AI**! This guide provides full setup, architectural concepts, and execution steps for human developers and AI coding agents.

---

## 💻 1. Local Development Quickstart

### Prerequisites
- **Python 3.11+**
- **Flutter SDK 3.29+**
- **PostgreSQL 14+** (running on local port 5432)
- **Ollama** (optional for free local AI reframing with model `qwen3-vl:8b`)

---

### Step 1: Clone Repository & Setup Environment
```bash
git clone silver_lining.git
cd silver_lining
```

---

### Step 2: Backend Setup (`/backend`)
```bash
cd backend

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Environment Variables (`backend/.env`):
Create `backend/.env` (or copy from `backend/.env.example`):
```env
# 🐘 Local PostgreSQL Database Connection URL
DATABASE_URL=postgresql://username:password@127.0.0.1:5432/silver_lining

# 🔐 Supabase Auth JWT Secret Key (Minimum 32 bytes)
SUPABASE_JWT_SECRET=dev-secret-key-must-be-at-least-32-bytes-long-for-jwt-security

# 🛡️ Guest Daily Request Limit (Default 5 requests/day)
GUEST_DAILY_LIMIT=5

# 🤖 AI Provider Strategy Choice: "ollama" (Free Local) or "gemini" (Cloud)
LLM_PROVIDER=ollama
OLLAMA_URL=http://localhost:11434/api/generate
OLLAMA_MODEL=qwen3-vl:8b

# Google Gemini Settings (Optional cloud alternative)
GEMINI_API_KEY=
GEMINI_MODEL=gemini-1.5-flash
```

#### Run Local Backend Server:
```bash
.venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```
- Interactive Swagger API Docs available at: [http://localhost:8000/docs](http://localhost:8000/docs)

---

### Step 3: Mobile App Setup (`/app`)
```bash
cd app
flutter pub get
flutter run -d chrome
```

---

## 🧪 2. Running Automated Verification Suites

Before pushing code changes, always run the full automated verification test suite:

### Backend Test Suites:
```bash
cd backend
.venv/bin/python test_auth_flow.py            # Tests JWT Auth & Guest DB Skip
.venv/bin/python test_history_api.py           # Tests GET /history
.venv/bin/python test_favorites_and_delete.py  # Tests Favorite & Delete endpoints
.venv/bin/python test_rate_limiter.py         # Tests slowapi Guest Rate Limiter
```

### Flutter Mobile Test Suites:
```bash
cd app
flutter analyze                               # Enforces 0 linter errors
flutter test                                  # Runs widget & unit tests
```

---

## 🧠 3. Core Architecture & Key Concepts Learned

### 🏛️ 3-Tier Layered Architecture
- **Router Layer** (`app/api/v1/`): Thin HTTP controllers (`reframe_router.py`, `history_router.py`).
- **Service Layer** (`app/services/`): Pure Python business logic (`ReframingService`, `HistoryService`, `SafetyService`, `LLMService`).
- **Database Layer** (`app/models/db_models.py`): Pure PostgreSQL `SQLModel` ORM entities (`User`, `ReframeRecord`, `SafetyLog`).

### 🆓 Guest vs. Authenticated User Strategy
- **Guest Users (`user_id = None`)**: 0 database storage (local device history only using `shared_preferences`). Enforces 5 reframings/day rate limit (`slowapi`).
- **Authenticated Users (`user_id = "uuid"`)**: Persists reframings to PostgreSQL DB under `user_id` for cloud backup & multi-device sync!

### 🤖 AI Strategy Pattern
- Zero-code switching between **Local Ollama** (100% Free local AI) and **Google Gemini 1.5 Flash** (Cloud AI) via `LLM_PROVIDER` in `.env`.
