#!/usr/bin/env python3
import json
import re
import subprocess
import sys


def get_cliphist_items():
    try:
        # 1. جلب القائمة الخام
        result = subprocess.run(
            "cliphist list | head -n 50",
            shell=True,
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            return []

        lines = result.stdout.strip().split("\n")
        processed_items = []

        for line in lines:
            # نفصل الـ ID عن النص
            parts = line.split("\t", 1)
            if len(parts) < 2:
                continue

            clip_id = parts[0]
            raw_text = parts[1]
            display_text = raw_text.strip()

            # تصنيف النص للألوان والأيقونات
            item_type = 0
            if re.match(r"^(http|https|ftp)://", display_text):
                item_type = 1
            elif (
                re.match(
                    r"^(sudo|git|docker|npm|pip|import|#|class |function |def |const |var |let )",
                    display_text,
                )
                or "{" in display_text
            ):
                item_type = 2
            elif re.match(r"^#(?:[0-9a-fA-F]{3}){1,2}$", display_text):
                item_type = 3
            elif display_text.startswith("/"):
                item_type = 4
            # افتراض الصور (binary)
            elif len(display_text) < 100 and "binary" in display_text.lower():
                item_type = 4

            processed_items.append(
                {"id": clip_id, "text": display_text, "type": item_type}
            )

        return processed_items

    except Exception as e:
        return []


def activate_item(clip_id):
    # النسخ بسيط: فك التشفير ثم النسخ
    # نستخدم decode لأنه يقبل ID مباشرة
    cmd = f"cliphist decode {clip_id} | wl-copy"
    subprocess.run(cmd, shell=True)


def delete_item(clip_id):
    try:
        # الحل لمشكلة الحذف:
        # 1. نجلب القائمة
        list_proc = subprocess.run(
            "cliphist list", shell=True, capture_output=True, text=True
        )
        lines = list_proc.stdout.splitlines()

        # 2. نبحث عن السطر الذي يبدأ بهذا الـ ID
        target_line = None
        prefix = f"{clip_id}\t"

        for line in lines:
            if line.startswith(prefix):
                target_line = line
                break

        # 3. إذا وجدناه، نرسله كاملاً لأمر الحذف
        if target_line:
            # ملاحظة: نستخدم echo مع pipe لإرسال السطر لأمر الحذف
            # نستخدم shlex.quote أو نضعها بين علامات اقتباس لتجنب مشاكل الرموز
            safe_line = target_line.replace('"', '\\"').replace("`", "\\`")
            cmd = f'echo "{safe_line}" | cliphist delete'
            subprocess.run(cmd, shell=True)

    except Exception as e:
        pass


def wipe_all():
    # أمر المسح عادة بسيط، لكن أحياناً يحتاج تأكيد
    subprocess.run("cliphist wipe", shell=True)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "list":
            print(json.dumps(get_cliphist_items()))
        elif cmd == "activate" and len(sys.argv) > 2:
            activate_item(sys.argv[2])
        elif cmd == "delete" and len(sys.argv) > 2:
            delete_item(sys.argv[2])
        elif cmd == "wipe":
            wipe_all()
    else:
        print(json.dumps(get_cliphist_items()))
