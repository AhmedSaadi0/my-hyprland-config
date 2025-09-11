import subprocess


def manage_connection(action, ssid=None, password=None, interface="wlan0"):
    """
    إدارة الاتصال بشبكات الواي فاي (اتصال أو قطع الاتصال).
    """
    try:
        if action.lower() == "connect":
            if not ssid:
                print("خطأ: يجب تحديد اسم الشبكة (SSID) للاتصال.")
                return

            print(f"جاري محاولة الاتصال بشبكة: {ssid}...")
            command = ["nmcli", "device", "wifi", "connect", ssid]
            if password:
                command.extend(["password", password])

            result = subprocess.run(command, capture_output=True, text=True)

            if result.returncode == 0:
                print(f"تم الاتصال بنجاح بشبكة {ssid}.")
            else:
                print(f"فشل الاتصال. الخطأ:\n{result.stderr}")

        elif action.lower() == "disconnect":
            print(f"جاري قطع الاتصال من الواجهة {interface}...")
            # للعثور على اسم الواجهة، يمكنك استخدام الأمر: nmcli device status
            command = ["nmcli", "device", "disconnect", interface]
            result = subprocess.run(command, capture_output=True, text=True)

            if result.returncode == 0:
                print("تم قطع الاتصال بنجاح.")
            else:
                print(f"فشل قطع الاتصال. الخطأ:\n{result.stderr}")
        else:
            print("إجراء غير معروف. استخدم 'connect' أو 'disconnect'.")

    except FileNotFoundError:
        print(
            "خطأ: لم يتم العثور على أداة 'nmcli'. تأكد من تثبيت NetworkManager."
        )
    except Exception as e:
        print(f"حدث خطأ غير متوقع: {e}")


if __name__ == "__main__":
    # مثال على الاستخدام
    # للاتصال:
    network_ssid = "اسم_الشبكة_هنا"
    network_password = "كلمة_السر_هنا"  # اتركها فارغة إذا كانت الشبكة مفتوحة
    manage_connection("connect", ssid=network_ssid, password=network_password)

    # لقطع الاتصال (قد تحتاج لتغيير 'wlan0' إلى اسم واجهة الواي فاي لديك):
    # manage_connection('disconnect', interface='wlan0')
