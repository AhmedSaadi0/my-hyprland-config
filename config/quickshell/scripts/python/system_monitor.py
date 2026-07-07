#!/usr/bin/env python3
import glob
import time

import psutil

# إعداد فترة التحديث (ثانيتين)
INTERVAL = 2

# 1. البحث عن مسارات الحرارة مرة واحدة فقط عند تشغيل السكربت وتخزينها (Cache).
# مسارات ملفات النظام للحرارة ثابتة ولا تتغير أثناء تشغيل الجهاز،
# لذا فإن البحث عنها في كل دورة (كل ثانيتين) يستهلك قوة المعالج بلا فائدة.
THERMAL_ZONES = glob.glob("/sys/class/thermal/thermal_zone*/temp")


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

            # 3. تحسين صياغة JSON باستخدام f-string بدلاً من مكتبة json
            # بما أن بنية البيانات ثابتة وبسيطة، استخدام f-string أسرع بكثير
            # ويتفادى استهلاك المعالج في بناء القواميس (Dictionaries) ومعالجتها عبر json.dumps.
            print(
                f'{{"cpu": {cpu_usage:.1f}, "ram": {ram_usage:.1f}, "temp": {max_temp:.1f}}}',
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
