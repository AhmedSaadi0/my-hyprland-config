import QtQuick

import "root:/components"
import "root:/services"
import "root:/themes"

TopbarCircularProgress {
    id: ramUsage

    activeProcess: false

    value: SystemService.ramUsage

    icon: ""
    iconFontSize: 10

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.secondary
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.warning
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.warning.alpha(0.4)

    iconColor: SystemService.isRamHigh ? fgWarning : fgNormal
    foregroundColor: SystemService.isRamHigh ? fgWarning : fgNormal
    backgroundColor: SystemService.isRamHigh ? bgWarning : bgNormal
}
