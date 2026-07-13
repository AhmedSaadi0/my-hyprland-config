# AGENTS.md — NibrasShell (Quickshell Config)

> Briefing file for AI coding agents: explains the architecture, conventions, and
> hard rules of this project so additions and edits stay consistent with the
> existing style. Read this file fully before touching any source.

---

## 1. Project Overview

- **Name**: NibrasShell — a Wayland desktop shell built on Quickshell + Hyprland.
- **Path**: `~/.config/quickshell/`
- **Entry point**: `shell.qml` (creates the `ShellRoot`).
- **Languages**: QML / QtQuick (UI) · Python 3.13 (backend) · JavaScript (`.js`) · Bash (lightweight glue).
- **Human language in comments**: Arabic is the primary developer language; English is used for technical terms. Keep this mix in any new comments.
- **Run command**: `./run.fish` (suppresses dbus/sni noise).
- **Persistent config**: `~/.nibrasshell.json` (written automatically by `ConfigStore.qml` when `updateConfig` is called).
- **Python interpreter**: `~/.cache/nibrasshell/venv/bin/python` (see `App.pythonPath`). Do not assume system Python works.
- **Python deps**: `scripts/python/requirements-3.13.txt`.

## 2. Directory Layout & Responsibilities

| Path | Responsibility |
|---|---|
| `shell.qml` | Root `ShellRoot`. Spawns the Splash then `mainUiLoader`. |
| `SplashScreen.qml` | Boot splash. |
| `windows/` | Full windows, one folder each: `smart_capsule/`, `settings/`, `dock/`, `leftwindow/`, `cheatsheet/`, `bottomlauncher/`, `poweroption/`, `overlay/`, `processdetail/`. |
| `bars/` | Persistent bars: `Topbar.qml`, `LeftBar.qml`, corner shells, widget trays. |
| `desktop/` | Wallpaper, desktop clock, notch, desktop widgets. |
| `osd/` | On-screen displays: volume, brightness, notifications. |
| `components/` | Reusable UI building blocks (MButton, MediaController, Shadow, IconImage, M3GroupBox, etc.). |
| `services/` | Business-logic singletons (Network, AI, Weather, Audio, Brightness, Clipboard, NotifManager, System, Overlay, Todo, ...). |
| `themes/` | Theme system. `ThemeManager.qml` + `BaseTheme.qml` (the `_primary / _surface / ...` model) + `variants/` (14 ready themes) + `modules/` (sub-controllers: WallpaperController, ThemeLoader, HyprlandBridge, SystemBridge, ThemeSerializer, AiThemeAssistant, DepthEffectController). |
| `utils/` | Generic helpers: `Helper.qml` (shell-command builder), `helpers.js`, `IconCache.js`, `LeftMenuStatus.qml`. |
| `config/` | **Global singletons + constants + EventBus**: `App.qml`, `ConfigStore.qml`, `EventBus.qml`, `EventNames.js`, `ConstValues.js`, `AnimationConfig.qml`, `NibrasShellShortcut.qml`, `CommandsRegistry.qml`. |
| `scripts/python/` | Python backend, split into sub-packages: `ai/`, `network/`, `m3/`, `devices/`. |
| `scripts/*.sh` | Light bash: `internet.sh`, `temp.sh`, `get_wallpapers.sh`. |
| `translations/` | `ar.ts`, `ar.qm` (Arabic only). |
| `i18n/` | Reserved for qsTranslate (currently empty). |
| `assets/` | icons, wallpapers, audio, fonts — **never edit or regenerate automatically**. |
| `graphify-out/` | Knowledge graph, refresh with `graphify update .` after edits (Python only — QML is not indexed). |

## 3. Application Lifecycle (read before touching `shell.qml`)

1. Quickshell loads `shell.qml` → `ShellRoot`.
2. `Component.onCompleted` sets `Qt.uiLanguage = "ar"` and calls `NetworkService.syncTimers()`.
3. When `ThemeManager` emits `initialThemeReady` (after a 50 ms safety `timerStartup`), `startComp` (1 s) calls `activateMainUI()` and turns `mainUiLoader.active = true`.
4. When the loader reports `Loader.Ready`, `hideSplashDelay` (300 ms) hides the splash.
5. **Rule**: any "global" window (settings, notifications) must be created via `incubateObject` (see `createGlobalWindowAsync` in `shell.qml:82`). Do not call `Component.createObject` directly from UI code.

## 4. Core Architectural Patterns

### 4.1 Global Singleton

```qml
pragma Singleton
import QtQuick
Singleton {
    id: root
    // ...
}
```

Existing singletons: `App`, `ThemeManager`, `EventBus`, `ConfigStore`, `NetworkService`, `AiService`, `Weather`, `Audio`, `Brightness`, `SystemService`, `NotifManager`, `OverlayService`, `LeftMenuStatus`, `IconService`, `MusicService`, `ClipboardService`, `TodoService`, `AiAnalysisService`, `Helper`. Anything new that holds cross-window state should follow the same pattern.

### 4.2 Sub-Controller (themes/modules)

A complex module is split into focused sub-controllers owned by a parent singleton. `ThemeManager` for example composes:

- `ThemeLoader` — loads a theme file.
- `WallpaperController` — manages local/downloaded/wallhaven wallpapers.
- `HyprlandBridge` — applies Hyprland config.
- `SystemBridge` — applies GTK/Plasma/Kvantum/Konsole/Qt/Cursor settings.
- `ThemeSerializer` — JSON cache read/write.
- `DepthEffectController` — rembg / opencv overlays.
- `AiThemeAssistant` — AI-driven palette generation.

### 4.3 EventBus

```qml
// emit
EventBus.emit(Events.TOGGLE_DOCK);

// subscribe (pass the owner so listeners auto-cleanup on destroy)
EventBus.on(Events.OPEN_LEFTBAR, callback, shellRoot);
```

- Event names **always** live in `config/EventNames.js` as `var`.
- Never inline a string literal into `EventBus.emit` / `EventBus.on` — add the name to `EventNames.js` first.

### 4.4 Process / JSON IPC with Python

```qml
Process {
    command: App.scripts.python.systemMonitorCommand
    stdout: StdioCollector {
        onStreamFinished: { /* parse JSON */ }
    }
    stderr: SplitParser { onRead: data => console.error(...) }
}
```

- stdout = JSON only. stderr = logs only. Never mix.
- For long-running wrappers, use `App.dispatchCommand(description, commandArray)` so commands show up in logs with a human-readable label.

### 4.5 AI Provider (Python)

```python
class LLMProvider(ABC):
    @abstractmethod
    def generate(self, message, history): ...

class GeminiProvider(LLMProvider): ...
class OpenAIProvider(LLMProvider): ...
class OpenRouterProvider(LLMProvider): ...
class OllamaProvider(LLMProvider): ...
class LocalProvider(LLMProvider): ...
```

- Provider selection is centralised in `get_provider()` in `ai/config.py` (driven by `App.aiProvider`).
- All prompt presets are defined in `PRESETS` (`weather`, `music`, `todo`, `boot_analyze`, `spike_analyze`, `system_action`, `color_palette`, `boot_solution`, `idle_capsule`, `coder`, `chat`). Add a new preset there before referencing it.

## 5. QML Conventions (strict)

- **Pragmas**: `pragma ComponentBehavior: Bound` in `shell.qml`; `pragma Singleton` on every singleton file.
- **Imports**: always `import "root:/..."` for project-relative paths. Do **not** use plain `./` / `../` outside the current directory — `root:` is the canonical way.
- **Root id**: every singleton and every reusable component uses `id: root`.
- **State exposure**: use `readonly property alias` only. Never expose a writable property on a singleton's top level.
- **Theme properties**: every backing color / dimension in `BaseTheme.qml` is prefixed with `_` (`_primary`, `_surfaceContainer`, `_baseRadius`). The underscore means "backing property used for persistence and system application"; UI files read these.
- **Naming**:
  - Files: `PascalCase.qml` (`MButton.qml`, `NetworkService.qml`).
  - IDs: `root` for the root, otherwise descriptive `camelCase` (`liveUsageListModel`, `fetchMusicModelsProcess`).
  - Properties: `camelCase`.
  - Leave the deliberate outliers (`QUICK_Q`, `TabBar.fillWidth`) alone.
- **Connections**: use the modern `Connections { target: X; function onYyy() {} }` form, not the legacy `onYyy: ...` shortcut.
- **Comments**: mixed Arabic / English. Section banners use `// =========== Title ===========`. Public helper functions in `Helper.qml` use JSDoc-style blocks (`@function`, `@param`, `@returns`).

## 6. JavaScript (`.js`) Conventions

- **Use `var` only** — no `const`, no `let`. This is a hard project rule (see `ConstValues.js`, `EventNames.js`).
- Constants are `UPPER_SNAKE_CASE` (`DASHBOARD_MENU_INDEX`, `IDLE`, `SRC_MUSIC`).
- Importing a JS module: `import "root:/config/ConstValues.js" as Consts`.
- `helpers.js` and `IconCache.js` hold pure utilities; add new pure helpers there instead of duplicating logic.

## 7. Python Conventions

- **Interpreter**: Python 3.13. Requirements file: `scripts/python/requirements-3.13.txt`.
- **Type hints** are required on every public function signature.
- **CLI entry points** use `argparse`. IPC outputs are JSON on stdout, logs on stderr.
- **Error handling**: `try / except` with clear Arabic-or-English messages. For AI responses, fall back to `json_repair` instead of crashing.
- **Layout**: each functional group is a sub-package (`ai/`, `network/`, `m3/`, `devices/`) with an `__init__.py`.
- **File naming**: CLI scripts use a hyphenated name (`dynamic-m3.py`, `list-gemini.py`); pure modules use `snake_case.py` with no suffix.
- **Provider example**:
  ```python
  class GeminiProvider(LLMProvider):
      def generate(self, message, history):
          # ...
  ```
- Do **not** drop loose `.py` files in `scripts/python/` root — put them in a sub-package.

## 8. Constants & Events

### 8.1 `config/ConstValues.js`
- Leftbar menu indices: `DASHBOARD_MENU_INDEX`, `NOTIFICATION_MENU_INDEX`, `WEATHER_MENU_INDEX`, `MONIROTS_MENU_INDEX`, `NETWORK_MENU_INDEX`, `CLIPBOARD_MENU_INDEX`, `TODO_MENU_INDEX`, `AI_BOT_MENU_INDEX`, ...
- Smart Capsule priorities: `IDLE=0`, `HOVER=1`, `TRANSIENT=2`, `NOTIFICATION=3`, `WARNING=4`, `CRITICAL=5`.
- Data sources: `SRC_MUSIC`, `SRC_SYSTEM`, `SRC_BATTERY`, `SRC_WEATHER`, `SRC_TODO`.
- Menu style: `FLOATING`, `DOCKED_FIXED_BAR`, `DOCKED_MOVING_BAR`.

### 8.2 `config/EventNames.js`
Every event has a `var X = "x"` entry whose variable name matches the string. Add the variable first, then use it. Currently exported: `OPEN_SETTINGS`, `OPEN_LEFTBAR`, `CLOSE_LEFTBAR`, `OPEN_CHEATSHEET`, `TOGGLE_BOTTOM_LAUNCHER`, `TOGGLE_DOCK`, `TOGGLE_POWER_MENU`, `CPU_THRESHOLD_EXCEEDED`, `MEMORY_THRESHOLD_EXCEEDED`, `APP_MENU_CLOSE_ALL`, etc.

## 9. Where to Add Things

| You want to add | Put it here |
|---|---|
| A new theme (e.g. Solarized) | `themes/variants/Solarized.qml` inheriting from `BaseTheme.qml`. Register it in `ThemeLoader`. |
| A new service (Singleton) | `services/YourService.qml` with `pragma Singleton`, `id: root`, plus its `Process` + `StdioCollector` blocks. Update `qmldir` if needed. |
| A new event | 1) Add `var X = "x"` in `EventNames.js`. 2) Use it via `EventBus`. |
| A new enum constant | Add to `ConstValues.js`. Never inline magic numbers. |
| A new Python CLI command | 1) Create the script in the right sub-package. 2) Add the path constant in `App.scripts.python.*`. 3) Add the `*Command` argv array. 4) Launch it via `App.dispatchCommand` or a `Process`. |
| A new UI control | `components/YourComponent.qml` with `id: root` and `import "root:/themes"` to read `_primary`/etc. |
| A new top-level window | `windows/yourwindow/` plus the `Component` in `shell.qml`. |
| A new AI provider | Subclass `LLMProvider` in `scripts/python/ai/` and register it in `get_provider()`. |
| A new AI preset | Add it to `PRESETS` in `scripts/python/ai/config.py` first, then reference by name. |

## 10. Hard Rules — Do Not Break

1. Never auto-edit `assets/`, `translations/`, or `i18n/` — these are user assets.
2. Keep the Arabic/English comment mix consistent with the surrounding file. Do not switch a file to English-only or Arabic-only.
3. Do not use `console.log`. Use `console.info` / `console.warn` / `console.error`.
4. Never hard-code API keys in Python. They must come in via `--api_key` from `App.scripts.python.*Command` (the user keys live in `App.config`).
5. Do not modify `BaseTheme.qml` without coordinating with `ThemeManager` — every active theme inherits from it.
6. Comments should be concise. Long technical explanations in English are acceptable; Arabic comments should stay short and clear.
7. IPC contract: stdout is JSON, stderr is logs. Do not mix.
8. Stick to the Quickshell imports the project already uses (`Quickshell`, `Quickshell.Io`, `Quickshell.Hyprland`, `Quickshell.Widgets`, `Quickshell.Networking`, `org.kde.kirigami`). Do not invent new module paths.
9. `ShellScreen` instances come from `Quickshell.screens`; always bind `screen: modelData` in `Variants { model: Quickshell.screens }`.
10. When a global window already exists, check `settingsWindowInstance` / `notificationsInstance` before re-creating it (see `initializeGlobalWindows`).

## 11. Testing & Running

```bash
# Launch the shell
./run.fish

# Recreate the Python venv (after editing requirements)
python -m venv ~/.cache/nibrasshell/venv
~/.cache/nibrasshell/venv/bin/pip install -r scripts/python/requirements-3.13.txt

# Lint a QML file
qmllint path/to/file.qml

# Refresh the knowledge graph (Python files only)
graphify update .
```

There is no automated test suite; rely on `qmllint`, manual `run.fish` runs, and a clean reload (`qs -p .`).

## 12. graphify-out/ Knowledge Graph

- **Scope**: Python scripts and their internal call graph (functions, classes, call edges). Node comments often include Arabic docstrings — that is intentional, leave them.
- **Not covered**: QML, `.js`, `.qml`, `.ts`, shell scripts, or anything outside `scripts/`.
- **How to use it**:
  - Before editing Python, skim `graphify-out/GRAPH_REPORT.md` (or `graphify-out/wiki/index.md` if present) for the relevant community / god nodes.
  - Use `graphify path "<A>" "<B>"` and `graphify explain "<concept>"` for cross-module questions instead of `grep`.
  - After editing Python, run `graphify update .` to refresh.
- **For QML**: do not expect graphify to help. Use `Grep` and `Glob` directly.

## 13. Pre-commit Checklist

- [ ] New code uses `id: root` and `readonly property alias` where applicable.
- [ ] Any new event / constant is declared in `EventNames.js` / `ConstValues.js`.
- [ ] Any new Python command is registered in `App.scripts.python.*` with both a path and a `*Command` argv array.
- [ ] No API keys are hard-coded anywhere.
- [ ] stdout is JSON only, stderr is logs only.
- [ ] `qmllint` passes on edited QML files.
- [ ] For Python edits, `graphify update .` was run.
- [ ] `./run.fish` starts the shell without new errors in the log filter.
- [ ] New comments match the language mix of the surrounding file.
