# 🎓 Full-Stack Product Requirements & Learning Curriculum
*Silver Lining AI - Feature-by-Feature Guided Development (Dart/Flutter + Python/FastAPI)*

---

## 🎯 Product Mission & Core Value Proposition

**Silver Lining AI** is a psychological resilience app designed to help users process stress, setbacks, and negative thought patterns by discovering constructive, growth-oriented perspectives—**strictly protected by a zero-tolerance safety guardrail** preventing positive reframing for self-harm, suicide, crime, or abuse.

---

## 📋 Complete Product Requirements Specification

### 1. User Experience & Design Requirements
- **Dark Glassmorphism Aesthetic**: Slate navy background (`#0F172A`), glowing gradient accents (Indigo `#6366F1` $\rightarrow$ Pink `#EC4899`), translucent glass cards with backdrop blur.
- **Frictionless Entry**: Preset scenario chips (*"Failed Interview"*, *"Burnout"*, *"Breakup"*) for quick 1-tap testing.
- **Safety First**: Immediate UI transformation into **🚨 Safety Shield** mode for crisis/self-harm inputs, offering 1-tap emergency calling to 988 Crisis Lifeline.

### 2. Backend & System Requirements
- **Standalone API**: Custom Python 3.11 FastAPI server (`http://localhost:8000`).
- **Data Validation**: Strict Pydantic models for incoming requests and outgoing payloads.
- **3-Tier Guardrails**:
  1. Pre-filter keyword & classification rules (Self-Harm, Violence, Illicit/Crime).
  2. Gemini 1.5 Flash system prompt instructions & Pydantic schema validation.
  3. Output sanitizer & emergency payload builder.
- **Documentation**: Interactive OpenAPI / Swagger docs at `http://localhost:8000/docs`.

---

## 🛣️ Feature-by-Feature Learning Roadmap

| Milestone | Feature Name | Python / Backend Focus | Dart / Flutter Focus |
|---|---|---|---|
| **Feature 1** | **End-to-End Reframing Connection** | Live HTTP server execution, CORS handling, Gemini API key configuration, Pydantic response. | `http` package integration, async API requests, state management (Loading/Success/Error/Crisis). |
| **Feature 2** | **Reframing History & DB Persistence** | SQLite / PostgreSQL integration with SQLModel/Pydantic, `GET /api/v1/history` endpoint. | Offline caching (`shared_preferences`), ListView rendering, swipe-to-delete. |
| **Feature 3** | **Bookmarking & Favorite Silver Linings** | `POST /api/v1/favorites` & `DELETE /api/v1/favorites/{id}` endpoints. | Animated Heart button, Bottom Navigation Bar (`BottomNavigationBar`), Favorites Screen. |
| **Feature 4** | **Word-by-Word AI Text Streaming** | Server-Sent Events (SSE) streaming endpoint (`GET /api/v1/reframe/stream`). | Flutter `StreamBuilder` & Typewriter text rendering effect. |
| **Feature 5** | **1-Tap Emergency Hotline Integration** | Geolocation-aware crisis hotline API lookup. | `url_launcher` plugin for triggering native OS phone dialer (`tel:988`). |

---

## 🚀 Learning Methodology for Every Feature

For each feature, we will follow a 4-step hands-on learning flow:

1. 💡 **Product & Design Goal**: Why are we building this feature?
2. 🐍 **Backend Implementation (Python / FastAPI)**: Writing data models, endpoints, services, and running tests.
3. 📱 **Mobile Implementation (Dart / Flutter)**: Writing widgets, state logic, network requests, and handling UI states.
4. 🧪 **End-to-End Verification**: Testing the feature live between your mobile app and local Python backend!
