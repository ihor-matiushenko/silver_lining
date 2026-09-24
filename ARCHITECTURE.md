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

## 🌐 2. Dynamic Universal Multi-Language Architecture

The system implements a **zero-hardcoding universal multi-language architecture**:

1. **AI Reframing Engine**: The LLM system prompt instructs AI providers (`OllamaProvider`, `GeminiProvider`, `MockLLMProvider`) to auto-detect input prompt language and reframe natively in that exact language (or honor explicit `target_language` parameters), falling back to English (`en`) if ambiguous.
2. **PostgreSQL Storage**: `ReframeRecord` stores `language` (`"auto"`, `"uk"`, `"es"`, `"en"`, etc.) with index for clean filtering and analytics.
3. **Dynamic UI String Localization Endpoint (`GET /api/v1/l10n/{lang_code}`)**:
   * Returns UI string dictionaries for ANY requested ISO language code.
   * If the requested language is missing from memory, uses AI Strategy to auto-translate the 10 UI dictionary keys on demand and caches the result.
   * Guarantees fallback to English (`en`) if network or translation fails.
4. **Flutter Mobile Integration**: `DynamicLocalizationService` fetches string maps dynamically and translates keys with zero `.arb` files or hardcoded static language arrays in mobile code.

---

## 🔒 3. Authentication & PostgreSQL Database Schema

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

## 🧪 4. Automated Verification & Testing

All backend unit and API test suites use `settings.LLM_PROVIDER = "mock"` to ensure **instant test execution (<3 seconds total)** with **0% extra CPU load**:
1. `tests/test_auth_flow.py`: 100% Pass
2. `tests/test_history_api.py`: 100% Pass
3. `tests/test_favorites_and_delete.py`: 100% Pass
4. `tests/test_rate_limiter.py`: 100% Pass
5. `tests/test_multi_lang.py`: 100% Pass (Verifies auto-detect, explicit language target, DB storage, and `/api/v1/l10n` endpoint).
