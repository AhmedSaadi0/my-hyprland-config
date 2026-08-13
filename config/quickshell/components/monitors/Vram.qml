// components/monitors/Vram.qml

import QtQuick

import "root:/components"
import "root:/services"
import "root:/themes"

TopbarCircularProgress {
    id: vramUsage

    activeProcess: false

    value: SystemService.vramUsage

    icon: "󰑹"
    iconFontSize: 10

    readonly property color fgNormal: ThemeManager.selectedTheme.colors.outline
    readonly property color bgNormal: ThemeManager.selectedTheme.colors.outline.alpha(0.4)
    readonly property color fgWarning: ThemeManager.selectedTheme.colors.secondary
    readonly property color bgWarning: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)

    iconColor: fgNormal
    foregroundColor: fgNormal
    backgroundColor: bgNormal
}
