// windows/smart_capsule/components/WeatherIcon.qml
import QtQuick
import "root:/themes"
import "root:/services"

Item {
    id: root

    property color contentColor: ThemeManager.selectedTheme.colors.onSurface

    implicitWidth: 30
    implicitHeight: 24

    Text {
        anchors.centerIn: parent

        text: (Weather && Weather.weatherIcon !== "") ? Weather.weatherIcon : "☁"

        font.family: ThemeManager.selectedTheme.typography.iconFont
        font.pixelSize: 18

        color: root.contentColor
    }
}
