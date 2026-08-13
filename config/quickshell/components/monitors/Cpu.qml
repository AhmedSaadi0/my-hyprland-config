import QtQuick
import "root:/components"
import "root:/services"
import "root:/themes"

TopbarCircularProgress {
    id: cpuUsage

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.primary
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.primary.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.secondary
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)

    activeProcess: false
    value: SystemService.cpuUsage
    icon: ""
    iconFontSize: 10

    iconColor: SystemService.isRamHigh ? fgWarning : fgNormal
    foregroundColor: SystemService.isRamHigh ? fgWarning : fgNormal
    backgroundColor: SystemService.isRamHigh ? bgWarning : bgNormal
}
