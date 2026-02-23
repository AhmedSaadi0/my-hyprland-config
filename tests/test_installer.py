import os
from pathlib import Path

import nibras_installer.modules.installer as installer


def _make_project_root(root: Path):
    (root / "config" / "quickshell" / "scripts").mkdir(parents=True)
    (root / "config" / "easyeffects").mkdir(parents=True)
    (root / "config" / ".fonts").mkdir(parents=True)
    (root / "config" / "gtk-themes").mkdir(parents=True)
    (root / "config" / "icons").mkdir(parents=True)
    (root / "config" / "konsole").mkdir(parents=True)
    (root / "config" / "plasma-colors").mkdir(parents=True)
    (root / "config" / "kvantum-themes").mkdir(parents=True)
    (root / "config" / "config.fish").write_text("# fish\n")
    (root / "scripts").mkdir(parents=True)


def test_backup_configs(tmp_path, monkeypatch):
    home = tmp_path / "home"
    config_dir = home / ".config"
    for d in ["hypr", "quickshell", "easyeffects"]:
        (config_dir / d).mkdir(parents=True)
    (config_dir / "fish").mkdir(parents=True)
    (config_dir / "fish" / "config.fish").write_text("# fish\n")

    monkeypatch.setenv("HOME", str(home))

    installer.backup_configs()

    backups_dir = config_dir / "nibrasshell_backups"
    assert backups_dir.exists()
    backup_entries = list(backups_dir.iterdir())
    assert len(backup_entries) == 1

    backup_dir = backup_entries[0]
    assert (backup_dir / "hypr").exists()
    assert (backup_dir / "quickshell").exists()
    assert (backup_dir / "easyeffects").exists()
    assert (backup_dir / "fish" / "config.back.fish").exists()

    assert not (config_dir / "hypr").exists()
    assert not (config_dir / "quickshell").exists()
    assert not (config_dir / "easyeffects").exists()


def test_install_nibrasshell(tmp_path, monkeypatch):
    project_root = tmp_path / "project"
    _make_project_root(project_root)

    home = tmp_path / "home"
    monkeypatch.setenv("HOME", str(home))

    monkeypatch.setattr(installer, "PROJECT_ROOT", str(project_root))
    monkeypatch.setattr(installer, "backup_configs", lambda: None)
    monkeypatch.setattr(installer, "create_user_config_file", lambda: None)
    monkeypatch.setattr(installer, "set_plasma_font", lambda: None)
    monkeypatch.setattr(installer, "extract_archives", lambda *_args, **_kw: None)
    monkeypatch.setattr(installer, "run_command", lambda *_args, **_kw: None)

    installer.install_nibrasshell()

    hypr_dest = home / ".config" / "hypr"
    assert hypr_dest.exists()
    assert (home / ".config" / "quickshell").exists()
    assert (home / ".config" / "easyeffects").exists()
    assert (home / ".config" / "fish" / "config.fish").exists()


def test_update_quickshell(tmp_path, monkeypatch):
    project_root = tmp_path / "project"
    _make_project_root(project_root)
    qs_file = project_root / "config" / "quickshell" / "test.txt"
    qs_file.write_text("ok")

    home = tmp_path / "home"
    monkeypatch.setenv("HOME", str(home))

    monkeypatch.setattr(installer, "PROJECT_ROOT", str(project_root))
    monkeypatch.setattr(installer, "run_command", lambda *_args, **_kw: None)

    installer.update_quickshell()

    dest = home / ".config" / "quickshell" / "test.txt"
    assert dest.exists()
    assert dest.read_text() == "ok"


def test_uninstall_nibrasshell_restore(tmp_path, monkeypatch):
    home = tmp_path / "home"
    config_dir = home / ".config"
    for d in ["hypr", "quickshell", "easyeffects"]:
        (config_dir / d).mkdir(parents=True)
        (config_dir / d / "file.txt").write_text("x")

    backup_dir = config_dir / "nibrasshell_backups" / "backup-2020-01-01_00-00-00"
    (backup_dir / "hypr").mkdir(parents=True)
    (backup_dir / "hypr" / "restored.txt").write_text("restored")

    monkeypatch.setenv("HOME", str(home))

    inputs = iter(["y", "y"])
    monkeypatch.setattr("builtins.input", lambda *_: next(inputs))

    installer.uninstall_nibrasshell()

    assert (config_dir / "hypr" / "restored.txt").exists()
    assert not (config_dir / "quickshell").exists()
    assert not (config_dir / "easyeffects").exists()
