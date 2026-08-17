#!/usr/bin/env python3
import argparse
import configparser
import json
import os
import re
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

_meta_cache = {}


def existing_theme_dir(theme_name: str):
    if not theme_name:
        return None
    for base in BASE_ICON_DIRS:
        candidate = Path(base) / theme_name
        if candidate.is_dir():
            return candidate
    return None


def read_theme_meta(theme_dir: Path):
    """Returns (inherits, directories, sections).

    sections maps a directory name to (size, scale, type) parsed from its
    index.theme section; effective size = size * scale (for @2x/@3x dirs).
    """
    key = str(theme_dir)
    if key in _meta_cache:
        return _meta_cache[key]

    inherits = []
    directories = []
    sections = {}

    index_file = theme_dir / "index.theme"
    if index_file.is_file():
        cfg = configparser.ConfigParser(interpolation=None)
        try:
            cfg.read(index_file, encoding="utf-8")
        except Exception:
            pass

        if cfg.has_section("Icon Theme"):
            raw_inherits = cfg.get("Icon Theme", "Inherits", fallback="")
            if raw_inherits:
                inherits = [x.strip() for x in raw_inherits.split(",") if x.strip()]

            raw_dirs = cfg.get("Icon Theme", "Directories", fallback="")
            raw_scaled = cfg.get("Icon Theme", "ScaledDirectories", fallback="")
            directories = [
                x.strip() for x in (raw_dirs + "," + raw_scaled).split(",") if x.strip()
            ]

        for section in cfg.sections():
            if section == "Icon Theme":
                continue
            size = cfg.getint(section, "Size", fallback=0)
            scale = cfg.getint(section, "Scale", fallback=1)
            dir_type = cfg.get(section, "Type", fallback="Fixed")
            sections[section] = (size, scale, dir_type)

    # بعض الثيمات تخفي مجلدات حجم في القرص لا تدرجها في index.theme
    # (مثل Vivid: apps/64 موجود فعلياً لكنه غير مذكور) — نكتشفها يدوياً
    for extra_dir, extra_type in scan_extra_dirs(theme_dir):
        if extra_dir not in directories:
            directories.append(extra_dir)
        # مجلد مكتشف على القرص بدون قسم في index.theme: نحدد نوعه من محتواه
        if extra_dir not in sections:
            sections[extra_dir] = (0, 1, extra_type)

    _meta_cache[key] = (inherits, directories, sections)
    return inherits, directories, sections


def scan_extra_dirs(theme_dir: Path):
    """يكتشف مجلدات الحجم الموجودة على القرص وغير المدرجة في index.theme.

    Returns: list of (dir_name, type) — type مستنتج من محتوى المجلد
    ("Scalable" إذا احتوى SVG، وإلا "Fixed").
    """
    extra = []
    try:
        entries = [
            e for e in theme_dir.iterdir() if e.is_dir() and not e.name.startswith(".")
        ]
    except OSError:
        return extra

    for entry in entries:
        name = entry.name
        is_size_parent = bool(re.fullmatch(r"\d+(?:x\d+)?(?:@\d+x)?", name.lower()))
        try:
            children = [
                c for c in entry.iterdir() if c.is_dir() and not c.name.startswith(".")
            ]
        except OSError:
            continue
        for sub in children:
            sub_name = sub.name
            is_size_child = bool(
                re.fullmatch(r"\d+(?:x\d+)?(?:@\d+x)?", sub_name.lower())
            )
            if (is_size_parent and not re.search(r"symbolic", sub_name.lower())) or (
                is_size_child and not re.search(r"symbolic", name.lower())
            ):
                extra.append((f"{name}/{sub_name}", _dir_type(sub)))
    return extra


def _dir_type(subdir: Path) -> str:
    """يستنتج نوع المجلد من محتواه: SVG => Scalable (جودة ثابتة)، غير ذلك Fixed."""
    try:
        for f in subdir.iterdir():
            if f.is_file() and f.suffix.lower() == ".svg":
                return "Scalable"
    except OSError:
        pass
    return "Fixed"


def extract_size(directory: str) -> int:
    """يستخرج الحجم الفعلي من اسم المجلد دون الاعتماد على index.theme:
    '48x48/apps' -> 48, 'apps/48' -> 48, 'apps/16@2x' -> 32, 'symbolic' -> 0.
    """
    m = re.search(r"(\d+)x(\d+)(?:@(\d+)x)?", directory)
    if m:
        scale = int(m.group(3)) if m.group(3) else 1
        return int(m.group(1)) * scale

    m = re.search(r"(\d+)(?:@(\d+)x)?", directory)
    if m:
        scale = int(m.group(2)) if m.group(2) else 1
        return int(m.group(1)) * scale
    return 0


def score_dir(directory: str, sections=None):
    d = directory.lower()
    score = 0

    # سياق التطبيقات: يظهر بأسلوبين — "48x48/apps" و "apps/48"
    if "apps" in d.split("/"):
        score += 100
    if "symbolic" in d:
        score -= 10

    size, scale, dir_type = 0, 1, ""
    if sections and directory in sections:
        size, scale, dir_type = sections[directory]

    # SVG قابل للتمدد: جودة ثابتة في أي حجم
    if "scalable" in d or dir_type.lower() == "scalable":
        score += 40

    # الحجم الأكبر أفضل دائماً: التصغير حاد، والتكبير هو مصدر الضبابية
    if size > 0:
        score += size * scale
    else:
        score += extract_size(directory)

    return score


def expand_dirs(directories, sections=None):
    if directories:
        return sorted(directories, key=lambda d: score_dir(d, sections), reverse=True)

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

        inherits, _, _ = read_theme_meta(theme_dir)
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

        _, directories, sections = read_theme_meta(theme_dir)
        for subdir in expand_dirs(directories, sections):
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
