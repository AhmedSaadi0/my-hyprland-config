# get_battery_info_extended.py
import json
import platform
import re  # للتعبير العادي في macOS
import subprocess
import sys

import psutil

# الاستيراد الشرطي لمكتبة WMI على Windows
try:
    if platform.system() == "Windows":
        import wmi
    else:
        wmi = None  # ليس Windows
except ImportError:
    wmi = None  # wmi غير متوفر على Windows


def get_linux_battery_details():
    """
    يسترجع تفاصيل البطارية الخاصة بنظام Linux من Sysfs.
    يتوقع وجود البطارية الأولى على BAT0.
    """
    details = {}
    base_path = (
        "/sys/class/power_supply/BAT0/"  # يمكن تكييف هذا للمزيد من البطاريات
    )
    try:
        # السعة التصميمية (Design Capacity)
        with open(base_path + "energy_full_design", "r") as f:
            # القيمة غالبًا ما تكون في Micro-Watt Hours (uWh)، نحولها إلى Milli-Watt Hours (mWh)
            details["design_capacity_mwh"] = int(f.read().strip()) / 1000.0
            details["design_capacity_text"] = (
                f"{details['design_capacity_mwh']:.0f} ميلي واط ساعة"
            )

        # سعة الشحن الكاملة (Full Charge Capacity)
        with open(base_path + "energy_full", "r") as f:
            # القيمة غالبًا ما تكون في Micro-Watt Hours (uWh)، نحولها إلى Milli-Watt Hours (mWh)
            details["full_charge_capacity_mwh"] = (
                int(f.read().strip()) / 1000.0
            )
            details["full_charge_capacity_text"] = (
                f"{details['full_charge_capacity_mwh']:.0f} ميلي واط ساعة"
            )

        # عدد دورات الشحن (Cycle Count)
        try:
            with open(base_path + "cycle_count", "r") as f:
                details["cycle_count"] = int(f.read().strip())
                details["cycle_count_text"] = f"{details['cycle_count']} دورة"
        except FileNotFoundError:
            details["cycle_count_text"] = "غير متاح"
            details["cycle_count"] = -1

        # درجة الحرارة (اختياري، قد لا تكون متاحة دائمًا)
        try:
            with open(base_path + "temp", "r") as f:
                # القيمة غالبًا تكون درجة مئوية * 1000
                temp_celsius = float(f.read().strip()) / 1000.0
                details["temperature_celsius"] = round(temp_celsius, 1)
                details["temperature_text"] = (
                    f"{details['temperature_celsius']}°C"
                )
        except FileNotFoundError:
            details["temperature_text"] = "غير متاح"

        # حساب مستوى التآكل (Wear Level)
        if (
            details.get("design_capacity_mwh", 0) > 0
            and details.get("full_charge_capacity_mwh", 0) > 0
        ):
            wear_level = (
                details["full_charge_capacity_mwh"]
                / details["design_capacity_mwh"]
            ) * 100
            details["wear_level_percent"] = round(wear_level, 2)
            details["wear_level_text"] = (
                f"{details['wear_level_percent']:.2f}%"
            )
        else:
            details["wear_level_text"] = "غير متاح"

    except FileNotFoundError:
        print(
            "خطأ: لم يتم العثور على معلومات بطارية Linux في المسار الافتراضي /sys/class/power_supply/BAT0/",
            file=sys.stderr,
        )
    except PermissionError:
        print(
            "خطأ: لا يوجد إذن لقراءة معلومات بطارية Linux. قد تحتاج إلى تشغيل بصلاحيات أعلى (مثال: sudo).",
            file=sys.stderr,
        )
    except Exception as e:
        print(
            f"خطأ غير متوقع عند قراءة تفاصيل بطارية Linux: {e}",
            file=sys.stderr,
        )
    return details


def get_windows_battery_details():
    """
    يسترجع تفاصيل البطارية الخاصة بنظام Windows عبر WMI.
    """
    details = {}
    if wmi is None:
        details["error"] = (
            "مكتبة WMI غير متوفرة. قم بتثبيت 'wmi' و 'pywin32' لتمكين ميزات Windows."
        )
        return details

    try:
        c = wmi.WMI()
        # يمكن أن يكون هناك أكثر من بطارية، نأخذ الأولى.
        batteries = c.Win32_Battery()
        if batteries:
            battery = batteries[0]

            details["design_capacity_mwh"] = battery.DesignCapacity
            details["full_charge_capacity_mwh"] = battery.FullChargedCapacity

            if details.get("design_capacity_mwh", 0) > 0:
                wear_level = (
                    details["full_charge_capacity_mwh"]
                    / details["design_capacity_mwh"]
                ) * 100
                details["wear_level_percent"] = round(wear_level, 2)
                details["wear_level_text"] = (
                    f"{details['wear_level_percent']:.2f}%"
                )
            else:
                details["wear_level_text"] = "غير متاح"

            details["design_capacity_text"] = (
                f"{details['design_capacity_mwh']:.0f} ميلي واط ساعة"
            )
            details["full_charge_capacity_text"] = (
                f"{details['full_charge_capacity_mwh']:.0f} ميلي واط ساعة"
            )
            details["cycle_count_text"] = "غير متاح (عادة عبر WMI)"
            details["temperature_text"] = "غير متاح (عادة عبر WMI)"

            # يمكن استرداد المزيد من الخصائص من كائن battery WMI إذا لزم الأمر
            # مثل: battery.BatteryStatus, battery.Caption, battery.Chemistry, battery.SerialNumber
            details["device_id"] = battery.DeviceID
            details["battery_status_wmi"] = battery.BatteryStatus
        else:
            details["error"] = "لم يتم العثور على بطاريات عبر WMI."
    except Exception as e:
        details["error"] = (
            f"خطأ عند استرداد تفاصيل بطارية Windows عبر WMI: {e}"
        )
        print(details["error"], file=sys.stderr)
    return details


def get_macos_battery_details():
    """
    يسترجع تفاصيل البطارية الخاصة بنظام macOS باستخدام ioreg.
    """
    details = {}
    try:
        # أمر ioreg للحصول على تفاصيل بطارية AppleSmartBattery
        cmd = ["ioreg", "-r", "-n", "AppleSmartBattery"]
        result = subprocess.run(
            cmd, capture_output=True, text=True, check=True
        )
        output = result.stdout

        # استخدام التعبير العادي لتحليل القيم
        design_capacity_match = re.search(
            r'"DesignCapacity"\s*=\s*(\d+)', output
        )
        max_capacity_match = re.search(
            r'"MaxCapacity"\s*=\s*(\d+)', output
        )  # MaxCapacity هي Full Charge Capacity
        cycle_count_match = re.search(r'"CycleCount"\s*=\s*(\d+)', output)
        serial_number_match = re.search(
            r'"BatterySerialNumber"\s*=\s*"([^"]+)"', output
        )
        # درجة الحرارة تكون "Temperature" في ioreg، غالبًا بالألف من الدرجة المئوية
        temperature_match = re.search(r'"Temperature"\s*=\s*(\d+)', output)

        if design_capacity_match:
            details["design_capacity_mah"] = int(
                design_capacity_match.group(1)
            )  # mAh
            details["design_capacity_text"] = (
                f"{details['design_capacity_mah']:.0f} ميلي أمبير ساعة"
            )
        if max_capacity_match:
            details["full_charge_capacity_mah"] = int(
                max_capacity_match.group(1)
            )  # mAh
            details["full_charge_capacity_text"] = (
                f"{details['full_charge_capacity_mah']:.0f} ميلي أمبير ساعة"
            )
        if cycle_count_match:
            details["cycle_count"] = int(cycle_count_match.group(1))
            details["cycle_count_text"] = f"{details['cycle_count']} دورة"
        else:
            details["cycle_count_text"] = "غير متاح"
            details["cycle_count"] = -1

        if serial_number_match:
            details["serial_number"] = serial_number_match.group(1)

        if temperature_match:
            temp_celsius = (
                float(temperature_match.group(1)) / 1000.0
            )  # From millicelsius to celsius
            details["temperature_celsius"] = round(temp_celsius, 1)
            details["temperature_text"] = f"{details['temperature_celsius']}°C"
        else:
            details["temperature_text"] = "غير متاح"

        if (
            details.get("design_capacity_mah", 0) > 0
            and details.get("full_charge_capacity_mah", 0) > 0
        ):
            wear_level = (
                details["full_charge_capacity_mah"]
                / details["design_capacity_mah"]
            ) * 100
            details["wear_level_percent"] = round(wear_level, 2)
            details["wear_level_text"] = (
                f"{details['wear_level_percent']:.2f}%"
            )
        else:
            details["wear_level_text"] = "غير متاح"

    except FileNotFoundError:
        print("خطأ: أمر 'ioreg' غير موجود (macOS).", file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"خطأ في تنفيذ أمر ioreg: {e}", file=sys.stderr)
    except Exception as e:
        print(f"خطأ عند استرداد تفاصيل بطارية macOS: {e}", file=sys.stderr)
    return details


def get_battery_info():
    """
    يجمع معلومات البطارية الأساسية من psutil ومعلومات متقدمة خاصة بنظام التشغيل.
    """
    battery = None
    try:
        battery = psutil.sensors_battery()
    except Exception as e:
        print(
            f"خطأ في الحصول على بيانات مستشعر بطارية psutil: {e}",
            file=sys.stderr,
        )

    info = {
        "percentage": -1,
        "status": "غير معروف",
        "time_remaining": "N/A",
        "is_charging": False,
        "has_battery": False,
    }

    if battery:
        info["has_battery"] = True
        info["percentage"] = round(battery.percent, 1)
        info["is_charging"] = battery.power_plugged

        # تفسير الحالة النصية والوقت المتبقي كما في السكربت السابق
        status_text = "غير معروف"
        time_remaining_text = "غير معروف"

        if battery.power_plugged:
            if battery.secsleft == psutil.POWER_TIME_UNLIMITED:
                if battery.percent == 100:
                    status_text = "مشحونة بالكامل"
                else:
                    status_text = "متصلة بالطاقة"  # أو "قيد الشحن (بالكامل)"
            elif battery.secsleft >= 0:
                status_text = "قيد الشحن"
            else:  # secsleft < 0 or POWER_TIME_UNKNOWN, but plugged in
                status_text = (
                    "متصلة بالطاقة"  # Fallback, likely error in logic/data
                )
        else:  # Not plugged in
            if battery.percent == 100:
                status_text = "مشحونة بالكامل (غير متصلة)"
            elif battery.secsleft == psutil.POWER_TIME_UNLIMITED:
                # هذا لا ينبغي أن يحدث في حالة عدم التوصيل.
                status_text = "متصلة بالطاقة (خطأ!)"
            else:
                status_text = "قيد التفريغ"

        # Time remaining calculation
        if battery.secsleft == psutil.POWER_TIME_UNLIMITED:
            time_remaining_text = "غير محدود"
        elif battery.secsleft == psutil.POWER_TIME_UNKNOWN:
            time_remaining_text = "غير معروف"
        elif battery.secsleft >= 0:
            hours = int(battery.secsleft // 3600)
            minutes = int((battery.secsleft % 3600) // 60)
            time_remaining_text = f"{hours} ساعة و {minutes} دقيقة"
            if info["is_charging"]:
                time_remaining_text = (
                    "يتبقى حوالي " + time_remaining_text + " حتى الاكتمال"
                )
            else:
                time_remaining_text = (
                    "يتبقى حوالي " + time_remaining_text + " من الاستخدام"
                )

        info["status"] = status_text
        info["time_remaining"] = time_remaining_text

    # إضافة التفاصيل الخاصة بنظام التشغيل
    system_name = platform.system()
    if system_name == "Linux":
        info.update(get_linux_battery_details())
    elif system_name == "Windows":
        info.update(get_windows_battery_details())
    elif system_name == "Darwin":  # macOS
        info.update(get_macos_battery_details())
    else:
        print(
            f"نظام التشغيل غير مدعوم لتفاصيل البطارية المتقدمة: {system_name}",
            file=sys.stderr,
        )

    return info


if __name__ == "__main__":
    battery_data = get_battery_info()
    print(json.dumps(battery_data, ensure_ascii=False))
