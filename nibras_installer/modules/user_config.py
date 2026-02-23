# modules/user_config.py
import json
import os

from config import GREEN, NC, RED, YELLOW

from .i18n import msg


def create_user_config_file():
    print("\n" + "=" * 35)
    print(f"{GREEN}{msg('config_creation_title')}{NC}")
    print(f"{YELLOW}{msg('config_prompt')}{NC}")
    print("=" * 35)

    home_dir = os.path.expanduser("~")
    config = {}

    # Get user input
    config["username"] = input(msg("prompt_username"))
    config["subtitle"] = input(msg("prompt_subtitle"))
    config["profilePicture"] = input(msg("prompt_profile_pic"))

    # Auto-detect and select network interface
    try:
        interfaces = [i for i in os.listdir("/sys/class/net") if i != "lo"]
        if not interfaces:
            raise IndexError
        print(f"{YELLOW}{msg('prompt_network_select')}{NC}")
        for idx, iface in enumerate(interfaces):
            print(f"  {idx + 1}. {iface}")
        choice_idx = int(input("> ")) - 1
        config["networkMonitor"] = interfaces[choice_idx]
    except (IndexError, ValueError, FileNotFoundError):
        print(
            f"{RED}Could not detect network interface. Defaulting to 'wlp0s20f3'.{NC}"
        )
        config["networkMonitor"] = "wlp0s20f3"

    config["darkM3WallpaperPath"] = input(msg("prompt_dark_wallpapers"))
    config["lightM3WallpaperPath"] = input(msg("prompt_light_wallpapers"))
    config["weatherLocation"] = input(msg("prompt_city"))
    config["city"] = config["weatherLocation"]
    config["country"] = input(msg("prompt_country"))

    use_prayer_ans = input(msg("prompt_use_prayer")).lower()
    config["usePrayerTimes"] = use_prayer_ans in ["y", "yes", "ن", "نعم"]

    config["geminiApiKey"] = input(msg("gemini_api_key"))
    config["musicAiApiKey"] = input(msg("music_ai_api_key"))
    config["weatherAiApiKey"] = input(msg("weather_ai_api_key"))
    config["aiPreferredLanguage"] = input(msg("ai_preferred_language"))

    # Set default values
    config["changePlasmaColor"] = True
    config["networkTimeout"] = 300
    config["networkInterval"] = 1000
    config["scripts"] = {
        "dynamicM3Py": None,
        "get_wallpapers": None,
        "createThumbnail": None,
        "gtk_theme": None,
        "systemInfo": None,
        "deviceLocal": None,
        "cpu": None,
        "ram": None,
        "deviceTemp": None,
        "hardwareInfo": None,
        "cpuUsage": None,
        "ramUsage": None,
        "cpuCores": None,
        "devicesTemp2": None,
        "playerctl": None,
    }

    # Write the config to a JSON file
    file_path = os.path.join(home_dir, ".nibrasshell.json")
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    print(f"\n{GREEN}{msg('config_saved')}{NC}")
