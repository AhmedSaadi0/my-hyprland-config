"""
Idle capsule prompts: short hover replies for an idle UI widget.

IDLE_CAPSULE_PROMPT         -> system instruction (with full JSON schema)
IDLE_CAPSULE_BULK_MESSAGE   -> user message: generate N at once
IDLE_CAPSULE_STARTUP_MESSAGE-> user message: N including 1 boot-context reply
IDLE_CAPSULE_FRESH_MESSAGE  -> user message: 1 reply for right now
build_idle_user_message()   -> helper to fill user messages by mode
"""

from ._base import (
    EMOTION_LIST,
    LANGUAGE_RULE,
    MAX_WORDS_RULE,
    NO_PREAMBLE,
    PERSONA,
)


IDLE_CAPSULE_PROMPT = f"""\
### SYSTEM ROLE
{PERSONA} You are a lively UI companion.

### GOAL
Generate a list of short hover responses for an idle UI widget. The responses should feel playful, smart, and varied.

### CORE RULES
- {LANGUAGE_RULE}
- Do NOT include offensive, political, or medical content.
- {MAX_WORDS_RULE}
- If `extra_text` is used, it MUST be a complete, engaging follow-up sentence (not just a few words).
- {NO_PREAMBLE}
- Vary tone contextually: witty, friendly, curious, subtle, funny.
- `emotion` MUST be one of: {EMOTION_LIST}

### REQUIRED OUTPUT (RAW JSON ONLY)
{{
  "responses": [
    {{
      "text": "string",
      "emotion": "one of {EMOTION_LIST}",
      "extra_text": "optional string (complete follow-up sentence)",
      "extra_delay_ms": "optional integer (e.g. 1200)"
    }}
  ]
}}
"""


IDLE_CAPSULE_BULK_MESSAGE = (
    "Generate {{count}} short hover replies for an idle UI widget. "
    "Use variety and keep them under 8 words. "
    "Some responses should include extra_text (a complete, engaging follow-up sentence) "
    "and extra_delay_ms (1200-2500). "
    "Ensure tone varies between witty, calm, and curious."
).format(count="{count}")


IDLE_CAPSULE_STARTUP_MESSAGE = """\
Generate exactly {count} short hover replies for an idle UI widget.
Use variety and keep them under 8 words.
Some responses should include extra_text (a complete, engaging follow-up sentence)
and extra_delay_ms (1200-2500).
Craft ONLY 1 response specifically about the system state based on the boot context below.
The rest must be general idle responses. Avoid line breaks within text fields.
BOOT_STATUS: {boot_status}
BOOT_TITLE: {boot_title}
BOOT_SUMMARY: {boot_summary}
BOOT_TIME: {boot_time}
BOOT_LOGS: {boot_logs}"""


IDLE_CAPSULE_FRESH_MESSAGE = (
    "Generate 1 short hover reply for right now. "
    "Keep it playful, context-aware, and under 8 words. "
    "You may include extra_text (a complete, engaging follow-up sentence) if needed for wit."
)


MESSAGE_TEMPLATES = {
    "idle_capsule_bulk": IDLE_CAPSULE_BULK_MESSAGE,
    "idle_capsule_startup": IDLE_CAPSULE_STARTUP_MESSAGE,
    "idle_capsule_fresh": IDLE_CAPSULE_FRESH_MESSAGE,
}


def build_idle_user_message(key: str, **kwargs) -> str | None:
    """
    Build a user message for the idle capsule prompt.

    key: one of 'idle_capsule_bulk', 'idle_capsule_startup', 'idle_capsule_fresh'
    kwargs: count, boot_status, boot_title, boot_summary, boot_time, boot_logs

    Returns the formatted user message, or None if key is unknown.
    Braces in values are escaped so str.format() cannot break.
    """
    template = MESSAGE_TEMPLATES.get(key)
    if not template:
        return None
    try:
        safe = {
            k: str(v).replace("{", "{{").replace("}", "}}") for k, v in kwargs.items()
        }
        return template.format(**safe)
    except Exception:
        return template
