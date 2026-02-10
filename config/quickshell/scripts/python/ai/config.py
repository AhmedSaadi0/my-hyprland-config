import datetime
import platform
import subprocess

import prompt
from gemini_provider import GeminiProvider
from local_provider import LocalProvider
from ollama_provider import OllamaProvider
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
    "boot_analyze": {
        "system_instruction": prompt.SYSTEM_ANALYST_PROMPT,
        "json_mode": True,
        "temperature": 0.1,
    },
    "spike_analyze": {
        "system_instruction": prompt.SPIKE_ANALYST_PROMPT,
        "json_mode": True,
        "temperature": 0.2,
    },
}


def get_raw_boot_logs():
    """تجميع بيانات الإقلاع واللوجات في نص واحد"""
    buffer = []

    # 1. Boot Time
    try:
        time_out = subprocess.check_output(
            ["systemd-analyze", "time"], text=True
        ).strip()
        buffer.append(f"--- BOOT DURATION ---\n{time_out}")
    except Exception as e:
        buffer.append(f"--- BOOT TIME ERROR: {e} ---")

    # 2. Critical Logs (Journalctl)
    try:
        # نجلب آخر 30 خطأ (Priority 3) من الإقلاع الحالي
        logs_out = subprocess.check_output(
            [
                "journalctl",
                "-b",
                "0",
                "-p",
                "3",
                "-n",
                "30",
                "--output",
                "short-iso",
                "--no-pager",
            ],
            text=True,
        ).strip()
        if not logs_out:
            logs_out = "No critical errors found."
        buffer.append(f"--- CRITICAL LOGS ---\n{logs_out}")
    except Exception as e:
        buffer.append(f"--- LOGS ERROR: {e} ---")

    return "\n\n".join(buffer)


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

    if "{SYSTEM_LOGS}" in final_system_instruction:
        sys_logs = get_raw_boot_logs()
        final_system_instruction = final_system_instruction.replace(
            "{SYSTEM_LOGS}",
            sys_logs,
        )

    replacements = {
        "$aiPreferredLanguage": preferred_language,
        "{USER_PERSONA}": user_persona,
        **sys_details,
    }

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

    if args.provider == "ollama":
        common_args["base_url"] = args.base_url
        return OllamaProvider(**common_args)

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
