import QtQuick

import "../"

TopbarCircularProgress {
    id: cpuUsage
    icon: ""
    command: ["sh", "-c", "~/.config/quickshell/scripts/cpu_usage.sh"]
    iconFontSize: 10
}
