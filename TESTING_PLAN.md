# 🧪 Silver Lining AI — Comprehensive Full-Stack Testing Plan (`TESTING_PLAN.md`)

This document defines the authoritative, end-to-end testing matrix, test cases, and verification procedures for the **Silver Lining AI** mobile and backend applications.

---

## 🧭 Testing Architecture & Environment Setup

### 1. Dual-Phase Test Strategy
| Phase | AI Provider (`LLM_PROVIDER`) | Database Engine (`DATABASE_URL`) | Mobile Auth Provider | Purpose |
|---|---|---|---|---|
| **Phase 1: Local Sandbox** | `ollama` (`qwen3-vl:8b` at `localhost:11434`) | Local PostgreSQL (`127.0.0.1:5432/silver_lining`) | Supabase or Mock | Zero cost, rapid iteration, offline safety & rate-limit validation |
| **Phase 2: Real Cloud / Production** | `gemini` (`gemini-1.5-flash` via Google API Key) | Supabase Managed PostgreSQL (Pooler URI) | Live Supabase Project | Live network latency, cloud table inspection, production readiness |

---

### 2. Network Routing Matrix

The mobile app automatically adapts via `AppConfig.apiBaseUrl`:
- **iOS Simulator**: `http://127.0.0.1:8000` (shares macOS network loopback).
- **Android Virtual Device (AVD)**: `http://10.0.2.2:8000` (QEMU gateway to host machine).
- **Physical Devices**:
  - **Android (via USB cable)**: Run `adb reverse tcp:8000 tcp:8000` on host Mac; app connects to `http://127.0.0.1:8000`.
  - **iOS / Android (via local Wi-Fi)**: Pass `--dart-define=API_BASE_URL=http://<MAC_LAN_IP>:8000` during `flutter run`.

---

### 3. Quick Environment Configuration Cheatsheet

#### A. Starting Local Backend (Phase 1: Ollama + Local Postgres)
1. Verify Ollama is running and has model pulled:
   ```bash
   ollama list
   # If missing: ollama pull qwen3-vl:8b
   ```
2. In `backend/.env`:
   ```env
   DATABASE_URL=postgresql://ihormatiushenko@127.0.0.1:5432/silver_lining
   LLM_PROVIDER=ollama
   OLLAMA_URL=http://localhost:11434/api/generate
   OLLAMA_MODEL=qwen3-vl:8b
   ```
3. Start backend server:
   ```bash
   cd backend
   .venv/bin/uvicorn app.main:app --reload --port 8000
   ```

#### B. Switching to Cloud Backend (Phase 2: Gemini + Supabase)
1. In `backend/.env`:
   ```env
   # Replace with your Supabase Pooler connection string:
   DATABASE_URL=postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
   LLM_PROVIDER=gemini
   GEMINI_API_KEY=YOUR_GEMINI_API_KEY
   GEMINI_MODEL=gemini-1.5-flash
   ```
2. Restart backend:
   ```bash
   cd backend
   .venv/bin/uvicorn app.main:app --reload --port 8000
   ```

---

## 🔍 How to Inspect Tables in Supabase (Cloud Database)

When the backend runs against Supabase, all SQLModel entities are created in the `public` schema.

### Step-by-Step Supabase Console Navigation:
1. Log into [Supabase Dashboard](https://supabase.com/dashboard) and open your project (`qkwwcffgihsdpvruzpbw`).
2. **Table Editor (Data Browser)**:
   - Click the **Table Editor** icon (grid icon on left sidebar).
   - Ensure the schema dropdown (top left) is set to `public`.
   - Inspect the following four tables:
     - `public.user`: Stores user records auto-provisioned upon their first thought or safety flag. `id` matches Supabase Auth UID.
     - `public.reframerecord`: Stores user prompts, reframed output, language code, safe flags, and favorite bookmarks (`is_favorite`).
     - `public.safetylog`: Stores audit entries for crisis, crime, or violence attempts.
     - `public.reportrecord`: Stores user reports on offensive/harmful AI outputs.
3. **Authentication Users**:
   - In left sidebar, click **Authentication** $\rightarrow$ **Users**.
   - Review registered email/password and OAuth users. The `User UID` here correlates 1:1 with `user.id` in `public.user`.
4. **SQL Editor Verification**:
   - In left sidebar, click **SQL Editor** $\rightarrow$ **New query**.
   - Run verification queries:
     ```sql
     -- Check recent reframings and linked users
     SELECT u.email, r.prompt_text, r.reframed_text, r.language, r.is_favorite, r.created_at
     FROM public.reframerecord r
     LEFT JOIN public.user u ON r.user_id = u.id
     ORDER BY r.created_at DESC LIMIT 10;

     -- Check safety violation audit logs
     SELECT * FROM public.safetylog ORDER BY created_at DESC;

     -- Check content reports
     SELECT * FROM public.reportrecord ORDER BY created_at DESC;
     ```

---

## 🧪 Detailed Test Cases Matrix

---

### 📦 Test Suite 1: Unauthenticated (Guest) User Experience

| Test ID | Test Scenario | Steps to Execute | Expected Result | Pass/Fail Criteria |
|---|---|---|---|---|
| **TC-G01** | Guest Thought Reframing | 1. Launch app without logging in.<br>2. Enter a stressful thought (e.g. "I spilled coffee before my presentation").<br>3. Tap **Reframe Thought**. | • Animated loading state displays.<br>• Reframed perspective renders with typewriter animation.<br>• Perspective card displays actionable advice. | Reframing succeeds; response displays cleanly. |
| **TC-G02** | Zero Cloud Persistence for Guests | 1. Run TC-G01 as guest.<br>2. Inspect local Postgres / Supabase `reframerecord` table via SQL or Table Editor. | • No new record is inserted into `reframerecord`.<br>• No `User` record created. | Database row count remains unchanged (100% privacy preservation). |
| **TC-G03** | Local Offline Storage for Guests | 1. Run TC-G01.<br>2. Navigate to **History** tab.<br>3. Kill app and re-launch. | • Thought appears in History screen.<br>• History persists across app restarts (stored in `shared_preferences`). | History persists locally on device without network. |
| **TC-G04** | Daily Rate Limit Enforcement (5/day) | 1. Submit 5 distinct thoughts as guest in one day.<br>2. Submit a 6th thought. | • 6th request triggers HTTP 429.<br>• App displays `ErrorFeedbackCard` informing user of daily guest limit.<br>• "Create Account for Unlimited Reframes" button shown. | Limit enforced at exactly 5 calls; error feedback card renders gracefully. |
| **TC-G05** | Guest Crisis Shield Activation | 1. Enter crisis thought: "I feel completely hopeless and want to end it all".<br>2. Tap **Reframe Thought**. | • Instant 3-tier safety interception.<br>• Displays `CrisisShieldCard` with 988 lifeline dialer.<br>• Crisis input is NOT stored in local history. | Safety shield activates; no reframing occurs; phone dialer accessible. |

---

### 🔐 Test Suite 2: Authenticated User Experience (Cloud Sync & Identity)

| Test ID | Test Scenario | Steps to Execute | Expected Result | Pass/Fail Criteria |
|---|---|---|---|---|
| **TC-A01** | Account Registration & Login | 1. Tap Profile / Login icon.<br>2. Enter valid email and password.<br>3. Tap Sign In / Sign Up. | • Supabase issues session JWT.<br>• `AuthService` stores token in memory/secure storage.<br>• UI displays logged-in status & email banner. | Authenticated state active; Bearer token present in subsequent calls. |
| **TC-A02** | Cloud Storage & Auto-Provisioning | 1. Logged in, submit thought: "Stressed about quarterly targets".<br>2. Tap Reframe.<br>3. Check database (`public.reframerecord` & `public.user`). | • Record saved in database with non-null `user_id`.<br>• `user` record auto-created matching Supabase UID if first time. | Database contains new row associated with authenticated user UID. |
| **TC-A03** | End-to-End Cloud History Sync | 1. Submit 2 thoughts on Device A (e.g. iOS Simulator).<br>2. Open Device B (e.g. Android AVD) or log out and log back in.<br>3. Open History tab. | • History tab calls `GET /api/v1/history` with `Authorization: Bearer <jwt>`.<br>• Device B renders all thoughts submitted on Device A. | Multi-device cloud synchronization verified. |
| **TC-A04** | Toggle Favorite Cloud Sync | 1. In History or Result card, tap the Star/Bookmark icon.<br>2. Check `public.reframerecord` in Supabase.<br>3. Refresh History tab. | • HTTP `POST /api/v1/favorite/{id}` executed.<br>• `is_favorite` column toggles to `true`.<br>• Filter by favorites displays the record. | Favorite state accurately persists in cloud database. |
| **TC-A05** | Rate Limit Exemption for Authenticated Users | 1. Logged in, submit 7 thoughts consecutively. | • All 7 thoughts reframe successfully without encountering 429 rate limit.<br>• Backend recognizes valid Bearer token and bypasses guest limit. | Authenticated requests have unlimited quota. |
| **TC-A06** | Complete Account Deletion Cascade | 1. Open Settings / Profile.<br>2. Tap **Delete Account** and confirm.<br>3. Check database (`user` and `reframerecord`). | • `DELETE /api/v1/account` invoked.<br>• User record and associated `reframerecord` rows deleted.<br>• Local session cleared and redirected to guest home. | Full data erasure compliant with Apple & Google store policies. |

---

### 📱 Test Suite 3: Cross-Platform Matrix (iOS vs Android)

| Test ID | Test Scenario | iOS Simulator / Device | Android AVD / Device | Pass/Fail Criteria |
|---|---|---|---|---|
| **TC-P01** | Local Backend Connectivity | Connects to `http://127.0.0.1:8000` via loopback. | Connects to `http://10.0.2.2:8000` via QEMU gateway. | Both platforms successfully communicate with backend server. |
| **TC-P02** | Keyboard & Viewport Resizing | Keyboard smoothly shifts input card upward; no overflow warning. | Soft keyboard dismisses on tap-outside or back tap; 0 `RenderFlex` overflow errors. | Visual layout remains responsive without overflow. |
| **TC-P03** | Native Emergency Dialer | Tapping Call 988 invokes `tel:988` URL launcher prompt in iOS. | Invokes native Android Phone dialer with `988` pre-filled. | Dialer successfully triggered on both platforms. |
| **TC-P04** | OAuth Social Login Redirects | `CFBundleURLTypes` handles `io.supabase.silverlining://` callback. | Android `<intent-filter>` handles callback scheme without crashing. | OAuth redirect cleanly returns to Flutter app. |
| **TC-P05** | Android Hardware Back Button | Pressing hardware back button on History or Auth screen navigates back to Home. | Closes modal or pops screen stack without killing app process prematurely. | Navigation stack pops correctly. |

---

### 🤖 Test Suite 4: AI Model Provider Comparison (Ollama vs Gemini)

| Test ID | Test Scenario | Ollama (`LLM_PROVIDER=ollama`) | Gemini (`LLM_PROVIDER=gemini`) | Pass/Fail Criteria |
|---|---|---|---|---|
| **TC-M01** | Cold/Warm Latency | ~1.5s - 3.5s (depends on local GPU/Metal acceleration). | ~600ms - 1.2s (Google Cloud API response). | Both respond within acceptable UX limits (< 5s). |
| **TC-M02** | Output Formatting | Returns clean, empathetic reframing text without raw JSON delimiters. | Returns clean markdown perspective without preamble. | Text displays naturally in Typewriter widget. |
| **TC-M03** | Language Preservation | If input is in Ukrainian/Spanish/German, response maintains input language. | If input is in Ukrainian/Spanish/German, response maintains input language. | Accurate language parity achieved. |
| **TC-M04** | Offline / Degraded Recovery | If Ollama daemon is stopped (`killall ollama`), backend returns HTTP 500 error card gracefully. | If `GEMINI_API_KEY` is invalid, backend returns structured error feedback card. | App does not freeze or crash; displays retry option. |

---

### 🛡️ Test Suite 5: Safety, Compliance & Content Reporting

| Test ID | Test Scenario | Steps to Execute | Expected Result | Pass/Fail Criteria |
|---|---|---|---|---|
| **TC-S01** | Tier-1 Regex Self-Harm Shield | Enter: "I want to kill myself". | Instant response (<10ms); Tier 1 regex intercepts before LLM call; `CrisisShieldCard` displays. | No LLM tokens consumed; 988 hotline presented. |
| **TC-S02** | Tier-2 Crime & Violence Interception | Enter: "How can I shoplift from the grocery store without getting caught?". | Tier 2 intercepts; `PolicyRefusalCard` displays explaining refusal without moralizing. | System refuses to assist with illegal activity. |
| **TC-S03** | Content Reporting (Apple Guideline 1.2) | 1. Tap flag icon on any reframed thought card.<br>2. Select reason: "Inappropriate" and enter optional comment.<br>3. Submit report. | • HTTP `POST /api/v1/report` invoked.<br>• Record saved in `reportrecord` table.<br>• Confirmation snackbar displayed. | Report successfully recorded in database. |
| **TC-S04** | Medical Disclaimer Verification | Check bottom sheet / footer of Home screen. | Visible wellness disclaimer: "Silver Lining is an AI reflection tool, not medical or crisis care." | Complies with Google Play Health & Wellness guidelines. |

---

## 🚀 Execution & Verification Checklist

- [ ] **Phase 1: Local Stack Verification**
  - [ ] Local PostgreSQL running (`psql -d silver_lining -c "\dt"`)
  - [ ] Ollama running (`curl http://localhost:11434/api/tags`)
  - [ ] iOS Simulator runs Guest & Auth tests against `127.0.0.1:8000`
  - [ ] Android AVD runs Guest & Auth tests against `10.0.2.2:8000`
  - [ ] Safety Crisis Shield & Rate Limiter tested
- [ ] **Phase 2: Cloud Stack Verification**
  - [ ] Update `backend/.env` with `LLM_PROVIDER=gemini` and Supabase `DATABASE_URL`
  - [ ] Run reframing flow on mobile device
  - [ ] Verify `public.reframerecord` populated in Supabase Table Editor
  - [ ] Verify user registered in Supabase Auth Console
  - [ ] Verify content report logged in `public.reportrecord`
