// components/monitors/Tempreture.qml

import QtQuick

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/services"

TopbarCircularProgress {
    id: tempUsage
    icon: ""
    activeProcess: false
    value: SystemService.cpuMaxTemp / 100.0

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.tertiary
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.tertiary.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.secondary
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)

    iconColor: fgNormal
    foregroundColor: fgNormal
    backgroundColor: bgNormal
}
