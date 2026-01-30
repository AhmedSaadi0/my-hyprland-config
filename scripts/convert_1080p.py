import os
import subprocess
import sys
from pathlib import Path

# قائمة بالصيغ التي سيبحث عنها السكربت
VIDEO_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.flv', '.wmv', '.webm'}

def convert_videos(directory):
    # تحويل المسار إلى كائن Path
    input_path = Path(directory)

    # التحقق من وجود المجلد
    if not input_path.exists() or not input_path.is_dir():
        print(f"Error: The directory '{directory}' does not exist.")
        return

    # إنشاء مجلد للمخرجات داخل المجلد المختار
    output_dir = input_path / "converted_1080p"
    output_dir.mkdir(exist_ok=True)

    print(f"--- Processing videos in: {input_path} ---")
    print(f"--- Output folder: {output_dir} ---\n")

    # البحث عن الملفات
    for file_path in input_path.iterdir():
        # التأكد أن الملف فيديو وليس مجلداً
        if file_path.is_file() and file_path.suffix.lower() in VIDEO_EXTENSIONS:

            output_file = output_dir / f"{file_path.stem}_1080p.mp4"

            print(f"Converting: {file_path.name} ...")

            # أمر FFmpeg
            # نستخدم scale=-2:1080 كما طلبت
            # نستخدم crf 23 للحفاظ على جودة جيدة وحجم معقول
            # نستخدم preset fast لسرعة التحويل
            command = [
                'ffmpeg',
                '-n', # عدم استبدال الملف اذا كان موجوداً مسبقاً
                '-i', str(file_path),
                '-vf', 'scale=0:1080',
                '-c:v', 'libx264',
                '-crf', '23',
                '-preset', 'fast',
                '-c:a', 'copy', # نسخ الصوت كما هو لتسريع العملية
                str(output_file)
            ]

            try:
                # تشغيل الأمر وإخفاء التفاصيل الكثيرة (نظهر الأخطاء فقط)
                subprocess.run(command, check=True, stderr=subprocess.DEVNULL)
                print(f"Done: {output_file.name}\n")
            except subprocess.CalledProcessError:
                print(f"Failed to convert: {file_path.name}\n")

    print("--- All tasks finished ---")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        # إذا لم يحدد المستخدم مجلداً، نطلب منه الإدخال
        folder = input("Please enter the folder path: ").strip()
    else:
        folder = sys.argv[1]

    # إزالة علامات التنصيص إذا أضافها المستخدم بالخطأ عند السحب والإفلات
    folder = folder.replace('"', '').replace("'", "")

    convert_videos(folder)
