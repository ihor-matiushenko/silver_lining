from app.services.llm_providers.base_provider import BaseLLMProvider

# ⚡ Instant Mock LLM Provider for CPU-free Automated Testing
class MockLLMProvider(BaseLLMProvider):

    async def generate_perspective(self, input_text: str, target_language: str = "auto") -> str:
        if target_language == "uk":
            return "Кожен виклик містить прихований урок. Зосередьтеся на своїх силах та робіть кроки вперед."
        elif target_language == "es":
            return "Cada desafío contiene una lección oculta. Concéntrate en tus fortalezas y avanza hoy."

        return "Every challenge contains a hidden lesson. Refocus on your strengths and take small steps forward today."
