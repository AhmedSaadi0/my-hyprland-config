import QtQuick

import "root:/themes"
import "root:/components"
import "root:/config"

ProcessTable {
    id: batteryTable
    height: 120
    interval: 1000 * 60
    running: true
    command: App.scripts.python.devicesTempCommand
    title: qsTr("Temp")
    value: ""

    model: dataModel // Assign the ListModel as the table's model
    columns: tableColumns // Assign the column definitions

    // --- Property Values ---
    // tableBackgroundColor: "#F0FFF4" // Very light mint-cream
    // tableBorderColor: "#2F4F4F" // Dark slate gray/green
    // headerBackgroundColor: "#2E8B57" // Sea green
    // headerTextColor: "white"
    // headerBorderColor: "#2E8B57"
    // cellTextColor: "#2F4F4F"
    // cellBackgroundColor: "white"
    // alternatingCellBackgroundColor: "#F0FFF0" // CSS color name for a pale green
    // cellBorderColor: "#98FB98" // Pale green grid lines

    ListModel {
        id: dataModel
        ListElement {
            textRole: qsTr("Loading ... ")
            valueRole: "0.00"
        }
    }

    property var tableColumns: [
        {
            title: batteryTable.title,
            role: "textRole",
            alignment: Text.AlignLeft,
            width: 100,
            leftMargin: 12
        },
        {
            title: "",
            role: "iconRole",
            alignment: Text.AlignHCenter,
            width: 20,
            leftMargin: 3,
            cellFont: Qt.font({
                family: ThemeManager.selectedTheme.typography.iconFont,
                pixelSize: ThemeManager.selectedTheme.typography.small
            })
        },
        {
            title: batteryTable.value,
            role: "valueRole",
            alignment: Text.AlignRight,
            width: 55,
            rightMargin: 10
        }
    ]

    onReadHandler: data => {
        try {
            var readData = JSON.parse(data);
            dataModel.clear();

            dataModel.append({
                textRole: qsTr("CPU"),
                iconRole: "",
                valueRole: readData.cpu_max_temp ? readData.cpu_max_temp.toFixed(0) + ' C°' : ""
            });

            dataModel.append({
                textRole: qsTr("GPU"),
                iconRole: "",
                valueRole: readData.gpu_max_temp ? readData.gpu_max_temp.toFixed(0) + ' C°' : ""
            });

            dataModel.append({
                textRole: qsTr("Storage"),
                iconRole: "󰋊",
                valueRole: readData.storage_max_temp ? readData.storage_max_temp.toFixed(0) + ' C°' : ""
            });
        } catch (e) {
            console.error("خطأ في تحليل JSON من سكربت المعالج:", e.message);
            console.error("البيانات المستلمة التي سببت الخطأ:", data);
            // Display an error message in the table if parsing fails
            if (dataModel.count === 0 || dataModel.get(0).textRole !== "خطأ في التحليل") {
                dataModel.clear();
                dataModel.append({
                    textRole: ("Error in reading data"),
                    valueRole: "N/A"
                });
            }
        }
    }
}
