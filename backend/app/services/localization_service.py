import json
from typing import Dict
from app.services.llm_service import LLMService

# 🌐 Dynamic AI-Powered UI Localization Service
# Serves UI translation dictionaries for ANY language code on earth with English fallback.
class LocalizationService:
    # Universal Base Dictionary in English ('en')
    BASE_ENGLISH_STRINGS: Dict[str, str] = {
        "appTitle": "Silver Lining",
        "reframePrompt": "What is weighing on your mind?",
        "reframeButton": "Find Silver Lining",
        "historyTitle": "Cloud History",
        "signInTitle": "Sign In to Sync History",
        "guestModeText": "Guest Mode (5 reframings / day)",
        "rateLimitWarning": "Guest limit reached. Sign up for unlimited access!",
        "favoriteLabel": "Favorites",
        "deleteConfirm": "Delete this record?",
        "languageAuto": "Auto-Detect Language",
    }

    # In-Memory Cache for Pre-translated and AI Auto-translated Languages
    TRANSLATIONS: Dict[str, Dict[str, str]] = {
        "uk": {
            "appTitle": "Світла Сторона",
            "reframePrompt": "Що турбує вас сьогодні?",
            "reframeButton": "Знайти світлу сторону",
            "historyTitle": "Хмарна Історія",
            "signInTitle": "Увійдіть для синхронізації",
            "guestModeText": "Гостьовий режим (5 рефреймінгів / день)",
            "rateLimitWarning": "Ліміт гостей вичерпано. Створіть акаунт!",
            "favoriteLabel": "Улюблені",
            "deleteConfirm": "Видалити цей запис?",
            "languageAuto": "Автовизначення мови",
        },
        "es": {
            "appTitle": "Lado Positivo",
            "reframePrompt": "¿Qué te preocupa hoy?",
            "reframeButton": "Encontrar el lado positivo",
            "historyTitle": "Historial en la Nube",
            "signInTitle": "Inicia sesión para sincronizar",
            "guestModeText": "Modo Invitado (5 reframings / día)",
            "rateLimitWarning": "¡Límite alcanzado! Registrate para acceso ilimitado.",
            "favoriteLabel": "Favoritos",
            "deleteConfirm": "¿Eliminar este registro?",
            "languageAuto": "Detección automática",
        },
        "de": {
            "appTitle": "Lichtblick",
            "reframePrompt": "Was beschäftigt dich heute?",
            "reframeButton": "Lichtblick finden",
            "historyTitle": "Cloud-Verlauf",
            "signInTitle": "Anmelden zum Synchronisieren",
            "guestModeText": "Gastmodus (5 Reframings / Tag)",
            "rateLimitWarning": "Gastlimit erreicht. Erstelle ein Konto!",
            "favoriteLabel": "Favoriten",
            "deleteConfirm": "Diesen Eintrag löschen?",
            "languageAuto": "Automatische Erkennung",
        },
        "fr": {
            "appTitle": "Côté Positif",
            "reframePrompt": "Qu'est-ce qui vous préoccupe aujourd'hui?",
            "reframeButton": "Trouver le côté positif",
            "historyTitle": "Historique Cloud",
            "signInTitle": "Se connecter pour synchroniser",
            "guestModeText": "Mode Invité (5 reformulations / jour)",
            "rateLimitWarning": "Limite atteinte. Créez un compte!",
            "favoriteLabel": "Favoris",
            "deleteConfirm": "Supprimer cet enregistrement?",
            "languageAuto": "Détection automatique",
        }
    }

    @classmethod
    async def get_ui_strings(cls, lang_code: str = "en") -> Dict[str, str]:
        """
        Returns UI string dictionary for requested language code.
        If the language is not in cache, uses AI Provider strategy to translate base dictionary dynamically.
        Guarantees fallback to English ('en') for missing keys or translation errors.
        Zero hardcoding in client apps!
        """
        code = lang_code.lower().strip().split("-")[0]  # e.g., 'en-US' -> 'en'
        if not code or code == "en":
            return dict(cls.BASE_ENGLISH_STRINGS)

        # Return cached dictionary if available
        if code in cls.TRANSLATIONS:
            result = dict(cls.BASE_ENGLISH_STRINGS)
            result.update(cls.TRANSLATIONS[code])
            return result

        # Dynamic AI Auto-Translation for any new language code
        try:
            prompt = (
                f"Translate the following JSON dictionary of UI strings into ISO language '{code}'. "
                f"Keep JSON key names identical. Output strictly valid JSON object ONLY.\n\n"
                f"Input JSON: {json.dumps(cls.BASE_ENGLISH_STRINGS, ensure_ascii=False)}"
            )
            raw_response = await LLMService.generate_reframed_perspective(prompt, target_language=code)

            cleaned = raw_response.strip()
            if cleaned.startswith("```json"):
                cleaned = cleaned.split("```json")[1].split("```")[0].strip()
            elif cleaned.startswith("```"):
                cleaned = cleaned.split("```")[1].strip()

            translated_map = json.loads(cleaned)
            if isinstance(translated_map, dict):
                valid_dict = dict(cls.BASE_ENGLISH_STRINGS)
                for k, v in translated_map.items():
                    if k in cls.BASE_ENGLISH_STRINGS and isinstance(v, str):
                        valid_dict[k] = v
                cls.TRANSLATIONS[code] = valid_dict
                return valid_dict
        except Exception:
            pass

        # Fallback to English if translation fails
        return dict(cls.BASE_ENGLISH_STRINGS)
