// components/SimpleTable.qml
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../themes"

Rectangle {
    id: tableRoot
    implicitWidth: 400
    // implicitHeight: childrenRect.height // Let content define implicitHeight
    // OR, if you want a minimum default height if no content:
    implicitHeight: headerHeight // At least the header height

    clip: true

    property var model: null

    // --- Properties for Table Container ---
    property color tableBackgroundColor: Kirigami.Theme.backgroundColor
    property color tableBorderColor: Kirigami.Theme.frameColor
    property int tableBorderWidth: 1
    property real tableRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    // --- Properties for Header ---
    property color headerBackgroundColor: Qt.tint(Kirigami.Theme.backgroundColor, 1.05)
    property color headerTextColor: Kirigami.Theme.textColor
    property font headerFont: Kirigami.Theme.font(Kirigami.Theme.FontWeight.Bold, Kirigami.Theme.FontSize.Small)
    property color headerBorderColor: Kirigami.Theme.frameColor
    property int headerBorderWidth: 1
    property int headerHeight: Kirigami.Units.gridUnit * 2.5
    property int headerCellSpacing: 0

    // --- DEFAULT Properties for Cells/Rows Text ---
    property color cellTextColor: Kirigami.Theme.textColor
    property font cellFont: Kirigami.Theme.font(Kirigami.Theme.FontWeight.Normal, Kirigami.Theme.FontSize.Small)
    property var cellElideMode: Text.ElideRight
    property var cellWrapMode: Text.NoWrap

    // --- General Cell Properties ---
    property color cellBackgroundColor: Kirigami.Theme.backgroundColor
    property color alternatingCellBackgroundColor: Kirigami.Theme.alternateBackgroundColor
    property color cellBorderColor: Kirigami.Theme.frameColor
    property int cellBorderWidth: 1
    property int rowHeight: Kirigami.Units.gridUnit * 2
    property int cellColumnSpacing: 0
    property int cellRowSpacing: 1

    // --- General Table Properties ---
    property var columns: []
    property int cellPadding: Kirigami.Units.smallSpacing
    property bool showVerticalGridLines: true
    property bool showHorizontalGridLines: true

    color: tableBackgroundColor
    border.color: tableBorderColor
    border.width: tableBorderWidth > 0 ? tableBorderWidth : 0
    radius: tableRadius

    ColumnLayout {
        id: tableContentLayout // Renamed for clarity
        // anchors.fill: parent // REMOVE THIS if you don't want it to stretch vertically
        // Instead, anchor to top and let it take its natural height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        // Its height will be determined by its children (headerRowLayout + dataGridLayout)
        // width: parent.width // Still take full width

        spacing: 0

        RowLayout {
            id: headerRowLayout
            // width: parent.width // This parent is now tableContentLayout
            Layout.fillWidth: true // Ensure it takes the width of tableContentLayout
            height: tableRoot.headerHeight // Fixed height for header
            spacing: tableRoot.headerCellSpacing

            Repeater { /* ... header delegate ... */
                id: headerRepeater
                model: tableRoot.columns
                delegate: Rectangle {
                    readonly property var columnDef: modelData

                    readonly property bool isFirstCellInRow: index === 0
                    readonly property bool isLastCellInRow: index === (headerRepeater.model.length - 1)

                    Layout.preferredHeight: tableRoot.headerHeight
                    Layout.preferredWidth: columnDef.width ? columnDef.width : ((headerRowLayout.width - (tableRoot.headerCellSpacing * (tableRoot.columns.length - 1))) / (tableRoot.columns.length || 1))
                    Layout.fillWidth: true
                    color: tableRoot.headerBackgroundColor
                    border.color: tableRoot.headerBorderColor
                    border.width: tableRoot.headerBorderWidth > 0 && (tableRoot.showVerticalGridLines || tableRoot.showHorizontalGridLines) ? tableRoot.headerBorderWidth : 0
                    clip: true

                    topLeftRadius: isFirstCellInRow ? tableRadius : 0
                    topRightRadius: isLastCellInRow ? tableRadius : 0

                    Text {
                        text: columnDef.title
                        font: columnDef.headerFont !== undefined ? columnDef.headerFont : tableRoot.headerFont
                        color: columnDef.headerTextColor !== undefined ? columnDef.headerTextColor : tableRoot.headerTextColor
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        horizontalAlignment: columnDef.alignment !== undefined ? columnDef.alignment : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: tableRoot.cellPadding
                        anchors.right: parent.right
                        anchors.rightMargin: tableRoot.cellPadding
                    }
                }
            }
        }

        GridLayout {
            id: dataGridLayout
            Layout.fillWidth: true // Take width of tableContentLayout
            // DO NOT USE Layout.fillHeight: true if you want it to take natural height
            // Its height will be sum of rowHeights + rowSpacings
            // Or, if you want scrolling within a fixed data area, this would be different

            columns: tableRoot.columns.length > 0 ? tableRoot.columns.length : 1
            columnSpacing: tableRoot.cellColumnSpacing
            rowSpacing: tableRoot.cellRowSpacing

            Repeater { /* ... data delegate ... */
                id: allDataCellsRepeater
                model: (tableRoot.model && tableRoot.columns.length > 0) ? (tableRoot.model.count * tableRoot.columns.length) : 0
                delegate: Rectangle {
                    readonly property int rowIndex: Math.floor(index / tableRoot.columns.length)
                    readonly property int colIndex: index % tableRoot.columns.length
                    readonly property var columnDef: tableRoot.columns[colIndex]
                    readonly property var rowData: tableRoot.model.get(rowIndex)
                    Layout.preferredHeight: tableRoot.rowHeight // Fixed height for data rows
                    Layout.preferredWidth: columnDef.width ? columnDef.width : ((dataGridLayout.width - (tableRoot.cellColumnSpacing * (tableRoot.columns.length - 1))) / (tableRoot.columns.length || 1))
                    Layout.fillWidth: true
                    color: rowIndex % 2 === 0 ? tableRoot.cellBackgroundColor : tableRoot.alternatingCellBackgroundColor
                    border.color: tableRoot.cellBorderColor
                    border.width: (tableRoot.cellBorderWidth > 0 && (tableRoot.showVerticalGridLines || tableRoot.showHorizontalGridLines)) ? tableRoot.cellBorderWidth : 0
                    clip: true

                    Text {
                        text: rowData && columnDef ? rowData[columnDef.role] : ""
                        font: columnDef.cellFont !== undefined ? columnDef.cellFont : tableRoot.cellFont
                        color: columnDef.cellTextColor !== undefined ? columnDef.cellTextColor : tableRoot.cellTextColor
                        elide: columnDef.cellElideMode !== undefined ? columnDef.cellElideMode : tableRoot.cellElideMode
                        wrapMode: columnDef.cellWrapMode !== undefined ? columnDef.cellWrapMode : tableRoot.cellWrapMode
                        horizontalAlignment: columnDef.alignment !== undefined ? columnDef.alignment : Text.AlignLeft
                        verticalAlignment: columnDef.cellVerticalAlignment !== undefined ? columnDef.cellVerticalAlignment : Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: tableRoot.cellPadding
                        anchors.right: parent.right
                        anchors.rightMargin: tableRoot.cellPadding
                    }
                }
            }
        }
    }
}
