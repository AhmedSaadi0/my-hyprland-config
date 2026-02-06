import subprocess
import sys
from pathlib import Path

VIDEO_EXTENSIONS = {".mp4", ".mkv", ".avi", ".mov", ".flv", ".wmv", ".webm"}


def convert_videos(directory):
    input_path = Path(directory)

    if not input_path.exists() or not input_path.is_dir():
        print(f"Error: The directory '{directory}' does not exist.")
        return

    output_dir = input_path / "compressed_wallpapers"
    output_dir.mkdir(exist_ok=True)

    print(f"--- Processing videos in: {input_path} ---")
    print("--- Optimization Mode: Maximum Compression (HEVC) ---\n")

    for file_path in input_path.iterdir():
        if (
            file_path.is_file()
            and file_path.suffix.lower() in VIDEO_EXTENSIONS
        ):

            output_file = output_dir / f"{file_path.stem}_optimized.mp4"

            print(f"Optimizing: {file_path.name} ...")

            command = [
                "ffmpeg",
                "-n",  # عدم الاستبدال إذا وجد الملف
                "-i",
                str(file_path),
                # 1. تغيير الدقة لـ 1080p وتقليل الفريمات لـ 24 لتقليل حجم البيانات
                "-vf",
                "scale=1920:-2,fps=24",
                # 2. استخدام المبرمج libx265 (أقوى بمرتين من x264 في الضغط)
                "-c:v",
                "libx265",
                # 3. رفع قيمة CRF لتقليل الحجم (28-30 توازن ممتاز)
                "-crf",
                "30",
                # 4. استخدام preset slower يجعل ffmpeg يأخذ وقتاً أطول للبحث عن أفضل ضغط ممكن
                "-preset",
                "slow",
                # 5. حذف الصوت نهائياً لتوفير مساحة إضافية
                "-an",
                # 6. إضافة خيار لجعل تشغيل الفيديو أسرع عند فتحه
                "-movflags",
                "+faststart",
                str(output_file),
            ]

            try:
                subprocess.run(command, check=True)
                print(f"✅ Success: {output_file.name} (Size reduced!)\n")
            except subprocess.CalledProcessError:
                print(f"❌ Failed to convert: {file_path.name}\n")

    print("--- All tasks finished! Your wallpapers are ready. ---")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        folder = input("Please enter the folder path: ").strip()
    else:
        folder = sys.argv[1]

    folder = folder.replace('"', "").replace("'", "")
    convert_videos(folder)
