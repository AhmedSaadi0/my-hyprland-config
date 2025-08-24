import Quickshell
import QtQuick

import "root:/themes"
import "root:/components"

Rectangle {
    id: clockBackground
    height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    width: clockText.width + 20
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: ThemeManager.selectedTheme.colors.primary
        }
        GradientStop {
            position: 1.0
            color: ThemeManager.selectedTheme.colors.secondary
        }
    }

    anchors.centerIn: parent
    // layer.enabled: true
    // layer.effect: Shadow {
    //     color: ThemeManager.selectedTheme.colors.topbarColor
    // }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockText
        text: clock.date.toLocaleString(Qt.locale(), "hh:mm AP - dddd, dd MMMM yyyy")
        font.bold: true
        anchors.centerIn: parent
        color: ThemeManager.selectedTheme.colors.onPrimary
    }
}
