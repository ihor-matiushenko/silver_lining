import os
import httpx

# 🤖 Asynchronous LLM Service (Local Ollama LLM + Fallback support)
class LLMService:
    OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")
    OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen3-vl:8b")

    SYSTEM_PROMPT = (
        "You are Silver Lining AI, a compassionate psychological reframing assistant. "
        "Take the user's stress point or problem and reframe it into a constructive, "
        "empowering, positive silver lining perspective in 2 to 3 sentences. "
        "Do not invalidate their feelings. Be empathetic and uplifting."
    )

    @staticmethod
    async def generate_reframed_perspective(input_text: str) -> str:
        """
        Asynchronously calls local Ollama LLM to generate positive perspective reframing.
        """
        full_prompt = f"{LLMService.SYSTEM_PROMPT}\n\nUser Stress Point: \"{input_text}\"\n\nSilver Lining Perspective:"

        payload = {
            "model": LLMService.OLLAMA_MODEL,
            "prompt": full_prompt,
            "stream": False,
        }

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(LLMService.OLLAMA_URL, json=payload)
                response.raise_for_status()
                data = response.json()
                
                reframed = data.get("response", "").strip()
                if reframed:
                    return reframed
                
                return "Every challenge contains a hidden lesson. Refocus on your strengths and take small steps forward today."

        except Exception as e:
            # Resilient fallback if Ollama service is unreachable
            return (
                "Setbacks often serve as redirection toward better alignment. "
                "Experiencing this struggle demonstrates your courage to put yourself out there."
            )
