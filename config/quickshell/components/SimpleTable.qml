// components/SimpleTable.qml
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../themes"

Rectangle {
    id: tableRoot
    implicitWidth: 400
    implicitHeight: 300

    property var model: null

    // --- Properties for Table Container ---
    property color tableBackgroundColor: Kirigami.Theme.backgroundColor
    property color tableBorderColor: Kirigami.Theme.frameColor
    property int tableBorderWidth: 1
    property real tableRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    // --- Properties for Header ---
    // (No changes needed for header text properties from columns for now, but could be added similarly)
    property color headerBackgroundColor: Qt.tint(Kirigami.Theme.backgroundColor, 1.05)
    property color headerTextColor: Kirigami.Theme.textColor
    property font headerFont: Kirigami.Theme.font(Kirigami.Theme.FontWeight.Bold, Kirigami.Theme.FontSize.Small)
    property color headerBorderColor: Kirigami.Theme.frameColor
    property int headerBorderWidth: 1
    property int headerHeight: Kirigami.Units.gridUnit * 2

    // --- DEFAULT Properties for Cells/Rows Text (used if not overridden by columnDef) ---
    property color cellTextColor: Kirigami.Theme.textColor
    property font cellFont: Kirigami.Theme.font(Kirigami.Theme.FontWeight.Normal, Kirigami.Theme.FontSize.Small)
    property var cellElideMode: Text.ElideRight // Default elide mode
    property var cellWrapMode: Text.NoWrap      // Default wrap mode
    // Default horizontalAlignment is handled per column if `alignment` is present in columnDef,
    // otherwise Text.AlignLeft is used by the Text element itself.
    // Default verticalAlignment is Text.AlignVCenter.

    // --- General Cell Properties ---
    property color cellBackgroundColor: Kirigami.Theme.backgroundColor
    property color alternatingCellBackgroundColor: Kirigami.Theme.alternateBackgroundColor
    property color cellBorderColor: Kirigami.Theme.frameColor
    property int cellBorderWidth: 1
    property int rowHeight: Kirigami.Units.gridUnit * 2

    // --- General Table Properties ---
    property var columns: []
    property int cellPadding: Kirigami.Units.smallSpacing
    property bool showVerticalGridLines: true
    property bool showHorizontalGridLines: true

    color: tableBackgroundColor
    border.color: tableBorderColor
    border.width: tableBorderWidth > 0 ? tableBorderWidth : 0
    radius: tableRadius

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        columns: tableRoot.columns.length > 0 ? tableRoot.columns.length : 1

        // --- Header Row ---
        Repeater {
            id: headerRepeater
            model: tableRoot.columns
            delegate: Rectangle {
                readonly property var columnDef: modelData // columnDef from headerRepeater
                Layout.preferredHeight: tableRoot.headerHeight
                Layout.preferredWidth: columnDef.width ? columnDef.width : ((tableRoot.width - (tableRoot.tableBorderWidth * 2)) / (tableRoot.columns.length || 1))
                Layout.fillWidth: !columnDef.width
                color: tableRoot.headerBackgroundColor
                border.color: tableRoot.headerBorderColor
                border.width: tableRoot.headerBorderWidth > 0 && (tableRoot.showVerticalGridLines || tableRoot.showHorizontalGridLines) ? tableRoot.headerBorderWidth : 0
                clip: true
                Text {
                    text: columnDef.title
                    // Check for column-specific header text properties (can be added similar to cell text)
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

        // --- Data Cells (Flat List) ---
        Repeater {
            id: allDataCellsRepeater
            model: (tableRoot.model && tableRoot.columns.length > 0) ? (tableRoot.model.count * tableRoot.columns.length) : 0
            delegate: Rectangle {
                readonly property int rowIndex: Math.floor(index / tableRoot.columns.length)
                readonly property int colIndex: index % tableRoot.columns.length
                readonly property var columnDef: tableRoot.columns[colIndex] // columnDef from allDataCellsRepeater
                readonly property var rowData: tableRoot.model.get(rowIndex)

                Layout.preferredHeight: tableRoot.rowHeight
                Layout.preferredWidth: columnDef.width ? columnDef.width : ((tableRoot.width - (tableRoot.tableBorderWidth * 2)) / (tableRoot.columns.length || 1))
                Layout.fillWidth: !columnDef.width
                color: rowIndex % 2 === 0 ? tableRoot.cellBackgroundColor : tableRoot.alternatingCellBackgroundColor
                border.color: tableRoot.cellBorderColor
                border.width: tableRoot.cellBorderWidth > 0 && (tableRoot.showVerticalGridLines || tableRoot.showHorizontalGridLines) ? tableRoot.cellBorderWidth : 0
                clip: true

                Text {
                    text: rowData && columnDef ? rowData[columnDef.role] : ""

                    // Apply column-specific or default text properties
                    font: columnDef.cellFont !== undefined ? columnDef.cellFont : tableRoot.cellFont
                    color: columnDef.cellTextColor !== undefined ? columnDef.cellTextColor : tableRoot.cellTextColor
                    elide: columnDef.cellElideMode !== undefined ? columnDef.cellElideMode : tableRoot.cellElideMode
                    wrapMode: columnDef.cellWrapMode !== undefined ? columnDef.cellWrapMode : tableRoot.cellWrapMode
                    horizontalAlignment: columnDef.alignment !== undefined ? columnDef.alignment : Text.AlignLeft // 'alignment' was already for horizontal
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
