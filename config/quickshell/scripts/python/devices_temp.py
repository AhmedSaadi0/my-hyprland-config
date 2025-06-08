# get_targeted_temps.py
import json
import platform
import re
import subprocess

import psutil

# Conditional import for wmi on Windows
try:
    if platform.system() == "Windows":
        import wmi
    else:
        wmi = None
except ImportError:
    wmi = None

# Global dictionary to collect targeted sensor data
all_temperatures_data = {
    "cpu_temps": [],
    "gpu_temps": [],
    "storage_temps": [],
    "warnings": [],
    "cpu_max_temp": None,  # New field for max CPU temp
    "gpu_max_temp": None,  # New field for max GPU temp
    "storage_max_temp": None,  # New field for max Storage temp
}


def add_temp_reading(category, label, temp_c, source=""):
    """
    Helper function to add a temperature reading to the correct list.
    Also updates the max temp for its category.
    """
    if temp_c is not None:
        try:
            temp_c = float(temp_c)
            if -50.0 <= temp_c <= 200.0:
                temp_entry = {
                    "label": label,
                    "temperature": round(temp_c, 1),
                    "unit": "C",
                    "source": source,
                }
                if category == "cpu":
                    all_temperatures_data["cpu_temps"].append(temp_entry)
                elif category == "gpu":
                    all_temperatures_data["gpu_temps"].append(temp_entry)
                elif category == "storage":
                    all_temperatures_data["storage_temps"].append(temp_entry)

                # Update max temperature for the category
                if category == "cpu":
                    current_max = all_temperatures_data.get("cpu_max_temp")
                    if current_max is None or temp_c > current_max:
                        all_temperatures_data["cpu_max_temp"] = temp_c
                elif category == "gpu":
                    current_max = all_temperatures_data.get("gpu_max_temp")
                    if current_max is None or temp_c > current_max:
                        all_temperatures_data["gpu_max_temp"] = temp_c
                elif category == "storage":
                    current_max = all_temperatures_data.get("storage_max_temp")
                    if current_max is None or temp_c > current_max:
                        all_temperatures_data["storage_max_temp"] = temp_c

        except ValueError:
            pass


# --- CPU Temp (reliable via psutil) ---
def get_cpu_temps_psutil():
    try:
        temps = psutil.sensors_temperatures()
        cpu_found = False
        for sensor_name, sensor_list in temps.items():
            for i, entry in enumerate(sensor_list):
                if entry.current is not None:
                    if (
                        "cpu" in sensor_name.lower()
                        or "core" in sensor_name.lower()
                        or "package id" in sensor_name.lower()
                        or "tctl" in sensor_name.lower()
                    ):
                        add_temp_reading(
                            "cpu",
                            f"معالج (psutil) {i+1}",
                            entry.current,
                            source="psutil",
                        )
                        cpu_found = True
        # Check if psutil had useful CPU temps, otherwise the OS-specific functions might fill it
        # We don't add the "not found" warning here explicitly because OS-specific functions might pick it up.

    except Exception as e:
        all_temperatures_data["warnings"].append(
            f"psutil: خطأ في جلب حرارة المعالج: {e}"
        )


# --- GPU Temp (Detecting NVIDIA or AMD automatically) ---
def get_gpu_temps():
    system = platform.system()

    if system == "Linux":
        # 1. Try NVIDIA GPU via nvidia-smi
        try:
            subprocess.run(
                ["which", "nvidia-smi"], check=True, capture_output=True
            )  # Will raise FileNotFoundError if not found

            result = subprocess.run(
                [
                    "nvidia-smi",
                    "--query-gpu=name,temperature.gpu",
                    "--format=csv,noheader,nounits",
                ],
                capture_output=True,
                text=True,
                check=True,
            )
            for line in result.stdout.strip().split("\n"):
                parts = line.strip().split(", ")
                if len(parts) == 2:
                    gpu_name = parts[0].strip()
                    gpu_temp = float(parts[1])
                    add_temp_reading(
                        "gpu",
                        f"{gpu_name} (NVIDIA)",
                        gpu_temp,
                        source="nvidia-smi",
                    )
        except FileNotFoundError:
            pass
        except (subprocess.CalledProcessError, ValueError) as e:
            all_temperatures_data["warnings"].append(
                f"Linux: خطأ في قراءة حرارة رسوميات NVIDIA: {e}"
            )

        # 2. Try AMD/other GPUs via lm_sensors
        try:
            result = subprocess.run(
                ["sensors", "-j"], capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip():
                sensors_data = json.loads(result.stdout)
                for chip_name, chip_data in sensors_data.items():
                    if (
                        "gpu" in chip_name.lower()
                        or "radeon" in chip_name.lower()
                        or "amdgpu" in chip_name.lower()
                        or "coretemp" in chip_name.lower()
                    ):  # Coretemp for integrated
                        for feature_name, feature_data in chip_data.get(
                            "features", {}
                        ).items():
                            temp_c = feature_data.get(
                                "temp1_input", feature_data.get("temp_input")
                            )
                            if temp_c is not None:
                                add_temp_reading(
                                    "gpu",
                                    f"{chip_name} - {feature_name}",
                                    temp_c,
                                    source="lm_sensors",
                                )
        except FileNotFoundError:
            all_temperatures_data["warnings"].append(
                "Linux: 'sensors' غير موجود. لدرجة حرارة GPU/لوحة الأم، قم بتثبيت lm_sensors."
            )
        except json.JSONDecodeError:
            all_temperatures_data["warnings"].append(
                "Linux: lm_sensors أخرج JSON غير صالح لحرارة GPU."
            )
        except Exception as e:
            all_temperatures_data["warnings"].append(
                f"Linux: خطأ عند قراءة حرارة GPU عبر sensors: {e}"
            )

    elif system == "Windows":
        all_temperatures_data["warnings"].append(
            "Windows: حرارة GPU قد تتطلب أدوات خارجية أو استدعاءات WMI خاصة جداً (غير متاحة دائمًا)."
        )
    elif system == "Darwin":  # macOS
        all_temperatures_data["warnings"].append(
            "macOS: حرارة GPU غير متاحة بسهولة عبر الأدوات القياسية."
        )


# --- Storage Temp (HDD/NVMe) ---
def get_storage_temps():
    system = platform.system()

    # Try psutil for NVMe (it sometimes captures this directly from OS sensors)
    try:
        temps = psutil.sensors_temperatures()
        for sensor_name, sensor_list in temps.items():
            for i, entry in enumerate(sensor_list):
                if entry.current is not None:
                    if (
                        "nvme" in sensor_name.lower()
                        or "disk" in sensor_name.lower()
                    ):
                        add_temp_reading(
                            "storage",
                            f"{sensor_name} (psutil)",
                            entry.current,
                            source="psutil",
                        )
    except Exception as e:
        all_temperatures_data["warnings"].append(
            f"psutil: خطأ في جلب حرارة التخزين عبر مستشعرات psutil: {e}"
        )

    if system == "Linux":
        try:
            lsblk_output = subprocess.run(
                ["lsblk", "-J", "-o", "NAME,TYPE,PKNAME"],
                capture_output=True,
                text=True,
                check=True,
                timeout=5,
            ).stdout
            block_devices = json.loads(lsblk_output).get("blockdevices", [])

            processed_dev_names = set()

            for dev in block_devices:
                disk_name = dev["name"]
                if (
                    dev["type"] != "disk"
                    and dev["type"] != "nvme"
                    and "pkname" in dev
                ):
                    disk_name = dev["pkname"]

                if (
                    (
                        dev["type"] == "disk"
                        or dev["type"] == "nvme"
                        or "pkname" in dev
                        and dev["type"] == "part"
                    )
                    and disk_name
                    and disk_name not in processed_dev_names
                ):
                    try:
                        smartctl_path = f"/dev/{disk_name}"
                        smartctl_result = subprocess.run(
                            ["smartctl", "-A", smartctl_path],
                            capture_output=True,
                            text=True,
                            check=True,
                            timeout=5,
                        )

                        match_hdd = re.search(
                            r"Temperature_Celsius:\s*(\d+)",
                            smartctl_result.stdout,
                        )
                        if match_hdd:
                            temp_c = int(match_hdd.group(1))
                            add_temp_reading(
                                "storage",
                                f"قرص صلب /dev/{disk_name}",
                                temp_c,
                                source="smartctl_hdd",
                            )
                        else:
                            match_nvme = re.search(
                                r"^Temperature:\s+(\d+) Celsius",
                                smartctl_result.stdout,
                                re.MULTILINE,
                            )
                            if match_nvme:
                                temp_c = int(match_nvme.group(1))
                                add_temp_reading(
                                    "storage",
                                    f"NVMe /dev/{disk_name}",
                                    temp_c,
                                    source="smartctl_nvme",
                                )
                            else:
                                # Only warn if no temp was found and smartctl worked but didn't have specific patterns.
                                pass

                    except FileNotFoundError:
                        all_temperatures_data["warnings"].append(
                            f"Linux: 'smartctl' غير موجود. لدرجة حرارة الأقراص، قم بتثبيت smartmontools."
                        )
                        break
                    except subprocess.CalledProcessError as e:
                        if (
                            "root privileges" in e.stderr.lower()
                            or "Perm" in e.stderr
                        ):
                            all_temperatures_data["warnings"].append(
                                f"Linux: 'smartctl' لـ /dev/{disk_name} يتطلب صلاحيات الجذر. حاول 'sudo smartctl -A {smartctl_path}' للتحقق."
                            )
                        else:
                            all_temperatures_data["warnings"].append(
                                f"Linux: فشل smartctl لـ /dev/{disk_name}: {e.stderr.strip()}"
                            )
                    except (
                        ValueError,
                        IndexError,
                        subprocess.TimeoutExpired,
                        json.JSONDecodeError,
                    ):
                        all_temperatures_data["warnings"].append(
                            f"Linux: خطأ في تحليل إخراج smartctl لـ /dev/{disk_name}."
                        )

                    processed_dev_names.add(disk_name)

        except (
            FileNotFoundError,
            subprocess.CalledProcessError,
            json.JSONDecodeError,
            ValueError,
        ) as e:
            all_temperatures_data["warnings"].append(
                f"Linux: خطأ عام في تعداد الأقراص أو smartctl: {e}"
            )

    elif system == "Windows":
        all_temperatures_data["warnings"].append(
            "Windows: حرارة الأقراص (HDD/SSD/NVMe) تتطلب أدوات خارجية أو استدعاءات WMI معقدة للغاية (غير مدعومة حاليا)."
        )
    elif system == "Darwin":  # macOS
        all_temperatures_data["warnings"].append(
            "macOS: حرارة الأقراص تتطلب 'smartmontools' (smartctl) وقد تحتاج صلاحيات جذر."
        )


# --- Main Temperature Gathering Function ---
def get_all_temperatures_targeted():
    global all_temperatures_data
    all_temperatures_data = {
        "cpu_temps": [],
        "gpu_temps": [],
        "storage_temps": [],
        "warnings": [],
        "cpu_max_temp": None,
        "gpu_max_temp": None,
        "storage_max_temp": None,
    }

    get_cpu_temps_psutil()
    get_gpu_temps()
    get_storage_temps()

    # General warnings if no temps found for categories and no specific warning was already issued
    if not all_temperatures_data["cpu_temps"] and not any(
        "cpu" in warn.lower() for warn in all_temperatures_data["warnings"]
    ):
        all_temperatures_data["warnings"].append(
            "لم يتم العثور على مستشعرات حرارة لوحدة المعالجة المركزية."
        )
    if not all_temperatures_data["gpu_temps"] and not any(
        "gpu" in warn.lower() for warn in all_temperatures_data["warnings"]
    ):
        all_temperatures_data["warnings"].append(
            "لم يتم العثور على مستشعرات حرارة لوحدة معالجة الرسوميات."
        )
    if not all_temperatures_data["storage_temps"] and not any(
        "قرص" in warn.lower()
        or "hdd" in warn.lower()
        or "ssd" in warn.lower()
        or "nvme" in warn.lower()
        or "storage" in warn.lower()
        for warn in all_temperatures_data["warnings"]
    ):
        all_temperatures_data["warnings"].append(
            "لم يتم العثور على مستشعرات حرارة للأقراص الصلبة/SSD/NVMe."
        )

    return all_temperatures_data


if __name__ == "__main__":
    temps = get_all_temperatures_targeted()
    print(json.dumps(temps, ensure_ascii=False))
