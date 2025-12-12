import QtQuick
import QtQuick.Layouts

import "root:/themes"
import "root:/components"
import "./components"

Item {
    id: root

    // هذه الخاصية يتم التحكم بها من SmartCapsule وأيضاً من المبدل الداخلي
    property string currentTab: "media"

    signal closeRequested

    implicitWidth: 400
    implicitHeight: 185

    // زر الإغلاق (X)
    MButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 15
        anchors.leftMargin: 14
        text: "✕"
        font: ThemeManager.selectedTheme.typography.iconFont
        implicitWidth: 34
        implicitHeight: 30
        onClicked: root.closeRequested()
        normalBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)
        normalForeground: ThemeManager.selectedTheme.colors.onPrimary
        hoveredBackground: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)
        downForeground: ThemeManager.selectedTheme.colors.onPrimary
        cursorShape: Qt.PointingHandCursor
    }

    // التخطيط الرئيسي
    ColumnLayout {
        anchors.fill: parent
        // anchors.margins: 10
        spacing: 0

        Behavior on Layout.preferredHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }
        }

        // 1. المبدل (Switcher) في الأعلى والوسط
        IslandSwitcher {
            Layout.alignment: Qt.AlignHCenter

            // ربط الحالة
            currentTab: root.currentTab

            // عند النقر، نغير التبويب الحالي
            onTabClicked: tab => root.currentTab = tab
        }

        // 2. منطقة المحتوى (Stack)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Media View
            MediaExpanded {
                anchors.fill: parent
                // visible: root.currentTab === "media"
                // opacity: visible ? 1 : 0

                opacity: root.currentTab === "media" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                transform: Translate {
                    x: root.currentTab === "media" ? 0 : 50
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // Weather View
            WeatherExpanded {
                anchors.fill: parent
                // visible: root.currentTab === "weather"
                // opacity: visible ? 1 : 0

                opacity: root.currentTab === "weather" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
                transform: Translate {
                    x: root.currentTab === "weather" ? 0 : -50
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    AIEyes {
        id: testEyes
        eyeColor: ThemeManager.selectedTheme.colors.onPrimary

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.rightMargin: 10
        anchors.leftMargin: 10

        MouseArea {
            anchors.fill: parent
            onClicked: root.requestExpand("media")
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered: {
                let infoText = MusicService.activePlayer.identity;
                if (root.isMusicPlaying) {
                    infoText = MusicService.fullInfo;
                }
                CapsuleManager.request({
                    priority: C.HOVER,
                    source: C.SRC_MUSIC,
                    icon: "󰝚",
                    text: infoText,
                    timeout: 0,
                    changeW: false
                });

                EyeController.showEmotion("happy", 2000);
            }

            onExited: {
                CapsuleManager.reset();
            }
        }
    }
}
