// windows/leftwindow/monitoring/Progresses.qml

import QtQuick
import QtQuick.Layouts

import "root:/components/monitors" // For Tempreture, Battery, Ram, Cpu
import "root:/themes"

import "root:/config/EventNames.js" as Events
import "root:/config"

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
        Tempreture {
            id: tempProgress
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        }
    }
    Component {
        id: batComponent
        Battery {
            glowIcon: false
            iconColor: ThemeManager.selectedTheme.colors.primary
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
            backgroundColor: ThemeManager.selectedTheme.colors.primary.alpha(0.2)
            foregroundColor: ThemeManager.selectedTheme.colors.primary
        }
    }
    Component {
        id: ramComponent
        Ram {
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        }
    }
    Component {
        id: cpuComponent
        Cpu {
            iconFontFamily: ThemeManager.selectedTheme.typography.iconFont
        }
    }

    RowLayout {
        id: mainLayout
        anchors {
            fill: parent
            margins: ThemeManager.selectedTheme.dimensions.smallPadding || 5 // Padding inside the root rectangle
        }
        spacing: ThemeManager.selectedTheme.dimensions.smallSpacing || 5         // Spacing between each MonitorWidget

        MonitorWidget {
            id: tempWidget
            Layout.fillWidth: true // Make each MonitorWidget take equal share of width
            title: qsTr("Temp") // Shorter title if space is tight
            // valueText: "100%" // Default is "100%", can be overridden or updated dynamically
            monitorComponent: tempComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }

        MonitorWidget {
            Layout.fillWidth: true
            title: qsTr("Battery")
            monitorComponent: batComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }

        MonitorWidget {
            Layout.fillWidth: true
            title: qsTr("RAM")
            monitorComponent: ramComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }

        MonitorWidget {
            Layout.fillWidth: true
            title: qsTr("CPU")
            monitorComponent: cpuComponent
            monitorItemWidth: root.monitorWidth
            monitorItemHeight: root.monitorHeight
            monitorItemThickness: root.monitorItemThickness
            monitorItemIconFontSize: root.monitorItemIconFontSize
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, function () {
            root.menuIsOpened();
        });

        EventBus.on(Events.LEFT_MENU_IS_CLOSED, function () {
            root.menuIsClosed();
        });
    }

    function menuIsOpened() {
        if (!tempComponent.constructor.running) {
            tempComponent.constructor.running = true;
            batComponent.constructor.running = true;
            ramComponent.constructor.running = true;
            cpuComponent.constructor.running = true;
            console.info("Start Menu progresses");
        }
    }

    function menuIsClosed() {
        if (!tempComponent.constructor.running) {
            tempComponent.constructor.running = false;
            batComponent.constructor.running = false;
            ramComponent.constructor.running = false;
            cpuComponent.constructor.running = false;
            console.info("Stop Menu progresses");
        }
    }
}
