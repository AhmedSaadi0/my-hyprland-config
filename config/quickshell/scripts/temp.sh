#!/usr/bin/env bash
# خفيف ودقيق: قراءة أعلى درجة حرارة من جميع المناطق الحرارية

set -euo pipefail

# تأكد من وجود مجلد sysfs الحراري
if [[ ! -d /sys/class/thermal ]]; then
    echo "خطأ: لا يوجد دعم sysfs للحرارة على هذا النظام." >&2
    exit 1
fi

max_temp=0

# اجمع أعلى قراءة من thermal_zone*/temp
for zone in /sys/class/thermal/thermal_zone*/temp; do
    if [[ -r "$zone" ]]; then
        raw=$(<"$zone") # قيمة millidegree مباشرة:contentReference[oaicite:8]{index=8}
        ((raw > max_temp)) && max_temp=$raw
    fi
done

# تحويل millidegree إلى °C بدقة عشرية واحدة
temp_c=$(awk "BEGIN{printf \"%.1f\", $max_temp/1000}") # دقة حتى منزلة عشرية:contentReference[oaicite:9]{index=9}

# طباعة الرقم فقط
echo "$temp_c"
