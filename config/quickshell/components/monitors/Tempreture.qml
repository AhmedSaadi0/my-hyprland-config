// components/monitors/Tempreture.qml

import QtQuick

import "root:/components"
import "root:/config"
import "root:/themes"

TopbarCircularProgress {
    id: tempUsage
    icon: ""
    command: App.scripts.bash.deviceTempretureCommand
    updateInterval: 1000 * 10

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.tertiary
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.tertiary.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.warning
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.warning.alpha(0.4)

    iconColor: fgNormal
    foregroundColor: fgNormal
    backgroundColor: bgNormal
}
