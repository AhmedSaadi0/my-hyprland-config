#!/bin/bash

# الحصول على العمليات مرتبة حسب استهلاك CPU
ps -eo pid,comm:20,pcpu --sort=-pcpu | head -n 7 | awk '
BEGIN {
    printf "["
    first=1
}

# تخطي السروات والخطوط الفارغة
NR <= 1 || $0 ~ /^$/ { next }

{
    pid = $1
    cmd = $2
    cpu = $3

    # تنظيف البيانات
    gsub(/"/, "", cmd)  # إزالة علامات الاقتباس
    cmd = substr(cmd, 1, 14)  # اقتصار الاسم على 14 حرفًا

    # إضافة + للأسماء المقطوعة
    if (length($2) >= 15) {
        cmd = cmd "+"
    }

    # تنسيق قيمة CPU
    if (cpu == "0.0") {
        cpu = "0"
    } else if (cpu < 1.0 && cpu > 0) {
        cpu = sprintf(".%02d", int(cpu*100))
    } else {
        cpu = sprintf("%.2f", cpu)
    }

    # توليد JSON
    if (!first) {
        printf ","
    } else {
        first = 0
    }

    printf "{\"pid\":\"%s\",\"process\":\"%s\",\"usage\":\"%s\"}", pid, cmd, cpu
}

END {
    print "]"
}'
