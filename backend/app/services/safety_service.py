from app.models.schemas import ReframeResponse

class SafetyService:
    """3-Tier Safety Engine for detecting self-harm, crime, and illegal acts."""

    @staticmethod
    def evaluate_input_safety(input_text: str) -> ReframeResponse | None:
        """
        Layer 1 & 2 Deterministic Pre-Filter.
        Returns a ReframeResponse if unsafe (crisis/crime), or None if safe to pass to LLM.
        """
        text_lower = input_text.lower().strip()

        # Category 1: Crisis / Self-Harm / Suicide
        crisis_keywords = [
            'hurt myself', 'ending everything', 'suicide', 'end it all', 
            'kill myself', 'want to die', 'cutting myself', 'no reason to live'
        ]
        if any(keyword in text_lower for keyword in crisis_keywords):
            return ReframeResponse(
                is_safe=False,
                safety_category="self_harm",
                reframed_text=None,
                crisis_triggered=True,
                emergency_hotline="tel:988"
            )

        # Category 2: Crime / Illegal Acts / Violence
        crime_keywords = [
            'stole', 'robbed', 'hack into', 'drug deal', 'hit my partner',
            'shoplifted', 'steal', 'how to cheat on taxes'
        ]
        if any(keyword in text_lower for keyword in crime_keywords):
            return ReframeResponse(
                is_safe=False,
                safety_category="crime",
                reframed_text=None,
                crisis_triggered=False,
                emergency_hotline=None
            )

        # Passed Layer 1 & 2 Pre-filter
        return None
