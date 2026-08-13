#!/usr/bin/env python3
"""فحص مساحات الأقراص (Disk Usage) — stdout: JSON فقط، stderr: الأخطاء فقط."""

import argparse
import json
import sys

import psutil


def get_disks() -> list[dict]:
    """جمع استخدام كل قرص مرة واحدة، مع إزالة تكرار bind-mounts حسب الجهاز (device).

    مثال: `/opt` و`/var` نفس قرص `/mnt/new_storage` على جهاز المستخدم —
    يظهر القرص مرة واحدة فقط.
    """
    disks: list[dict] = []
    seen_devices: set[str] = set()

    for partition in psutil.disk_partitions(all=False):
        # تجاهل تكرار نفس الجهاز عبر عدة mountpoints (bind-mounts)
        if partition.device in seen_devices:
            continue
        try:
            usage = psutil.disk_usage(partition.mountpoint)
        except (PermissionError, OSError) as e:
            print(
                f"disk_usage: تعذر قراءة {partition.mountpoint}: {e}", file=sys.stderr
            )
            continue

        seen_devices.add(partition.device)
        disks.append(
            {
                "device": partition.device,
                "mount": partition.mountpoint,
                "fstype": partition.fstype,
                "total_gb": round(usage.total / (2**30), 1),
                "used_gb": round(usage.used / (2**30), 1),
                "free_gb": round(usage.free / (2**30), 1),
                "percent": usage.percent,
            }
        )

    return disks


def main() -> None:
    """نقطة دخول CLI — تطبع JSON على stdout وتخرج."""
    parser = argparse.ArgumentParser(description="عرض مساحات الأقراص كـ JSON")
    parser.parse_args()

    try:
        disks = get_disks()
        print(json.dumps(disks))
    except Exception as e:
        print(f"disk_usage: خطأ غير متوقع: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
