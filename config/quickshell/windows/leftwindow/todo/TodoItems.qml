import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

ListView {
    id: todoList
    
    property var theme
    property var typography
    
    property var listModel 

    signal requestSave()

    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    spacing: 8
    
    topMargin: 5
    bottomMargin: 10
    
    model: listModel

    delegate: Rectangle {
            width: todoList.width
            height: 60
            radius: 8
            color: model.isUrgent ? Qt.rgba(1, 0, 0, 0.08) : Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.03)
            border.color: model.isUrgent ? "#ff4444" : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // 1. Text Info (Left)
                ColumnLayout {
                    Layout.fillWidth: true 
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    Text {
                        text: model.title
                        font.family: root.typography.bodyFont
                        font.pixelSize: 14
                        font.strikeout: model.completed
                        color: root.theme.leftMenuFgColorV1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: model.date
                        font.family: root.typography.bodyFont
                        font.pixelSize: 11
                        color: root.theme.leftMenuFgColorV1
                        opacity: 0.6
                    }
                }

                // 2. Check Icon (Centered)
                CheckBox {
                    id: completionCheck
                    checked: model.completed
                    Layout.alignment: Qt.AlignVCenter
                    onCheckedChanged: {
                        if (model.completed !== checked) {
                        model.completed = checked
                        todoList.requestSave()
                    }
                    }
                    indicator: Rectangle {
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 11
                        border.color: completionCheck.checked ? "#4CAF50" : root.theme.leftMenuFgColorV1
                        color: "transparent"
                        Text {
                            text: "✓"
                            anchors.centerIn: parent
                            color: "#4CAF50"
                            font.pixelSize: 16
                            visible: completionCheck.checked
                        }
                    }
                }

                // 3. Delete Icon (Right)
                Button {
                    id: deleteBtn
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35 
                    Layout.alignment: Qt.AlignVCenter
                    flat: true
                    onClicked: {
                        todoList.listModel.remove(index)
                    todoList.requestSave()
                    }
                    contentItem: Text { 
                        text: "✕"
                        color: "red"
                        font.bold: true
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter 
                        verticalAlignment: Text.AlignVCenter 
                    }
                    background: Rectangle {
                        color: deleteBtn.pressed ? Qt.rgba(1, 0, 0, 0.1) : "transparent"
                        radius: 6
                    }
                }
            }
        }
    
}