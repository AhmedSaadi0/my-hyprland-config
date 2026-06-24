#!/usr/bin/env python3
import argparse
import json
import platform
import re
import subprocess
import time

import psutil

# محاولة استيراد wmi لنظام الويندوز (اختياري)
try:
    if platform.system() == "Windows":
        import wmi
    else:
        wmi = None
except ImportError:
    wmi = None

# ==========================================
# 1. دوال المعالج (CPU) والذاكرة (RAM)
# ==========================================


def get_top_cpu(limit=20):
    processes_data = []
    num_logical_cores = psutil.cpu_count(logical=True)
    if num_logical_cores is None or num_logical_cores == 0:
        num_logical_cores = 1

    procs = {}
    for proc in psutil.process_iter(["pid", "name", "cmdline"]):
        try:
            if not proc.is_running():
                continue
            proc.cpu_percent(interval=None)
            procs[proc.pid] = proc
        except (
            psutil.NoSuchProcess,
            psutil.AccessDenied,
            psutil.ZombieProcess,
        ):
            continue
        except Exception:
            pass

    time.sleep(0.5)

    for pid, proc in list(procs.items()):
        try:
            if not proc.is_running():
                continue
            cpu_usage = proc.cpu_percent(interval=None)
            if cpu_usage is not None and cpu_usage > 0:
                normalized_cpu_usage = cpu_usage / num_logical_cores
                cmdline = proc.info.get("cmdline") or []
                processes_data.append(
                    {
                        "pid": pid,
                        "name": proc.info.get("name", "Unknown"),
                        "value": round(normalized_cpu_usage, 2),
                        "cmdline": " ".join(cmdline[:8]),
                    }
                )
        except (
            psutil.NoSuchProcess,
            psutil.AccessDenied,
            psutil.ZombieProcess,
        ):
            continue
        except Exception:
            pass

    if len(processes_data) == 0:
        time.sleep(0.3)
        for pid, proc in list(procs.items()):
            try:
                if not proc.is_running():
                    continue
                cpu_usage = proc.cpu_percent(interval=None)
                if cpu_usage is not None:
                    normalized_cpu_usage = cpu_usage / num_logical_cores
                    cmdline = proc.info.get("cmdline") or []
                    processes_data.append(
                        {
                            "pid": pid,
                            "name": proc.info.get("name", "Unknown"),
                            "value": round(normalized_cpu_usage, 2),
                            "cmdline": " ".join(cmdline[:8]),
                        }
                    )
            except (
                psutil.NoSuchProcess,
                psutil.AccessDenied,
                psutil.ZombieProcess,
            ):
                continue
            except Exception:
                pass

    processes_data.sort(key=lambda x: x["value"], reverse=True)
    return processes_data[:limit]


def get_top_ram(limit=20):
    processes = []
    for p in psutil.process_iter(["pid", "name", "memory_percent", "memory_info"]):
        try:
            mem_pct = p.info.get("memory_percent", 0.0)
            if mem_pct is None:
                mem_pct = 0.0

            mem_info = p.info.get("memory_info")
            mem_mb = round(mem_info.rss / (1024 * 1024), 2) if mem_info else 0.0

            processes.append(
                {
                    "pid": p.info.get("pid", 0),
                    "name": p.info.get("name", "Unknown"),
                    "value": round(mem_pct, 2),
                    "memory_usage_mb": mem_mb,
                }
            )
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    processes.sort(key=lambda x: x["value"], reverse=True)
    return processes[:limit]


def get_process_detail(pid):
    try:
        proc = psutil.Process(pid)
        # cpu_percent returns 0.0 on first call (no previous delta),
        # so measure with interval to get a real value immediately.
        cpu_percent = proc.cpu_percent(interval=0.1)
        proc_info = proc.as_dict(
            attrs=[
                "pid",
                "name",
                "status",
                "username",
                "create_time",
                "memory_percent",
                "memory_info",
                "exe",
                "cmdline",
                "cwd",
                "num_threads",
                "ppid",
            ]
        )
        proc_info["cpu_percent"] = cpu_percent
    except psutil.NoSuchProcess:
        return {"error": f"Process with PID {pid} not found"}
    except psutil.AccessDenied:
        return {"error": f"Access denied for PID {pid}"}

    mem_info = proc_info.get("memory_info")
    mem_rss_mb = round(mem_info.rss / (1024 * 1024), 2) if mem_info else 0.0
    mem_vms_mb = round(mem_info.vms / (1024 * 1024), 2) if mem_info else 0.0

    create_time = proc_info.get("create_time")
    if create_time:
        create_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(create_time))
    else:
        create_time = "Unknown"

    cmdline = proc_info.get("cmdline") or []

    parent_name = "Unknown"
    ppid = proc_info.get("ppid", 0)
    if ppid:
        try:
            parent_name = psutil.Process(ppid).name()
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            parent_name = "Unknown"

    children = []
    try:
        for child in proc.children(recursive=True):
            children.append({"pid": child.pid, "name": child.name()})
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        pass

    return {
        "pid": proc_info.get("pid", pid),
        "name": proc_info.get("name", "Unknown"),
        "status": proc_info.get("status", "Unknown"),
        "username": proc_info.get("username", "Unknown"),
        "create_time": create_time,
        "cpu_percent": round(proc_info.get("cpu_percent", 0.0) or 0.0, 2),
        "memory_percent": round(proc_info.get("memory_percent", 0.0) or 0.0, 2),
        "memory_rss_mb": mem_rss_mb,
        "memory_vms_mb": mem_vms_mb,
        "exe": proc_info.get("exe") or "Unknown",
        "cmdline": " ".join(cmdline[:16]),
        "cwd": proc_info.get("cwd") or "Unknown",
        "num_threads": proc_info.get("num_threads", 0),
        "ppid": ppid,
        "parent_name": parent_name,
        "children": children,
    }


# ==========================================
# 2. دوال الحرارة الشاملة (Temps)
# ==========================================

all_temperatures_data = {}


def init_temp_data():
    global all_temperatures_data
    all_temperatures_data = {
        "cpu_temps": [],
        "gpu_temps": [],
        "storage_temps": [],
        "warnings": [],
        "cpu_max_temp": 0.0,  # تم تغييره إلى 0.0 لتجنب أخطاء QML مع قيم null
        "gpu_max_temp": 0.0,
        "storage_max_temp": 0.0,
    }


def add_temp_reading(category, label, temp_c, source=""):
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
                    if temp_c > all_temperatures_data["cpu_max_temp"]:
                        all_temperatures_data["cpu_max_temp"] = temp_c

                elif category == "gpu":
                    all_temperatures_data["gpu_temps"].append(temp_entry)
                    if temp_c > all_temperatures_data["gpu_max_temp"]:
                        all_temperatures_data["gpu_max_temp"] = temp_c

                elif category == "storage":
                    all_temperatures_data["storage_temps"].append(temp_entry)
                    if temp_c > all_temperatures_data["storage_max_temp"]:
                        all_temperatures_data["storage_max_temp"] = temp_c

        except ValueError:
            pass


def get_cpu_temps_psutil():
    try:
        temps = psutil.sensors_temperatures()
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
                            f"معالج (psutil) {i + 1}",
                            entry.current,
                            source="psutil",
                        )
    except Exception as e:
        all_temperatures_data["warnings"].append(
            f"psutil: خطأ في جلب حرارة المعالج: {e}"
        )


def get_gpu_temps():
    system = platform.system()
    if system == "Linux":
        # محاولة قراءة NVIDIA
        try:
            subprocess.run(["which", "nvidia-smi"], check=True, capture_output=True)
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
                    add_temp_reading(
                        "gpu",
                        f"{parts[0].strip()} (NVIDIA)",
                        float(parts[1]),
                        source="nvidia-smi",
                    )
        except FileNotFoundError:
            pass
        except Exception as e:
            all_temperatures_data["warnings"].append(f"Linux: خطأ في قراءة NVIDIA: {e}")

        # محاولة قراءة AMD/Intel عبر sensors
        try:
            result = subprocess.run(
                ["sensors", "-j"], capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip():
                sensors_data = json.loads(result.stdout)
                for chip_name, chip_data in sensors_data.items():
                    if any(
                        x in chip_name.lower()
                        for x in ["gpu", "radeon", "amdgpu", "coretemp"]
                    ):
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
        except Exception as e:
            all_temperatures_data["warnings"].append(f"Linux: خطأ sensors: {e}")


def get_storage_temps():
    system = platform.system()
    # 1. psutil
    try:
        temps = psutil.sensors_temperatures()
        for sensor_name, sensor_list in temps.items():
            for i, entry in enumerate(sensor_list):
                if entry.current is not None and (
                    "nvme" in sensor_name.lower() or "disk" in sensor_name.lower()
                ):
                    add_temp_reading(
                        "storage",
                        f"{sensor_name} (psutil)",
                        entry.current,
                        source="psutil",
                    )
    except Exception:
        pass

    # 2. smartctl (Linux)
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
                if dev["type"] not in ["disk", "nvme"] and "pkname" in dev:
                    disk_name = dev["pkname"]

                if disk_name and disk_name not in processed_dev_names:
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
                            add_temp_reading(
                                "storage",
                                f"قرص صلب /dev/{disk_name}",
                                int(match_hdd.group(1)),
                                source="smartctl_hdd",
                            )
                        else:
                            match_nvme = re.search(
                                r"^Temperature:\s+(\d+) Celsius",
                                smartctl_result.stdout,
                                re.MULTILINE,
                            )
                            if match_nvme:
                                add_temp_reading(
                                    "storage",
                                    f"NVMe /dev/{disk_name}",
                                    int(match_nvme.group(1)),
                                    source="smartctl_nvme",
                                )
                    except Exception as e:
                        all_temperatures_data["warnings"].append(
                            f"Linux: فشل smartctl لـ /dev/{disk_name}: {e}"
                        )
                    processed_dev_names.add(disk_name)
        except Exception as e:
            all_temperatures_data["warnings"].append(f"Linux: خطأ عام في الأقراص: {e}")


def get_detailed_temps():
    init_temp_data()
    get_cpu_temps_psutil()
    get_gpu_temps()
    get_storage_temps()
    return all_temperatures_data


# ==========================================
# 3. نقطة الدخول (Main)
# ==========================================

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="System Diagnostics On-Demand")
    parser.add_argument(
        "--action",
        choices=["cpu", "ram", "temps", "process_detail", "all"],
        required=True,
        help="Type of data to fetch",
    )
    parser.add_argument(
        "--pid",
        type=int,
        default=None,
        help="PID for process_detail action",
    )
    args = parser.parse_args()

    result = {}

    try:
        if args.action == "cpu":
            result = get_top_cpu()
        elif args.action == "ram":
            result = get_top_ram()
        elif args.action == "temps":
            result = get_detailed_temps()
        elif args.action == "process_detail":
            if args.pid is None:
                result = {"error": "--pid is required for process_detail"}
            else:
                result = get_process_detail(args.pid)
        elif args.action == "all":
            result = {
                "top_cpu": get_top_cpu(10),
                "top_ram": get_top_ram(10),
                "temps": get_detailed_temps(),
            }

        # ensure_ascii=False مهمة جداً لطباعة النصوص العربية (مثل "معالج") بشكل صحيح
        print(json.dumps(result, ensure_ascii=False))

    except Exception as e:
        print(json.dumps({"error": str(e)}, ensure_ascii=False))
