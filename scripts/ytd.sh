#!/usr/bin/env bash
# سكربت لتحميل الفيديو باستخدام yt-dlp مع دمج الصوت والفيديو وفق الخيارات المحددة، أو تنزيل الصوت فقط

# التحقق من وجود yt-dlp
if ! command -v yt-dlp &>/dev/null; then
    echo "خطأ: لم يتم تثبيت yt-dlp. الرجاء تثبيته أولاً."
    exit 1
fi

# قراءة رابط الفيديو من المستخدم
echo "أدخل رابط الفيديو:"
read video_url

# اختيار نوع التنزيل
echo "اختر نوع التنزيل:"
echo "1) فيديو مع الصوت (تنزيل متكامل)"
echo "2) صوت فقط"
read download_type

if [ "$download_type" == "1" ]; then
    ### تنزيل فيديو مع دمج الصوت
    # اختيار جودة الصوت
    echo "اختر جودة الصوت:"
    echo "1) منخفض"
    echo "2) متوسط"
    echo "3) مرتفع"
    echo "4) اعلى صيغة"
    read audio_choice

    case "$audio_choice" in
    1)
        audio_filter="worstaudio"
        audio_label="منخفض"
        ;;
    2)
        audio_filter="bestaudio[abr<=128]"
        audio_label="متوسط"
        ;;
    3)
        audio_filter="bestaudio[abr<=192]"
        audio_label="مرتفع"
        ;;
    4)
        audio_filter="bestaudio"
        audio_label="اعلى صيغة"
        ;;
    *)
        echo "اختيار صوت غير صحيح."
        exit 1
        ;;
    esac

    # اختيار جودة الفيديو
    echo "اختر جودة الفيديو:"
    echo "1) 144"
    echo "2) 360"
    echo "3) 440"
    echo "4) 720"
    echo "5) 1080"
    echo "6) 4k"
    read video_choice

    case "$video_choice" in
    1)
        video_filter="height<=144"
        ;;
    2)
        video_filter="height<=360"
        ;;
    3)
        video_filter="height<=480"
        ;;
    4)
        video_filter="height<=720"
        ;;
    5)
        video_filter="height<=1080"
        ;;
    6)
        video_filter="height>=2160"
        ;;
    *)
        echo "اختيار فيديو غير صحيح."
        exit 1
        ;;
    esac

    # بناء سلسلة اختيار الصيغة مع ضمان دمج الصوت
    fmt="bestvideo[${video_filter}]+${audio_filter}/best[${video_filter}]"

    echo "سيتم تنزيل الفيديو بالجودة التالية:"
    echo "الصوت: $audio_label"
    echo "الفيديو: $video_filter"
    echo "سلسلة الاختيار: $fmt"
    echo "جاري التنزيل والدمج..."

    yt-dlp -f "$fmt" --merge-output-format mp4 -o "%(title)s.%(ext)s" "$video_url"

    echo "اكتمل التنزيل! تم حفظ الملف في الدليل الحالي."

elif [ "$download_type" == "2" ]; then
    ### تنزيل صوت فقط
    echo "اختر جودة الصوت:"
    echo "1) منخفض"
    echo "2) متوسط"
    echo "3) مرتفع"
    echo "4) اعلى صيغة"
    read audio_choice

    case "$audio_choice" in
    1)
        audio_filter="worstaudio"
        audio_label="منخفض"
        ;;
    2)
        audio_filter="bestaudio[abr<=128]"
        audio_label="متوسط"
        ;;
    3)
        audio_filter="bestaudio[abr<=192]"
        audio_label="مرتفع"
        ;;
    4)
        audio_filter="bestaudio"
        audio_label="اعلى صيغة"
        ;;
    *)
        echo "اختيار صوت غير صحيح."
        exit 1
        ;;
    esac

    echo "سيتم تنزيل الصوت بالجودة: $audio_label"
    echo "جاري التنزيل..."

    # تنزيل واستخراج الصوت فقط وتحويله إلى صيغة MP3
    yt-dlp -f "$audio_filter" --extract-audio --audio-format mp3 -o "%(title)s.%(ext)s" "$video_url"

    echo "اكتمل التنزيل! تم حفظ الملف الصوتي في الدليل الحالي."
else
    echo "اختيار غير صحيح."
    exit 1
fi
