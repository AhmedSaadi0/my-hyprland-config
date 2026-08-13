#!/usr/bin/env python3
import glob
import shutil
import subprocess
import time

import psutil

# إعداد فترة التحديث (ثانيتين)
INTERVAL = 2

# 1. البحث عن مسارات الحرارة مرة واحدة فقط عند تشغيل السكربت وتخزينها (Cache).
# مسارات ملفات النظام للحرارة ثابتة ولا تتغير أثناء تشغيل الجهاز،
# لذا فإن البحث عنها في كل دورة (كل ثانيتين) يستهلك قوة المعالج بلا فائدة.
THERMAL_ZONES = glob.glob("/sys/class/thermal/thermal_zone*/temp")

# 2. كشف مصدر استهلاك GPU مرة واحدة فقط عند التشغيل (Cache) بنفس فلسفة كاش الحرارة.
# كل دورة فحص تُستهلك قوة المعالج بلا فائدة، لذا نحدد المصدر المتاح في البداية فقط.
GPU_SOURCE = None  # "nvidia" | "amd" | None

# أ) NVIDIA: عبر nvidia-smi (متوفر على الجهاز الحالي)
_NVIDIA_BIN = shutil.which("nvidia-smi")

# ب) AMD: قراءة ملف sysfs مباشرة (بدون spawn لأي عملية)
_AMD_BUSY_PATHS = glob.glob("/sys/class/drm/card*/device/gpu_busy_percent")

if _NVIDIA_BIN:
    GPU_SOURCE = "nvidia"
elif _AMD_BUSY_PATHS:
    GPU_SOURCE = "amd"


def get_max_temp():
    """الحصول على أعلى درجة حرارة من المسارات المخزنة مسبقاً"""
    if not THERMAL_ZONES:
        return 0.0

    max_temp = 0.0
    for zone in THERMAL_ZONES:
        try:
            with open(zone, "r") as f:
                # تحويل القيمة مباشرة إلى float دون الحاجة لـ strip()
                # دالة float() في بايثون تتجاهل الفراغات والسطر الجديد تلقائياً.
                raw_temp = float(f.read())
                temp_c = raw_temp / 1000.0
                if temp_c > max_temp:
                    max_temp = temp_c
        except Exception:
            # تجاهل أي ملف لا يمكن قراءته
            continue
    return max_temp


def get_gpu_metrics():
    """قراءة استهلاك GPU والذاكرة (VRAM) وفق المصدر المكتشف مسبقاً.
    ترجع (gpu%, vram%, vram_used_mb, vram_total_mb) وتعطي -1 لأي قيمة غير متاحة
    """
    if GPU_SOURCE is None:
        return -1, -1, -1, -1

    if GPU_SOURCE == "nvidia":
        try:
            # استعلام صغير واحد مدمج (استهلاك + ذاكرة) بلا لوحة كاملة + مهلة 1 ثانية كضمان
            out = subprocess.run(
                [
                    _NVIDIA_BIN,
                    "--query-gpu=utilization.gpu,memory.used,memory.total",
                    "--format=csv,noheader,nounits",
                ],
                capture_output=True,
                text=True,
                timeout=1,
            )
            util_str, used_str, total_str = out.stdout.strip().split(", ")
            gpu_util = float(util_str)
            used_mb = float(used_str)
            total_mb = float(total_str)
            vram_pct = (used_mb / total_mb * 100.0) if total_mb > 0 else -1
            return gpu_util, vram_pct, used_mb, total_mb
        except Exception:
            return -1, -1, -1, -1

    # AMD: قراءة الملف الأول مباشرة (بدون معلومات ذاكرة)
    try:
        with open(_AMD_BUSY_PATHS[0], "r") as f:
            return float(f.read()), -1, -1, -1
    except Exception:
        return -1, -1, -1, -1


def main():
    # استدعاء أولي لتهيئة psutil
    psutil.cpu_percent(interval=None)

    while True:
        try:
            # 1. جلب استهلاك المعالج والرام
            cpu_usage = psutil.cpu_percent(interval=None)
            ram_usage = psutil.virtual_memory().percent

            # 2. جلب أعلى درجة حرارة
            max_temp = get_max_temp()

            # 3. جلب استهلاك GPU والذاكرة (يكلف ~24ms فقط مرة كل دورتين)
            gpu_usage, vram_pct, vram_used, vram_total = get_gpu_metrics()

            # 4. تحسين صياغة JSON باستخدام f-string بدلاً من مكتبة json
            # بما أن بنية البيانات ثابتة وبسيطة، استخدام f-string أسرع بكثير
            # ويتفادى استهلاك المعالج في بناء القواميس (Dictionaries) ومعالجتها عبر json.dumps.
            print(
                f'{{"cpu": {cpu_usage:.1f}, "ram": {ram_usage:.1f}, "temp": {max_temp:.1f}, "gpu": {gpu_usage:.1f}, "vram": {vram_pct:.1f}, "vram_used": {vram_used:.0f}, "vram_total": {vram_total:.0f}}}',
                flush=True,
            )

            # الانتظار قبل القراءة التالية
            time.sleep(INTERVAL)

        except KeyboardInterrupt:
            break
        except Exception as e:
            # صياغة رسالة الخطأ كـ JSON مع تجنب تعارض علامات الاقتباس
            err_msg = str(e).replace('"', '\\"')
            print(f'{{"error": "{err_msg}"}}', flush=True)
            time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
