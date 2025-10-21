import argparse
import json
import subprocess
import sys


def manage_connection(action, interface, profile_name=None, password=None):
    """
    إدارة الاتصالات:
    - connect: يتصل بشبكة جديدة (ينشئ ملف تعريف إذا لزم الأمر).
    - up: يقوم بتفعيل ملف تعريف اتصال محفوظ.
    - delete: يحذف ملف تعريف اتصال محفوظ.
    - disconnect: يقطع الاتصال من واجهة.
    """
    result = {}

    try:
        action = action.lower()

        # --- الإجراء 1: تفعيل اتصال محفوظ ---
        if action == "up":
            if not profile_name:
                raise ValueError("يجب تحديد اسم ملف التعريف لتفعيله.")
            print(
                f"جاري محاولة تفعيل ملف التعريف '{profile_name}'...",
                file=sys.stderr,
            )
            command = [
                "nmcli",
                "connection",
                "up",
                profile_name,
                "ifname",
                interface,
            ]
            proc = subprocess.run(command, capture_output=True, text=True)
            if proc.returncode == 0:
                result = {
                    "status": "success",
                    "message": f"تم تفعيل الاتصال '{profile_name}' بنجاح.",
                }
            else:
                result = {
                    "status": "error",
                    "message": f"فشل تفعيل الاتصال: {proc.stderr.strip()}",
                }

        # --- الإجراء 2: الاتصال بشبكة جديدة (أو موجودة) ---
        elif action == "connect":
            if not profile_name:
                raise ValueError("يجب تحديد اسم الشبكة (SSID) للاتصال.")

            # محاولة الاتصال المباشر أولاً
            direct_command = [
                "nmcli",
                "device",
                "wifi",
                "connect",
                profile_name,
                "ifname",
                interface,
            ]
            if password:
                direct_command.extend(["password", password])
            proc = subprocess.run(
                direct_command, capture_output=True, text=True
            )

            if proc.returncode == 0:
                result = {
                    "status": "success",
                    "message": f"تم الاتصال بنجاح بشبكة {profile_name}.",
                }
            else:  # إذا فشل الاتصال المباشر، نستخدم الطريقة الموثوقة
                # print(
                #     "الاتصال المباشر فشل، سيتم استخدام الطريقة الموثوقة (Add/Up)...",
                #     file=sys.stderr,
                # )

                # التحقق مما إذا كان ملف التعريف موجودًا بالفعل
                check_proc = subprocess.run(
                    ["nmcli", "con", "show", "id", profile_name],
                    capture_output=True,
                )

                # إذا لم يكن موجودًا، قم بإنشائه
                if check_proc.returncode != 0:
                    add_command = [
                        "nmcli",
                        "con",
                        "add",
                        "type",
                        "wifi",
                        "con-name",
                        profile_name,
                        "ifname",
                        interface,
                        "ssid",
                        profile_name,
                    ]
                    if password:
                        add_command.extend(
                            [
                                "--",
                                "wifi-sec.key-mgmt",
                                "wpa-psk",
                                "wifi-sec.psk",
                                password,
                            ]
                        )
                    add_proc = subprocess.run(
                        add_command, capture_output=True, text=True
                    )
                    if add_proc.returncode != 0:
                        raise RuntimeError(
                            f"فشل إنشاء ملف التعريف: {add_proc.stderr.strip()}"
                        )

                # الآن، قم بتفعيله
                up_command = [
                    "nmcli",
                    "connection",
                    "up",
                    profile_name,
                    "ifname",
                    interface,
                ]
                up_proc = subprocess.run(
                    up_command, capture_output=True, text=True
                )
                if up_proc.returncode == 0:
                    result = {
                        "status": "success",
                        "message": f"تم تفعيل الاتصال بنجاح بشبكة {profile_name}.",
                    }
                else:
                    result = {
                        "status": "error",
                        "message": f"فشل تفعيل الاتصال: {up_proc.stderr.strip()}",
                    }

        # --- الإجراء 3: حذف اتصال محفوظ ---
        elif action == "delete":
            if not profile_name:
                raise ValueError("يجب تحديد اسم ملف التعريف لحذفه.")
            print(
                f"جاري محاولة حذف ملف التعريف '{profile_name}'...",
                file=sys.stderr,
            )
            command = ["nmcli", "connection", "delete", "id", profile_name]
            proc = subprocess.run(command, capture_output=True, text=True)
            if proc.returncode == 0:
                result = {
                    "status": "success",
                    "message": f"تم حذف ملف التعريف '{profile_name}' بنجاح.",
                }
            else:
                result = {
                    "status": "error",
                    "message": f"فشل حذف ملف التعريف: {proc.stderr.strip()}",
                }

        # --- الإجراء 4: قطع الاتصال ---
        elif action == "disconnect":
            if not interface:
                raise ValueError("يجب تحديد اسم الواجهة لقطع الاتصال.")
            command = ["nmcli", "device", "disconnect", interface]
            proc = subprocess.run(command, capture_output=True, text=True)
            if proc.returncode == 0:
                result = {
                    "status": "success",
                    "message": f"تم قطع الاتصال من الواجهة {interface}.",
                }
            else:
                result = {"status": "error", "message": proc.stderr.strip()}
        else:
            raise ValueError("إجراء غير صالح.")

    except (ValueError, RuntimeError) as e:
        result = {"status": "error", "message": str(e)}
    except FileNotFoundError:
        result = {
            "status": "error",
            "message": "لم يتم العثور على أداة 'nmcli'.",
        }
    except Exception as e:
        result = {"status": "error", "message": f"حدث خطأ غير متوقع: {str(e)}"}

    print(json.dumps(result))
    if result.get("status") == "error":
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="إدارة اتصالات الواي فاي.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "action",
        choices=["connect", "up", "delete", "disconnect"],
        help="الإجراء:\n"
        "connect  - للاتصال بشبكة (جديدة أو محفوظة).\n"
        "up       - لتفعيل اتصال محفوظ (أسرع من connect).\n"
        "delete   - لحذف ملف تعريف شبكة محفوظة.\n"
        "disconnect - لقطع الاتصال.",
    )
    parser.add_argument(
        "-s",
        "--ssid",
        dest="profile_name",
        help="اسم الشبكة (SSID) أو اسم ملف التعريف.",
    )
    parser.add_argument(
        "-i", "--interface", default="wlp0s20f3", help="اسم واجهة الواي فاي."
    )
    parser.add_argument(
        "-p", "--password", help="كلمة المرور (فقط لإجراء 'connect')."
    )

    args = parser.parse_args()

    # التحقق من أن الوسائط المطلوبة موجودة لكل إجراء
    if args.action in ["connect", "up", "delete"] and not args.profile_name:
        parser.error(f"الوسيطة --ssid مطلوبة لإجراء '{args.action}'.")

    manage_connection(
        args.action, args.interface, args.profile_name, args.password
    )
