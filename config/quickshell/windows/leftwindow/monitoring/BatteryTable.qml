import QtQuick

import "root:/themes"
import "root:/components"
import "root:/config"

ProcessTable {
    id: batteryTable
    height: 120
    interval: 1000 * 60
    running: true
    // command: ["python", ".config/quickshell/scripts/python/battery_info.py"]
    command: App.scripts.python.batteryInfoCommand
    title: "Battery"
    value: "󱧥"

    model: dataModel // Assign the ListModel as the table's model
    columns: tableColumns // Assign the column definitions

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
            width: 110,
            leftMargin: 12
        },
        {
            title: "",
            role: "iconRole",
            alignment: Text.AlignLeft,
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

            if (!readData.has_battery) {
                batteryTable.value = "󱟨";
                dataModel.append({
                    textRole: qsTr("No Battery found"),
                    iconRole: "",
                    valueRole: ""
                });
                return;
            } else {
                batteryTable.value = "󱟢";
            }

            dataModel.append({
                textRole: qsTr("Percentage"),
                iconRole: "",
                valueRole: readData.percentage.toFixed(0)
            });

            dataModel.append({
                textRole: qsTr("Health"),
                iconRole: "",
                valueRole: readData.wear_level_percent.toFixed(2)
            });

            dataModel.append({
                textRole: ("Cycles"),
                iconRole: "󱍸",
                valueRole: readData.cycle_count.toFixed(0)
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
