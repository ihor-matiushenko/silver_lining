import httpx
from app.core.config import settings
from app.services.llm_providers.base_provider import BaseLLMProvider

# ✨ Concrete Provider for Google Gemini 1.5 Flash AI
class GeminiProvider(BaseLLMProvider):
    
    async def generate_perspective(self, input_text: str) -> str:
        if not settings.GEMINI_API_KEY:
            return (
                "Gemini API key is missing in .env configuration. "
                "Please set GEMINI_API_KEY or switch LLM_PROVIDER=ollama."
            )

        gemini_url = (
            f"https://generativelanguage.googleapis.com/v1beta/models/"
            f"{settings.GEMINI_MODEL}:generateContent?key={settings.GEMINI_API_KEY}"
        )

        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "text": f"{self.SYSTEM_PROMPT}\n\nUser Stress Point: \"{input_text}\"\n\nSilver Lining Perspective:"
                        }
                    ]
                }
            ]
        }

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(gemini_url, json=payload)
                response.raise_for_status()
                data = response.json()
                
                candidates = data.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if parts:
                        return parts[0].get("text", "").strip()

                return "Every setback provides an opportunity for growth and personal discovery."

        except Exception as e:
            return (
                "Setbacks often serve as redirection toward better alignment. "
                "Experiencing this struggle demonstrates your courage to put yourself out there."
            )
