import nibras_installer.modules.dependencies as deps


def test_install_fedora_calls_python_env(monkeypatch):
    called = {"env": False}

    monkeypatch.setattr(deps, "run_command_verbose", lambda *_args, **_kw: None)
    monkeypatch.setattr(deps, "run_command", lambda *_args, **_kw: None)
    monkeypatch.setattr(deps.subprocess, "run", lambda *_args, **_kw: None)

    def fake_env():
        called["env"] = True

    monkeypatch.setattr(deps, "install_python_env", fake_env)

    deps.install_fedora(False)
    assert called["env"] is True


def test_install_arch_calls_python_env(monkeypatch):
    called = {"env": False}

    monkeypatch.setattr(deps, "run_command_verbose", lambda *_args, **_kw: None)

    def fake_env():
        called["env"] = True

    monkeypatch.setattr(deps, "install_python_env", fake_env)

    deps.install_arch(False)
    assert called["env"] is True


def test_install_void_calls_python_env(monkeypatch):
    called = {"env": False}

    monkeypatch.setattr(deps, "run_command_verbose", lambda *_args, **_kw: None)

    def fake_env():
        called["env"] = True

    monkeypatch.setattr(deps, "install_python_env", fake_env)

    deps.install_void(False)
    assert called["env"] is True


def test_install_dependencies_enables_vnstat(monkeypatch):
    calls = []

    monkeypatch.setattr(deps, "install_fedora", lambda *_: None)
    monkeypatch.setattr(deps, "run_command", lambda cmd, **_kw: calls.append(cmd))

    deps.install_dependencies("fedora", install_optional=False)

    assert any("systemctl enable --now vnstat" in c for c in calls)
