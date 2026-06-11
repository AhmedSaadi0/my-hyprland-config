import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import org.kde.kirigami as Kirigami
import "root:/config"
import "root:/themes"

PanelWindow {
    id: root

    color: "transparent"

    readonly property var theme: ThemeManager.selectedTheme
    readonly property bool hasTheme: theme !== null

    property bool active: true // يتم التحكم بها من ملف shell.qml

    readonly property color backgroundColor: hasTheme ? theme.colors.surface : "#0f0f0f"
    readonly property color foregroundColor: hasTheme ? theme.colors.onSurface : "#ffffff"
    readonly property color subtleColor: hasTheme ? theme.colors.onSurfaceVariant : "#a0a0a0"
    readonly property color primaryColor: hasTheme ? theme.colors.primary : "#007aff"
    readonly property string bodyFont: hasTheme ? theme.typography.bodyFont : "sans-serif"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "NibrasShell:splash"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Item {
        id: mainContainer
        anchors.fill: parent

        // --- نظام الحالات (States) والانتقالات (Transitions) على مستوى الحاوية الداخلية ---
        state: (root.hasTheme && root.active) ? "visible" : "hidden"

        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: background
                    opacity: 0.0
                }
                PropertyChanges {
                    target: auroraContainer
                    opacity: 0.0
                }
                PropertyChanges {
                    target: logoGroup
                    opacity: 0.0
                    scale: 0.7
                }
                PropertyChanges {
                    target: textContainer
                    opacity: 0.0
                    yOffset: 20
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: background
                    opacity: 1.0
                }
                PropertyChanges {
                    target: auroraContainer
                    opacity: 1.0
                }
                PropertyChanges {
                    target: logoGroup
                    opacity: 1.0
                    scale: 1.0
                }
                PropertyChanges {
                    target: textContainer
                    opacity: 1.0
                    yOffset: 0.0
                }
            }
        ]

        transitions: [
            // أنميشن ظهور العناصر (حركة الدخول الدائرية والمنزلقة)
            Transition {
                from: "hidden"
                to: "visible"
                ParallelAnimation {
                    NumberAnimation {
                        target: background
                        property: "opacity"
                        duration: 800
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: auroraContainer
                        property: "opacity"
                        duration: 1000
                        easing.type: Easing.OutQuad
                    }

                    SequentialAnimation {
                        PauseAnimation {
                            duration: 100
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: logoGroup
                                property: "opacity"
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: logoGroup
                                property: "scale"
                                duration: 1000
                                easing.type: Easing.OutBack
                            }
                        }
                    }

                    SequentialAnimation {
                        PauseAnimation {
                            duration: 350
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: textContainer
                                property: "opacity"
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: textContainer
                                property: "yOffset"
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            },
            // أنميشن إخفاء العناصر وتلاشيها (حركة الخروج)
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: background
                            property: "opacity"
                            duration: 600
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: auroraContainer
                            property: "opacity"
                            duration: 600
                            easing.type: Easing.OutQuad
                        }

                        NumberAnimation {
                            target: logoGroup
                            property: "opacity"
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: logoGroup
                            property: "scale"
                            duration: 500
                            easing.type: Easing.OutQuad
                        }

                        NumberAnimation {
                            target: textContainer
                            property: "opacity"
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: textContainer
                            property: "yOffset"
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                    }
                    // إخفاء نافذة النظام كلياً بعد انتهاء حركات التلاشي بالكامل
                    ScriptAction {
                        script: {
                            root.visible = false;
                        }
                    }
                }
            }
        ]

        // --- 1. الخلفية العميقة ---
        Rectangle {
            id: background
            anchors.fill: parent
            color: root.backgroundColor
            opacity: 0.0

            Image {
                anchors.fill: parent
                source: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAIklEQVQIW2NkQAKrVq36zwjjgzhhYWGMYAEYB8RmROaABADeOQ8CXl/xfgAAAABJRU5ErkJggg=="
                fillMode: Image.Tile
                opacity: 0.03
            }
        }

        // --- 2. أضواء الأورورا المتحركة ---
        Item {
            id: auroraContainer
            anchors.fill: parent
            opacity: 0.0

            Rectangle {
                id: light1
                width: auroraContainer.width * 0.8
                height: width
                radius: width / 2
                x: -width * 0.2
                y: -height * 0.2

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.12)
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    running: root.hasTheme && root.active
                    NumberAnimation {
                        to: 0
                        duration: 9000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: -auroraContainer.width * 0.2
                        duration: 9000
                        easing.type: Easing.InOutSine
                    }
                }
            }

            Rectangle {
                id: light2
                width: auroraContainer.width * 0.7
                height: width
                radius: width / 2
                x: auroraContainer.width - width * 0.8
                y: auroraContainer.height - height * 0.8

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(root.subtleColor.r, root.subtleColor.g, root.subtleColor.b, 0.08)
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    running: root.hasTheme && root.active
                    NumberAnimation {
                        to: auroraContainer.height - auroraContainer.height * 0.9
                        duration: 11000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: auroraContainer.height - auroraContainer.height * 0.8
                        duration: 11000
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }

        // --- 3. محتويات الواجهة العائمة ---
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24

            // الشعار والنبضات
            Item {
                id: logoGroup
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.0
                scale: 0.7

                Repeater {
                    model: 3
                    Rectangle {
                        id: rippleCircle
                        anchors.centerIn: parent
                        width: 96
                        height: 96
                        radius: width / 2
                        color: "transparent"
                        border.color: root.primaryColor
                        border.width: 1.5
                        opacity: 0

                        SequentialAnimation {
                            running: root.hasTheme && root.active
                            loops: Animation.Infinite
                            PauseAnimation {
                                duration: index * 700
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: rippleCircle
                                    property: "width"
                                    from: 96
                                    to: 240
                                    duration: 2800
                                    easing.type: Easing.OutQuad
                                }
                                NumberAnimation {
                                    target: rippleCircle
                                    property: "height"
                                    from: 96
                                    to: 240
                                    duration: 2800
                                    easing.type: Easing.OutQuad
                                }
                                NumberAnimation {
                                    target: rippleCircle
                                    property: "opacity"
                                    from: 0.5
                                    to: 0
                                    duration: 2800
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 96
                    height: 96
                    radius: width / 2
                    color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g, root.backgroundColor.b, 0.8)
                    border.color: Qt.rgba(root.foregroundColor.r, root.foregroundColor.g, root.foregroundColor.b, 0.12)
                    border.width: 1
                    anchors.centerIn: parent

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        source: App.assets.logo
                        color: root.foregroundColor
                    }
                }
            }

            // النصوص والعناوين
            Column {
                id: textContainer
                Layout.alignment: Qt.AlignHCenter
                spacing: 12
                opacity: 0.0

                property real yOffset: 20
                transform: Translate {
                    y: textContainer.yOffset
                }

                Item {
                    width: mainText.implicitWidth
                    height: mainText.implicitHeight
                    anchors.horizontalCenter: parent.horizontalCenter

                    // النص الأساسي
                    Text {
                        id: mainText
                        text: "NIBRAS SHELL"
                        anchors.centerIn: parent
                        color: root.foregroundColor
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        font.letterSpacing: 8
                        font.family: root.bodyFont
                    }
                }

                Text {
                    id: statusText
                    text: "BOOT SEQUENCE INITIATED"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.primaryColor
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 3
                    font.family: root.bodyFont
                    opacity: 0.8

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.hasTheme && root.active
                        NumberAnimation {
                            to: 0.3
                            duration: 1800
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 0.8
                            duration: 1800
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }
        }
    }
}
