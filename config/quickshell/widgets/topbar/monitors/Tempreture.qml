import QtQuick
import org.kde.kirigami as Kirigami
import "../../../components"

TopbarCircularProgress {
    id: tempUsage
    icon: ""
    command: ["sh", "-c", "~/.config/quickshell/scripts/temp.sh"]
    updateInterval: 1000 * 10
    textColor: Kirigami.Theme.neutralTextColor
    backgroundColor: Kirigami.Theme.neutralTextColor.alpha(0.3)
    foregroundColor: Kirigami.Theme.neutralTextColor
}
