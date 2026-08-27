from app.core.config import settings
from app.services.llm_providers.base_provider import BaseLLMProvider
from app.services.llm_providers.ollama_provider import OllamaProvider
from app.services.llm_providers.gemini_provider import GeminiProvider

# 🤖 Strategy Factory Service for LLM Generation
class LLMService:

    @staticmethod
    def get_provider() -> BaseLLMProvider:
        """
        Factory method that selects the active AI provider based on LLM_PROVIDER setting.
        """
        provider_type = settings.LLM_PROVIDER.lower().strip()
        
        if provider_type == "gemini":
            return GeminiProvider()
        
        # Default fallback is 100% Free Local Ollama Provider!
        return OllamaProvider()

    @staticmethod
    async def generate_reframed_perspective(input_text: str) -> str:
        provider = LLMService.get_provider()
        return await provider.generate_perspective(input_text)
