import QtQuick

import "../../../themes"
import "../../../components"

ProcessTable {
    id: batteryTable
    height: 105
    interval: 1000 * 60
    running: true
    command: ["python", ".config/quickshell/scripts/python/devices_temp.py"]
    title: "Temp"
    value: ""

    model: dataModel // Assign the ListModel as the table's model
    columns: tableColumns // Assign the column definitions

    ListModel {
        id: dataModel
        ListElement {
            textRole: "جاري تحميل البيانات..."
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
                textRole: "CPU",
                iconRole: "",
                valueRole: readData.cpu_max_temp.toFixed(0) + ' C°'
            });

            dataModel.append({
                textRole: "GPU",
                iconRole: "",
                valueRole: readData.gpu_max_temp.toFixed(0) + ' C°'
            });

            dataModel.append({
                textRole: "Storage",
                iconRole: "󰋊",
                valueRole: readData.storage_max_temp.toFixed(0) + ' C°'
            });
        } catch (e) {
            console.error("خطأ في تحليل JSON من سكربت المعالج:", e.message);
            console.error("البيانات المستلمة التي سببت الخطأ:", data);
            // Display an error message in the table if parsing fails
            if (dataModel.count === 0 || dataModel.get(0).textRole !== "خطأ في التحليل") {
                dataModel.clear();
                dataModel.append({
                    textRole: "خطأ في التحليل",
                    valueRole: "N/A"
                });
            }
        }
    }
}
