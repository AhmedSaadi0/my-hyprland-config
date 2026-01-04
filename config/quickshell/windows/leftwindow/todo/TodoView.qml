import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "root:/themes"
import "root:/config"

ColumnLayout {
    id: root
    spacing: 15
    
    readonly property var theme: ThemeManager.selectedTheme.colors
    readonly property var typography: ThemeManager.selectedTheme.typography
    property date selectedDate: new Date()
    
    // --- Persistence Logic (Quickshell FileView) ---
    property string tasksFilePath: App.todoFilePath 

    FileView {
        id: tasksFile
        path: root.tasksFilePath
        watchChanges: true
        
        onLoaded: {
            if (!text() || text().trim() === "") return;
            try {
                const data = JSON.parse(text());
                todoModel.clear();
                for (let i = 0; i < data.length; i++) {
                    todoModel.append(data[i]);
                }
            } catch (e) {
                console.error("Error loading tasks: " + e);
            }
        }
    }

    function saveTasks() {
        let tempArray = [];
        for (let i = 0; i < todoModel.count; i++) {
            tempArray.push(todoModel.get(i));
        }
        tasksFile.setText(JSON.stringify(tempArray, null, 2));
    }

    Component.onCompleted: tasksFile.reload()

    // --- Data Model ---
    ListModel { id: todoModel }

    // --- Header ---
    Text {
        text: "My Tasks"
        font.family: root.typography.bodyFont
        font.pixelSize: 22
        font.bold: true
        color: root.theme.leftMenuFgColorV1
        Layout.leftMargin: 10
        Layout.topMargin: 5
    }

    // --- Input Area ---
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 185
        Layout.margins: 10
        color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.05)
        border.color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.1)
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
                font.family: root.typography.bodyFont
                color: root.theme.leftMenuFgColorV1
                
                background: Rectangle {
                    color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.08)
                    radius: 4
                    border.width: 1
                    border.color: taskInput.activeFocus ? root.theme.primary : "transparent"
                }
                onAccepted: addTaskBtn.clicked()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
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
                        border.color: Qt.rgba(1,1,1,0.1)
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: root.typography.bodyFont
                        color: root.theme.leftMenuFgColorV1
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
                        font.family: root.typography.bodyFont
                        color: root.theme.leftMenuFgColorV1
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
                        todoModel.insert(0, {
                            "title": taskInput.text,
                            "date": root.selectedDate.toLocaleDateString(Qt.locale(), "MMM d"),
                            "isUrgent": urgentCheck.checked,
                            "completed": false
                        });
                        taskInput.text = "";
                        urgentCheck.checked = false;
                        root.saveTasks(); 
                    }
                }
                background: Rectangle {
                    color: parent.pressed ? root.theme.primary : root.theme.leftMenuFgColorV1
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    font.family: root.typography.bodyFont
                    font.bold: true
                    color: "white"
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
                        model.completed = checked
                        root.saveTasks()
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
                        todoModel.remove(index)
                        root.saveTasks()
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

    // --- Date Selection Popup ---
// --- Improved Calendar Dialog Picker ---
    Popup {
        id: datePopup
        x: (root.width - width) / 2
        y: 60
        width: 280
        height: 360
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // Local state for the calendar view
        property date viewDate: new Date() 

        background: Rectangle {
            color: "#1a1a1a"
            radius: 12
            border.color: Qt.rgba(root.theme.leftMenuFgColorV1.r, root.theme.leftMenuFgColorV1.g, root.theme.leftMenuFgColorV1.b, 0.2)
            border.width: 1
            
            // Subtle shadow effect
            layer.enabled: true
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.3
                z: -1
                radius: 12
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            // Header: Month/Year and Nav Buttons
            RowLayout {
                Layout.fillWidth: true
                
                Button {
                    text: "‹"
                    flat: true
                    onClicked: datePopup.viewDate = new Date(datePopup.viewDate.setMonth(datePopup.viewDate.getMonth() - 1))
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter }
                }

                Text {
                    Layout.fillWidth: true
                    text: datePopup.viewDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                    color: "white"
                    font.family: root.typography.bodyFont
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "›"
                    flat: true
                    onClicked: datePopup.viewDate = new Date(datePopup.viewDate.setMonth(datePopup.viewDate.getMonth() + 1))
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter }
                }
            }

            // Days of the Week Header
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    delegate: Text {
                        Layout.fillWidth: true
                        text: modelData
                        color: root.theme.primary
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Calendar Grid
            GridView {
                id: calendarGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: width / 7
                cellHeight: 40
                interactive: false

                model: 42 // 6 weeks to cover any month start

                delegate: Item {
                    width: calendarGrid.cellWidth
                    height: calendarGrid.cellHeight

                    // Logic to calculate the specific day for this cell
                    property var dayDate: {
                        let firstDay = new Date(datePopup.viewDate.getFullYear(), datePopup.viewDate.getMonth(), 1);
                        let startingOffset = firstDay.getDay();
                        let d = new Date(firstDay);
                        d.setDate(d.getDate() - startingOffset + index);
                        return d;
                    }

                    property bool isCurrentMonth: dayDate.getMonth() === datePopup.viewDate.getMonth()
                    property bool isSelected: dayDate.toDateString() === root.selectedDate.toDateString()
                    property bool isToday: dayDate.toDateString() === new Date().toDateString()

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: width / 2
                        color: isSelected ? root.theme.primary : (isToday ? Qt.rgba(1,1,1,0.1) : "transparent")
                        border.width: isToday && !isSelected ? 1 : 0
                        border.color: root.theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: dayDate.getDate()
                            color: isSelected ? "white" : (isCurrentMonth ? "white" : "#444")
                            font.family: root.typography.bodyFont
                            font.pixelSize: 12
                            font.bold: isToday
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.selectedDate = dayDate;
                                datePopup.close();
                            }
                        }
                    }
                }
            }

            // Footer Quick Actions
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    text: "Today"
                    onClicked: {
                        root.selectedDate = new Date();
                        datePopup.close();
                    }
                    background: Rectangle { color: "#333"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Tomorrow"
                    onClicked: {
                        let d = new Date();
                        d.setDate(d.getDate() + 1);
                        root.selectedDate = d;
                        datePopup.close();
                    }
                    background: Rectangle { color: "#333"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                }
            }
        }
    }
}