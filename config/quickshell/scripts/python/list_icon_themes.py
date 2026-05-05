import sys
import os
import json
import configparser

def is_valid_icon_theme(path):
    index_path = os.path.join(path, "index.theme")
    if not os.path.isfile(index_path):
        return False
    config = configparser.ConfigParser()
    try:
        config.read(index_path)
        # Must have Icon Theme section
        if "Icon Theme" not in config:
            return False
        # Exclude cursor themes by checking for Cursor Theme section or cursors dir
        if "Cursor Theme" in config:
            return False
        if os.path.isdir(os.path.join(path, "cursors")):
            return False
        return True
    except:
        return False

def get_icon_themes():
    themes = []
    dirs = [
        "/usr/share/icons",
        os.path.expanduser("~/.icons"),
        os.path.expanduser("~/.local/share/icons")
    ]
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for entry in os.listdir(d):
            full_path = os.path.join(d, entry)
            if os.path.isdir(full_path) and is_valid_icon_theme(full_path):
                if entry not in themes:
                    themes.append(entry)
    return sorted(themes)

if __name__ == "__main__":
    print(json.dumps(get_icon_themes()))
