// components/monitors/Ram.qml

import QtQuick
import org.kde.kirigami as Kirigami

import "root:/components"
import "root:/config"

TopbarCircularProgress {
    id: cpuUsage
    // command: ["sh", "-c", "~/.config/quickshell/scripts/ram_usage.sh"]
    command: App.scripts.bash.ramCommand
    updateInterval: 1000 * 20

    icon: ""
    iconColor: Kirigami.Theme.positiveTextColor
    iconFontSize: 10

    backgroundColor: Kirigami.Theme.positiveTextColor.alpha(0.4)
    foregroundColor: Kirigami.Theme.positiveTextColor
}
