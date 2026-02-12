#!/usr/bin/env python3
import argparse
import configparser
import json
import os
from pathlib import Path

EXTS = (".svg", ".png", ".xpm", ".webp")

BASE_ICON_DIRS = [
    os.path.expanduser("~/.icons"),
    os.path.expanduser("~/.local/share/icons"),
    "/usr/share/icons",
    "/usr/local/share/icons",
    "/var/lib/flatpak/exports/share/icons",
    "/run/host/usr/share/icons",
]


def existing_theme_dir(theme_name: str):
    if not theme_name:
        return None
    for base in BASE_ICON_DIRS:
        candidate = Path(base) / theme_name
        if candidate.is_dir():
            return candidate
    return None


def read_theme_meta(theme_dir: Path):
    index_file = theme_dir / "index.theme"
    if not index_file.is_file():
        return [], []

    cfg = configparser.ConfigParser(interpolation=None)
    try:
        cfg.read(index_file, encoding="utf-8")
    except Exception:
        return [], []

    inherits = []
    directories = []

    if cfg.has_section("Icon Theme"):
        raw_inherits = cfg.get("Icon Theme", "Inherits", fallback="")
        if raw_inherits:
            inherits = [x.strip() for x in raw_inherits.split(",") if x.strip()]

        raw_dirs = cfg.get("Icon Theme", "Directories", fallback="")
        if raw_dirs:
            directories = [x.strip() for x in raw_dirs.split(",") if x.strip()]

    return inherits, directories


def score_dir(directory: str):
    d = directory.lower()
    score = 0

    if "/apps" in d or d.endswith("apps"):
        score += 100
    if "scalable" in d:
        score += 30
    if "symbolic" in d:
        score -= 10

    size_bonus = 0
    for size in (64, 48, 32, 24, 22, 16, 128, 256):
        if f"{size}x{size}" in d:
            size_bonus = max(size_bonus, 20 - abs(48 - size))
    score += size_bonus

    return score


def expand_dirs(directories):
    if directories:
        return sorted(directories, key=score_dir, reverse=True)

    return [
        "scalable/apps",
        "128x128/apps",
        "64x64/apps",
        "48x48/apps",
        "32x32/apps",
        "24x24/apps",
        "22x22/apps",
        "16x16/apps",
        "symbolic/apps",
    ]


def build_theme_chain(theme_name: str):
    queue = [theme_name]
    seen = set()
    chain = []

    while queue:
        name = queue.pop(0)
        if not name or name in seen:
            continue
        seen.add(name)
        chain.append(name)

        theme_dir = existing_theme_dir(name)
        if theme_dir is None:
            continue

        inherits, _ = read_theme_meta(theme_dir)
        for parent in inherits:
            if parent not in seen:
                queue.append(parent)

    for fallback in ("hicolor", "Adwaita"):
        if fallback not in seen:
            chain.append(fallback)

    return chain


def resolve_icon(icon_name: str, chain):
    if not icon_name:
        return ""

    p = Path(icon_name)
    if p.is_absolute() and p.is_file():
        return str(p)

    for theme_name in chain:
        theme_dir = existing_theme_dir(theme_name)
        if theme_dir is None:
            continue

        _, directories = read_theme_meta(theme_dir)
        for subdir in expand_dirs(directories):
            d = theme_dir / subdir
            if not d.is_dir():
                continue

            with_ext = any(icon_name.lower().endswith(ext) for ext in EXTS)
            if with_ext:
                candidate = d / icon_name
                if candidate.is_file():
                    return str(candidate)
            else:
                for ext in EXTS:
                    candidate = d / f"{icon_name}{ext}"
                    if candidate.is_file():
                        return str(candidate)

        for ext in EXTS:
            candidate = theme_dir / f"{icon_name}{ext}"
            if candidate.is_file():
                return str(candidate)

    return ""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--theme", required=True)
    parser.add_argument("--icons-json", required=True)
    args = parser.parse_args()

    try:
        icons = json.loads(args.icons_json)
        if not isinstance(icons, list):
            raise ValueError("icons-json must be a list")
    except Exception:
        print("{}")
        return

    chain = build_theme_chain(args.theme)
    out = {}

    for raw_name in icons:
        name = str(raw_name).strip()
        if not name:
            continue
        out[name] = resolve_icon(name, chain)

    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()
