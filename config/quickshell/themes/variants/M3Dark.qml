pragma Singleton

import org.kde.kirigami as Kirigami
import QtQuick

import "root:/themes"
import "root:/config"

BaseTheme {
    id: root
    themeName: "M3Dark"

    _enableDynamicColoring: true
    _enableDynamicWallpapers: false
    _wallpaper: App.assets.getWallpaperPath("m3_dark.png")
    _desktopClockDepthOverlayPath: App.assets.getWallpaperPath("m3_dark_depth.png")
    _desktopClockFont: "Unrealised"
    _desktopClockFormat: "hh:mm AP - MM/dd"
    _desktopClockPosition: Qt.point(3.0234375, 8.60546875)
    _desktopClockDepthEffectEnabled: true
    _desktopClockSize: Qt.size(1859.52734375, 498.1171875)
    _desktopClockShadowEnabled: false
    _desktopClockUseThemeColor: false
    _desktopClockColor: Qt.rgba(0.79, 0.97, 0.77, 0.8)

    _themeMode: "dark"
    _baseRadius: 14
    _hyprBorderWidth: 3

    // ربط الألوان الأساسية بنظام ألوان KDE
    _primary: Kirigami.Theme.highlightColor
    _onPrimary: Kirigami.Theme.highlightedTextColor

    _secondary: Kirigami.Theme.linkColor
    _onSecondary: Kirigami.Theme.highlightedTextColor

    _tertiary: "#bd93f9"
    _onTertiary: "#16161e"

    _error: Kirigami.Theme.negativeTextColor
    _onError: Kirigami.Theme.highlightedTextColor

    // تدرج الخلفيات الديناميكي بنسب تقريبية متناهية الصغر (لمنع التشوه والتباين الحاد)
    _surface: Kirigami.Theme.backgroundColor
    _onSurface: Kirigami.Theme.textColor
    _surfaceDim: Qt.darker(_surface, 1.04)                   // أغمق بنسبة 4% فقط عن الخلفية الأساسية
    _surfaceBright: Qt.lighter(_surface, 1.08)                // أفتح بنسبة 8% فقط

    _surfaceContainerLowest: Qt.darker(_surface, 1.08)        // أغمق بنسبة 8% كحد أقصى لأعمق الطبقات
    _surfaceContainerLow: Qt.darker(_surface, 1.02)
    _surfaceContainer: Kirigami.Theme.alternateBackgroundColor
    _surfaceContainerHigh: Qt.lighter(_surfaceContainer, 1.04)
    _surfaceContainerHighest: Qt.lighter(_surfaceContainer, 1.08)

    _surfaceVariant: Kirigami.Theme.alternateBackgroundColor
    _onSurfaceVariant: Qt.rgba(_onSurface.r, _onSurface.g, _onSurface.b, 0.65) // خفض سطوع النصوص الثانوية لراحة العين

    // حاويات الألوان مدمجة بنسبة 8% فقط لتوفير خلفية ملونة ناعمة للغاية ومريحة بصرياً
    _primaryContainer: Qt.tint(_surface, Qt.rgba(_primary.r, _primary.g, _primary.b, 0.08))
    _onPrimaryContainer: _primary

    _secondaryContainer: Qt.tint(_surface, Qt.rgba(_secondary.r, _secondary.g, _secondary.b, 0.08))
    _onSecondaryContainer: _secondary

    _tertiaryContainer: Qt.tint(_surface, Qt.rgba(_tertiary.r, _tertiary.g, _tertiary.b, 0.08))
    _onTertiaryContainer: _tertiary

    _errorContainer: Qt.tint(_surface, Qt.rgba(_error.r, _error.g, _error.b, 0.08))
    _onErrorContainer: _error

    // فواصل رقيقة وناعمة للغاية بنسبة شفافية 15% و 8% لتجنب الخطوط البيضاء الحادة أو المشوهة
    _outline: Qt.rgba(_onSurface.r, _onSurface.g, _onSurface.b, 0.15)
    _outlineVariant: Qt.rgba(_onSurface.r, _onSurface.g, _onSurface.b, 0.08)
    _inverseSurface: _onSurface
    _onInverseSurface: _surface
    _inversePrimary: _primary
    _shadow: "#000000"
    _scrim: "#000000"
}
