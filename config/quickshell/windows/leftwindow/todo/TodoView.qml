import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

ColumnLayout {
    id: root
    spacing: 15
    
    readonly property var theme: ThemeManager.selectedTheme.colors
    readonly property var typography: ThemeManager.selectedTheme.typography
    property date selectedDate: new Date()
    property alias taskText: taskInput.text
    
    // This function is called by Menus.qml to ensure you can type immediately
    function gainFocus() {
        taskInput.text = "";
        taskInput.forceActiveFocus();
    }

    // --- Data Model ---
    ListModel {
        id: todoModel
    }

    // --- Header ---
    Text {
        text: "My Tasks"
        font.family: root.typography.bodyFont
        font.pixelSize: 22
        font.bold: true
        color: root.theme.leftMenuFgColorV1
        Layout.topMargin: 10
        Layout.leftMargin: 10
    }

    // --- Input Area ---
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 185
        Layout.margins: 10
        color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.05)
        border.color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.1)
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Task Name Input (Using your working searchField logic)
            TextField {
                id: taskInput
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                placeholderText: "What needs to be done?"
                font.family: root.typography.bodyFont
                color: root.theme.leftMenuFgColorV1
                focus: true
                
                background: Rectangle {
                    color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.08)
                    radius: 4
                    border.width: 1
                    border.color: taskInput.activeFocus ? root.theme.primary : "transparent"
                }

                // Allow adding task by pressing Enter
                onAccepted: addTaskBtn.clicked()

                // Ensure focus on load
                Component.onCompleted: forceActiveFocus()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // Date Picker Trigger
                Button {
                    id: dateBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    text: "📅  " + root.selectedDate.toLocaleDateString(Qt.locale(), "ddd, MMM d")
                    
                    onClicked: datePopup.open()

                    background: Rectangle {
                        color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.08)
                        radius: 4
                        border.width: 1
                        border.color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.2)
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: root.typography.bodyFont
                        color: root.theme.leftMenuFgColorV1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Urgent Toggle
                CheckBox {
                    id: urgentCheck
                    text: "Urgent"
                    Layout.preferredHeight: 35
                    contentItem: Text {
                        text: parent.text
                        font.family: root.typography.bodyFont
                        color: root.theme.leftMenuFgColorV1
                        leftPadding: parent.indicator.width + parent.spacing
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Add Button
            Button {
                id: addTaskBtn
                text: "Add New Task"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                
                onClicked: {
                    if (taskInput.text.trim() !== "") {
                        todoModel.insert(0, { // Add to top of list
                            "title": taskInput.text,
                            "date": root.selectedDate.toLocaleDateString(Qt.locale(), "MMM d"),
                            "isUrgent": urgentCheck.checked,
                            "completed": false
                        });
                        taskInput.text = "";
                        urgentCheck.checked = false;
                        taskInput.forceActiveFocus();
                    }
                }

                background: Rectangle {
                    color: parent.pressed ? root.theme.primary : root.theme.leftMenuFgColorV1
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    font.family: root.typography.bodyFont
                    font.bold: true
                    color: parent.pressed ? "white" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // --- Scrollable Task List ---
    ListView {
        id: todoList
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 10
        clip: true
        model: todoModel
        spacing: 8
        
        delegate: Rectangle {
            width: todoList.width
            height: 60
            radius: 6
            color: model.isUrgent ? Qt.rgba(1, 0, 0, 0.1) : Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.03)
            border.color: model.isUrgent ? "#ff4444" : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                CheckBox {
                    checked: model.completed
                    onCheckedChanged: model.completed = checked
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: model.title
                        font.family: root.typography.bodyFont
                        font.pixelSize: 14
                        font.strikeout: model.completed
                        color: root.theme.leftMenuFgColorV1
                        elide: Text.ElideRight
                    }
                    Text {
                        text: model.date
                        font.family: root.typography.bodyFont
                        font.pixelSize: 11
                        color: root.theme.leftMenuFgColorV1
                        opacity: 0.6
                    }
                }

                Button {
                    text: "✕"
                    Layout.preferredWidth: 30
                    flat: true
                    onClicked: todoModel.remove(index)
                    contentItem: Text { 
                        text: parent.text
                        color: "red"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter 
                    }
                }
            }
        }
    }

    // --- Date Selection Popup ---
    Popup {
        id: datePopup
        x: (root.width - width) / 2
        y: 60
        width: 240
        height: 320
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#1a1a1a"
            radius: 8
            border.color: root.theme.leftMenuFgColorV1
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            
            Text {
                text: "Select Due Date"
                color: "white"
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
            }

            ListView {
                id: dateListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: 14 // Next 2 weeks
                
                delegate: ItemDelegate {
                    width: dateListView.width
                    height: 40
                    
                    property date itemDate: {
                        let d = new Date();
                        d.setDate(d.getDate() + index);
                        return d;
                    }

                    contentItem: Text {
                        text: index === 0 ? "Today" : 
                              index === 1 ? "Tomorrow" : 
                              itemDate.toLocaleDateString(Qt.locale(), "ddd, MMM d")
                        color: "white"
                        font.family: root.typography.bodyFont
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.highlighted ? Qt.rgba(1,1,1,0.1) : "transparent"
                        radius: 4
                    }

                    onClicked: {
                        root.selectedDate = itemDate;
                        datePopup.close();
                    }
                }
            }
        }
    }
}