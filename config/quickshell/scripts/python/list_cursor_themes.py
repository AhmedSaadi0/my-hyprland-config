import sys
import os
import json

def is_valid_cursor_theme(path):
    # A cursor theme must have a 'cursors' directory
    if not os.path.isdir(os.path.join(path, "cursors")):
        return False
    # Should have an index.theme file (either [Cursor Theme] or [Icon Theme])
    index_path = os.path.join(path, "index.theme")
    if not os.path.isfile(index_path):
        # Some cursor themes don't have index.theme but have cursors dir
        return True
    return True

def get_cursor_themes():
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
            if os.path.isdir(full_path) and is_valid_cursor_theme(full_path):
                if entry not in themes:
                    themes.append(entry)
    return sorted(themes)

if __name__ == "__main__":
    print(json.dumps(get_cursor_themes()))
