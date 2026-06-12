pragma Singleton
import QtQuick

import "root:/config"
import "root:/themes"

BaseTheme {
    id: tokyoNightDark
    themeName: "TokyoNightDark"
    _themeMode: "dark"

    _wallpaper: App.assets.getWallpaperPath("tokyonight-dark.png")

    // الألوان الرئيسية والثانوية الرسمية لـ Tokyo Night
    _primary: "#7aa2f7"            // Blue (الأزرق الرئيسي)
    _onPrimary: "#16161e"          // bg_dark (الخلفية الداكنة)
    _secondary: "#bb9af7"          // Magenta (الأرجواني)
    _onSecondary: "#16161e"
    _tertiary: "#7dcfff"           // Cyan (السماوي)
    _onTertiary: "#16161e"
    _error: "#f7768e"              // Red (الأحمر)
    _onError: "#16161e"

    // تدرجات الأسطح والخلفيات (Surfaces & Containers) لبناء تسلسل طبقات مريح للعين
    _surface: "#1a1b26"                      // bg (الخلفية الأساسية للسمة)
    _onSurface: "#c0caf5"                    // fg (النص الأساسي البارز)
    _surfaceDim: "#16161e"                   // bg_dark (الخلفية الأكثر دكنة للتحكم الجانبي والـ Sidebars)
    _surfaceBright: "#292e42"                // bg_highlight (الخلفية المضيئة للتحديد والأسطر النشطة)
    _surfaceContainerLowest: "#13141c"       // درجة داكنة جداً للطبقات العميقة السفلى
    _surfaceContainerLow: "#16161e"          // bg_dark (الطبقة السفلى)
    _surfaceContainer: "#1a1b26"             // bg (الطبقة المتوسطة)
    _surfaceContainerHigh: "#1f2335"         // درجة انتقالية بين الخلفية والتحديد
    _surfaceContainerHighest: "#292e42"      // bg_highlight (الطبقة الأعلى)
    _surfaceVariant: "#292e42"
    _onSurfaceVariant: "#a9b1d6"             // fg_dark (النصوص الثانوية الأقل بروزاً)

    // ألوان الحاويات وخلفيات التحديد النشطة
    _primaryContainer: "#283457"             // bg_visual (خلفية التحديد البصري الأزرق)
    _onPrimaryContainer: "#7aa2f7"           // الأزرق الرئيسي للتحديدات
    _secondaryContainer: "#443a5e"           // درجة تحديد أرجوانية داكنة متناسقة
    _onSecondaryContainer: "#bb9af7"         // الأرجواني الرئيسي
    _tertiaryContainer: "#1f3547"            // درجة تحديد سماوية داكنة
    _onTertiaryContainer: "#7dcfff"          // السماوي الرئيسي
    _errorContainer: "#4c242c"               // درجة أحمر داكنة لخلفية الأخطاء
    _onErrorContainer: "#f7768e"             // الأحمر الرئيسي للأخطاء

    // الحدود والفواصل (Outlines) لتقليل التشتت البصري
    _outline: "#3b4261"                      // fg_gutter (اللون المستخدم للحدود والفواصل الافتراضية)
    _outlineVariant: "#414868"               // terminal_black (درجة حدود بديلة أكثر وضوحاً عند الحاجة)

    _inverseSurface: "#c0caf5"
    _onInverseSurface: "#1a1b26"
    _inversePrimary: "#7aa2f7"
    _shadow: "#000000"
    _scrim: "#000000"

    _plasmaColorScheme: "NibrasTokyoNightDark"
    _konsoleProfile: "NibrasTokyoNightDark.profile"

    _themeIcons: "Tela-dark"
    _gtkTheme: "Tokyonight-Dark"
}
