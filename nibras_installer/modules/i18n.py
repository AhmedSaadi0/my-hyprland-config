# modules/i18n.py
import json
import os

from config import PROJECT_ROOT

MESSAGES = {}
LANG = "en"


def load_languages():
    global MESSAGES
    json_path = os.path.join(PROJECT_ROOT, "data", "locales.json")
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            MESSAGES = json.load(f)
    except FileNotFoundError:
        print(f"Error: Could not find translation file at {json_path}")
        exit(1)


def set_lang(language_code):
    global LANG
    if language_code in MESSAGES:
        LANG = language_code


def msg(key):
    # إرجاع النص أو المفتاح نفسه في حال عدم وجوده
    return MESSAGES.get(LANG, MESSAGES.get("en", {})).get(key, key)
