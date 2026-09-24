from fastapi import APIRouter
from app.services.localization_service import LocalizationService

localization_router = APIRouter(tags=["Localization"])

@localization_router.get("/l10n/{lang_code}")
async def get_localization_strings(lang_code: str = "en"):
    """
    🌐 Dynamic Localization Endpoint: Serves UI translation strings for ANY language code.
    If the requested language is new, uses AI Strategy to auto-translate the UI dictionary on demand.
    Guarantees English ('en') fallback for missing keys.
    """
    strings = await LocalizationService.get_ui_strings(lang_code)
    return {
        "language": lang_code,
        "strings": strings
    }
