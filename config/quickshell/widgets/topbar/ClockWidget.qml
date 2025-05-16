import Quickshell
import QtQuick

import "../../themes"
import "../../components"

Rectangle {
    id: clockBackground
    height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
    width: clockText.width + 20
    radius: ThemeManager.selectedTheme.dimensions.elementRadius

    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: ThemeManager.selectedTheme.colors.textBackgroundColor1
        }
        GradientStop {
            position: 1.0
            color: ThemeManager.selectedTheme.colors.textBackgroundColor2
        }
    }

    anchors.centerIn: parent
    layer.enabled: true
    layer.effect: Shadow {
        color: palette.shadow.alpha(0.3)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockText
        text: clock.date.toLocaleString(Qt.locale(), "hh:mm AP - dddd, dd MMMM yyyy")
        anchors.centerIn: parent
        color: ThemeManager.selectedTheme.colors.textFg
    }
}
