# AI Silver Lining / Positivity Reframer - Project Tracking

## 🎯 Project Overview
An AI-powered mobile application (iOS & Android) that takes user problems, stress points, or daily struggles and provides positive perspective reframing, **strictly gated by multi-layered safety guardrails** to prevent reframing illegal acts, self-harm/suicide, crime, violence, or severe abuse.

---

## 📌 Phase Overview & Status

| Phase | Description | Status |
|---|---|---|
| **Phase 1** | Product Research & UX Design (Wireframes, Persona, Free Google tools / HTML prototypes) | 🟢 Complete (Interactive Prototype Ready) |
| **Phase 2** | AI Guardrail & Safety Architecture (Taxonomy, Moderation Pipeline, Hotline Routing) | 🟢 Specification Complete |
| **Phase 3** | System Architecture & Tech Stack Selection (Flutter + Custom Python/FastAPI Backend) | 🟢 Architecture Defined |
| **Phase 4** | Cost Estimation & Unit Economics (Models, API fees, Serverless infrastructure) | 🟢 Calculated |
| **Phase 5** | Testing & CI/CD Pipeline Strategy | 🟢 Defined |
| **Phase 6** | Agentic Harness & MCP Setup (Figma MCP, GitHub MCP, Subagents & Skills) | 🟢 Fully Configured |
| **Phase 7** | Mobile App Development (Flutter) | 🟢 Scaffolding & Mobile UI Complete |
| **Phase 8** | Custom Backend Development (Python 3.11 + FastAPI) | 🟢 Initialized & Pushed to GitHub |

---

## 📋 Task Checklist

### Phase 1: Product Research & UX Design
- [x] Define User Personas & Value Proposition
- [x] Design User Journey & Tone of Voice guidelines
- [x] Build interactive HTML/CSS UI mockups (`/prototype/index.html`)
- [x] Document Figma integration path & design tokens

### Phase 2: Safety & Moderation Engine (Critical Core)
- [x] Define Content Risk Taxonomy (Self-Harm, Illegal Acts, Violence, Hate, Crisis)
- [x] Design 3-tier Guardrail Architecture (Pre-filter Moderation API -> Pydantic Schema Rules -> Output Sanitization)
- [x] Design Crisis Intervention UX (Direct hotline numbers, emergency buttons, compassionate refusal messages)

### Phase 3: Technical Architecture
- [x] Mobile Stack: **Flutter (Dart)** - iOS & Android cross-platform UI
- [x] Backend Stack: **Custom Python Standalone Server (FastAPI + Pydantic + Uvicorn)**
- [x] AI Models: **Gemini 1.5 Flash** (Reframing) + **OpenAI Moderation API / Google Safety API** (Guardrails)

### Phase 4: Cost Analysis
- [x] Cost breakdown per 1,000 active users (~$0.086 per 1k requests)
- [x] Monthly cost comparison across scales (1K, 10K, 100K DAU)

### Phase 5: Testing & CI/CD
- [x] Define testing stack (Flutter widget tests, Pytest, Safety Red-Teaming suite)
- [x] CI/CD configuration setup (GitHub Actions + Fastlane)

### Phase 6: Agentic Harness & MCP Setup
- [x] Configure GitHub MCP server integration (`@modelcontextprotocol/server-github`)
- [x] Configure Figma MCP server integration (`@modelcontextprotocol/server-figma`)
- [x] Link Git remote `git@github.com:ihor-matiushenko/silver_lining.git`

### Phase 7 & 8: Codebase Implementation
- [x] Install Flutter SDK 3.44.8 (`/opt/homebrew/bin/flutter`)
- [x] Scaffold Flutter app (`flutter create --org com.silverlining app`)
- [x] Translate HTML glassmorphism UI into Flutter Widgets (`app/lib/main.dart`)
- [x] Initialize Python FastAPI backend inside `backend/` (`main.py`, `schemas.py`, `safety_service.py`, `llm_service.py`)
- [x] Containerize backend with Dockerfile
- [x] Push clean build to GitHub main branch

---
*Updated: 2026-08-11*
