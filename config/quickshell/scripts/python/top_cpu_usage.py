# get_cpu_usage.py
import json
import time

import psutil


def get_top_cpu_processes(limit=10):
    """
    يسترجع أكثر العمليات استهلاكًا للمعالج بدقة عالية باستخدام psutil،
    ويقوم بتطبيع النسبة المئوية لتكون نسبة من إجمالي قدرة المعالج في النظام (مجموع كل الأنوية).
    """
    processes_data = []

    # الحصول على عدد الأنوية المنطقية مرة واحدة
    num_logical_cores = psutil.cpu_count(logical=True)
    if num_logical_cores is None or num_logical_cores == 0:
        # إذا تعذر تحديد عدد الأنوية، افترض نواة واحدة لتجنب القسمة على صفر أو الأخطاء
        num_logical_cores = 1

    # الخطوة 1: تهيئة عدادات المعالج لجميع العمليات النشطة.
    primed_procs = {}
    for proc in psutil.process_iter(["pid", "name"]):
        try:
            if not proc.is_running():
                continue
            proc.cpu_percent(interval=None)  # تهيئة العداد الأول
            primed_procs[proc.pid] = proc
        except (
            psutil.NoSuchProcess,
            psutil.AccessDenied,
            psutil.ZombieProcess,
        ):
            continue
        except Exception:
            pass  # يمكن تجاهل الأخطاء البسيطة هنا للحفاظ على الاستمرارية

    # الخطوة 2: الانتظار لفترة قصيرة جداً (0.1 ثانية) للسماح بتغير عدادات المعالج.
    time.sleep(0.5)

    # الخطوة 3: الحصول على نسبة استخدام المعالج الفعلية لكل عملية وتطبيعها.
    for pid, proc in primed_procs.items():
        try:
            cpu_usage = proc.cpu_percent(interval=None)
            if cpu_usage is not None:
                # قم بتطبيع نسبة استهلاك المعالج بناءً على عدد الأنوية المنطقية
                # مثال: إذا كانت العملية تستخدم 150% على نظام ثنائي النواة، ستصبح 75%.
                normalized_cpu_usage = cpu_usage / num_logical_cores
                processes_data.append(
                    {"name": proc.info["name"], "value": normalized_cpu_usage}
                )
        except (
            psutil.NoSuchProcess,
            psutil.AccessDenied,
            psutil.ZombieProcess,
        ):
            continue
        except Exception:
            pass

    # فرز جميع العمليات المجمعة حسب استهلاك المعالج تنازليًا
    processes_data.sort(key=lambda x: x["value"], reverse=True)

    return processes_data[:limit]


if __name__ == "__main__":
    top_processes = get_top_cpu_processes(limit=10)
    # لا حاجة لـ round() هنا، QML سيهتم بـ toFixed(2) للعرض
    print(json.dumps(top_processes))
