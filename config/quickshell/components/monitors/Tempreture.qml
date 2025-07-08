// components/monitors/Tempreture.qml

import QtQuick
import org.kde.kirigami as Kirigami

import "root:/components"
import "root:/config"

TopbarCircularProgress {
    id: tempUsage
    icon: ""
    // command: ["sh", "-c", "~/.config/quickshell/scripts/temp.sh"]
    command: App.scripts.bash.deviceTempretureCommand
    updateInterval: 1000 * 10
    iconColor: Kirigami.Theme.neutralTextColor
    backgroundColor: Kirigami.Theme.neutralTextColor.alpha(0.5)
    foregroundColor: Kirigami.Theme.neutralTextColor
}
