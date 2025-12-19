import QtQuick
import org.kde.kirigami as Kirigami
import "root:/components"
import "root:/services"

TopbarCircularProgress {
    id: cpuUsage

    activeProcess: false

    value: SystemService.cpuUsage

    icon: ""
    iconFontSize: 10

    iconColor: SystemService.isCpuHigh ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
    foregroundColor: SystemService.isCpuHigh ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
    backgroundColor: SystemService.isCpuHigh ? Kirigami.Theme.negativeTextColor.alpha(0.5) : Kirigami.Theme.positiveTextColor.alpha(0.2)
}
