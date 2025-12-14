pragma Singleton

import QtQuick
import Quickshell
import "root:/config/ConstValues.js" as C
import "root:/config"

Singleton {
    id: root

    // دالة مساعدة للاختيار العشوائي من المصفوفات
    function getRandom(arr) {
        return arr[Math.floor(Math.random() * arr.length)];
    }

    // ========================================================================
    // 1. 🌤️ Weather Test Shortcut
    // ========================================================================
    NibrasShellShortcut {
        name: "testCapsuleWeather" // تأكد من إضافة هذا الاسم في ملف الاختصارات لديك لربطه بمفتاح
        onPressed: {
            // احتمالية 30% أن يكون الطقس عاجلاً/خطيراً
            const isUrgent = Math.random() < 0.3;

            // بنك بيانات الطقس العادي
            const normalWeather = [
                {
                    text: "السماء صافية، درجة الحرارة 24°C. يوم مثالي للمشي.",
                    icon: "",
                    emotion: "happy",
                    bg1: "#2980b9",
                    bg2: "#6dd5fa"
                },
                {
                    text: "غائم جزئياً، 19°C. احتمالية خفيفة للأمطار.",
                    icon: "",
                    emotion: "thinking",
                    bg1: "#606c88",
                    bg2: "#3f4c6b"
                },
                {
                    text: "أمطار خفيفة، 15°C. لا تنس مظلتك.",
                    icon: "",
                    emotion: "wink",
                    bg1: "#373B44",
                    bg2: "#4286f4"
                }
            ];

            // بنك بيانات الطقس الخطر
            const urgentWeather = [
                {
                    text: "تحذير: عاصفة رعدية قوية تقترب خلال 10 دقائق!",
                    icon: "",
                    emotion: "shocked",
                    bg1: "#232526",
                    bg2: "#414345"
                },
                {
                    text: "تنبيه حرارة: درجة الحرارة تجاوزت 45°C، تجنب الشمس.",
                    icon: "",
                    emotion: "dead",
                    bg1: "#ff512f",
                    bg2: "#dd2476"
                },
                {
                    text: "عاجل: رياح قوية جداً (80 كم/س). ابق في الداخل.",
                    icon: "",
                    emotion: "suspicious",
                    bg1: "#1f4037",
                    bg2: "#99f2c8"
                }
            ];

            const data = isUrgent ? getRandom(urgentWeather) : getRandom(normalWeather);

            console.log("🧪 Test: Weather -> Urgent:", isUrgent, "|", data.text);

            // إرسال البيانات للمنسق
            CapsuleCoordinator.handleWeatherUpdate({
                urgent_alert: isUrgent,
                smart_summary: {
                    summary_text: data.text
                },
                ui: {
                    emotion: data.emotion,
                    icon: data.icon,
                    bg_color1: data.bg1,
                    bg_color2: data.bg2,
                    fg_color: "#ffffff"
                }
            });
        }
    }

    // ========================================================================
    // 2. 🔋 Battery Test Shortcut
    // ========================================================================
    NibrasShellShortcut {
        name: "testCapsuleBattery"
        onPressed: {
            // مستويات مختلفة للاختبار (تحذير، منخفض، حرج، احتضار)
            const levels = [25, 20, 15, 10, 8, 4];
            const randomLevel = getRandom(levels);

            console.log("🧪 Test: Battery -> Level:", randomLevel + "%");

            // إرسال البيانات للمنسق
            CapsuleCoordinator.triggerBatteryAlert(randomLevel);
        }
    }

    // ========================================================================
    // 3. 🎵 Music AI Test Shortcut
    // ========================================================================
    NibrasShellShortcut {
        name: "testCapsuleMusic"
        onPressed: {
            const musicScenarios = [
                {
                    emotion: "happy",
                    comment: "إيقاع هذه الأغنية يرفع المعنويات! يبدو أنك في مزاج جيد."
                },
                {
                    emotion: "sad",
                    comment: "كلمات الأغنية تعبر عن حنين عميق للماضي.."
                },
                {
                    emotion: "thinking",
                    comment: "التركيب الموسيقي هنا معقد جداً، مزيج بين الجاز والكلاسيك."
                },
                {
                    emotion: "shocked",
                    comment: "واو! هذا السولو للجيتار سريع جداً ومذهل!"
                },
                {
                    emotion: "listening",
                    comment: "هدوء البيانو يساعد على التركيز العميق."
                }
            ];

            const data = getRandom(musicScenarios);

            console.log("🧪 Test: Music AI -> Emotion:", data.emotion);

            // إرسال البيانات للمنسق
            CapsuleCoordinator.handleMusicAnalysis(data.emotion, data.comment);
        }
    }

    // ========================================================================
    // 4. 🖥️ System (Volume/Brightness) Test Shortcut
    // ========================================================================
    NibrasShellShortcut {
        name: "testCapsuleSystem"
        onPressed: {
            // اختيار عشوائي بين الصوت والسطوع
            const isVolume = Math.random() > 0.5;

            // قيمة عشوائية
            const randomVal = Math.random().toFixed(2); // 0.00 to 1.00

            console.log("🧪 Test: System ->", isVolume ? "Volume" : "Brightness", randomVal);

            // بما أن المنسق يقرأ القيم الحقيقية من SystemService،
            // سنقوم هنا بمحاكاة الطلب المباشر للكبسولة (Mocking the request)
            // لأننا لا نستطيع تغيير مستوى صوت النظام الحقيقي عشوائياً بسهولة دون إزعاج

            if (isVolume) {
                // محاكاة منطق الصوت
                CapsuleManager.request({
                    priority: C.TRANSIENT,
                    source: C.SRC_SYSTEM,
                    icon: "",
                    text: Math.round(randomVal * 100) + "%",
                    progress: randomVal,
                    withProgress: true,
                    timeout: 2000
                });
                // محاكاة حركة العين المرتبطة بالصوت
                if (typeof EyeController !== "undefined")
                    EyeController.showEmotion("wink", 1000);
            } else {
                // محاكاة منطق السطوع
                CapsuleManager.request({
                    priority: C.TRANSIENT,
                    source: C.SRC_SYSTEM,
                    icon: "",
                    text: Math.round(randomVal * 100) + "%",
                    progress: randomVal,
                    withProgress: true,
                    timeout: 2000
                });
                // محاكاة حركة العين المرتبطة بالسطوع
                if (typeof EyeController !== "undefined")
                    EyeController.showEmotion("focused", 1000);
            }
        }
    }
}
