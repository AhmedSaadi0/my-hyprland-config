# get_top_ram_usage_with_details.py
import json

import psutil

# import sys


def get_top_ram_processes(limit=10):
    """
    يسترجع أكثر العمليات استهلاكًا للذاكرة (RAM) مع تفاصيل كاملة.
    تُعيد قائمة من القواميس تحتوي على:
    - 'pid': معرّف العملية (Process ID)
    - 'name': اسم العملية
    - 'memory_percent': نسبة استهلاك الذاكرة المئوية
    - 'memory_usage_mb': حجم استهلاك الذاكرة بالميجابايت
    """
    processes_info = []

    # الحصول على قائمة العمليات مع المعلومات المطلوبة دفعة واحدة لتحسين الأداء
    # تمت إضافة 'pid' هنا
    for proc in psutil.process_iter(
        ["pid", "name", "memory_percent", "memory_info", "status"]
    ):
        try:
            # استبعاد العمليات التي لا تعمل أو في حالة الزومبي
            if (
                not proc.is_running()
                or proc.info["status"] == psutil.STATUS_ZOMBIE
            ):
                continue

            mem_percent = proc.info["memory_percent"]
            if mem_percent is not None and mem_percent > 0.0:
                # الحصول على حجم الذاكرة المستخدمة بالبايت (RSS)
                mem_usage_bytes = proc.info["memory_info"].rss
                # تحويل البايت إلى ميجابايت
                mem_usage_mb = mem_usage_bytes / (1024 * 1024)

                processes_info.append(
                    {
                        "pid": proc.info["pid"],  # إضافة معرّف العملية هنا
                        "name": proc.info["name"],
                        "value": round(mem_percent, 2),  # تقريب النسبة المئوية
                        "memory_usage_mb": round(
                            mem_usage_mb, 2
                        ),  # تقريب حجم الاستهلاك
                    }
                )
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            # قد تنتهي العملية أثناء التنفيذ أو لا يمكن الوصول إليها
            continue
        except Exception as e:
            # للتعامل مع أي أخطاء غير متوقعة
            # print(f"Warning: Could not get memory info for {proc.info.get('name', '')}: {e}", file=sys.stderr)
            continue

    # ترتيب العمليات بناءً على النسبة المئوية لاستهلاك الذاكرة (من الأعلى إلى الأقل)
    processes_info.sort(key=lambda p: p["value"], reverse=True)

    # إرجاع أعلى عدد محدد من العمليات
    return processes_info[:limit]


if __name__ == "__main__":
    top_processes = get_top_ram_processes(limit=20)
    # طباعة النتيجة بصيغة JSON منسقة لسهولة القراءة
    # ensure_ascii=False تضمن عرض الأسماء العربية بشكل صحيح إن وجدت
    print(json.dumps(top_processes))
