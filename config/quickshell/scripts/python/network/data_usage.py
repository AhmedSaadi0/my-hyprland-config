import subprocess
from datetime import datetime


def get_data_usage(start_date_str, end_date_str, interface="wlp0s20f3"):
    """
    يعرض استهلاك البيانات لواجهة شبكة معينة خلال فترة زمنية محددة.
    """
    try:
        # التحقق من صحة صيغة التاريخ
        datetime.strptime(start_date_str, "%Y-%m-%d")
        datetime.strptime(end_date_str, "%Y-%m-%d")

        print(
            f"جاري جلب بيانات الاستهلاك للواجهة {interface} من {start_date_str} إلى {end_date_str}..."
        )

        # بناء الأمر
        command = [
            "vnstat",
            "--days",
            "--begin",
            start_date_str,
            "--end",
            end_date_str,
            "-i",
            interface,
        ]

        result = subprocess.check_output(command, text=True)
        print("\n--- تقرير استهلاك البيانات ---\n")
        print(result)

    except FileNotFoundError:
        print("خطأ: أداة 'vnstat' غير مثبتة. يرجى تثبيتها أولاً.")
    except ValueError:
        print("خطأ: صيغة التاريخ غير صحيحة. يرجى استخدام YYYY-MM-DD.")
    except subprocess.CalledProcessError as e:
        print(f"حدث خطأ أثناء تشغيل vnstat: {e.output}")


if __name__ == "__main__":
    # تحديد فترة زمنية (مثال: من بداية الشهر الحالي حتى اليوم)
    today = datetime.now()
    start_of_month = today.replace(day=1).strftime("%Y-%m-%d")
    today_str = today.strftime("%Y-%m-%d")

    # يمكنك تغيير التواريخ حسب حاجتك
    get_data_usage(start_of_month, today_str, interface="wlp0s20f3")
