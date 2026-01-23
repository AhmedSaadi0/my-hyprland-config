import datetime
import platform

import prompt
from gemini_provider import GeminiProvider
from local_provider import LocalProvider
from openai_provider import OpenAIProvider
from openrouter_provider import OpenRouterProvider

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


def get_system_details():
    now = datetime.datetime.now()
    return {
        "{CURRENT_DATE}": now.strftime("%Y-%m-%d"),
        "{CURRENT_TIME}": now.strftime("%H:%M"),
        "{DAY_NAME}": now.strftime("%A"),
        "{OS_INFO}": f"{platform.system()} {platform.release()} {platform.freedesktop_os_release()}",
        "{YEAR}": str(now.year),
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
    sys_details = get_system_details()

    replacements = {
        "$aiPreferredLanguage": preferred_language,
        "{USER_PERSONA}": user_persona,
        **sys_details,
    }

    # if final_system_instruction is None:
    #     final_system_instruction = ""

    # print(sys_details)
    # print(user_persona)
    # print(preferred_language)
    for key, value in replacements.items():
        if key in final_system_instruction:
            final_system_instruction = final_system_instruction.replace(
                key, str(value)
            )

    common_args = {
        "api_key": args.api_key,
        "model": args.model,
        "system_instruction": final_system_instruction,
        "temperature": final_temperature,
        "json_mode": final_json_mode,
    }

    if args.provider == "local":
        return LocalProvider(**common_args)

    if args.provider == "gemini":  # or "gemini" in args.model.lower():
        return GeminiProvider(**common_args)

    if args.provider == "openrouter":
        return OpenRouterProvider(**common_args)

    # TODO: -> test logic
    base_url = args.base_url
    if args.provider == "deepseek" and not base_url:
        base_url = "https://api.deepseek.com"

    # TODO: -> test logic
    return OpenAIProvider(base_url=base_url, **common_args)
