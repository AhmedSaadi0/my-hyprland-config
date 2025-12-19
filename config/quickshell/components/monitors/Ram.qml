import QtQuick
import org.kde.kirigami as Kirigami
import "root:/components"
import "root:/services"

TopbarCircularProgress {
    id: ramUsage

    activeProcess: false

    value: SystemService.ramUsage

    icon: ""
    iconFontSize: 10

    iconColor: SystemService.isRamHigh ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
    foregroundColor: SystemService.isRamHigh ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
    backgroundColor: SystemService.isRamHigh ? Kirigami.Theme.negativeTextColor.alpha(0.5) : Kirigami.Theme.positiveTextColor.alpha(0.2)
}
