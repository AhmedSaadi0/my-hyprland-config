# get_top_ram_usage.py
import json

import psutil


def get_top_ram_processes(limit=10):
    """
    يسترجع أكثر العمليات استهلاكًا للرام (Memory) بدقة باستخدام psutil.
    تُعيد قائمة من القواميس تحتوي على مفتاح 'name' لاسم العملية
    ومفتاح 'memory_percent' لنسبة استهلاك الرام (من إجمالي الرام المتاح في النظام).
    """
    processes_info = []

    # Iterate over all processes
    for proc in psutil.process_iter(
        ["pid", "name", "memory_percent", "status"]
    ):
        try:
            # Skip processes that are not running or are zombies
            if (
                not proc.is_running()
                or proc.info["status"] == psutil.STATUS_ZOMBIE
            ):
                continue

            # Get memory percentage directly
            mem_percent = proc.info["memory_percent"]
            if mem_percent is not None and mem_percent > 0.0:
                processes_info.append(
                    {"name": proc.info["name"], "value": mem_percent}
                )
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            # Process may have terminated or access denied during iteration
            continue
        except Exception as e:
            # Catch other unexpected errors
            # print(f"Warning: Could not get memory info for process {proc.info.get('name', proc.pid)}: {e}", file=sys.stderr)
            continue

    # Sort processes by memory percentage in descending order
    processes_info.sort(key=lambda x: x["value"], reverse=True)

    # Return the top 'limit' processes
    return processes_info[:limit]


if __name__ == "__main__":
    top_processes = get_top_ram_processes(limit=10)
    # Output the result as a single line JSON string
    print(json.dumps(top_processes))
