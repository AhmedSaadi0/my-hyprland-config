import QtQuick
import "root:/components"
import "root:/services"
import "root:/themes"

TopbarCircularProgress {
    id: cpuUsage

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.success
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.success.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.warning
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.warning.alpha(0.4)

    activeProcess: false
    value: SystemService.cpuUsage
    icon: ""
    iconFontSize: 10

    iconColor: SystemService.isRamHigh ? fgWarning : fgNormal
    foregroundColor: SystemService.isRamHigh ? fgWarning : fgNormal
    backgroundColor: SystemService.isRamHigh ? bgWarning : bgNormal
}
