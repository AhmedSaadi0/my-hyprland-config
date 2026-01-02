pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: lightTheme
    themeName: "NordLight"
    _themeMode: "light"

    // Nord Palette
    // Polar Night (Foregrounds): #2E3440, #3B4252, #434C5E, #4C566A
    // Snow Storm (Backgrounds): #D8DEE9, #E5E9F0, #ECEFF4
    // Frost (Accents): #8FBCBB, #88C0D0, #81A1C1, #5E81AC
    // Aurora (Syntax/Status): #BF616A (Red), #A3BE8C (Green), #EBCB8B (Yellow)

    _wallpaper: App.assets.getWallpaperPath("nord-light.png")

    // الألوان الأساسية (طبقًا لوحة Frost)
    _primary: "#5E81AC"      // nord10 (أزرق عميق - للتأكيدات الأساسية)
    _secondary: "#88C0D0"    // nord8  (فيروزي - للتأكيدات الثانوية)

    _onPrimary: "#ECEFF4"    // nord6  (نص على العناصر الأساسية)
    _onSecondary: "#2E3440"  // nord0  (نص على العناصر الثانوية)

    _tertiary: "#A3BE8C"
    _onTertiary: "#2E3440"   // نص داكن للتباين

    // Error: أحمر (nord11)
    _error: "#BF616A"
    _onError: "#ECEFF4"      // نص فاتح

    // Success: أخضر (nord14)
    _success: "#A3BE8C"
    _onSuccess: "#2E3440"    // نص داكن

    // Warning: أصفر (nord13)
    _warning: "#EBCB8B"
    _onWarning: "#2E3440"    // نص داكن لأن الأصفر فاتح

    // شريط الأدوات العلوي (طبقًا لوحة Snow Storm)
    _topbarColor: "#FFFFFF"  // أبيض نقي (مقتبس من nord6 لتحسين التباين)
    _topbarFgColor: "#3B4252" // nord1 (نص داكن لوضوح أعلى)
    _topbarBgColorV1: "#EAEFF9" // nord6 (خلفية بطاقات)
    _topbarBgColorV2: "#cae6ff" // nord5 (تدرج متوسط)
    _topbarBgColorV3: "#fdd7d7" // nord4 (تدرج داكن)
    _topbarFgColorV1: "#2E3440" // nord0 (نص عالي التباين)
    _topbarFgColorV2: "#434C5E" // nord2
    _topbarFgColorV3: "#4C566A" // nord3

    // القائمة الجانبية (دمج Polar Night + Snow Storm)
    _leftMenuBgColorV1: "#FFFFFF"              // خلفية رئيسية (تباين عالي)
    _leftMenuBgColorV2: "#F8FAFC"              // تدرج فاتح (غير موجود في نورد - لسلاسة التدرج)
    _leftMenuBgColorV3: "#5E81AC"              // nord10 (عنصر نشط)
    _leftMenuFgColorV1: "#3B4252"              // nord1 (نص قياسي)
    _leftMenuFgColorV2: "#4C566A"              // nord3 (نص ثانوي)
    _leftMenuFgColorV3: "#FFFFFF"              // نص على عنصر نشط

    // عناصر واجهة إضافية
    _subtleTextColor: "#4C566A"                // nord3 (نص خافت)
    _volOsdBgColor: "#3B4252"                  // nord1 (خلفية بوب أب)
    _volOsdFgColor: "#ECEFF4"                  // nord6 (نص بوب أب)

    _hyprActiveBorder: "rgba(5E81ACff) rgba(88C0D0ff) 0deg"

    _plasmaColorScheme: "NibrasNordLight"
    _konsoleProfile: "NordLight.profile"

    _themeIcons: "Zafiro-Nord-Light-Blue"

    _gtkTheme: "Nordic-lighter"
}
