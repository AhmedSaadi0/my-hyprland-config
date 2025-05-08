import QtQuick
import org.kde.kirigami as Kirigami
import "../../../components"

TopbarCircularProgress {
    id: cpuUsage
    command: ["sh", "-c", "~/.config/quickshell/scripts/ram_usage.sh"]
    updateInterval: 1000 * 20

    icon: ""
    iconColor: Kirigami.Theme.positiveTextColor
    iconFontSize: 10

    backgroundColor: Kirigami.Theme.positiveTextColor.alpha(0.4)
    foregroundColor: Kirigami.Theme.positiveTextColor
}
