import json
import os

import nibras_installer.modules.user_config as user_config


def test_create_user_config_file(tmp_path, monkeypatch):
    monkeypatch.setenv("HOME", str(tmp_path))

    inputs = iter(
        [
            "Ahmed",  # username
            "Subtitle",  # subtitle
            "/path/to/pic.png",  # profile picture
            "1",  # network interface choice
            "/wall/dark",  # dark wallpapers
            "/wall/light",  # light wallpapers
            "Riyadh",  # city
            "SA",  # country
            "y",  # use prayer times
            "gemini-key",  # geminiApiKey
            "music-key",  # musicAiApiKey
            "weather-key",  # weatherAiApiKey
            "ar",  # aiPreferredLanguage
        ]
    )

    monkeypatch.setattr("builtins.input", lambda _: next(inputs))

    def fake_listdir(path):
        if path == "/sys/class/net":
            return ["wlan0"]
        return os.listdir(path)

    monkeypatch.setattr(user_config.os, "listdir", fake_listdir)

    user_config.create_user_config_file()

    cfg_path = tmp_path / ".nibrasshell.json"
    assert cfg_path.exists()
    data = json.loads(cfg_path.read_text(encoding="utf-8"))

    assert data["username"] == "Ahmed"
    assert data["networkMonitor"] == "wlan0"
    assert data["usePrayerTimes"] is True
    assert data["geminiApiKey"] == "gemini-key"
    assert data["musicAiApiKey"] == "music-key"
    assert data["weatherAiApiKey"] == "weather-key"
    assert data["aiPreferredLanguage"] == "ar"
