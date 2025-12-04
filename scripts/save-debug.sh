#!/bin/bash

# تحديد اسم الملف مع الوقت والتاريخ
LOG_FILE="$HOME/hypr_crash_report_$(date +%Y%m%d_%H%M%S).txt"

echo "=== JUMPING TO RESCUE ===" >"$LOG_FILE"
echo "Report generated at: $(date)" >>"$LOG_FILE"
echo "" >>"$LOG_FILE"

echo "-------------------------------------------" >>"$LOG_FILE"
echo "1. SYSTEMD FAILED UNITS (خدمات فشلت)" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
systemctl --user list-units --failed >>"$LOG_FILE" 2>&1

echo "" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
echo "2. XDG PORTAL PROCESSES (هل هناك تضارب؟)" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
ps aux | grep -i xdg-desktop-portal | grep -v grep >>"$LOG_FILE" 2>&1

echo "" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
echo "3. PORTAL SERVICE STATUS (حالة الخدمات)" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
systemctl --user status xdg-desktop-portal* --no-pager >>"$LOG_FILE" 2>&1

echo "" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
echo "4. CRITICAL ERRORS (آخر دقيقتين)" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
# يجلب الأخطاء الحرجة التي حدثت في آخر دقيقتين فقط
journalctl --user --since "2 minutes ago" -p 3 --no-pager >>"$LOG_FILE" 2>&1

echo "" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
echo "5. HYPRLAND LOG (آخر ما قاله هيبرلاند)" >>"$LOG_FILE"
echo "-------------------------------------------" >>"$LOG_FILE"
# يجلب آخر ملف لوق لهيبرلاند
HYPR_LOG="/tmp/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/*.log | head -n 1)/hyprland.log"
if [ -f "$HYPR_LOG" ]; then
    tail -n 50 "$HYPR_LOG" >>"$LOG_FILE"
else
    echo "Hyprland log not found!" >>"$LOG_FILE"
fi

echo "" >>"$LOG_FILE"
echo "DONE! Saved to $LOG_FILE"
# إرسال إشعار لك بأن الملف تم حفظه (إذا كان الإشعار يعمل)
notify-send "Debug Saved" "File: $LOG_FILE"
