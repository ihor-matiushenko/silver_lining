# 🐍 Python & FastAPI Learning Guide for Frontend Developers

Welcome to Python & FastAPI! As a JavaScript/TypeScript frontend developer, you will find Python and FastAPI surprisingly intuitive. 

FastAPI uses **type hints** (like TypeScript) and **Pydantic** (like Zod), and automatically generates interactive API documentation at `http://localhost:8000/docs`.

---

## 🔁 1. Concept Mapping: TypeScript/Express vs. Python/FastAPI

| Concept | **TypeScript / Node (Express/Fastify)** | 🐍 **Python / FastAPI** |
|---|---|---|
| **Package Manager** | `npm` / `yarn` / `pnpm` | `uv` / `pip` (with `requirements.txt` or `pyproject.toml`) |
| **Runtime / Server** | Node.js / Bun | Python 3.11+ / `uvicorn` (ASGI Server) |
| **HTTP Framework** | `express` / `fastify` | `fastapi` |
| **Type System** | `interface User { id: string }` | `class User(BaseModel): id: str` (Pydantic) |
| **Data Validation** | Zod / Yup | Pydantic (built directly into FastAPI!) |
| **Async Code** | `async function fetchData(): Promise<Data>` | `async def fetch_data() -> Data:` |
| **Imports** | `import { Router } from 'express'` | `from fastapi import APIRouter` |
| **API Docs** | Swagger UI (manual setup) | **Automatic** at `/docs` (Interactive OpenAPI) |

---

## 🏗️ 2. Structure of a Python FastAPI Backend

```
silver_lining/backend/
├── app/
│   ├── main.py              <-- FastAPI App Entry Point (like app.ts)
│   ├── api/
│   │   └── v1/
│   │       └── reframe.py   <-- Route Endpoints (like routes/reframe.ts)
│   ├── core/
│   │   ├── config.py        <-- Env variables & Settings (like dotenv)
│   │   └── safety.py        <-- AI Safety Guardrail Logic
│   ├── models/
│   │   └── schemas.py       <-- Pydantic Request/Response Models (like DTOs)
│   └── services/
│       └── llm_service.py   <-- Gemini & Safety API Integrations
├── requirements.txt         <-- Dependencies (like package.json)
├── Dockerfile               <-- Container definition
└── README.md
```

---

## ⚡ 3. A Sneak Peek at FastAPI Code

In TypeScript / Express:
```typescript
import express, { Request, Response } from 'express';
import { z } from 'zod';

const RequestSchema = z.object({ input_text: z.string() });

app.post('/reframe', (req: Request, res: Response) => {
  const body = RequestSchema.parse(req.body);
  res.json({ success: true, text: body.input_text });
});
```

In Python / FastAPI:
```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Silver Lining AI Backend")

class ReframeRequest(BaseModel):
    input_text: str

class ReframeResponse(BaseModel):
    is_safe: bool
    reframed_text: str

@app.post("/api/v1/reframe", response_model=ReframeResponse)
async def reframe_thought(payload: ReframeRequest):
    return ReframeResponse(
        is_safe=True, 
        reframed_text=f"Reframed: {payload.input_text}"
    )
```

Notice how FastAPI **automatically validates** `payload.input_text`, checks types, and generates Swagger documentation without writing single extra lines of code!
