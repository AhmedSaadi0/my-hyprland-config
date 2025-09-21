import json
from collections import defaultdict

import psutil


def get_process_connections():
    """
    يعرض قائمة بالعمليات التي لديها اتصالات شبكية مفتوحة باستخدام psutil.
    """
    process_connections = defaultdict(list)

    try:
        # احصل على جميع الاتصالات الشبكية في النظام
        connections = psutil.net_connections(kind="inet")

        for conn in connections:
            # نريد فقط الاتصالات التي لها PID (عملية مرتبطة بها) وحالة "ESTABLISHED"
            if conn.pid is None or conn.status != "ESTABLISHED":
                continue

            try:
                proc = psutil.Process(conn.pid)
                # تجاهل العمليات التي لا تملك اسم مستخدم (عمليات النظام الأساسية)
                if proc.username() is None:
                    continue

                # أضف معلومات الاتصال إلى العملية
                process_connections[conn.pid].append(
                    {
                        "local_address": f"{conn.laddr.ip}:{conn.laddr.port}",
                        "remote_address": f"{conn.raddr.ip}:{conn.raddr.port}",
                    }
                )

            except (psutil.NoSuchProcess, psutil.AccessDenied):
                # تجاهل العمليات التي اختفت أو لا يمكن الوصول إليها
                continue

        # تحويل البيانات إلى صيغة JSON النهائية
        output_list = []
        for pid, conns in process_connections.items():
            try:
                proc = psutil.Process(pid)
                output_list.append(
                    {
                        "pid": pid,
                        "name": proc.name(),
                        "user": proc.username(),
                        "connections_count": len(conns),
                        "connections": conns,
                    }
                )
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue

        return {"status": "success", "data": output_list}

    except Exception as e:
        return {"status": "error", "message": str(e)}


if __name__ == "__main__":
    result = get_process_connections()
    print(json.dumps(result, indent=2, ensure_ascii=False))
