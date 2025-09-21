#!/usr/bin/env python3

import argparse
import json
import os


def clean_up_images(json_folder_path, images_folder_path):
    """
    تقوم هذه الدالة بحذف صور PNG غير المستخدمة من مجلد معين،
    بناءً على قائمة بالصور المطلوب الاحتفاظ بها والمستخرجة من ملفات JSON.
    """

    # الخطوة 1: استخراج أسماء الصور المطلوب الاحتفاظ بها من ملفات JSON
    files_to_keep = set()

    # التأكد من وجود مجلد الـ JSON
    if not os.path.isdir(json_folder_path):
        print(f"   [خطأ] مجلد JSON غير موجود. يرجى التأكد من صحة المسار.")
        return

    for filename in os.listdir(json_folder_path):
        if filename.endswith(".json"):
            file_path = os.path.join(json_folder_path, filename)
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    # البحث عن الحقل المطلوب داخل ملف الـ JSON
                    if "_desktopClockDepthOverlayPath" in data:
                        image_path = data["_desktopClockDepthOverlayPath"]
                        if image_path and image_path.lower().endswith(".png"):
                            # استخلاص اسم الملف فقط من المسار
                            image_name = os.path.basename(image_path)
                            files_to_keep.add(image_name)
                            # print(f"   - سيتم الاحتفاظ بـ: '{image_name}'") # يمكن إلغاء التعليق لطباعة تفاصيل أكثر
            except Exception as e:
                print(
                    f"   [تحذير] حدث خطأ أثناء معالجة الملف '{filename}': {e}"
                )

    if not files_to_keep:
        print(
            "\n   [نتيجة] لم يتم العثور على أي صور للاحتفاظ بها في ملفات JSON. لن يتم حذف أي شيء."
        )
        return

    # التأكد من وجود مجلد الصور
    if not os.path.isdir(images_folder_path):
        print(f"   [خطأ] مجلد الصور غير موجود. يرجى التأكد من صحة المسار.")
        return

    deleted_count = 0
    # المرور على كل الملفات في مجلد الصور
    for filename in os.listdir(images_folder_path):
        # التحقق إذا كان الملف PNG وغير موجود في قائمة الملفات المطلوبة
        if filename.lower().endswith(".png") and filename not in files_to_keep:
            try:
                file_to_delete_path = os.path.join(
                    images_folder_path, filename
                )
                os.remove(file_to_delete_path)
                deleted_count += 1
            except OSError as e:
                print(f"   [خطأ] لم يتم حذف الملف '{filename}': {e}")

    # print(f"\n3. اكتملت العملية. تم حذف {deleted_count} صورة.")
    print(
        f"\nProcess complete. A total of {deleted_count} image(s) were deleted."
    )


# هذا الجزء من الكود يعمل عند تشغيل السكربت مباشرةً
if __name__ == "__main__":

    # تحديد المسارات الافتراضية بشكل ديناميكي بناءً على مجلد المستخدم الحالي
    home_dir = os.path.expanduser("~")
    default_json_path = os.path.join(home_dir, ".cache/nibrasshell/themes/")
    default_images_path = os.path.join(home_dir, ".cache/nibrasshell/")

    # إعداد محلل وسائط سطر الأوامر لاستقبال المدخلات
    parser = argparse.ArgumentParser(
        description="ينظف مجلد الصور (PNG) بناءً على قائمة مستخرجة من ملفات JSON."
    )

    # تعريف الوسائط كخيارات اختيارية مع تحديد القيم الافتراضية
    parser.add_argument(
        "--json_dir",
        default=default_json_path,
        help=f"المسار إلى مجلد JSON. (الافتراضي: {default_json_path})",
    )
    parser.add_argument(
        "--images_dir",
        default=default_images_path,
        help=f"المسار إلى مجلد الصور للتنظيف. (الافتراضي: {default_images_path})",
    )

    # تحليل الوسائط التي أدخلها المستخدم (إن وجدت)
    args = parser.parse_args()

    # استدعاء الدالة الرئيسية وتمرير المسارات (سواء الافتراضية أو المحددة)
    clean_up_images(args.json_dir, args.images_dir)
