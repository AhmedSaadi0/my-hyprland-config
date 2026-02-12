#!/usr/bin/env python3
import argparse
import os
import re
import shutil
import subprocess
import sys


def qdbus_candidates():
    candidates = [
        os.environ.get("QDBUS_BIN"),
        shutil.which("qdbus"),
        shutil.which("qdbus6"),
        "/usr/bin/qdbus6",
        "/usr/bin/qdbus",
    ]
    result = []
    for candidate in candidates:
        if candidate and os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            if candidate not in result:
                result.append(candidate)
    return result


def pick_qdbus_bin():
    candidates = qdbus_candidates()
    for candidate in candidates:
        try:
            probe = subprocess.run(
                [candidate],
                check=False,
                capture_output=True,
                text=True,
            )
            # The working binary should list bus names successfully.
            if probe.returncode == 0 and "org.freedesktop.DBus" in probe.stdout:
                return candidate
        except Exception:
            continue

    # Fallback to first available candidate if probing was inconclusive.
    return candidates[0] if candidates else None


QDBUS_BIN = pick_qdbus_bin()


def run_qdbus(args):
    if not QDBUS_BIN:
        return None

    try:
        return subprocess.run(
            [QDBUS_BIN, *args],
            check=False,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        return None


def list_konsole_services():
    res = run_qdbus([])
    if res is None or res.returncode != 0:
        return []

    services = []
    for line in res.stdout.splitlines():
        name = line.strip()
        if name.startswith("org.kde.konsole"):
            services.append(name)
    return services


def list_session_paths(service):
    res = run_qdbus([service])
    if res is None or res.returncode != 0:
        return []

    paths = []
    for line in res.stdout.splitlines():
        path = line.strip()
        if re.fullmatch(r"/Sessions/\d+", path):
            paths.append(path)
    return paths


def apply_profile_to_session(service, session_path, profile):
    profile_variants = []
    if profile.endswith(".profile"):
        profile_variants.append(profile)
        profile_variants.append(profile[: -len(".profile")])
    else:
        profile_variants.append(profile)
        profile_variants.append(profile + ".profile")

    for profile_value in profile_variants:
        candidates = [
            [service, session_path, "setProfile", profile_value],
            [service, session_path, "org.kde.konsole.Session.setProfile", profile_value],
        ]

        for args in candidates:
            res = run_qdbus(args)
            if res is not None and res.returncode == 0:
                return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", required=True)
    args = parser.parse_args()

    services = list_konsole_services()
    if not QDBUS_BIN:
        print("[KonsoleProfile] qdbus binary not found.")
        return 0

    if not services:
        print("[KonsoleProfile] No running Konsole DBus service found.")
        return 0

    updated = 0
    failed = 0

    for service in services:
        for session_path in list_session_paths(service):
            if apply_profile_to_session(service, session_path, args.profile):
                updated += 1
            else:
                failed += 1

    print(f"[KonsoleProfile] Updated sessions: {updated}, failed: {failed}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
