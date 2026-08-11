from pydantic import BaseModel, Field
from typing import Optional

class ReframeRequest(BaseModel):
    """Payload received from the mobile app."""
    input_text: str = Field(
        ..., 
        description="The user's problem, concern, or thought to be reframed",
        example="I prepared for weeks for my final interview and still got rejected."
    )

class ReframeResponse(BaseModel):
    """Payload returned to the mobile app after 3-tier safety filtering."""
    is_safe: bool = Field(
        ..., 
        description="True if request passed all safety guardrails; False if crisis or crime detected"
    )
    safety_category: str = Field(
        default="none", 
        description="Category of request: 'none', 'self_harm', 'crime', or 'violence'"
    )
    reframed_text: Optional[str] = Field(
        default=None, 
        description="Empathetic, positive perspective reframing text (populated only if is_safe is True)"
    )
    crisis_triggered: bool = Field(
        default=False, 
        description="True if emergency hotline resources should be rendered by the mobile app"
    )
    emergency_hotline: Optional[str] = Field(
        default=None, 
        description="Localized hotline phone number/URL for crisis intervention"
    )
