import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

ColumnLayout {
    id: headerRoot
    spacing: 15
    Layout.fillWidth: true

    // الخصائص المطلوبة من الخارج
    property var theme
    property var typography
    property date selectedDate
    
    // الإشارات (Signals) للتواصل مع TodoView
    signal addTask(string title, bool urgent)
    signal openCalendar()

    // 1. العنوان
    Text {
        text: "My Tasks"
        font.family: typography.bodyFont
        font.pixelSize: 22
        font.bold: true
        color: theme.leftMenuFgColorV1
        Layout.leftMargin: 10
        Layout.topMargin: 5
    }

    // 2. منطقة الإدخال
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 185
        Layout.margins: 10
        color: Qt.rgba(theme.leftMenuFgColorV1.r, theme.leftMenuFgColorV1.g, theme.leftMenuFgColorV1.b, 0.05)
        border.color: Qt.rgba(theme.leftMenuFgColorV1.r, theme.leftMenuFgColorV1.g, theme.leftMenuFgColorV1.b, 0.1)
        radius: 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            TextField {
                id: taskInput
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                placeholderText: "What needs to be done?"
                font.family: typography.bodyFont
                color: theme.leftMenuFgColorV1
                
                background: Rectangle {
                    color: Qt.rgba(theme.leftMenuFgColorV1.r, theme.leftMenuFgColorV1.g, theme.leftMenuFgColorV1.b, 0.08)
                    radius: 4
                    border.width: 1
                    border.color: taskInput.activeFocus ? theme.primary : "transparent"
                }
                onAccepted: addTaskBtn.clicked()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    text: "📅  " + headerRoot.selectedDate.toLocaleDateString(Qt.locale(), "ddd, MMM d")
                    onClicked: headerRoot.openCalendar()
                    
                    background: Rectangle {
                        color: Qt.rgba(theme.leftMenuFgColorV1.r, theme.leftMenuFgColorV1.g, theme.leftMenuFgColorV1.b, 0.08)
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: typography.bodyFont
                        color: theme.leftMenuFgColorV1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                CheckBox {
                    id: urgentCheck
                    text: "Urgent"
                    Layout.preferredHeight: 35
                    contentItem: Text {
                        text: parent.text
                        font.family: typography.bodyFont
                        color: theme.leftMenuFgColorV1
                        leftPadding: parent.indicator.width + 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Button {
                id: addTaskBtn
                text: "Add New Task"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                onClicked: {
                    if (taskInput.text.trim() !== "") {
                        headerRoot.addTask(taskInput.text, urgentCheck.checked)
                        taskInput.text = ""
                        urgentCheck.checked = false
                    }
                }
                background: Rectangle {
                    color: parent.pressed ? theme.primary : theme.leftMenuFgColorV1
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    font.family: typography.bodyFont
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}