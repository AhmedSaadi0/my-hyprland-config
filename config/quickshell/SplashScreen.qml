import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import org.kde.kirigami as Kirigami
import "root:/config"

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "NibrasShell:splash"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // --- 1. الخلفية تعتمد على لون الثيم ---
    Rectangle {
        id: background
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
                }
            }
        }
    }

    // --- 2. الإضاءة الخلفية (Ambient Glow) ---
    Rectangle {
        width: Math.min(parent.width, parent.height) * 0.6
        height: width
        anchors.centerIn: parent
        radius: width / 2
        color: Kirigami.Theme.highlightColor
        opacity: 0.1

        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation {
                to: 1.1
                duration: 4000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: 1.0
                duration: 4000
                easing.type: Easing.InOutSine
            }
        }
    }

    // --- 3. المحتوى ---
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30

        // الأيقونة
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 80
            height: 80

            Kirigami.Icon {
                anchors.fill: parent
                source: App.assets.logo
                color: Kirigami.Theme.textColor
            }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 1.1
                    duration: 1500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // النصوص
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Text {
                text: "NIBRAS SHELL"
                anchors.horizontalCenter: parent.horizontalCenter
                color: Kirigami.Theme.textColor
                font.pixelSize: 36
                font.bold: true
                font.letterSpacing: 4
                font.family: Kirigami.Theme.defaultFont.family
            }

            Text {
                text: "Initializing Environment..."
                anchors.horizontalCenter: parent.horizontalCenter
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: 14
                font.letterSpacing: 1
                font.family: Kirigami.Theme.defaultFont.family
            }
        }

        // شريط التحميل
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            width: 300
            height: 4

            Rectangle {
                anchors.fill: parent
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 2
            }

            // الشريط المتقدم
            Rectangle {
                height: parent.height
                width: 0
                radius: 2

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: Kirigami.Theme.highlightColor
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.lighter(Kirigami.Theme.highlightColor, 1.4)
                    }
                }

                NumberAnimation on width {
                    from: 0
                    to: 300
                    duration: 2500
                    easing.type: Easing.OutExpo
                }
            }
        }
    }

    // أنيميشن الظهور
    Component.onCompleted: introAnim.start()
    NumberAnimation {
        id: introAnim
        target: root
        property: "opacity"
        to: 1
        duration: 800
        easing.type: Easing.OutQuad
    }
}
