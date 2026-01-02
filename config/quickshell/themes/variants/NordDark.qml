pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: nordDark
    themeName: "NordDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("nord-dark.png")

    // الألوان الأساسية (باستخدام Frost + Aurora)
    _primary: "#799ddc"      // nord8  (فيروزي - كأساس لتحسين الوضوح)
    _secondary: "#A3BE8C"    // nord14 (أخضر - للتأكيدات المهمة)

    _onPrimary: "#2E3440"    // nord0  (نص داكن على عناصر فاتحة)
    _onSecondary: "#ECEFF4"  // nord6  (نص فاتح على عناصر داكنة)

    _tertiary: "#B48EAD"
    _onTertiary: "#2E3440"   // نص داكن

    // Error: أحمر (nord11)
    _error: "#BF616A"
    _onError: "#ECEFF4"      // نص فاتح

    // Success: أخضر (nord14)
    _success: "#A3BE8C"
    _onSuccess: "#2E3440"    // نص داكن

    // Warning: أصفر (nord13)
    _warning: "#EBCB8B"
    _onWarning: "#2E3440"    // نص داكن

    // شريط الأدوات العلوي (طبقًا لوحة Polar Night)
    _topbarColor: "#2E3440"  // nord0 (خلفية داكنة)
    _topbarFgColor: "#E5E9F0" // nord5 (نص فاتح)
    _topbarBgColorV1: "#3B4252" // nord1 (بطاقات - طبقة 1)
    _topbarBgColorV2: "#434C5E" // nord2 (طبقة 2)
    _topbarBgColorV3: "#4C566A" // nord3 (طبقة 3)
    _topbarFgColorV1: "#ECEFF4" // nord6 (نص عالي التباين)
    _topbarFgColorV2: "#D8DEE9" // nord4
    _topbarFgColorV3: "#8FBCBB" // nord7 (للملاحظات)

    // القائمة الجانبية (Polar Night مع تعزيز)
    _leftMenuBgColorV1: "#252934"              // أغمق من nord0 (تحسين التباين)
    _leftMenuBgColorV2: "#2E3440"              // nord0
    _leftMenuBgColorV3: "#88C0D0"              // nord8 (عنصر نشط)
    _leftMenuFgColorV1: "#D8DEE9"              // nord4 (نص قياسي)
    _leftMenuFgColorV2: "#81A1C1"              // nord9 (نص ثانوي)
    _leftMenuFgColorV3: "#2E3440"              // نص داكن على عنصر نشط

    // عناصر واجهة إضافية
    _subtleTextColor: "#81A1C1"                // nord9 (لون خافت)
    _volOsdBgColor: "#434C5E"                  // nord2 (خلفية بوب أب)
    _volOsdFgColor: "#EBCB8B"                  // nord13 (نص تحذيري)

    _hyprActiveBorder: "rgba(88C0D0ff) rgba(A3BE8Cff) 0deg"

    _plasmaColorScheme: "NibrasNordDark"
    _konsoleProfile: "NordDark.profile"

    _themeIcons: "Zafiro-Nord-Black-Blue"

    _gtkTheme: "Nordic-darker-standard-buttons"
}
