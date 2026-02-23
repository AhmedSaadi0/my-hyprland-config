import json
from pathlib import Path

import nibras_installer.modules.i18n as i18n


def test_i18n_load_and_msg(tmp_path, monkeypatch):
    data_dir = tmp_path / "data"
    data_dir.mkdir()
    locales = {
        "en": {"hello": "Hello"},
        "ar": {"hello": "مرحبا"},
    }
    (data_dir / "locales.json").write_text(
        json.dumps(locales, ensure_ascii=False), encoding="utf-8"
    )

    monkeypatch.setattr(i18n, "PROJECT_ROOT", str(tmp_path))

    i18n.load_languages()
    i18n.set_lang("ar")
    assert i18n.msg("hello") == "مرحبا"
    i18n.set_lang("en")
    assert i18n.msg("hello") == "Hello"
    assert i18n.msg("missing_key") == "missing_key"
