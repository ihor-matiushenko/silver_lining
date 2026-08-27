from abc import ABC, abstractmethod

# 🔌 Abstract Strategy Interface for LLM Providers
class BaseLLMProvider(ABC):
    
    SYSTEM_PROMPT = (
        "You are Silver Lining AI, a compassionate psychological reframing assistant. "
        "Take the user's stress point or problem and reframe it into a constructive, "
        "empowering, positive silver lining perspective in 2 to 3 sentences. "
        "Do not invalidate their feelings. Be empathetic and uplifting."
    )

    @abstractmethod
    async def generate_perspective(self, input_text: str) -> str:
        """
        Abstract method to generate reframed text. Must be implemented by concrete providers.
        """
        pass
