import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "root:/themes"
import "root:/config"
import "root:/components"

Item {
    id: root

    // --- Constants for Ranking ---
    readonly property int rankUrgent: 0
    readonly property int rankNormal: 1
    readonly property int rankDone: 2

    // --- Theme Properties ---
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    // --- State Properties ---
    property date selectedDate: new Date()
    
    // -1 = Editing the Header (New Task), 0+ = Editing an existing item index
    property int activeCalendarIndex: -1 

    Layout.fillWidth: true
    Layout.fillHeight: true

    // --- Functions ---
    function getTaskRank(item) {
        if (item.completed) return root.rankDone;
        if (item.isUrgent) return root.rankUrgent;
        return root.rankNormal;
    }

    function shouldSwap(itemA, itemB) {
        let rankA = getTaskRank(itemA);
        let rankB = getTaskRank(itemB);

        if (rankA > rankB) return true;
        if (rankA < rankB) return false;

        let timeA = itemA.timestamp || 0;
        let timeB = itemB.timestamp || 0;
        return timeA < timeB;
    }

    function sortTasks() {
        let n = todoModel.count;
        let swapped;
        do {
            swapped = false;
            for (let i = 0; i < n - 1; i++) {
                let item1 = todoModel.get(i);
                let item2 = todoModel.get(i + 1);
                if (shouldSwap(item1, item2)) {
                    todoModel.move(i, i + 1, 1);
                    swapped = true;
                }
            }
        } while (swapped)
    }

    function saveTasks() {
        let arr = [];
        for (let i = 0; i < todoModel.count; i++) {
            let item = todoModel.get(i);
            arr.push({
                "title": item.title,
                "date": item.date,
                "timestamp": item.timestamp || 0,
                "isUrgent": item.isUrgent,
                "completed": item.completed
            });
        }
        tasksFile.setText(JSON.stringify(arr, null, 2));
    }

    // --- Data Components ---
    ListModel { id: todoModel }

    FileView {
        id: tasksFile
        path: App.todoFilePath
        onLoaded: {
            if (!text() || text().trim() === "") return;
            try {
                let data = JSON.parse(text());
                todoModel.clear();
                for (let i = 0; i < data.length; i++) {
                    todoModel.append(data[i]);
                }
                root.sortTasks();
            } catch (e) {
                console.error("Error loading JSON: " + e);
            }
        }
        onSaved: console.info("Tasks saved")
        onSaveFailed: error => console.error("Save failed: " + error)
    }
    Component.onCompleted: tasksFile.reload()

    // --- UI Structure ---
    ColumnLayout {
        anchors.fill: parent
        spacing: dims.spacingMedium

        TodoHeader {
            id: header
            Layout.fillWidth: true
            selectedDate: root.selectedDate

            onOpenCalendar: {
                // Set index to -1 so we know we are editing the new task date
                root.activeCalendarIndex = -1
                calendarPopup.open()
            }

            onAddTask: (title, urgent) => {
                todoModel.append({
                    "title": title,
                    "date": root.selectedDate.toLocaleDateString(Qt.locale(), "MMM d"),
                    "timestamp": new Date().getTime(),
                    "isUrgent": urgent,
                    "completed": false
                });
                root.sortTasks();
                root.saveTasks();
            }
        }

        ScrollView {
            id: bodyItems
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            TodoItems {
                listModel: todoModel

                onRequestSave: {
                    root.sortTasks();
                    root.saveTasks();
                }

                // Handle request from a list item to edit its date
                onRequestCalendar: (index) => {
                    root.activeCalendarIndex = index
                    calendarPopup.open()
                }
            }
        }
    }

    CustomCalendar {
        id: calendarPopup
        x: (root.width - width) / 2
        y: 80
        z: 100

        onDateSelected: date => {
            if (root.activeCalendarIndex === -1) {
                // Editing Header Date
                root.selectedDate = date;
            } else {
                // Editing Existing Task Date
                let formattedDate = date.toLocaleDateString(Qt.locale(), "MMM d");
                
                // Directly update the model
                todoModel.setProperty(root.activeCalendarIndex, "date", formattedDate);
                
                // Note: We don't save immediately, the user will save when clicking 'Done' (Checkmark) 
                // in the list item, or we can force a save here if preferred. 
                // For now, let's leave it to the user to confirm via the edit button, 
                // but since the date update is instant in UI, saving immediately is safer for consistency:
                // root.saveTasks(); 
            }
        }
    }
}