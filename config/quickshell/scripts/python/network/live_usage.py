import subprocess
import time


def monitor_app_usage(interface="wlp0s20f3", duration=10):
    """
    يراقب التطبيقات التي تستهلك الإنترنت في الوقت الفعلي لمدة محددة.
    يتطلب صلاحيات الجذر (sudo).
    """
    print(
        f"بدء مراقبة استهلاك التطبيقات على {interface} لمدة {duration} ثوانٍ..."
    )
    print("قد يُطلب منك إدخال كلمة مرور sudo.")

    command = ["sudo", "nethogs", "-t", "-d", "1", interface]

    try:
        process = subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )

        start_time = time.time()
        output_lines = []

        # قراءة المخرجات
        while time.time() - start_time < duration:
            line = process.stdout.readline()
            if not line:
                break
            # تجاهل الأسطر الفارغة أو التي لا تحتوي على بيانات مفيدة
            if line.strip() and "Refreshing" not in line:
                # يمكنك هنا تحليل السطر لاستخراج اسم البرنامج والاستهلاك
                print(line.strip())
                output_lines.append(line.strip())

        process.terminate()  # إنهاء عملية nethogs
        print("\n--- انتهت المراقبة ---")

    except FileNotFoundError:
        print("خطأ: أداة 'nethogs' غير مثبتة. يرجى تثبيتها أولاً.")
    except Exception as e:
        print(f"حدث خطأ: {e}")


if __name__ == "__main__":
    monitor_app_usage(interface="wlp0s20f3", duration=15)
