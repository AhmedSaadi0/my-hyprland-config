#!/usr/bin/env python3
import time
from concurrent.futures import ThreadPoolExecutor

import dbus


def close_notification(nid):
    try:
        # إنشاء اتصال جديد بالـ Session Bus لكل طلب
        bus = dbus.SessionBus()
        obj = bus.get_object(
            "org.freedesktop.Notifications", "/org/freedesktop/Notifications"
        )
        interface = dbus.Interface(obj, "org.freedesktop.Notifications")
        interface.CloseNotification(nid)
        time.sleep(0.1)  # تأخير بسيط بين الإشعارات لجعلها تظهر بشكل واضح
    except dbus.exceptions.DBusException:
        # نتجاهل الأخطاء في حال عدم وجود إشعار برقم nid
        pass


def bulk_delete_notifications(start=1, end=1000, max_workers=10, delay=0.005):
    """
    يحاول حذف الإشعارات من start إلى end باستخدام ThreadPoolExecutor
    مع max_workers طلبات متزامنة وتأخير بسيط delay بين جدولة الطلبات.
    """
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for nid in range(start, end):
            executor.submit(close_notification, nid)
            time.sleep(delay)  # تأخير بسيط لتخفيف الضغط على ags


if __name__ == "__main__":
    bulk_delete_notifications()
