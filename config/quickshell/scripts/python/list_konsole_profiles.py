import sys
import os
import json

def get_konsole_profiles():
    profiles = []
    dirs = [
        "/usr/share/konsole",
        os.path.expanduser("~/.local/share/konsole")
    ]
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if f.endswith(".profile"):
                profile_name = f[:-8]  # remove .profile
                if profile_name not in profiles:
                    profiles.append(profile_name)
    return sorted(profiles)

if __name__ == "__main__":
    print(json.dumps(get_konsole_profiles()))
