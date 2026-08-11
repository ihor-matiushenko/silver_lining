# AI Positivity Reframer - Safety & Guardrail Specification

## 1. Safety Principles & Zero-Tolerance Policy

The AI Positivity Reframer ("Silver Lining") application is designed to offer constructive, empathetic perspective reframing for everyday human problems, stress, and emotional struggles. 

**Zero-Tolerance Rule**: The system MUST NEVER provide positive reframing, silver linings, justification, validation, or encouragement for:
- Self-harm, suicide, or suicide ideation.
- Illegal acts (past, present, or future), criminal activity, theft, violence, assault, or fraud.
- Domestic violence, child abuse, sexual abuse, exploitation, or non-consensual behavior.
- Acts of terrorism, hate speech, harassment, or severe harm to others.

---

## 2. Risk Taxonomy & Action Matrix

| Category | Example User Inputs | System Action | Output Experience |
|---|---|---|---|
| **Category 1: Self-Harm / Crisis** | *"I want to end it all", "Feeling like cutting myself", "No reason to live"* | **IMMEDIATE BLOCK (Priority 1)** | Compassionate crisis refusal screen with direct click-to-call hotlines (988 Lifeline, Crisis Text Line). No AI reframing. |
| **Category 2: Criminal / Illegal Acts** | *"I stole money from work and didn't get caught", "Planning to hack my ex's account", "Got away with drunk driving"* | **NEUTRAL REFUSAL (Priority 2)** | Neutral refusal message ("I cannot provide reframing or perspective on illegal activities or criminal acts."). No hotlines needed unless distress expressed. |
| **Category 3: Violence / Exploitation** | *"How to get revenge on my neighbor", "I hit my partner"* | **SAFETY REFUSAL (Priority 2)** | Safety refusal message + optional conflict resolution / anger management resources. |
| **Category 4: Valid Everyday Stress** | *"I failed my exam", "I got laid off today", "My partner broke up with me", "Feeling overwhelmed at work"* | **PASS TO REFRAMING ENGINE** | Empathetic, supportive reframing focusing on resilience, learning opportunities, self-compassion, and practical hope. |

---

## 3. Multi-Layer Guardrail Architecture

### Layer 1: Deterministic & Moderation API Filter
- **Input Text** is first passed to an ultra-fast classification API (OpenAI Moderation API / Google Cloud Safety / Llama Guard).
- **Categories Checked**: `self-harm`, `violence`, `sexual`, `hate`, `harassment`, `illicit`.
- If any score exceeds the threshold ($\ge 0.1$ for self-harm/violence; $\ge 0.2$ for illicit), **execution stops immediately**.

### Layer 2: LLM System Prompt Instructions & JSON Output Schema
- System prompt instructs the model to validate safety *before* reframing.
- Model must return structured JSON:
```json
{
  "is_safe": false,
  "safety_category": "self_harm",
  "crisis_trigger": true,
  "reframed_text": "",
  "user_guidance": "It sounds like you're going through a deeply difficult time. Please reach out to someone who can support you."
}
```

### Layer 3: Output Post-Validation Engine
- A lightweight post-processor checks the JSON schema response.
- If `is_safe` is false, or if forbidden keywords/patterns are detected in `reframed_text`, the system replaces the output with the standard fallback screen.

---

## 4. Emergency Resources Matrix
- **United States & Canada**: 988 Suicide & Crisis Lifeline (Call/Text 988)
- **United Kingdom**: 111 (NHS) or 116 123 (Samaritans)
- **International**: [Befrienders Worldwide](https://www.befrienders.org/) / [Find A Helpline](https://findahelpline.com/)
