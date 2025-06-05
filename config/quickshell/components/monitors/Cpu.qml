// components/monitors/Cpu.qml

import QtQuick
import org.kde.kirigami as Kirigami

import "../"

TopbarCircularProgress {
    id: cpuUsage
    icon: ""
    command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    iconFontSize: 10
    iconColor: Kirigami.Theme.negativeTextColor
    backgroundColor: Kirigami.Theme.negativeTextColor.alpha(0.5)
    foregroundColor: Kirigami.Theme.negativeTextColor
}
