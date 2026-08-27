import httpx
from app.core.config import settings
from app.services.llm_providers.base_provider import BaseLLMProvider

# 🦙 Concrete Provider for Local Ollama AI
class OllamaProvider(BaseLLMProvider):
    
    async def generate_perspective(self, input_text: str) -> str:
        full_prompt = f"{self.SYSTEM_PROMPT}\n\nUser Stress Point: \"{input_text}\"\n\nSilver Lining Perspective:"

        payload = {
            "model": settings.OLLAMA_MODEL,
            "prompt": full_prompt,
            "stream": False,
        }

        try:
            async with httpx.AsyncClient(timeout=35.0) as client:
                response = await client.post(settings.OLLAMA_URL, json=payload)
                response.raise_for_status()
                data = response.json()
                
                reframed = data.get("response", "").strip()
                if reframed:
                    return reframed
                
                return "Every challenge contains a hidden lesson. Refocus on your strengths and take small steps forward today."

        except Exception as e:
            return (
                "Setbacks often serve as redirection toward better alignment. "
                "Experiencing this struggle demonstrates your courage to put yourself out there."
            )
