#!/usr/bin/env python3
import os
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
        # تأخير بسيط بعد إغلاق الإشعار لتخفيف الضغط على النظام
        time.sleep(0.1)
    except dbus.exceptions.DBusException as e:
        # طباعة الخطأ للتشخيص في حال حدوث مشكلة
        print(f"خطأ عند إغلاق الإشعار {nid}: {e}")


def bulk_delete_notifications(start=1, end=1000, max_workers=10, delay=0.005):
    """
    يقوم بحذف الإشعارات من start إلى end باستخدام ThreadPoolExecutor مع max_workers
    وتطبيق تأخير بسيط delay بين جدولة كل عملية إغلاق.
    """
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for nid in range(start, end):
            executor.submit(close_notification, nid)
            time.sleep(delay)


if __name__ == "__main__":
    # إنشاء عملية فرعية لتشغيل bulk_delete_notifications في الخلفية وعدم حجز الطرفية
    pid = os.fork()
    if pid > 0:
        # العملية الأصلية تنهي نفسها فورًا دون انتظار انتهاء العملية الفرعية
        os._exit(0)
    else:
        # فصل العملية الفرعية عن جلسة الطرفية
        os.setsid()
        bulk_delete_notifications()
