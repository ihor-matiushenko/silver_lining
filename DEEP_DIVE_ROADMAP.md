# 🗺️ Full-Stack Learning & Deep Dive Curriculum Roadmap (`DEEP_DIVE_ROADMAP.md`)

This tracking document records our progress in mastering **Dart & Flutter** (Mobile Frontend) and **Python & FastAPI** (Backend & AI) for a Senior JavaScript/TypeScript Engineer, ensuring smooth continuity across sessions.

---

## 📌 Status Summary
* **Current Checkpoint**: Session 3 Completed! (Part 3: Dart & Flutter Mobile UI & Design System)
* **Next Session**: Session 4 $\rightarrow$ **Part 4: Mobile State, Networking, Auth & End-to-End Sync**
* **Context Preservation**: All architectural bugs verified, all backend test suites 100% pass, flutter analyze & flutter test 100% pass!

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

### 3. Mobile Architectural Refactoring & Bug Fixes (Session 3)
* 🐞 **Bug: Authenticated Thought Leakage into Local Storage**: In [`home_screen.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/screens/home_screen.dart), added `!AuthService().isAuthenticated` check before saving to `StorageService` (`shared_preferences`), preventing logged-in user thoughts from leaking into offline guest storage.
* 🐞 **Bug: Inconsistent Android Emulator Host**: Moved platform-aware `apiBaseUrl` (`10.0.2.2:8000` on Android, `127.0.0.1:8000` on iOS/web) into [`app_config.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/config/app_config.dart), used by both `ApiReframingService` and `DynamicLocalizationService`.
* 🐞 **Bug: Broken Profile/Sign-Out Flow**: Updated [`home_app_bar.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/app_bar/home_app_bar.dart) with `ListenableBuilder` and an Account Dialog showing email and "Sign Out" when authenticated, instead of forcing the user back to the login screen.
* 🧼 **Modularization: Card Decomposition**: Extracted inline widgets from `HistoryScreen` into reusable [`HistoryCard`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/cards/history_card.dart) and [`GuestHistoryBanner`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/cards/guest_history_banner.dart). Added unit and widget tests in [`cards_test.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/test/cards_test.dart).
* 🧼 **Modularization: AuthScreen Decomposition**: Decomposed 395-line `AuthScreen` into modular [`PrimaryAuthForm`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/forms/primary_auth_form.dart) and [`TwoFactorAuthForm`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/widgets/forms/two_factor_auth_form.dart), reusing `GlassCard`.
* ⚡ **Reactive State**: Made [`AuthService`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/auth_service.dart) extend `ChangeNotifier` so all UI elements reactively update on sign-in and sign-out.
* 🔐 **Live Supabase Integration & URL Sanitization**: Configured live credentials in [`app_config.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/config/app_config.dart), added auto-trimming for trailing `/rest/v1` to prevent 404s, and added cold-start `_isInitialized` guards in [`supabase_auth_provider.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/providers/supabase_auth_provider.dart).
* 🛡️ **Dual-Engine JWT Verification (ES256 + HS256)**: Upgraded [`security.py`](file:///Users/ihormatiushenko/Workspace/silver_lining/backend/app/core/security.py) with `PyJWKClient` to automatically resolve modern asymmetric ECC keys via Supabase JWKS alongside symmetric fallback.

---

## 🚀 Upcoming Deep Dive Roadmap

### 📍 Session 4 (Next Time): Part 4 - Mobile State, Networking, Auth & End-to-End Sync
* **Goal**: Master mobile asynchronous operations, offline persistence, and cloud synchronization.
* **Files to Explore in Detail**:
  1. [`app/lib/services/providers/`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/providers/): Abstract Auth Provider interface (`IAuthProvider`), live Supabase implementation vs Mock implementation.
  2. [`app/lib/services/api_reframing_service.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/api_reframing_service.dart): `http` package, header construction, JWT bearer injection, and error handling.
  3. [`app/lib/services/storage_service.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/services/storage_service.dart): `shared_preferences` key-value persistence vs React `localStorage`.
  4. [`app/lib/screens/history_screen.dart`](file:///Users/ihormatiushenko/Workspace/silver_lining/app/lib/screens/history_screen.dart): Dual-mode data fetching (PostgreSQL Cloud vs local device history).
