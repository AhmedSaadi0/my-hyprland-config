"""
Concise few-shot examples for complex JSON schemas.

Each constant is a minimal valid example the model can mirror.
They are concatenated into prompts at definition time and contain no
placeholders (so they survive the str.replace() pipeline used by get_provider).
"""

WEATHER_EXAMPLE = """\
### EXAMPLE OUTPUT
{
  "ui": {"icon": "\\ue30d", "bg_color1": "#1e3a8a", "bg_color2": "#3b82f6", "fg_color": "#FFFFFF", "title": "Nibras", "emotion": "happy"},
  "data": {"temp": "24°C", "feels_like": "23°C", "humidity": "58%"},
  "smart_summary": {"summary_text": "Crisp morning, light breeze from the north.", "trend_badge": "Rising", "tags": ["Clear", "Breeze"]},
  "urgent_alert": false,
  "system_control": {"next_check_minutes": 30, "reason": "Stable conditions, no rapid changes expected."}
}
"""


COLOR_PALETTE_EXAMPLE = """\
### EXAMPLE OUTPUT (Dracula theme)
{
  "reply": "Applied Dracula accents with distinct primary, secondary, and tertiary hues.",
  "apply": true,
  "changes": [
    {"key": "_primary",   "value": "#bd93f9", "reason": "Dracula iconic purple"},
    {"key": "_secondary", "value": "#ff79c6", "reason": "Dracula pink, distinct hue from primary"},
    {"key": "_tertiary",  "value": "#50fa7b", "reason": "Dracula green for tertiary contrast"},
    {"key": "_topbarBg",  "value": "#1e1e2e", "reason": "Topbar slightly darker than left menu"},
    {"key": "_leftMenuBg", "value": "#282a36", "reason": "Left menu V1, distinct from topbar"}
  ],
  "warnings": []
}
"""


SYSTEM_ANALYST_EXAMPLE = """\
### EXAMPLE OUTPUT (WARNING case)
{
  "title": "Slow Boot Detected",
  "summary": "Startup took 42s. A few driver notices detected, but no critical failures.",
  "icon": "\\uf071",
  "boot_duration": "42.1s",
  "status_color": "orange",
  "logs": [
    {"time": "08:14:22", "process": "bluetooth", "message": "Bluetooth controller lacks advanced features, basic connectivity still works.", "raw_details": "kernel: bluetooth: hci0: Failed to set mode: 0x03"},
    {"time": "08:14:35", "process": "acpi",       "message": "Minor BIOS compatibility notice from the motherboard.",                     "raw_details": "kernel: ACPI: BIOS _INI data is not valid 0x4 bytes"}
  ]
}
"""


SPIKE_EXAMPLE = """\
### EXAMPLE OUTPUT
{
  "title": "Memory Leak Suspected",
  "severity": "warning",
  "narrative": "RAM climbed from 4.2GB to 11.8GB over 12 minutes. The firefox process is currently holding 6.1GB, well above its baseline. This pattern suggests a per-tab leak rather than a system-wide issue.",
  "root_cause_hypothesis": "Browser tab leak (likely long-lived tab holding detached DOM tree)",
  "thermal_impact": {"risk_level": "low", "details": "RAM pressure does not directly generate heat, but swap usage may slow I/O and raise SSD temps slightly."},
  "process_anomaly": {"name": "firefox", "behavior": "Memory Leak"},
  "actions": [
    "Inspect: ps -o pid,rss,comm -p <pid>",
    "Mitigation: Close oldest tabs and restart firefox to reclaim RSS."
  ],
  "confidence_score": 78
}
"""


BOOT_SOLUTION_EXAMPLE = """\
### EXAMPLE OUTPUT
{
  "solutions": [
    {
      "id": "bluetooth_mode_reset",
      "related_log": "bluetooth",
      "title": "Reset Bluetooth Mode",
      "difficulty": "easy",
      "priority": "optional",
      "description": "The Bluetooth controller is rejecting advanced features. Basic audio/transfer still works, but BLE profiles are degraded.",
      "why_this_works": "Reloading the btusb module re-initialises the controller with conservative defaults and clears stale state.",
      "steps": [
        {"label": "Reload the btusb kernel module", "command": "sudo modprobe -r btusb && sudo modprobe btusb", "warning": null}
      ]
    }
  ]
}
"""
