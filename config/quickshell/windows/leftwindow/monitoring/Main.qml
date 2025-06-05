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
            // width: 150,
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

        rowHeight: 25
        headerHeight: 30

        tableBackgroundColor: palette.accent
        // tableBorderColor: "navy"
        tableBorderWidth: 0
        // tableRadius: Kirigami.Units.smallRadius // Or a fixed value like 8

        showVerticalGridLines: false
        showHorizontalGridLines: false

        // Header
        headerBackgroundColor: palette.mid
        headerTextColor: Kirigami.Theme.textColor
        headerFont: Qt.font({
            family: "Arial",
            pixelSize: 14,
            bold: true
        })
        // headerBorderColor: "transparent"
        // headerBorderWidth: 0

        // Cells
        cellBackgroundColor: Kirigami.Theme.backgroundColor.alpha(0.8)
        alternatingCellBackgroundColor: "transparent"
        cellTextColor: Kirigami.Theme.textColor
        cellFont: Qt.font({
            family: "Verdana",
            pixelSize: 12
        })
        // cellBorderColor: "transparent"
        // cellBorderWidth: 0

        // General
        cellPadding: 15

        // --- Control Spacing ---
        headerCellSpacing: 0   // <<< SET THIS TO 0 FOR CONNECTED HEADERS
        cellColumnSpacing: 0   // Optional: for data cells
        cellRowSpacing: 1      // Optional: for data rows
    }
}
