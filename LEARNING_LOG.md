# 🎓 Personal Learning Log & Skill Progression
*Silver Lining AI - Full-Stack Mobile & AI Engineering Journey*

---

## 👤 Learner Profile
- **Starting Background**: Senior Frontend Engineer (HTML/CSS, JavaScript/TypeScript, React, UI/UX).
- **Target Skills**: Cross-Platform Mobile Development (Dart/Flutter), AI System Design & Safety, Custom Python Backends (FastAPI & Pydantic), LLM Integration (Gemini 1.5 Flash).

---

## 🏆 Concept & Skill Mastery Tracker

### 1. Mobile Development (Dart & Flutter)
- [x] **Flutter Architecture**: Understanding Widget Trees (`StatelessWidget` vs. `StatefulWidget`).
- [x] **React $\rightarrow$ Flutter Mapping**: Translating JSX/Flexbox to `Row`, `Column`, `Container`, `Padding`, and `Wrap`.
- [x] **State Management**: Using Dart `setState()` for local reactive state mutations.
- [x] **Dark Glassmorphism UI**: Implementing `BoxDecoration`, custom gradients, `Border.all`, and `withValues(alpha)`.
- [x] **Network & HTTP**: Using `package:http` (`http.post`, `jsonEncode`, `jsonDecode`, timeout handling, and offline fallback).
- [ ] **Data Persistence**: Offline caching (`shared_preferences` / `hive`).
- [ ] **Native OS Integration**: Triggering phone dialer via `url_launcher`.

### 2. Backend & System Design (Python & FastAPI)
- [x] **Python 3.11 Fundamentals**: Virtual environments (`.venv`), package management (`requirements.txt`).
- [x] **TypeScript $\rightarrow$ Python Mapping**: Understanding Python type hints, `async def`, module imports, and `sys.path`.
- [x] **FastAPI Framework**: Setting up ASGI server (Uvicorn), CORS middleware, and OpenAPI Swagger docs (`/docs`).
- [x] **Pydantic Data Models**: Creating schema models (`ReframeRequest`, `ReframeResponse`) for strict type safety.
- [x] **3-Tier AI Safety Engine**: Implementing deterministic pre-filters, category rules (crisis/crime), and crisis payload transformers.
- [ ] **Database Integration**: Relational modeling with SQLModel / SQLite / PostgreSQL.
- [ ] **Streaming AI Responses**: Server-Sent Events (SSE) streaming.

### 3. AI Engineering & Safety Guardrails
- [x] **LLM Integration**: Google Gemini 1.5 Flash API client configuration.
- [x] **Zero-Tolerance Safety Rules**: Preventing reframing for self-harm, suicide, violence, or illegal acts.
- [x] **Crisis Intervention UX**: 988 Crisis Lifeline integration & emergency resource payloads.
- [x] **Unit Economics**: Token math and financial modeling ($0.086 / 1k requests).

### 4. Tooling, Agentic Harness, & IDE
- [x] **MCP Configuration**: GitHub MCP (`@modelcontextprotocol/server-github`) & Figma MCP (`@modelcontextprotocol/server-figma`).
- [x] **IDE Optimization**: Resolving monorepo search paths using `.vscode/settings.json` and `pyrightconfig.json`.
- [x] **Git & CI Workflow**: Multi-file commit discipline, Git remotes, and zero-error static analysis (`flutter analyze`).

---

## 📜 Learning Log Entries

### 🗓️ Entry 1: Project Setup & Mobile Scaffold
- **Concepts Learned**: Installed Flutter 3.44.8 SDK, mapped React concepts to Flutter widgets, created glassmorphism UI in Dart.
- **Key Takeaway**: Flutter's `Column` is identical to `flex-direction: column` in CSS!

### 🗓️ Entry 2: Custom Python FastAPI Backend & Safety Engine
- **Concepts Learned**: Selected Python + FastAPI for maximum AI ecosystem compatibility, built Pydantic schemas, designed 3-tier safety guardrails.
- **Key Takeaway**: Pydantic validates incoming JSON payload types automatically, just like Zod in TypeScript!

### 🗓️ Entry 3: Feature 1 - End-to-End Network Connection
- **Concepts Learned**: Installed `http` package, made asynchronous `http.post` REST requests in Dart, parsed JSON response maps, added offline fallback handlers.
- **Key Takeaway**: Dart's `jsonDecode(response.body)` converts JSON strings directly into typed Dart `Map<String, dynamic>` objects.
