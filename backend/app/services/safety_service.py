import re
from typing import Optional
from app.models.schemas import ReframeResponse

# 🛡️ 3-Tier AI Safety & Guardrails Engine
class SafetyService:
    
    # Multi-language keyword sets for Tier 1 Self-Harm Crisis Trigger
    # Supports English, Ukrainian, Spanish, German, French
    SELF_HARM_KEYWORDS = {
        # English
        "hurt myself", "suicide", "end it all", "end my life",
        "kill myself", "want to die", "self harm", "cut myself",
        # Ukrainian
        "покінчити з життям", "вбити себе", "суїцид", "самогубство",
        "заподіяти собі шкоду", "не хочу жити",
        # Spanish
        "matarme", "suicidio", "quitarme la vida", "hacerme daño", "no quiero vivir",
        # German
        "mich umbringen", "suizid", "selbstmord", "mein leben beenden",
        # French
        "me tuer", "mettre fin à mes jours", "me suicider", "me faire du mal",
    }

    # Tier 2 Crime / Illegal patterns with word boundaries (avoids false positives like "my account was hacked")
    CRIME_PATTERNS = [
        r"\b(i\s+stole|i\s+steal|how\s+to\s+steal|how\s+to\s+rob|stole\s+money)\b",
        r"\b(robbed|murder|murdered|how\s+to\s+murder)\b",
        r"\b(how\s+to\s+hack|hack\s+into|planning\s+to\s+hack)\b",
        r"\b(commit\s+fraud|how\s+to\s+pirate|pirate\s+software)\b",
        r"\b(вкрасти|пограбувати|як\s+зламати|вбивство)\b",
        r"\b(robar|asesinar|cómo\s+hackear)\b",
    ]

    @staticmethod
    def evaluate_input_safety(input_text: str) -> Optional[ReframeResponse]:
        """
        Evaluates input text against 3-tier safety guardrails:
        - Returns ReframeResponse with crisis_triggered=True if Tier 1 (Self-Harm) is detected.
        - Returns ReframeResponse with is_safe=False if Tier 2 (Crime/Illegal) is detected.
        - Returns None if Tier 3 (Safe Input), clearing it for AI generation.
        """
        text_lower = input_text.lower().strip()

        # Tier 1: Check for Self-Harm Crisis Trigger (Multi-Language)
        for keyword in SafetyService.SELF_HARM_KEYWORDS:
            if keyword in text_lower:
                return ReframeResponse(
                    is_safe=True,
                    safety_category="self_harm_crisis",
                    reframed_text=None,
                    crisis_triggered=True,
                    emergency_hotline="988"
                )

        # Tier 2: Check for Crime / Illegal Act Policy Refusal Trigger (Pattern based)
        for pattern in SafetyService.CRIME_PATTERNS:
            if re.search(pattern, text_lower, re.IGNORECASE):
                return ReframeResponse(
                    is_safe=False,
                    safety_category="crime_refusal",
                    reframed_text=None,
                    crisis_triggered=False,
                    emergency_hotline=None
                )

        # Tier 3: Passed all safety checks -> Safe for AI Reframing
        return None
