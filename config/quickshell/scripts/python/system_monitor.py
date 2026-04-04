#!/usr/bin/env python3
import glob
import json
import time

import psutil

# إعداد فترة التحديث (ثانيتين)
INTERVAL = 2


def get_max_temp():
    """نفس منطق سكربت الباش الخاص بك ولكن بلغة بايثون للحصول على دقة وأداء أعلى"""
    max_temp = 0.0
    # البحث في جميع مسارات الحرارة
    for zone in glob.glob("/sys/class/thermal/thermal_zone*/temp"):
        try:
            with open(zone, "r") as f:
                # قراءة القيمة وتحويلها من ملي-درجة إلى درجة مئوية
                raw_temp = float(f.read().strip())
                temp_c = raw_temp / 1000.0
                if temp_c > max_temp:
                    max_temp = temp_c
        except Exception:
            # تجاهل أي ملف لا يمكن قراءته
            continue
    return round(max_temp, 1)


def main():
    # استدعاء أولي لتهيئة psutil (الاستدعاء الأول دائما يرجع 0)
    psutil.cpu_percent(interval=None)

    while True:
        try:
            # 1. جلب استهلاك المعالج (يقارن الاستهلاك منذ آخر استدعاء في الحلقة)
            cpu_usage = psutil.cpu_percent(interval=None)

            # 2. جلب استهلاك الرام (النسبة المئوية مباشرة)
            ram_usage = psutil.virtual_memory().percent

            # 3. جلب أعلى درجة حرارة
            max_temp = get_max_temp()

            # تجميع البيانات في قاموس
            data = {"cpu": cpu_usage, "ram": ram_usage, "temp": max_temp}

            # طباعة البيانات كـ JSON. (flush=True مهم جداً لكي يصل الـ QML فوراً)
            print(json.dumps(data), flush=True)

            # الانتظار قبل القراءة التالية
            time.sleep(INTERVAL)

        except KeyboardInterrupt:
            break
        except Exception as e:
            # طباعة الخطأ كـ JSON لكي لا يتعطل الـ QML في حالة وجود مشكلة غير متوقعة
            print(json.dumps({"error": str(e)}), flush=True)
            time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
