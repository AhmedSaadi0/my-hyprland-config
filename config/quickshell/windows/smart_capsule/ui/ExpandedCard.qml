import QtQuick
import QtQuick.Layouts
import "root:/themes"
import "./components"

Item {
    id: root

    // هذه الخاصية يتم التحكم بها من SmartCapsule وأيضاً من المبدل الداخلي
    property string currentTab: "media"

    signal closeRequested

    implicitWidth: 400
    implicitHeight: 180

    // زر الإغلاق (X)
    Text {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 15
        text: "✕"
        color: ThemeManager.selectedTheme.colors.onSurface
        opacity: 0.6
        font.pixelSize: 14
        z: 10
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested()
        }
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
}
