# scripts/python/scan_wallpapers.py
import argparse
import glob
import json
import os
import sys

# الامتدادات المدعومة للصور
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif"}


def debug(msg):
    """طباعة رسائل تتبع في stderr"""
    sys.stderr.write(f"[DEBUG] {msg}\n")


def get_mtime(filepath):
    """جلب تاريخ تعديل الملف لغرض الترتيب"""
    try:
        return os.path.getmtime(filepath)
    except OSError:
        return 0  # إذا كان الملف غير موجود أو لا يمكن قراءته، نعتبره قديماً جداً


def resolve_path(path, shell_dir):
    """تحويل المسارات إلى مسارات مطلقة وصحيحة"""
    if not path or not isinstance(path, str) or path.strip() == "":
        return None

    path = path.strip()

    # 1. التعامل مع المسار النسبي للمستخدم (~)
    if path.startswith("~"):
        path = os.path.expanduser(path)

    # 2. التعامل مع مسارات Quickshell (root:/)
    if path.startswith("root:/"):
        path = path.replace("root:/", shell_dir + "/", 1)

    # 3. تحويل المسار إلى مطلق
    path = os.path.abspath(path)

    return path


def get_images_from_dir(directory):
    """جلب الصور من مجلد معين"""
    images = set()
    if not directory or not os.path.exists(directory):
        return images

    try:
        with os.scandir(directory) as entries:
            for entry in entries:
                if entry.is_file():
                    ext = os.path.splitext(entry.name)[1].lower()
                    if ext in IMAGE_EXTENSIONS:
                        images.add(entry.path)
    except Exception as e:
        debug(f"Error scanning directory {directory}: {e}")

    return images


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--themes_cache_dir",
        required=True,
        help="Path to cached themes json directory",
    )
    parser.add_argument(
        "--global_dir", required=False, help="Path to global wallpapers"
    )
    parser.add_argument(
        "--shell_dir", required=True, help="Root path of the shell"
    )
    args = parser.parse_args()

    target_directories = set()
    collected_images = set()

    # تحسين المسار المدخل لمجلد الثيمات
    themes_cache_path = resolve_path(args.themes_cache_dir, args.shell_dir)
    debug(f"Scanning themes in: {themes_cache_path}")

    # 1. إضافة المجلد العام للخلفيات
    if args.global_dir:
        resolved_global = resolve_path(args.global_dir, args.shell_dir)
        if resolved_global and os.path.exists(resolved_global):
            target_directories.add(resolved_global)

    # 2. فحص ملفات JSON
    if themes_cache_path and os.path.exists(themes_cache_path):
        json_files = glob.glob(os.path.join(themes_cache_path, "*.json"))

        for json_file in json_files:
            try:
                with open(json_file, "r", encoding="utf-8") as f:
                    data = json.load(f)

                    # أ) استخراج مسار المجلد الديناميكي
                    dyn_path = data.get("_dynamicWallpapersPath")
                    if dyn_path:
                        resolved_dyn = resolve_path(dyn_path, args.shell_dir)
                        if resolved_dyn and os.path.exists(resolved_dyn):
                            target_directories.add(resolved_dyn)

                    # ب) استخراج الخلفية الفردية
                    single_wall = data.get("_wallpaper")
                    if single_wall:
                        resolved_single = resolve_path(
                            single_wall, args.shell_dir
                        )
                        if resolved_single and os.path.exists(resolved_single):
                            ext = os.path.splitext(resolved_single)[1].lower()
                            if ext in IMAGE_EXTENSIONS:
                                collected_images.add(resolved_single)

            except Exception as e:
                debug(f"Error reading {json_file}: {e}")
                continue

    # 3. جلب الصور من المجلدات المكتشفة
    debug(f"Scanning {len(target_directories)} unique directories...")
    for directory in target_directories:
        images_in_dir = get_images_from_dir(directory)
        collected_images.update(images_in_dir)

    # 4. الترتيب (الأحدث أولاً) والطباعة
    final_list = list(collected_images)

    # هنا يتم الترتيب بناءً على وقت التعديل، وعكس القائمة (reverse=True)
    final_list.sort(key=get_mtime, reverse=True)

    debug(f"Total unique wallpapers found: {len(final_list)}")
    print(json.dumps(final_list))


if __name__ == "__main__":
    main()
