import sys
import os
import json

def get_plasma_schemes():
    schemes = []
    dirs = [
        "/usr/share/color-schemes",
        os.path.expanduser("~/.local/share/color-schemes")
    ]
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if f.endswith(".colors"):
                scheme_name = f[:-7]  # remove .colors
                if scheme_name not in schemes:
                    schemes.append(scheme_name)
    return sorted(schemes)

if __name__ == "__main__":
    print(json.dumps(get_plasma_schemes()))
