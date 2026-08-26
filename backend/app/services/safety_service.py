from typing import Optional
from app.models.schemas import ReframeResponse

# 🛡️ 3-Tier AI Safety & Guardrails Engine
class SafetyService:
    
    # Keyword sets for Tier 1 & Tier 2 safety filtering
    SELF_HARM_KEYWORDS = {
        "hurt myself", "suicide", "end it all", "end my life",
        "kill myself", "want to die", "self harm"
    }

    CRIME_KEYWORDS = {
        "stole", "steal", "robbed", "rob", "hack", "murder",
        "pirate", "illegal"
    }

    @staticmethod
    def evaluate_input_safety(input_text: str) -> Optional[ReframeResponse]:
        """
        Evaluates input text against 3-tier safety guardrails:
        - Returns ReframeResponse with crisis_triggered=True if Tier 1 (Self-Harm) is detected.
        - Returns ReframeResponse with is_safe=False if Tier 2 (Crime/Illegal) is detected.
        - Returns None if Tier 3 (Safe Input), clearing it for Gemini AI generation.
        """
        text_lower = input_text.lower().strip()

        # Tier 1: Check for Self-Harm Crisis Trigger
        for keyword in SafetyService.SELF_HARM_KEYWORDS:
            if keyword in text_lower:
                return ReframeResponse(
                    is_safe=True,
                    safety_category="self_harm_crisis",
                    reframed_text=None,
                    crisis_triggered=True,
                    emergency_hotline="988"
                )

        # Tier 2: Check for Crime / Illegal Act Policy Refusal Trigger
        for keyword in SafetyService.CRIME_KEYWORDS:
            if keyword in text_lower:
                return ReframeResponse(
                    is_safe=False,
                    safety_category="crime_refusal",
                    reframed_text=None,
                    crisis_triggered=False,
                    emergency_hotline=None
                )

        # Tier 3: Passed all safety checks -> Safe for AI Reframing
        return None
