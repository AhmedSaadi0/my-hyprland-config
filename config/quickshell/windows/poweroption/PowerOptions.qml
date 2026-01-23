// windows/poweroption/PowerOptions.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

import "root:/windows/smart_capsule/logic"
import "root:/utils/helpers.js" as Helpers
import "root:/config/ConstValues.js" as C
import "root:/components"
import "root:/themes"

Item {
    id: root
    anchors.fill: parent

    readonly property var theme: ThemeManager.selectedTheme

    property var pendingActionCommand: []
    property string pendingActionMessage: ""
    property string confirmActionText: ""
    property color currentAccentColor: theme.colors.primary

    signal close

    focus: true
    Keys.onEscapePressed: {
        root.close();
    }

    Process {
        id: powerActionProcess
        command: root.pendingActionCommand
        // onExited: exitCode => {
        //     if (exitCode === 0)
        //         root.parent.parent.visible = false;
        // }
        function start() {
            powerActionProcess.running = true;
        }
    }

    // الحاوية الكبرى المتوسطة في الشاشة
    ColumnLayout {
        anchors.centerIn: parent
        spacing: theme.dimensions.spacingLarge * 2
        width: parent.width

        // 1. العنوان والوصف
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: theme.dimensions.spacingSmall

            Text {
                text: viewStack.depth > 1 ? root.pendingActionMessage : qsTr("System Control")
                color: theme.colors.topbarFgColor
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.heading1Size
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: viewStack.depth > 1 ? qsTr("This action cannot be undone") : qsTr("Choose an action to perform")
                color: theme.colors.subtleText
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.7
            }
        }

        // 2. منطقة الأزرار (StackView)
        StackView {
            id: viewStack
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 800 // عرض كافٍ للأزرار
            Layout.preferredHeight: 180
            clip: false

            initialItem: mainActions

            pushEnter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.95
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            popExit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 150
                }
            }
        }
    }

    // --- واجهة الأزرار الرئيسية ---
    Component {
        id: mainActions
        Item {
            // حاوية تملأ الـ StackView
            width: viewStack.width
            height: viewStack.height

            RowLayout {
                anchors.centerIn: parent // توسيط حقيقي داخل الحاوية
                spacing: theme.dimensions.spacingLarge

                PowerTile {
                    icon: "\uf011"
                    label: qsTr("Shut Down")
                    accentColor: theme.colors.error
                    onClicked: {
                        root.currentAccentColor = accentColor;
                        root.pendingActionCommand = ["systemctl", "poweroff"];
                        root.pendingActionMessage = qsTr("Shut Down System?");
                        root.confirmActionText = qsTr("Shut Down");
                        viewStack.push(confirmActions);
                    }
                }

                PowerTile {
                    icon: "\uf01e"
                    label: qsTr("Restart")
                    accentColor: theme.colors.warning
                    onClicked: {
                        root.currentAccentColor = accentColor;
                        root.pendingActionCommand = ["systemctl", "reboot"];
                        root.pendingActionMessage = qsTr("Restart System?");
                        root.confirmActionText = qsTr("Restart");
                        viewStack.push(confirmActions);
                    }
                }

                PowerTile {
                    icon: "\uf186"
                    label: qsTr("Suspend")
                    accentColor: theme.colors.tertiary
                    onClicked: {
                        root.currentAccentColor = accentColor;
                        root.pendingActionCommand = ["systemctl", "suspend"];
                        root.pendingActionMessage = qsTr("Suspend System?");
                        root.confirmActionText = qsTr("Suspend");
                        viewStack.push(confirmActions);
                    }
                }

                PowerTile {
                    icon: "\uf08b"
                    label: qsTr("Log Out")
                    accentColor: theme.colors.primary
                    onClicked: {
                        root.currentAccentColor = accentColor;
                        root.pendingActionCommand = ["hyprctl", "dispatch", "exit"];
                        root.pendingActionMessage = qsTr("Exit Session?");
                        root.confirmActionText = qsTr("Log Out");
                        viewStack.push(confirmActions);
                    }
                }
            }
        }
    }

    Component {
        id: confirmActions
        Item {
            // حاوية تملأ الـ StackView لضمان مرجع التوسيط
            width: viewStack.width
            height: viewStack.height

            RowLayout {
                anchors.centerIn: parent
                spacing: theme.dimensions.spacingLarge * 1.5

                MButton {
                    text: qsTr("Back")
                    iconText: "\uf060"
                    iconFirst: true
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 55
                    // شفافية متناسقة
                    normalBackground: Qt.rgba(theme.colors.topbarBgColorV1.r, theme.colors.topbarBgColorV1.g, theme.colors.topbarBgColorV1.b, 0.4)
                    onClicked: viewStack.pop()
                }

                MButton {
                    text: root.confirmActionText
                    iconText: "\uf00c"
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 55
                    // شفافية بلون الأكشن المختار
                    normalBackground: Qt.rgba(root.currentAccentColor.r, root.currentAccentColor.g, root.currentAccentColor.b, 0.6)
                    normalForeground: "#ffffff"
                    focus: true
                    Keys.onReturnPressed: clicked()
                    onClicked: {
                        // نمنع الضغط المتكرر
                        enabled = false;
                        // استدعاء دالة الوداع
                        root.prepareGoodbye(root.confirmActionText);
                    }
                }
            }
        }
    }

    // --- مكون البلاطة (PowerTile) ---
    component PowerTile: Rectangle {
        id: tileRoot
        property string icon: ""
        property string label: ""
        property color accentColor: theme.colors.primary
        signal clicked
        width: 150
        height: 150

        radius: theme.dimensions.elementRadius
        color: mouseArea.hovered ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15) : Qt.rgba(theme.colors.topbarBgColorV1.r, theme.colors.topbarBgColorV1.g, theme.colors.topbarBgColorV1.b, 0.3)

        border.color: mouseArea.hovered ? accentColor : Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: icon
                font.family: theme.typography.iconFont
                font.pixelSize: 40
                color: mouseArea.hovered ? accentColor : theme.colors.topbarFgColor
                Layout.alignment: Qt.AlignHCenter
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            Text {
                text: label
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                color: theme.colors.topbarFgColor
                Layout.alignment: Qt.AlignHCenter
                opacity: mouseArea.hovered ? 1.0 : 0.6
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tileRoot.clicked()
        }

        scale: mouseArea.pressed ? 0.96 : (mouseArea.hovered ? 1.04 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }
    }

    Timer {
        id: executionDelayTimer
        interval: 2500
        repeat: false
        onTriggered: powerActionProcess.start()
    }

    // دالة لتجهيز الوداع
    function prepareGoodbye(actionType) {
        root.close();
        let eyeEmotion = "wink";
        let capsuleMsg = "";
        let capsuleIcon = "";
        let capsuleColor = theme.colors.primary;

        if (actionType === qsTr("Shut Down")) {
            eyeEmotion = "sleeping";
            capsuleMsg = "System shutting down... Goodbye!";
            capsuleIcon = "\uf011";
            capsuleColor = theme.colors.error;
        } else if (actionType === qsTr("Restart")) {
            eyeEmotion = "happy";
            capsuleMsg = "System is restarting...";
            capsuleIcon = "\uf01e";
            capsuleColor = theme.colors.warning;
        } else if (actionType === qsTr("Suspend")) {
            eyeEmotion = "sleeping";
            capsuleMsg = "System is going to sleep...";
            capsuleIcon = "\uf186";
            capsuleColor = theme.colors.tertiary;
        } else {
            eyeEmotion = "wink";
            capsuleMsg = "Logging out... See you soon!";
            capsuleIcon = "\uf08b";
        }

        EyeController.showEmotion(eyeEmotion, 5000);

        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: "System",
            icon: capsuleIcon,
            text: capsuleMsg,
            bgColor1: capsuleColor,
            timeout: 5000
        });

        // 3. بدء العد التنازلي للتنفيذ
        executionDelayTimer.start();
    }
}
