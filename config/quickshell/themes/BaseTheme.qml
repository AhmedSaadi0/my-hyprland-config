// themes/BaseTheme.qml

import QtQuick
import Quickshell
import org.kde.kirigami as Kirigami

PersistentProperties {
    id: root

    property string themeName: "BaseTheme"

    // --- SOURCE PROPERTIES (for overriding in custom themes) ---
    // These are the actual values. Custom themes will override these.
    // The underscore is a convention to indicate these are the 'backing' properties.
    property real _alpha: 1

    // --------------------
    // ------ Colors ------
    // --------------------
    property color _primary: Kirigami.Theme.highlightColor
    property color _onPrimary: Kirigami.Theme.highlightedTextColor

    property color _secondary: Kirigami.Theme.textColor
    property color _onSecondary: Kirigami.Theme.textColor

    property color _tertiary: "#bd93f9"
    property color _onTertiary: "#ffffff"

    property color _error: Kirigami.Theme.negativeTextColor
    property color _onError: "#ffffff"

    property color _success: Kirigami.Theme.positiveTextColor
    property color _onSuccess: "#ffffff"

    property color _warning: "#ffb86c"
    property color _onWarning: "#ffffff"

    // topbar
    // TODO: -> these colors must be changed to a better way, maybe follow m3 naming
    property color _topbarColor: Kirigami.Theme.backgroundColor
    property color _topbarFgColor: Kirigami.Theme.textColor

    property color _topbarBgColorV1: Kirigami.Theme.backgroundColor.lighter(1.5)
    property color _topbarBgColorV2: Kirigami.Theme.negativeBackgroundColor
    property color _topbarBgColorV3: Kirigami.Theme.neutralBackgroundColor
    property color _topbarFgColorV1: Kirigami.Theme.textColor
    property color _topbarFgColorV2: Kirigami.Theme.textColor
    property color _topbarFgColorV3: Kirigami.Theme.textColor

    // Left Menu
    property color _leftMenuBgColorV1: Kirigami.Theme.backgroundColor
    property color _leftMenuBgColorV2: _themeMode === "dark" ? Kirigami.Theme.backgroundColor.lighter(1.5) : Kirigami.Theme.backgroundColor.darker(1.1)
    property color _leftMenuBgColorV3: Kirigami.Theme.highlightColor.alpha(0.6)
    property color _leftMenuFgColorV1: Kirigami.Theme.textColor
    property color _leftMenuFgColorV2: Kirigami.Theme.textColor
    property color _leftMenuFgColorV3: Kirigami.Theme.highlightedTextColor

    property color _subtleTextColor: Kirigami.Theme.textColor.alpha(0.6)

    // OSDs
    property color _volOsdBgColor: Kirigami.Theme.backgroundColor.lighter(1.5)
    property color _volOsdFgColor: Kirigami.Theme.textColor

    // --------------------
    // ---- Dimensions ----
    // --------------------
    property int _baseRadius: 12
    property int _barHeight: 30
    property int _leftBarWidth: 40
    property int _barBottomMargin: 10
    property int _barWidgetsHeight: 22
    property int _menuHeight: 900
    property int _menuWidth: 380
    property int _menuWidgetsMargin: 15
    property int _elementRadius: root._baseRadius // Reference the source property

    property int _spacingSmall: 4
    property int _spacingMedium: 8
    property int _spacingLarge: 12

    // --------------------
    // ---- Typography ----
    // --------------------
    property string _iconFont: "FantasqueSansM Nerd Font Propo"
    property string _bodyFont: "JF Flat"
    property int _baseFontSize: 12
    property int _heading1Size: 22
    property int _heading2Size: 20
    property int _heading3Size: 18
    property int _heading4Size: 16
    property int _mediumFontSize: 14
    property int _smallFontSize: 12

    // ------------------------
    // -- System Integration --
    // ------------------------
    property bool _enableAccentColoring: false
    property string _qtThemeStyle: "Breeze"
    property string _plasmaColorScheme: "MaterialYouDark"
    property string _kvantumTheme: "KvGnome"
    property string _konsoleProfile: "MaterialYouAlt.profile"

    property string _gtkTheme: "Breeze"
    property string _themeMode: "dark"

    property string _themeIcons: "breeze-dark"

    // -------------------------
    // -- Wallpapers Settings --
    // -------------------------
    property string _wallpaper: "linux.png"
    property bool _enableDynamicColoring: false
    property bool _enableWallpaperBlur: false
    property real _wallpaperBlurStrength: 0.9

    property int _dynamicColoringSchemeVariant: 2
    property real _dynamicColoringChromaMult: 2.5
    property real _dynamicColoringToneMult: 1

    property bool _enableDynamicWallpapers: false
    property int _dynamicWallpapersInterval: 15 * 1000 * 60
    property string _dynamicWallpapersPath: ""
    property int _selectedWallpaperIndex: 0

    // ===================================
    // Hyprland Properties
    // ===================================
    // Decoration
    property int _hyprBorderWidth: 2
    property string _hyprActiveBorder: 'rgba(FDEAB0ff) rgba(fd77e0ff) 45deg'
    property string _hyprInactiveBorder: 'rgba(50505088)'
    property int _hyprRounding: 16
    property string _hyprDropShadow: 'no' // إعداداتك معطلة، لذا 'no' هو الافتراضي

    // Gaps & Layout
    property int _hyprGapsIn: 5
    property string _hyprGapsOut: "12, 15, 15, 52"
    property string _hyprLayout: "dwindle"

    // Animations
    property bool _hyprAnimationsEnabled: true
    property string _hyprBezier: "decel, 0.05, 0.7, 0.1, 1"
    property string _hyprAnimWindows: "1, 5, decel, slidefade 18%"
    property string _hyprAnimWorkspaces: "1, 3, md_standard, slidefade 8%"

    // Visual Effects (Blur & Dim)
    property bool _hyprBlurEnabled: true
    property int _hyprBlurSize: 4
    property int _hyprBlurPasses: 2
    property bool _hyprDimInactive: true
    property double _hyprDimStrength: 0.0

    // Shadow Enhancements
    property int _hyprShadowRange: 30
    property point _hyprShadowOffset: Qt.point(0, 0) // لا يوجد إزاحة في إعداداتك
    property color _hyprShadowColor: "#00000044"

    // ----------------------------
    // --- Desktop Clock Widget ---
    // ----------------------------
    property bool _desktopClockEnabled: true
    property bool _desktopClockSahdowEnabled: false
    property color _desktopClockSahdowColor: "#40000000"
    property color _desktopClockColor: _primary
    property bool _desktopClockUseThemeColor: true
    property bool _desktopClockUseAnimation: false
    property string _desktopClockLocal: "en_US"
    property string _desktopClockFormat: "hh:mm AP"
    property string _desktopClockFont: _bodyFont
    property point _desktopClockPosition: Qt.point(100, 100)

    // Depth Effect Settings
    property bool _desktopClockDepthEffectEnabled: false
    property string _desktopClockDepthModel: "u2net" // isnet-general-use
    property string _desktopClockDepthOverlayPath
    property size _desktopClockSize: Qt.size(701, 501)

    // ======================================================================
    // --- PUBLIC GROUPED API (for using the theme) ---
    // These structured objects are for clean access (e.g., theme.colors.xyz).
    // They are readonly to prevent accidental replacement.
    // ======================================================================

    // --- Color Palette ---

    readonly property var colors: QtObject {
        // General
        property color primary: Qt.rgba(root._primary.r, root._primary.g, root._primary.b, root._alpha)
        property color secondary: Qt.rgba(root._secondary.r, root._secondary.g, root._secondary.b, root._alpha)
        // property color onPrimary: Qt.rgba(root._onPrimary.r, root._onPrimary.g, root._onPrimary.b, root._alpha)
        property alias onPrimary: root._onPrimary
        // property color onPrimary: {
        //     color = Helper.getAccurteTextColor(root._primary);
        //     console.info(color);
        //     return color;
        // }
        property alias onSecondary: root._onSecondary

        property color tertiary: Qt.rgba(root._tertiary.r, root._tertiary.g, root._tertiary.b, root._alpha)
        property alias onTertiary: root._onTertiary

        property color error: Qt.rgba(root._error.r, root._error.g, root._error.b, root._alpha)
        property alias onError: root._onError

        property color success: Qt.rgba(root._success.r, root._success.g, root._success.b, root._alpha)
        property alias onSuccess: root._onSuccess

        property color warning: Qt.rgba(root._warning.r, root._warning.g, root._warning.b, root._alpha)
        property alias onWarning: root._onWarning

        // Top Bar
        property color topbarColor: Qt.rgba(root._topbarColor.r, root._topbarColor.g, root._topbarColor.b, root._alpha)
        property color topbarFgColor: Qt.rgba(root._topbarFgColor.r, root._topbarFgColor.g, root._topbarFgColor.b, root._alpha)

        property color topbarBgColorV1: Qt.rgba(root._topbarBgColorV1.r, root._topbarBgColorV1.g, root._topbarBgColorV1.b, root._alpha)
        property color topbarBgColorV2: Qt.rgba(root._topbarBgColorV2.r, root._topbarBgColorV2.g, root._topbarBgColorV2.b, root._alpha)
        property color topbarBgColorV3: Qt.rgba(root._topbarBgColorV3.r, root._topbarBgColorV3.g, root._topbarBgColorV3.b, root._alpha)

        property color topbarFgColorV1: Qt.rgba(root._topbarFgColorV1.r, root._topbarFgColorV1.g, root._topbarFgColorV1.b, 1)
        property color topbarFgColorV2: Qt.rgba(root._topbarFgColorV2.r, root._topbarFgColorV2.g, root._topbarFgColorV2.b, 1)
        property color topbarFgColorV3: Qt.rgba(root._topbarFgColorV3.r, root._topbarFgColorV3.g, root._topbarFgColorV3.b, 1)

        // Left Menu
        property color leftMenuBgColorV1: Qt.rgba(root._leftMenuBgColorV1.r, root._leftMenuBgColorV1.g, root._leftMenuBgColorV1.b, root._alpha)
        property color leftMenuBgColorV2: Qt.rgba(root._leftMenuBgColorV2.r, root._leftMenuBgColorV2.g, root._leftMenuBgColorV2.b, root._alpha)
        property color leftMenuBgColorV3: Qt.rgba(root._leftMenuBgColorV3.r, root._leftMenuBgColorV3.g, root._leftMenuBgColorV3.b, root._alpha)

        property color leftMenuFgColorV1: Qt.rgba(root._leftMenuFgColorV1.r, root._leftMenuFgColorV1.g, root._leftMenuFgColorV1.b, 1)
        property color leftMenuFgColorV2: Qt.rgba(root._leftMenuFgColorV2.r, root._leftMenuFgColorV2.g, root._leftMenuFgColorV2.b, 1)
        property color leftMenuFgColorV3: Qt.rgba(root._leftMenuFgColorV3.r, root._leftMenuFgColorV3.g, root._leftMenuFgColorV3.b, 1)

        property color volOsdBgColor: Qt.rgba(root._volOsdBgColor.r, root._volOsdBgColor.g, root._volOsdBgColor.b, root._alpha)
        property color volOsdFgColor: Qt.rgba(root._volOsdFgColor.r, root._volOsdFgColor.g, root._volOsdFgColor.b, 1)

        property color subtleText: Qt.rgba(root._subtleTextColor.r, root._subtleTextColor.g, root._subtleTextColor.b, root._alpha)
    }

    // --- Dimensions and Spacing ---
    readonly property var dimensions: QtObject {
        property alias baseRadius: root._baseRadius
        property alias barHeight: root._barHeight
        property alias leftBarWidth: root._leftBarWidth
        property alias barBottomMargin: root._barBottomMargin
        property alias barWidgetsHeight: root._barWidgetsHeight
        property alias menuHeight: root._menuHeight
        property alias menuWidth: root._menuWidth
        property alias menuWidgetsMargin: root._menuWidgetsMargin
        property alias elementRadius: root._elementRadius

        property alias spacingSmall: root._spacingSmall
        property alias spacingMedium: root._spacingMedium
        property alias spacingLarge: root._spacingLarge
    }

    // --- Typography ---
    readonly property var typography: QtObject {
        property alias iconFont: root._iconFont
        property alias bodyFont: root._bodyFont
        property alias heading1Size: root._heading1Size
        property alias heading2Size: root._heading2Size
        property alias heading3Size: root._heading3Size
        property alias heading4Size: root._heading4Size
        property alias baseFontSize: root._baseFontSize
        property alias medium: root._mediumFontSize
        property alias small: root._smallFontSize

        property alias spacingSmall: root._spacingSmall
        property alias spacingMedium: root._spacingMedium
        property alias spacingLarge: root._spacingLarge
    }

    // --- System Integration Settings ---
    readonly property var systemSettings: QtObject {
        property alias wallpaper: root._wallpaper
        property alias qtThemeStyle: root._qtThemeStyle
        property alias kvantumTheme: root._kvantumTheme
        property alias gtkTheme: root._gtkTheme
        property alias themeIcons: root._themeIcons
        property alias themeMode: root._themeMode
        property alias plasmaColorScheme: root._plasmaColorScheme
        property alias konsoleProfile: root._konsoleProfile
        property alias fontName: root._bodyFont

        property alias enableAccentColoring: root._enableAccentColoring
        property alias enableDynamicColoring: root._enableDynamicColoring
        property alias enableWallpaperBlur: root._enableWallpaperBlur
        property alias wallpaperBlurStrength: root._wallpaperBlurStrength
        property alias enableDynamicWallpapers: root._enableDynamicWallpapers
        property alias dynamicWallpapersInterval: root._dynamicWallpapersInterval
        property alias dynamicWallpapersPath: root._dynamicWallpapersPath
        property alias selectedWallpaperIndex: root._selectedWallpaperIndex

        property alias dynamicColoringSchemeVariant: root._dynamicColoringSchemeVariant
        property alias dynamicColoringChromaMult: root._dynamicColoringChromaMult
        property alias dynamicColoringToneMult: root._dynamicColoringToneMult
    }

    // --- Hyprland Configuration ---
    readonly property var hyprlandConfiguration: QtObject {
        // --- Decoration ---
        property alias borderWidth: root._hyprBorderWidth
        property alias activeBorder: root._hyprActiveBorder
        property alias inactiveBorder: root._hyprInactiveBorder
        property alias rounding: root._hyprRounding
        property alias dropShadow: root._hyprDropShadow

        // --- Gaps & Layout ---
        property alias gapsIn: root._hyprGapsIn
        property alias gapsOut: root._hyprGapsOut
        property alias layout: root._hyprLayout

        // --- Animations ---
        property alias animationsEnabled: root._hyprAnimationsEnabled
        property alias bezier: root._hyprBezier
        property alias animWindows: root._hyprAnimWindows
        property alias animWorkspaces: root._hyprAnimWorkspaces

        // --- Visual Effects ---
        property alias blurEnabled: root._hyprBlurEnabled
        property alias blurSize: root._hyprBlurSize
        property alias blurPasses: root._hyprBlurPasses
        property alias dimInactive: root._hyprDimInactive
        property alias dimStrength: root._hyprDimStrength

        // --- Shadow Enhancements ---
        property alias shadowRange: root._hyprShadowRange
        property alias shadowOffset: root._hyprShadowOffset
        property alias shadowColor: root._hyprShadowColor
    }

    // --- Desktop Clock Widget Configuration ---
    readonly property var desktopClock: QtObject {
        property alias enabled: root._desktopClockEnabled
        property alias shadowEnabled: root._desktopClockSahdowEnabled
        property alias shadowColor: root._desktopClockSahdowColor
        property alias color: root._desktopClockColor
        property alias useThemeColor: root._desktopClockUseThemeColor
        property alias enableAnimation: root._desktopClockUseAnimation
        property alias local: root._desktopClockLocal
        property alias format: root._desktopClockFormat
        property alias font: root._desktopClockFont
        property alias position: root._desktopClockPosition
        property alias size: root._desktopClockSize

        // Depth Effect
        property alias depthEffectEnabled: root._desktopClockDepthEffectEnabled
        property alias depthModel: root._desktopClockDepthModel
        property alias depthOverlayPath: root._desktopClockDepthOverlayPath
    }
}
