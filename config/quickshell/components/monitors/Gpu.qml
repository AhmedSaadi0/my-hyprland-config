// components/monitors/Gpu.qml

import QtQuick

import "root:/components"
import "root:/services"
import "root:/themes"

TopbarCircularProgress {
    id: gpuUsage

    activeProcess: false

    value: SystemService.gpuUsage

    icon: "󰢮"
    iconFontSize: 10

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.tertiary
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.tertiary.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.secondary
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)

    iconColor: fgNormal
    foregroundColor: fgNormal
    backgroundColor: bgNormal
}
