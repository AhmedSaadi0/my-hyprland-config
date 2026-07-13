"""
Nibras prompt package.

All prompts are organized by task. The legacy `prompt.py` module at the
parent level re-exports these for full backward compatibility.
"""

from . import (
    boot_solution,
    color_palette,
    idle_capsule,
    music,
    simple,
    spike_analyst,
    system_action,
    system_analyst,
    todo,
    weather,
)
from ._base import (
    DESKTOP_RULES,
    EMOTION_LIST,
    GPU_RULES,
    LANGUAGE_RULE,
    MAX_WORDS_RULE,
    NO_PREAMBLE,
    PACKAGE_MANAGERS,
    PERSONA,
    SAFETY_RULES,
    STATUS_COLORS,
    STATUS_ICONS,
    WEATHER_ICONS,
)
from .boot_solution import BOOT_SOLUTION_PROMPT
from .color_palette import COLOR_PALETTE_PROMPT
from .idle_capsule import (
    IDLE_CAPSULE_FRESH_MESSAGE,
    IDLE_CAPSULE_PROMPT,
    IDLE_CAPSULE_STARTUP_MESSAGE,
    MESSAGE_TEMPLATES,
    build_idle_user_message,
)
from .music import MUSIC_MASTER_PROMPT
from .simple import ASSISTANT_PROMPT, PROGRAMMER_PROMPT
from .spike_analyst import SPIKE_ANALYST_PROMPT
from .system_action import (
    BATTERY_PROMPTS,
    CATEGORIES,
    SYSTEM_ACTION_PROMPT,
    build_full as build_system_action_full,
    list_battery_levels,
)
from .system_analyst import SYSTEM_ANALYST_PROMPT
from .todo import TODO_MASTER_PROMPT
from .weather import WEATHER_MASTER_PROMPT


# Backwards-compatible alias for the original IDLE_CAPSULE_BULK_MESSAGE
# name. Imported by main.py via build_message() with count= kwarg.
IDLE_CAPSULE_BULK_MESSAGE = MESSAGE_TEMPLATES["idle_capsule_bulk"]


__all__ = [
    "DESKTOP_RULES",
    "EMOTION_LIST",
    "GPU_RULES",
    "LANGUAGE_RULE",
    "MAX_WORDS_RULE",
    "NO_PREAMBLE",
    "PACKAGE_MANAGERS",
    "PERSONA",
    "SAFETY_RULES",
    "STATUS_COLORS",
    "STATUS_ICONS",
    "WEATHER_ICONS",
    "ASSISTANT_PROMPT",
    "BOOT_SOLUTION_PROMPT",
    "COLOR_PALETTE_PROMPT",
    "IDLE_CAPSULE_BULK_MESSAGE",
    "IDLE_CAPSULE_FRESH_MESSAGE",
    "IDLE_CAPSULE_PROMPT",
    "IDLE_CAPSULE_STARTUP_MESSAGE",
    "MESSAGE_TEMPLATES",
    "MUSIC_MASTER_PROMPT",
    "PROGRAMMER_PROMPT",
    "SPIKE_ANALYST_PROMPT",
    "SYSTEM_ACTION_PROMPT",
    "SYSTEM_ANALYST_PROMPT",
    "TODO_MASTER_PROMPT",
    "WEATHER_MASTER_PROMPT",
    "BATTERY_PROMPTS",
    "CATEGORIES",
    "build_idle_user_message",
    "build_system_action_full",
    "list_battery_levels",
]
