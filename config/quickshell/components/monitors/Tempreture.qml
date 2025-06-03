import QtQuick
import org.kde.kirigami as Kirigami
import "../"

TopbarCircularProgress {
    id: tempUsage
    icon: ""
    command: ["sh", "-c", "~/.config/quickshell/scripts/temp.sh"]
    updateInterval: 1000 * 10
    iconColor: Kirigami.Theme.neutralTextColor
    backgroundColor: Kirigami.Theme.neutralTextColor.alpha(0.5)
    foregroundColor: Kirigami.Theme.neutralTextColor
}
