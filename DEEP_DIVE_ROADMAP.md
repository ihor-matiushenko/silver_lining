# 🗺️ Full-Stack Learning & Deep Dive Curriculum Roadmap (`DEEP_DIVE_ROADMAP.md`)

This tracking document records our progress in mastering **Dart & Flutter** (Mobile Frontend) and **Python & FastAPI** (Backend & AI) for a Senior JavaScript/TypeScript Engineer, ensuring smooth continuity across sessions.

---

## 📌 Status Summary
* **Current Checkpoint**: Session 1 Completed!
* **Next Session**: Session 2 $\rightarrow$ **Part 2: The AI Engine, 3-Tier Safety Engine & SQLModel ORM**
* **Context Preservation**: All architectural bugs identified on September 28, 2026, have been fixed and verified with 100% test pass rates!

---

## 🛠️ Summary of Session 1: Architecture & Bug Fixes (Completed)

### 1. Architectural Explanations Added to Docs
* **[ARCHITECTURE.md](file:///Users/ihormatiushenko/Workspace/silver_lining/ARCHITECTURE.md)**: Added Section 2 with 3-Tier Layered Architecture Diagram, full `backend/` directory tree, and file-by-file breakdown explaining *what* each file does and *why* it was designed that way.
* **[PYTHON_FASTAPI_GUIDE.md](file:///Users/ihormatiushenko/Workspace/silver_lining/PYTHON_FASTAPI_GUIDE.md)**: Updated Section 2 to reflect the modern structure with links to the architecture spec.
* **[AGENTS.md](file:///Users/ihormatiushenko/Workspace/silver_lining/AGENTS.md)**: Added the Continuous Documentation Sync rule.

### 2. Bugs Fixed & Verified
* 🐞 **Bug 1: Foreign Key Violation for New Users**: In [`reframing_service.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/services/reframing_service.py), auto-provisioned the `User` row in PostgreSQL if not already present before creating `ReframeRecord`.
* 🐞 **Bug 2: Guest Rate Limiter Blocking Authenticated Users**: In [`reframe_router.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/api/v1/reframe_router.py), added `exempt_when=is_authenticated_request` to `limiter.limit` so logged-in users have unlimited access. Verified in [`test_rate_limiter.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/tests/test_rate_limiter.py).
* 🐞 **Bug 3: AuthScreen Was an Orphan Widget**:
  - Connected [`HomeAppBar`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/app_bar/home_app_bar.dart) with an account/login action button navigating to `AuthScreen`.
  - Added a "Sign In" button to the guest banner in [`HistoryScreen`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/screens/history_screen.dart) and a "Sign Out" button in its AppBar.
* 🐞 **Bug 4: Mock Auth Dev Token Crashing Backend**: In [`security.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/core/security.py), added a development bypass for `dev_mock_jwt_token` so offline development and UI testing work without live Supabase credentials.
* 🐞 **Bug 5: Multi-Language Safety Bypass & False Positives**: In [`safety_service.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/services/safety_service.py), added multi-lingual crisis keywords (Ukrainian, Spanish, German, French) and switched to regex word boundaries (`\b`) to prevent false positives like "my account was hacked".
* 🐞 **Bug 7: Android Emulator URL**: In [`api_reframing_service.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/api_reframing_service.dart), configured host mapping to `10.0.2.2:8000` when running on Android.

---

## 🚀 Upcoming Deep Dive Roadmap

### 📍 Session 2 (Tomorrow): Part 2 - AI Engine, 3-Tier Safety & SQLModel ORM
* **Goal**: Understand Python AI integration, prompt engineering, guardrails, and database ORM design.
* **Files to Explore in Detail**:
  1. [`backend/app/services/safety_service.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/services/safety_service.py): How deterministic regex & classification guardrails work before any LLM token is billed.
  2. [`backend/app/services/llm_service.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/services/llm_service.py) & [`llm_providers/`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/services/llm_providers/): The Strategy Pattern in Python (`BaseLLMProvider`, `OllamaProvider`, `GeminiProvider`, `MockLLMProvider`).
  3. [`backend/app/services/localization_service.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/services/localization_service.py): Dynamic prompt auto-translation pass and memory caching.
  4. [`backend/app/models/db_models.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/models/db_models.py): SQLModel vs Prisma/TypeORM, declarative table declarations, foreign keys, and indexes.

### 📍 Session 3: Part 3 - Dart & Flutter Mobile UI & Design System
* **Goal**: Map React/TS frontend paradigms to Dart and Flutter widget trees.
* **Files to Explore in Detail**:
  1. [`app/lib/main.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/main.dart) & [`app/lib/screens/main_navigation_screen.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/screens/main_navigation_screen.dart): App bootstrap, MaterialApp, `IndexedStack`, and Bottom Navigation.
  2. [`app/lib/theme/app_colors.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/theme/app_colors.dart) & [`app_typography.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/theme/app_typography.dart): Design tokens in Flutter vs CSS variables / Tailwind.
  3. [`app/lib/widgets/glass_card.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/glass_card.dart) & [`app/lib/widgets/animations/typewriter_text.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/animations/typewriter_text.dart): Custom graphics, `BackdropFilter`, animations, and Ticker lifecycles.
  4. [`app/lib/widgets/forms/input_form_card.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/forms/input_form_card.dart) & [`chips/preset_chips.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/chips/preset_chips.dart): `TextEditingController` vs React controlled inputs (`useState`).

### 📍 Session 4: Part 4 - Mobile State, Networking, Auth & End-to-End Sync
* **Goal**: Master mobile asynchronous operations, offline persistence, and cloud synchronization.
* **Files to Explore in Detail**:
  1. [`app/lib/services/providers/`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/providers/): Abstract Auth Provider interface (`IAuthProvider`), live Supabase implementation vs Mock implementation.
  2. [`app/lib/services/api_reframing_service.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/api_reframing_service.dart): `http` package, header construction, JWT bearer injection, and error handling.
  3. [`app/lib/services/storage_service.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/storage_service.dart): `shared_preferences` key-value persistence vs React `localStorage`.
  4. [`app/lib/screens/history_screen.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/screens/history_screen.dart): Dual-mode data fetching (PostgreSQL Cloud vs local device history).
