import sys
import os
import json

def get_kvantum_themes():
    themes = []
    dirs = [
        "/usr/share/Kvantum",
        os.path.expanduser("~/.config/Kvantum")
    ]
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for root_dir, dirs_list, files in os.walk(d):
            for f in files:
                if f.endswith(".kvconfig"):
                    theme_name = os.path.basename(root_dir)
                    if theme_name not in themes:
                        themes.append(theme_name)
                    break  # only need one per dir
    return sorted(themes)

if __name__ == "__main__":
    print(json.dumps(get_kvantum_themes()))
