import os
from typing import Optional

class LLMService:
    """Service orchestrating AI perspective reframing via Google Gemini 1.5 Flash."""

    @staticmethod
    async def generate_reframed_perspective(input_text: str) -> str:
        """
        Sends the safe user prompt to Gemini 1.5 Flash with strict empathy system instructions.
        Falls back to a default reframing response if API key is not configured yet.
        """
        api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            # Fallback mock reframing response for development/POC testing
            return (
                "Setbacks often serve as redirection toward better alignment. "
                "Experiencing this struggle demonstrates your courage to put yourself out there. "
                "This moment does not define your worth, but serves as a stepping stone toward finding an environment "
                "that truly recognizes and values your full potential."
            )

        try:
            from google import genai
            client = genai.Client(api_key=api_key)
            
            prompt = (
                "You are an empathetic, wise psychological perspective coach. "
                "The user will share a personal stress, struggle, or problem. "
                "Provide a concise (2-3 sentences), compassionate, constructive perspective reframing. "
                "Focus on growth, resilience, self-compassion, and practical hope. "
                f"\n\nUser Input: {input_text}"
            )
            
            response = client.models.generate_content(
                model='gemini-1.5-flash',
                contents=prompt,
            )
            return response.text.strip()
        except Exception as e:
            return (
                "Every challenge holds the seed of personal resilience. While this moment feels difficult, "
                "it provides an opportunity to reflect, adapt, and build inner strength for what lies ahead."
            )
