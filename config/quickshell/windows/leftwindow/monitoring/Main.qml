// windows/leftwindow/monitoring/Main.qml

import QtQuick

import org.kde.kirigami as Kirigami // Still useful for Theme defaults and Units
import "../../../themes"
import "../../../components"

Column {
    id: monotoringMenu
    objectName: "monitoring"
    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    Progresses {
        id: progresses
    }

    ListModel {
        id: myDataModel
        ListElement {
            memoryRole: "Alice Wonderland Smith"
            percentageRole: "10"
        }
        ListElement {
            memoryRole: "Alice FIIII"
            percentageRole: "99.99"
        }
        ListElement {
            memoryRole: "Alice FIIII"
            percentageRole: "99.99"
        }
        ListElement {
            memoryRole: "Alice FIIII"
            percentageRole: "99.99"
        }
        ListElement {
            memoryRole: "Alice FIIII"
            percentageRole: "99.99"
        }
    }

    property var myColumns: [
        {
            title: "الذاكرة",
            role: "memoryRole",
            width: 100,
            alignment: Text.AlignLeft
        },
        {
            title: "%",
            role: "percentageRole",
            width: 50,
            alignment: Text.AlignRight
        }
    ]

    SimpleTable {
        id: myMonitoringTable

        width: 160
        height: 220

        model: myDataModel
        columns: myColumns

        rowHeight: 20
        headerHeight: 25

        tableBackgroundColor: Kirigami.Theme.activeBackgroundColor
        // tableBorderColor: "navy"
        tableBorderWidth: 0
        // tableRadius: Kirigami.Units.smallRadius // Or a fixed value like 8

        showVerticalGridLines: false
        showHorizontalGridLines: false

        // Header
        headerBackgroundColor: "transparent"
        headerTextColor: Kirigami.Theme.textColor
        headerFont: Qt.font({
            family: "Arial",
            pixelSize: 14,
            bold: true
        })
        // headerBorderColor: "transparent"
        // headerBorderWidth: 0

        // Cells
        cellBackgroundColor: "transparent"
        alternatingCellBackgroundColor: "transparent"
        cellTextColor: Kirigami.Theme.textColor
        cellFont: Qt.font({
            family: "Verdana",
            pixelSize: 12
        })
        // cellBorderColor: "transparent"
        // cellBorderWidth: 0

        // General
        cellPadding: 8
    }
}
