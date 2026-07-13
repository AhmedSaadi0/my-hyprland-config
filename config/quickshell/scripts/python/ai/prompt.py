"""
Backward-compatible re-export of all Nibras prompts.

The actual definitions live in the `prompts/` subpackage, organized by
task. This module preserves every public name the previous version of
prompt.py exposed so external callers (config.py, main.py, boot_analyzer.py)
continue to work without modification.

For new code, prefer importing from `ai.prompts` directly.
"""

import warnings

from prompts import (
    ASSISTANT_PROMPT,
    BOOT_SOLUTION_PROMPT,
    COLOR_PALETTE_PROMPT,
    IDLE_CAPSULE_BULK_MESSAGE,
    IDLE_CAPSULE_FRESH_MESSAGE,
    IDLE_CAPSULE_PROMPT,
    IDLE_CAPSULE_STARTUP_MESSAGE,
    MESSAGE_TEMPLATES,
    MUSIC_MASTER_PROMPT,
    PROGRAMMER_PROMPT,
    SPIKE_ANALYST_PROMPT,
    SYSTEM_ACTION_PROMPT,
    SYSTEM_ANALYST_PROMPT,
    TODO_MASTER_PROMPT,
    WEATHER_MASTER_PROMPT,
)
from prompts.idle_capsule import build_idle_user_message


def build_message(key, **kwargs):
    """
    DEPRECATED: use prompts.idle_capsule.build_idle_user_message() instead.

    Kept for callers (main.py line 151) that still pass a message_key
    string. Emits a DeprecationWarning once per process.
    """
    warnings.warn(
        "prompt.build_message() is deprecated; "
        "use prompts.idle_capsule.build_idle_user_message() instead.",
        DeprecationWarning,
        stacklevel=2,
    )
    return build_idle_user_message(key, **kwargs)


__all__ = [
    "PROGRAMMER_PROMPT",
    "ASSISTANT_PROMPT",
    "IDLE_CAPSULE_BULK_MESSAGE",
    "IDLE_CAPSULE_STARTUP_MESSAGE",
    "IDLE_CAPSULE_FRESH_MESSAGE",
    "IDLE_CAPSULE_PROMPT",
    "MESSAGE_TEMPLATES",
    "build_message",
    "WEATHER_MASTER_PROMPT",
    "MUSIC_MASTER_PROMPT",
    "TODO_MASTER_PROMPT",
    "COLOR_PALETTE_PROMPT",
    "SYSTEM_ANALYST_PROMPT",
    "SYSTEM_ACTION_PROMPT",
    "SPIKE_ANALYST_PROMPT",
    "BOOT_SOLUTION_PROMPT",
]
