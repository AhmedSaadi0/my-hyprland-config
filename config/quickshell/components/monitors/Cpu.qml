// components/monitors/Cpu.qml

import QtQuick
import org.kde.kirigami as Kirigami

import "root:/components"
import "root:/config"

TopbarCircularProgress {
    id: cpuUsage
    icon: ""
    // command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    command: App.scripts.bash.cpuCommand
    iconFontSize: 10
    iconColor: Kirigami.Theme.negativeTextColor
    backgroundColor: Kirigami.Theme.negativeTextColor.alpha(0.5)
    foregroundColor: Kirigami.Theme.negativeTextColor
}
