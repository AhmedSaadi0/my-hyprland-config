import QtQuick

import "../../../components"

TopbarCircularProgress {
    id: cpuUsage
    icon: ""
    command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    iconFontSize: 10
}
