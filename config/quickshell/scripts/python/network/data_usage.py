import argparse
import json
import subprocess
import sys
from datetime import date, datetime


def get_data_usage(interface, start_date_str, end_date_str):
    """
    يعرض استهلاك البيانات لفترة محددة بصيغة JSON.
    مبني على الهيكل الفعلي لمخرجات vnstat لضمان الدقة.
    """
    result = {}

    try:
        start_date = datetime.strptime(start_date_str, "%Y-%m-%d").date()
        end_date = datetime.strptime(end_date_str, "%Y-%m-%d").date()

        command = ["vnstat", "--json", "d", "-i", interface]
        proc = subprocess.run(
            command, capture_output=True, text=True, check=True
        )
        vnstat_data = json.loads(proc.stdout)

        target_interface_data = None
        # في JSON، اسم الواجهة هو 'name' وليس 'id' كما هو متوقع في بعض الإصدارات
        for iface_object in vnstat_data.get("interfaces", []):
            if iface_object.get("name") == interface:
                target_interface_data = iface_object
                break

        if not target_interface_data:
            raise KeyError(
                f"لم يتم العثور على بيانات للواجهة '{interface}' في مخرجات vnstat."
            )

        days_list = target_interface_data.get("traffic", {}).get("day", [])

        total_rx = 0
        total_tx = 0

        for day_data in days_list:
            day_date_obj = date(
                day_data["date"]["year"],
                day_data["date"]["month"],
                day_data["date"]["day"],
            )

            if start_date <= day_date_obj <= end_date:
                total_rx += day_data.get("rx", 0)
                total_tx += day_data.get("tx", 0)

        result = {
            "status": "success",
            "interface": interface,
            "period": {"start": start_date_str, "end": end_date_str},
            "usage_bytes": {
                "received": total_rx,
                "sent": total_tx,
                "total": total_rx + total_tx,
            },
        }

    except FileNotFoundError:
        result = {"status": "error", "message": "أداة 'vnstat' غير مثبتة."}
    except subprocess.CalledProcessError as e:
        result = {
            "status": "error",
            "message": f"فشل أمر vnstat: {e.stderr.strip()}.",
        }
    except (json.JSONDecodeError, KeyError) as e:
        result = {
            "status": "error",
            "message": f"فشل في تحليل المخرجات أو العثور على البيانات: {e}",
        }
    except ValueError:
        result = {
            "status": "error",
            "message": "صيغة التاريخ غير صحيحة. يرجى استخدام YYYY-MM-DD.",
        }
    except Exception as e:
        result = {"status": "error", "message": f"حدث خطأ غير متوقع: {str(e)}"}

    print(json.dumps(result, indent=2, ensure_ascii=False))
    if result.get("status") == "error":
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="عرض استهلاك البيانات بصيغة JSON."
    )

    today = date.today()
    start_of_month = today.replace(day=1).strftime("%Y-%m-%d")
    today_str = today.strftime("%Y-%m-%d")

    parser.add_argument(
        "-i",
        "--interface",
        required=True,
        help="اسم الواجهة (مثال: wlp0s20f3).",
    )
    parser.add_argument(
        "-s",
        "--start-date",
        default=start_of_month,
        help="تاريخ البدء (YYYY-MM-DD).",
    )
    parser.add_argument(
        "-e",
        "--end-date",
        default=today_str,
        help="تاريخ الانتهاء (YYYY-MM-DD).",
    )

    args = parser.parse_args()

    get_data_usage(args.interface, args.start_date, args.end_date)
