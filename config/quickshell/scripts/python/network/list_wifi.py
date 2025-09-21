import argparse
import json
import subprocess
import sys


def parse_nmcli_line(line: str) -> list[str]:
    """محلل مخصص لأسطر nmcli الذي يتعامل مع الحروف المهملة (escaped characters)."""
    fields = []
    current_field = ""
    i = 0
    while i < len(line):
        char = line[i]
        if char == "\\":
            if i + 1 < len(line):
                current_field += line[i + 1]
                i += 1
        elif char == ":":
            fields.append(current_field)
            current_field = ""
        else:
            current_field += char
        i += 1
    fields.append(current_field)
    return fields


def is_ssid_saved(ssid: str) -> bool:
    """
    يتحقق مما إذا كان ملف تعريف اتصال لـ SSID معين موجودًا.
    """
    if not ssid:  # لا تتحقق من SSID الفارغ
        return False
    try:
        # نستعلم مباشرة عن وجود اتصال بهذا الـ SSID
        # نستخدم con show id <SSID> لأنه سيفشل إذا لم يكن موجودًا
        command = ["nmcli", "connection", "show", "id", ssid]
        # نخفي المخرجات لأننا نهتم فقط بنجاح الأمر أو فشله
        subprocess.check_output(command, stderr=subprocess.DEVNULL, text=True)
        # إذا لم يثر الأمر استثناءً، فهذا يعني أنه موجود
        return True
    except subprocess.CalledProcessError:
        # فشل الأمر يعني عدم وجود ملف تعريف بهذا الاسم
        return False
    except FileNotFoundError:
        # في حالة عدم وجود nmcli نفسه
        return False


def list_available_networks(interface: str):
    """
    تعرض شبكات الواي فاي المتاحة، باستخدام طريقة تحقق فردية.
    """
    networks_list = []
    error_output = None

    try:
        command = [
            "nmcli",
            "-t",
            "-e",
            "yes",
            "-f",
            "IN-USE,BSSID,SSID,SIGNAL,SECURITY",
            "device",
            "wifi",
            "list",
            "--rescan",
            "yes",
            "ifname",
            interface,
        ]
        scan_output = subprocess.check_output(
            command, text=True, stderr=subprocess.PIPE
        )

        for line in scan_output.strip().split("\n"):
            if not line.strip():
                continue
            try:
                parts = parse_nmcli_line(line)
                if len(parts) == 5:
                    is_in_use = parts[0] == "*"
                    ssid = parts[2]

                    # لكل شبكة، نستعلم بشكل منفصل لمعرفة ما إذا كانت محفوظة
                    is_saved_status = is_ssid_saved(ssid)

                    networks_list.append(
                        {
                            "in_use": is_in_use,
                            "bssid": parts[1],
                            "ssid": ssid,
                            "signal": int(parts[3]),
                            "security": parts[4] if parts[4] else "None",
                            "is_saved": is_saved_status,
                        }
                    )
            except (ValueError, IndexError):
                continue
    except FileNotFoundError:
        error_output = {"error": "لم يتم العثور على أداة 'nmcli'."}
    except subprocess.CalledProcessError as e:
        error_output = {"error": f"فشل أمر nmcli: {e.stderr.strip()}"}
    except Exception as e:
        error_output = {"error": f"حدث خطأ غير متوقع: {str(e)}"}

    if error_output:
        print(json.dumps(error_output))
        sys.exit(1)
    else:
        print(json.dumps(networks_list))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="عرض شبكات الواي فاي المتاحة مع بيان ما إذا كانت محفوظة."
    )
    parser.add_argument(
        "-i", "--interface", default="wlan0", help="اسم واجهة الواي فاي."
    )
    args = parser.parse_args()
    list_available_networks(args.interface)
