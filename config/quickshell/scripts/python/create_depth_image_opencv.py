# scripts/python/create_depth_image_opencv.py (النسخة النهائية والمدمجة)

import sys
from pathlib import Path

import cv2
import numpy as np


def process_image_grabcut(input_path_str: str, output_path_str: str):
    input_path = Path(input_path_str)
    output_path = Path(output_path_str)

    if not input_path.is_file():
        print(
            f"Error: Input file not found at '{input_path}'", file=sys.stderr
        )
        sys.exit(1)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        # 1. قراءة الصورة
        img = cv2.imread(str(input_path))
        if img is None:
            print(
                f"Error: Could not read image from '{input_path}'",
                file=sys.stderr,
            )
            sys.exit(1)

        # 2. تشغيل GrabCut كالمعتاد لإنشاء القناع
        mask = np.zeros(img.shape[:2], np.uint8)
        height, width = img.shape[:2]
        rect = (
            int(width * 0.05),
            int(height * 0.05),
            int(width * 0.9),
            int(height * 0.9),
        )
        bgdModel = np.zeros((1, 65), np.float64)
        fgdModel = np.zeros((1, 65), np.float64)
        cv2.grabCut(
            img, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT
        )

        # إنشاء القناع النهائي (0 للخلفية، 1 للمقدمة)
        mask2 = np.where((mask == 2) | (mask == 0), 0, 1).astype("uint8")

        # --- [بداية الجزء المصحح] ---
        # الخطوة أ: إزالة البيانات اللونية للخلفية (جعلها سوداء)
        # هذا هو الجزء الناجح من السكربت الأول
        img_fg_with_black_bg = img * mask2[:, :, np.newaxis]

        # الخطوة ب: إضافة قناة الشفافية
        # نحول الصورة ذات الخلفية السوداء إلى صيغة BGRA
        bgra = cv2.cvtColor(img_fg_with_black_bg, cv2.COLOR_BGR2BGRA)

        # الخطوة ج: تعيين الشفافية بناءً على القناع
        # الآن، البيكسلات السوداء ستصبح شفافة تماماً
        bgra[:, :, 3] = mask2 * 255
        # --- [نهاية الجزء المصحح] ---

        # 3. حفظ الصورة النهائية
        cv2.imwrite(str(output_path), bgra)

        print(
            f"Success (OpenCV): Foreground created correctly at '{output_path}'"
        )

    except Exception as e:
        print(f"An error occurred in OpenCV script: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python create_depth_image_opencv.py <input> <output.png>",
            file=sys.stderr,
        )
        sys.exit(1)
    process_image_grabcut(sys.argv[1], sys.argv[2])
