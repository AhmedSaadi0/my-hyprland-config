import argparse
import json
import subprocess
import sys


def list_available_networks(interface):
    """
    يفحص ويعرض شبكات الواي فاي المتاحة بصيغة JSON.
    """
    networks_list = []
    error_output = None

    try:
        # استخدام الخيار -t (terse) للحصول على مخرجات سهلة التحليل
        # نحدد الحقول المطلوبة لضمان الاتساق
        command = [
            "nmcli",
            "-t",
            "-f",
            "IN-USE,SSID,SIGNAL,SECURITY",
            "device",
            "wifi",
            "list",
            "--rescan",
            "yes",
            "ifname",
            interface,
        ]

        # تنفيذ الأمر
        scan_output = subprocess.check_output(
            command, text=True, stderr=subprocess.PIPE
        )

        lines = scan_output.strip().split("\n")

        for line in lines:
            # يفصل السطر بناءً على ':' مع التعامل مع القيم الفارغة
            parts = line.split(":")
            if len(parts) >= 3:
                networks_list.append(
                    {
                        "in_use": parts[0] == "*",
                        "ssid": parts[1],
                        "signal": int(parts[2]),
                        "security": parts[3] if len(parts) > 3 else "None",
                    }
                )

    except FileNotFoundError:
        error_output = {
            "error": "لم يتم العثور على أداة 'nmcli'. تأكد من تثبيت NetworkManager."
        }
    except subprocess.CalledProcessError as e:
        # في حالة فشل الأمر، مثل عدم وجود الواجهة
        error_output = {"error": f"فشل أمر nmcli: {e.stderr.strip()}"}
    except Exception as e:
        error_output = {"error": f"حدث خطأ غير متوقع: {str(e)}"}

    # طباعة المخرجات النهائية بصيغة JSON
    if error_output:
        print(json.dumps(error_output, indent=2, ensure_ascii=False))
        sys.exit(1)  # الخروج برمز خطأ
    else:
        print(json.dumps(networks_list, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="عرض شبكات الواي فاي المتاحة بصيغة JSON."
    )
    parser.add_argument(
        "-i",
        "--interface",
        default="wlan0",
        help="اسم واجهة الواي فاي (الافتراضي: wlan0).",
    )
    args = parser.parse_args()

    list_available_networks(args.interface)
