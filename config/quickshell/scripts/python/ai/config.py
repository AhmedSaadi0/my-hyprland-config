import prompt
from gemini_provider import GeminiProvider
from openai_provider import OpenAIProvider

# -----------------------------------------------------------------------------
# 0. التكوينات والإعدادات المسبقة (Presets)
# -----------------------------------------------------------------------------
PRESETS = {
    "weather": {
        "system_instruction": prompt.WEATHER_MASTER_PROMPT,
        "json_mode": True,  # الطقس يحتاج دائماً JSON
        "temperature": 0.4,  # نحتاج دقة أكثر وإبداعاً أقل
    },
    "coder": {
        "system_instruction": prompt.PROGRAMMER_PROMPT,
        "json_mode": False,
        "temperature": 0.2,
    },
    "chat": {
        "system_instruction": prompt.ASSISTANT_PROMPT,
        "json_mode": False,
        "temperature": 0.7,
    },
    "music": {
        "system_instruction": prompt.MUSIC_MASTER_PROMPT,
        "json_mode": True,
        "temperature": 0.5,
    },
}


# -----------------------------------------------------------------------------
# 4. Factory & Main Logic
# -----------------------------------------------------------------------------
def get_provider(
    args,
    final_system_instruction,
    final_temperature,
    final_json_mode,
):
    preferred_language = args.preferred_language or "English"
    user_persona = args.user_persona or ""

    final_system_instruction = final_system_instruction.replace(
        "$aiPreferredLanguage",
        preferred_language,
    ).replace(
        "{USER_PERSONA}",
        user_persona,
    )

    common_args = {
        "api_key": args.api_key,
        "model": args.model,
        "system_instruction": final_system_instruction,
        "temperature": final_temperature,
        "json_mode": final_json_mode,
    }

    if args.provider == "gemini" or "gemini" in args.model.lower():
        return GeminiProvider(**common_args)

    # TODO: -> test logic
    base_url = args.base_url
    if args.provider == "deepseek" and not base_url:
        base_url = "https://api.deepseek.com"

    return OpenAIProvider(base_url=base_url, **common_args)
