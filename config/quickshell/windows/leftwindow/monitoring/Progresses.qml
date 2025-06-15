// windows/leftwindow/monitoring/Progresses.qml
// import QtQuick.Effects
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "../../../components/monitors" // For Tempreture, Battery, Ram, Cpu
// import "../../../components" // For Tempreture, Battery, Ram, Cpu
import "../../../themes"

Rectangle {
    id: root
    height: 150
    width: ThemeManager.selectedTheme.dimensions.menuWidth - (ThemeManager.selectedTheme.dimensions.menuWidgetsMargin * 2)
    radius: ThemeManager.selectedTheme.dimensions.elementRadius
    // color: Kirigami.Theme.linkBackgroundColor

    color: ThemeManager.selectedTheme.colors.topbarBgColorV2

    property int monitorWidth: 65
    property int monitorHeight: 65
    property int monitorItemThickness: root.thickness
    property int monitorItemIconFontSize: root.iconFontSize

    property int thickness: 7
    property int iconFontSize: 24

    // layer.enabled: true
    // layer.smooth: true
    // layer.effect: Shadow {}

    // ShaderEffect {
    //     width: 200
    //     height: 100
    //     // fragmentShader: "
    //     // varying highp vec2 qt_TexCoord0;
    //     // void main() {
    //     //     // Simple shadow simulation (darken background)
    //     //     gl_FragColor = vec4(0, 0, 0, 0.3);
    //     // }"
    // }

    // MultiEffect {
    //     source: root
    //     anchors.fill: root
    //     autoPaddingEnabled: false
    //     paddingRect: Qt.rect(0, 10 * (-1), 100, 100)
    //     shadowBlur: 1.0
    //     shadowColor: 'black'
    //     shadowEnabled: true
    //     shadowVerticalOffset: 10
    // }

    // Define the components to be loaded by MonitorWidget
    Component {
        id: tempComponent
        Tempreture {}
    }
    Component {
        id: batComponent
        Battery {}
    }
    Component {
        id: ramComponent
        Ram {}
    }
    Component {
        id: cpuComponent
        Cpu {}
    }

    RowLayout {
        id: mainLayout
        anchors {
            fill: parent
            margins: ThemeManager.selectedTheme.dimensions.smallPadding || 5 // Padding inside the root rectangle
        }
        spacing: ThemeManager.selectedTheme.dimensions.smallSpacing || 5         // Spacing between each MonitorWidget

        MonitorWidget {
            Layout.fillWidth: true // Make each MonitorWidget take equal share of width
            title: "Temp" // Shorter title if space is tight
            // valueText: "100%" // Default is "100%", can be overridden or updated dynamically
            monitorComponent: tempComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }

        MonitorWidget {
            Layout.fillWidth: true
            title: "Battery"
            monitorComponent: batComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }

        MonitorWidget {
            Layout.fillWidth: true
            title: "RAM"
            monitorComponent: ramComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }

        MonitorWidget {
            Layout.fillWidth: true
            title: "CPU"
            monitorComponent: cpuComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }
    }
}
