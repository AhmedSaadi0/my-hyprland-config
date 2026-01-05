import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "root:/themes"
import "root:/config"
import "root:/components"

ColumnLayout {
    id: root
    anchors.fill: parent
    spacing: 0 
    
    readonly property var theme: ThemeManager.selectedTheme.colors
    readonly property var typography: ThemeManager.selectedTheme.typography
    property date selectedDate: new Date()

    // --- Logic & Data ---
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
            } catch (e) { console.error("Error loading JSON: " + e) }
        }
        onSaved: console.info("Tasks saved to: " + path)
        onSaveFailed: error => console.error("Save failed: " + error)
    }

    function saveTasks() {
        let arr = [];
        for (let i = 0; i < todoModel.count; i++) {
            let item = todoModel.get(i);
            arr.push({
                "title": item.title,
                "date": item.date,
                "isUrgent": item.isUrgent,
                "completed": item.completed
            });
        }
        tasksFile.setText(JSON.stringify(arr, null, 2));
    }

    Component.onCompleted: tasksFile.reload()

    // --- UI Structure ---

    TodoHeader {
        theme: root.theme
        typography: root.typography
        selectedDate: root.selectedDate
        Layout.fillWidth: true 
        
        onOpenCalendar: calendarPopup.open()
        onAddTask: (title, urgent) => {
            todoModel.insert(0, {
                "title": title,
                "date": root.selectedDate.toLocaleDateString(Qt.locale(), "MMM d"),
                "isUrgent": urgent,
                "completed": false
            });
            root.saveTasks();
        }
    }

    TodoItems {
        id: bodyItems
        theme: root.theme
        typography: root.typography
        listModel: todoModel 
        Layout.fillWidth: true
        Layout.fillHeight: true 
        
        onRequestSave: root.saveTasks()
    }

    CustomCalendar {
        id: calendarPopup
        x: (root.width - width) / 2
        y: 60
        theme: root.theme
        typography: root.typography
        selectedDate: root.selectedDate
        onDateSelected: (date) => root.selectedDate = date
    }
}