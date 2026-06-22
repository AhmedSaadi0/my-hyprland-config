import argparse
import json
import os
import re
import shutil
import sqlite3
import subprocess
import time
from collections import defaultdict
from datetime import date, datetime, timedelta
from pathlib import Path

import psutil


def get_vnstat_daily(interface, start_date_str, end_date_str):
    """
    جلب vnstat totals اليومية (دقيق).
    يرجع: {rx_bytes, tx_bytes, total_bytes}
    """
    try:
        command = ["vnstat", "--json", "d", "-i", interface]
        proc = subprocess.run(
            command, capture_output=True, text=True, check=True, timeout=5
        )
        vnstat_data = json.loads(proc.stdout)

        target_interface_data = None
        for iface_object in vnstat_data.get("interfaces", []):
            if iface_object.get("name") == interface:
                target_interface_data = iface_object
                break

        if not target_interface_data:
            return None

        start_date = datetime.strptime(start_date_str, "%Y-%m-%d").date()
        end_date = datetime.strptime(end_date_str, "%Y-%m-%d").date()

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

        return {
            "rx_bytes": total_rx,
            "tx_bytes": total_tx,
            "total_bytes": total_rx + total_tx,
        }
    except Exception:
        return None


def get_vnstat_hourly(interface, hours=24):
    """
    جلب vnstat بيانات كل ساعة (لأدق من 24 ساعة).
    يرجع: [{hour_ts, rx_bytes, tx_bytes}, ...]
    """
    try:
        command = ["vnstat", "--json", "h", "-i", interface]
        proc = subprocess.run(
            command, capture_output=True, text=True, check=True, timeout=5
        )
        vnstat_data = json.loads(proc.stdout)

        target_interface_data = None
        for iface_object in vnstat_data.get("interfaces", []):
            if iface_object.get("name") == interface:
                target_interface_data = iface_object
                break

        if not target_interface_data:
            return []

        cutoff_ts = int(time.time()) - int(max(1, hours) * 3600)
        hours_list = target_interface_data.get("traffic", {}).get("hour", [])

        result = []
        for hour_data in hours_list:
            ts = hour_data.get("timestamp", 0)
            if ts >= cutoff_ts:
                result.append({
                    "hour_ts": ts,
                    "rx_bytes": hour_data.get("rx", 0),
                    "tx_bytes": hour_data.get("tx", 0),
                })
        return result
    except Exception:
        return []


def calculate_app_ratios_from_db(db_path, start_ts, end_ts, interface=None):
    """
    حساب نسب كل تطبيق من nethogs database.
    يرجع: [{app_name, ratio_rx, ratio_tx, approx_rx_bytes, approx_tx_bytes}, ...]
    """
    if not Path(db_path).exists():
        return []

    params = [start_ts, end_ts]
    where = "WHERE ts >= ? AND ts <= ?"
    if interface:
        where += " AND interface = ?"
        params.append(interface)

    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row

    query = f"""
        SELECT
            app_name,
            SUM(approx_rx_bytes) AS rx_bytes,
            SUM(approx_tx_bytes) AS tx_bytes,
            SUM(approx_total_bytes) AS total_bytes,
            MAX(total_rate_bps) AS peak_rate_bps
        FROM app_samples
        {where}
        GROUP BY app_name
        HAVING total_bytes > 0
        ORDER BY total_bytes DESC
    """
    rows = [dict(row) for row in con.execute(query, params).fetchall()]
    con.close()

    if not rows:
        return []

    total_rx = sum(r["rx_bytes"] for r in rows)
    total_tx = sum(r["tx_bytes"] for r in rows)
    total_all = max(1, total_rx + total_tx)

    for row in rows:
        row["ratio_rx"] = row["rx_bytes"] / max(1, total_rx) if total_rx > 0 else 0
        row["ratio_tx"] = row["tx_bytes"] / max(1, total_tx) if total_tx > 0 else 0
        row["ratio_total"] = (row["rx_bytes"] + row["tx_bytes"]) / total_all

    return rows


def estimate_per_app_from_vnstat(vnstat_totals, app_ratios, top=15):
    """
    حساب الاستهلاك لكل تطبيق باستخدام vnstat totals × nethogs ratios.
    يرجع: [{name, estimated_rx, estimated_tx, estimated_total, peak_rate_bps}, ...]
    """
    if not app_ratios or not vnstat_totals:
        return []

    vnstat_rx = vnstat_totals.get("rx_bytes", 0)
    vnstat_tx = vnstat_totals.get("tx_bytes", 0)
    vnstat_total = vnstat_totals.get("total_bytes", 0)

    results = []
    for row in app_ratios[:top]:
        est_rx = int(vnstat_rx * row["ratio_rx"])
        est_tx = int(vnstat_tx * row["ratio_tx"])
        est_total = int(vnstat_total * row["ratio_total"])
        results.append({
            "name": row["app_name"],
            "estimated_rx": est_rx,
            "estimated_tx": est_tx,
            "estimated_total": est_total,
            "peak_rate_bps": int(row.get("peak_rate_bps") or 0),
            "samples_count": 0,
        })

    return results


def summarize_usage_with_vnstat(db_path, hours=24, top=15, interface=None, start_date=None, end_date=None):
    """
    ملخص الاستهلاك باستخدام vnstat (دقيق) + nethogs ratios (تقريبي).
    """
    if not interface:
        return {
            "status": "success",
            "range_hours": hours,
            "data": [],
            "totals": {},
            "source": "vnstat+nethogs",
            "meta": {"message": "no interface specified"},
        }

    now_ts = int(time.time())
    now_date_obj = date.today()

    if start_date and end_date:
        vnstat_start = start_date
        vnstat_end = end_date
        start_dt = datetime.strptime(start_date, "%Y-%m-%d").date()
        end_dt = datetime.strptime(end_date, "%Y-%m-%d").date()
        start_ts = int(start_dt.strftime("%s"))
        now_ts = int(end_dt.strftime("%s")) + 86400
    else:
        vnstat_start = (now_date_obj - timedelta(days=max(1, hours // 24 + 1))).strftime("%Y-%m-%d")
        vnstat_end = now_date_obj.strftime("%Y-%m-%d")
        start_ts = now_ts - int(max(1, hours) * 3600)

    vnstat_totals = get_vnstat_daily(interface, vnstat_start, vnstat_end)

    if vnstat_totals is None:
        vnstat_hourly = get_vnstat_hourly(interface, hours)
        if vnstat_hourly:
            vnstat_rx = sum(h["rx_bytes"] for h in vnstat_hourly)
            vnstat_tx = sum(h["tx_bytes"] for h in vnstat_hourly)
            vnstat_totals = {
                "rx_bytes": vnstat_rx,
                "tx_bytes": vnstat_tx,
                "total_bytes": vnstat_rx + vnstat_tx,
            }
        else:
            vnstat_totals = {"rx_bytes": 0, "tx_bytes": 0, "total_bytes": 0}

    app_ratios = calculate_app_ratios_from_db(db_path, start_ts, now_ts, interface)

    per_app = estimate_per_app_from_vnstat(vnstat_totals, app_ratios, top)

    vnstat_peak = 0
    vnstat_hourly = get_vnstat_hourly(interface, hours)
    if vnstat_hourly:
        vnstat_peak = max(
            (h["rx_bytes"] + h["tx_bytes"]) / 3600 for h in vnstat_hourly
        )

    range_label = f"{vnstat_start} to {vnstat_end}" if start_date else f"{hours}h"

    return {
        "status": "success",
        "range_hours": int(max(1, hours)),
        "range_label": range_label,
        "data": per_app,
        "totals": {
            "rx_bytes": vnstat_totals["rx_bytes"],
            "tx_bytes": vnstat_totals["tx_bytes"],
            "total_bytes": vnstat_totals["total_bytes"],
            "peak_rate_bps": int(vnstat_peak),
            "samples_count": 0,
        },
        "source": "vnstat+nethogs",
    }


NETHOGS_LINE_RE = re.compile(
    r"^(?P<proc>.+?)\s+(?P<sent>[0-9]*\.?[0-9]+)\s+(?P<recv>[0-9]*\.?[0-9]+)\s*$"
)
REFRESH_RE = re.compile(r"^Refreshing:\s+(?P<seconds>[0-9]*\.?[0-9]+)\s*s")


def parse_nethogs_process(proc_field):
    parts = proc_field.rsplit("/", 2)
    if len(parts) < 3:
        return None, None, None

    name, pid_raw, user = parts
    try:
        pid = int(pid_raw)
    except ValueError:
        return None, None, None

    display_name = os.path.basename(name) if name else "Unknown"
    return pid, display_name or "Unknown", user or ""


def parse_nethogs_output(text):
    # Keep the latest cycle for live UI, but aggregate all cycles for history persistence.
    current_cycle = defaultdict(
        lambda: {
            "name": "Unknown",
            "user": "",
            "connections_count": 0,
            "rx_rate_bps": 0,
            "tx_rate_bps": 0,
        }
    )
    current_cycle_seconds = 1.0
    cycles = []

    def new_cycle():
        return defaultdict(
            lambda: {
                "name": "Unknown",
                "user": "",
                "connections_count": 0,
                "rx_rate_bps": 0,
                "tx_rate_bps": 0,
            }
        )

    def cycle_to_rows(cycle):
        rows = []
        for pid, item in cycle.items():
            rows.append(
                {
                    "pid": pid,
                    "name": item["name"],
                    "user": item["user"],
                    "connections_count": max(1, item["connections_count"]),
                    "rx_rate_bps": item["rx_rate_bps"],
                    "tx_rate_bps": item["tx_rate_bps"],
                    "total_rate_bps": item["rx_rate_bps"] + item["tx_rate_bps"],
                    "bytes_recv": 0,
                    "bytes_sent": 0,
                    "bytes_total": 0,
                    "source": "nethogs",
                }
            )

        rows.sort(
            key=lambda item: (item["total_rate_bps"], item["connections_count"]),
            reverse=True,
        )
        return rows

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue

        refresh_match = REFRESH_RE.match(line)
        if refresh_match:
            try:
                next_cycle_seconds = float(refresh_match.group("seconds"))
            except ValueError:
                next_cycle_seconds = 1.0
            if current_cycle:
                cycles.append((current_cycle, current_cycle_seconds))
                current_cycle = new_cycle()
            current_cycle_seconds = next_cycle_seconds
            continue

        if line.startswith("unknown TCP"):
            continue

        match = NETHOGS_LINE_RE.match(line)
        if not match:
            continue

        pid, name, user = parse_nethogs_process(match.group("proc"))
        if pid is None:
            continue

        try:
            sent_kbps = float(match.group("sent"))
            recv_kbps = float(match.group("recv"))
        except ValueError:
            continue

        entry = current_cycle[pid]
        entry["name"] = name
        entry["user"] = user
        entry["connections_count"] += 1
        entry["tx_rate_bps"] += int(sent_kbps * 1024)
        entry["rx_rate_bps"] += int(recv_kbps * 1024)

    if current_cycle:
        cycles.append((current_cycle, current_cycle_seconds))

    latest_cycle = cycles[-1][0] if cycles else new_cycle()
    latest_rows = cycle_to_rows(latest_cycle)

    aggregated = defaultdict(
        lambda: {
            "name": "Unknown",
            "user": "",
            "connections_count": 0,
            "rx_rate_bps": 0,
            "tx_rate_bps": 0,
            "total_rate_bps": 0,
            "approx_rx_bytes": 0,
            "approx_tx_bytes": 0,
            "approx_total_bytes": 0,
        }
    )

    for cycle, seconds in cycles:
        observed_seconds = max(0.0, float(seconds))
        for pid, item in cycle.items():
            entry = aggregated[pid]
            total_rate = item["rx_rate_bps"] + item["tx_rate_bps"]
            entry["name"] = item["name"]
            entry["user"] = item["user"]
            entry["connections_count"] = max(
                entry["connections_count"], item["connections_count"]
            )
            entry["rx_rate_bps"] = max(entry["rx_rate_bps"], item["rx_rate_bps"])
            entry["tx_rate_bps"] = max(entry["tx_rate_bps"], item["tx_rate_bps"])
            entry["total_rate_bps"] = max(entry["total_rate_bps"], total_rate)
            entry["approx_rx_bytes"] += int(item["rx_rate_bps"] * observed_seconds)
            entry["approx_tx_bytes"] += int(item["tx_rate_bps"] * observed_seconds)
            entry["approx_total_bytes"] += int(total_rate * observed_seconds)

    persist_rows = []
    for pid, item in aggregated.items():
        persist_rows.append(
            {
                "pid": pid,
                "name": item["name"],
                "user": item["user"],
                "connections_count": max(1, item["connections_count"]),
                "rx_rate_bps": item["rx_rate_bps"],
                "tx_rate_bps": item["tx_rate_bps"],
                "total_rate_bps": item["total_rate_bps"],
                "approx_rx_bytes": item["approx_rx_bytes"],
                "approx_tx_bytes": item["approx_tx_bytes"],
                "approx_total_bytes": item["approx_total_bytes"],
                "source": "nethogs",
            }
        )

    persist_rows.sort(
        key=lambda item: (item["approx_total_bytes"], item["total_rate_bps"]),
        reverse=True,
    )
    observed_total_seconds = sum(max(0.0, float(seconds)) for _, seconds in cycles)
    return latest_rows, persist_rows, observed_total_seconds or 1.0


def run_nethogs(interface=None, timeout_sec=8, cycles=3):
    if shutil.which("nethogs") is None:
        raise RuntimeError("nethogs is not installed")

    cmd = ["nethogs", "-t", "-c", str(max(2, cycles))]
    if interface:
        cmd.append(interface)

    proc = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=timeout_sec,
        check=False,
    )

    output = (proc.stdout or "").strip()
    errors = (proc.stderr or "").strip()
    rows, persist_rows, observed_seconds = parse_nethogs_output(output)

    if rows:
        return rows, persist_rows, observed_seconds, ""

    if errors:
        raise RuntimeError(errors)
    raise RuntimeError("nethogs returned no parsable rows")


def fallback_psutil(limit):
    by_pid = defaultdict(lambda: {"connections_count": 0})

    for conn in psutil.net_connections(kind="inet"):
        if conn.pid is None or conn.status != "ESTABLISHED":
            continue
        by_pid[conn.pid]["connections_count"] += 1

    rows = []
    for pid, item in by_pid.items():
        try:
            proc = psutil.Process(pid)
            rows.append(
                {
                    "pid": pid,
                    "name": proc.name() or "Unknown",
                    "user": proc.username() or "",
                    "connections_count": item["connections_count"],
                    "rx_rate_bps": 0,
                    "tx_rate_bps": 0,
                    "total_rate_bps": 0,
                    "bytes_recv": 0,
                    "bytes_sent": 0,
                    "bytes_total": 0,
                    "source": "psutil_fallback",
                }
            )
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue

    rows.sort(key=lambda item: item["connections_count"], reverse=True)
    return rows[:limit] if limit > 0 else rows


def ensure_db(db_path):
    path_obj = Path(db_path)
    path_obj.parent.mkdir(parents=True, exist_ok=True)

    con = sqlite3.connect(str(path_obj))
    con.execute(
        """
        CREATE TABLE IF NOT EXISTS app_samples (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ts INTEGER NOT NULL,
            interface TEXT NOT NULL,
            app_name TEXT NOT NULL,
            user_name TEXT,
            pid INTEGER NOT NULL,
            source TEXT NOT NULL,
            connections_count INTEGER NOT NULL,
            rx_rate_bps INTEGER NOT NULL,
            tx_rate_bps INTEGER NOT NULL,
            total_rate_bps INTEGER NOT NULL,
            approx_rx_bytes INTEGER NOT NULL,
            approx_tx_bytes INTEGER NOT NULL,
            approx_total_bytes INTEGER NOT NULL
        )
        """
    )
    con.execute("CREATE INDEX IF NOT EXISTS idx_app_samples_ts ON app_samples(ts)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_app_samples_name_ts ON app_samples(app_name, ts)")
    con.commit()
    return con


def persist_rows(db_path, interface, rows, sample_seconds, retention_days):
    now_ts = int(time.time())
    iface = interface or "unknown"
    seconds = max(1.0, float(sample_seconds))
    con = ensure_db(db_path)

    with con:
        for row in rows:
            rx_rate = int(row.get("rx_rate_bps", 0) or 0)
            tx_rate = int(row.get("tx_rate_bps", 0) or 0)
            total_rate = int(row.get("total_rate_bps", rx_rate + tx_rate) or 0)
            rx_bytes = int(row.get("approx_rx_bytes", rx_rate * seconds) or 0)
            tx_bytes = int(row.get("approx_tx_bytes", tx_rate * seconds) or 0)
            total_bytes = int(
                row.get("approx_total_bytes", total_rate * seconds) or 0
            )
            con.execute(
                """
                INSERT INTO app_samples (
                    ts, interface, app_name, user_name, pid, source,
                    connections_count, rx_rate_bps, tx_rate_bps, total_rate_bps,
                    approx_rx_bytes, approx_tx_bytes, approx_total_bytes
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    now_ts,
                    iface,
                    row.get("name") or "Unknown",
                    row.get("user") or "",
                    int(row.get("pid") or 0),
                    row.get("source") or "unknown",
                    int(row.get("connections_count") or 0),
                    rx_rate,
                    tx_rate,
                    total_rate,
                    rx_bytes,
                    tx_bytes,
                    total_bytes,
                ),
            )

        cutoff_ts = now_ts - int(max(1, retention_days) * 86400)
        con.execute("DELETE FROM app_samples WHERE ts < ?", (cutoff_ts,))

    con.close()
    return now_ts


def get_live_usage(limit=10, interface=None, db_path=None, retention_days=14, persist=True):
    warning = ""
    sample_seconds = 1.0
    persistable_rows = []
    try:
        rows, persistable_rows, sample_seconds, _ = run_nethogs(interface=interface)
    except Exception as exc:
        warning = f"nethogs unavailable ({exc}); using connection-count fallback"
        rows = fallback_psutil(limit=limit)
        persistable_rows = rows

    persisted = False
    snapshot_ts = None
    if persist and db_path:
        try:
            snapshot_ts = persist_rows(
                db_path=db_path,
                interface=interface,
                rows=persistable_rows,
                sample_seconds=sample_seconds,
                retention_days=retention_days,
            )
            persisted = True
        except Exception as exc:
            persist_warning = f"persist failed ({exc})"
            warning = f"{warning}; {persist_warning}" if warning else persist_warning

    display_rows = rows[:limit] if limit > 0 else rows

    return {
        "status": "success",
        "data": display_rows,
        "warning": warning,
        "persisted": persisted,
        "sample_seconds": sample_seconds,
        "snapshot_ts": snapshot_ts,
    }


def summarize_usage(db_path, hours=24, top=15, interface=None, use_vnstat=False, start_date=None, end_date=None):
    if use_vnstat and interface:
        return summarize_usage_with_vnstat(
            db_path=db_path, hours=hours, top=top, interface=interface,
            start_date=start_date, end_date=end_date
        )

    if not Path(db_path).exists():
        return {
            "status": "success",
            "range_hours": hours,
            "data": [],
            "meta": {"message": "database file not found yet"},
        }

    now_ts = int(time.time())
    start_ts = now_ts - int(max(1, hours) * 3600)
    params = [start_ts]
    where = "WHERE ts >= ?"
    if interface:
        where += " AND interface = ?"
        params.append(interface)

    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row

    query = f"""
        SELECT
            app_name AS name,
            SUM(approx_rx_bytes) AS rx_bytes,
            SUM(approx_tx_bytes) AS tx_bytes,
            SUM(approx_total_bytes) AS total_bytes,
            MAX(total_rate_bps) AS peak_rate_bps,
            COUNT(*) AS samples_count
        FROM app_samples
        {where}
        GROUP BY app_name
        ORDER BY total_bytes DESC
        LIMIT ?
    """
    params.append(max(1, int(top)))
    rows = [dict(row) for row in con.execute(query, params).fetchall()]

    totals_query = f"""
        SELECT
            SUM(approx_rx_bytes) AS rx_bytes,
            SUM(approx_tx_bytes) AS tx_bytes,
            SUM(approx_total_bytes) AS total_bytes,
            MAX(total_rate_bps) AS peak_rate_bps,
            COUNT(*) AS samples_count
        FROM app_samples
        {where}
    """
    totals = dict(con.execute(totals_query, params[:-1]).fetchone())
    con.close()

    for item in rows:
        item["rx_bytes"] = int(item.get("rx_bytes") or 0)
        item["tx_bytes"] = int(item.get("tx_bytes") or 0)
        item["total_bytes"] = int(item.get("total_bytes") or 0)
        item["peak_rate_bps"] = int(item.get("peak_rate_bps") or 0)
        item["samples_count"] = int(item.get("samples_count") or 0)

    totals = {
        "rx_bytes": int(totals.get("rx_bytes") or 0),
        "tx_bytes": int(totals.get("tx_bytes") or 0),
        "total_bytes": int(totals.get("total_bytes") or 0),
        "peak_rate_bps": int(totals.get("peak_rate_bps") or 0),
        "samples_count": int(totals.get("samples_count") or 0),
    }

    return {
        "status": "success",
        "range_hours": int(max(1, hours)),
        "data": rows,
        "totals": totals,
        "source": "nethogs",
    }


def parse_args():
    parser = argparse.ArgumentParser(description="Live and historical per-app network usage.")
    parser.add_argument("--mode", choices=["live", "summary"], default="live")
    parser.add_argument("--limit", type=int, default=10, help="Max live rows to return.")
    parser.add_argument("--interface", type=str, default="", help="Interface for nethogs filtering.")
    parser.add_argument("--db-path", type=str, default="", help="SQLite db path.")
    parser.add_argument("--retention-days", type=int, default=14, help="History retention window.")
    parser.add_argument("--hours", type=int, default=168, help="Summary range in hours.")
    parser.add_argument("--top", type=int, default=15, help="Top apps in summary mode.")
    parser.add_argument("--no-persist", action="store_true", help="Do not persist live samples to the history database.")
    parser.add_argument("--use-vnstat", action="store_true", help="Use vnstat for accurate totals with nethogs ratios.")
    parser.add_argument("--start-date", type=str, default=None, help="Start date (YYYY-MM-DD) for date range mode.")
    parser.add_argument("--end-date", type=str, default=None, help="End date (YYYY-MM-DD) for date range mode.")
    return parser.parse_args()


def default_db_path():
    return os.path.expanduser("~/.cache/nibrasshell/network_usage/live_usage.sqlite")


if __name__ == "__main__":
    args = parse_args()
    db_path = args.db_path or default_db_path()

    if args.mode == "summary":
        result = summarize_usage(
            db_path=db_path,
            hours=max(1, args.hours),
            top=max(1, args.top),
            interface=(args.interface or None),
            use_vnstat=args.use_vnstat,
            start_date=args.start_date,
            end_date=args.end_date,
        )
    else:
        result = get_live_usage(
            limit=max(0, args.limit),
            interface=(args.interface or None),
            db_path=db_path,
            retention_days=max(1, args.retention_days),
            persist=not args.no_persist,
        )

    print(json.dumps(result, ensure_ascii=False))
