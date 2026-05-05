import sys
import os
import json

def is_valid_gtk_theme(path):
    return os.path.isdir(os.path.join(path, "gtk-3.0")) or os.path.isdir(os.path.join(path, "gtk-4.0"))

def get_gtk_themes():
    themes = []
    dirs = [
        "/usr/share/themes",
        os.path.expanduser("~/.themes"),
        os.path.expanduser("~/.local/share/themes")
    ]
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for entry in os.listdir(d):
            full_path = os.path.join(d, entry)
            if os.path.isdir(full_path) and is_valid_gtk_theme(full_path):
                if entry not in themes:
                    themes.append(entry)
    return sorted(themes)

if __name__ == "__main__":
    print(json.dumps(get_gtk_themes()))
