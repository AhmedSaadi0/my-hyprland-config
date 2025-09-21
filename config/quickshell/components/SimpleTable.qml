// components/SimpleTable.qml

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../themes"

Rectangle {
    id: tableRoot
    implicitWidth: 400
    implicitHeight: headerRowLayout.height + dataGridLayout.height

    clip: true

    property var model: null

    // --- Properties for Table Container ---
    property color tableBackgroundColor: Kirigami.Theme.backgroundColor
    property color tableBorderColor: Kirigami.Theme.positiveBackgroundColor
    property int tableBorderWidth: 2
    property real tableRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    // --- Properties for Header ---
    property color headerBackgroundColor: Kirigami.Theme.backgroundColor
    property color headerTextColor: Kirigami.Theme.textColor
    property font headerFont: Qt.font({
        pixelSize: ThemeManager.selectedTheme.typography.heading4Size,
        bold: true
    })
    property color headerBorderColor: headerBackgroundColor
    property int headerBorderWidth: 1
    property int headerHeight: Kirigami.Units.gridUnit * 2.5
    property int headerCellSpacing: 0

    // --- DEFAULT Properties for Cells/Rows Text ---
    property color cellTextColor: Kirigami.Theme.textColor
    property font cellFont: Qt.font({
        pixelSize: ThemeManager.selectedTheme.typography.medium
    })
    property var cellElideMode: Text.ElideRight
    property var cellWrapMode: Text.NoWrap

    // --- Properties for Sub-Value Text ---
    property color subCellTextColor: Kirigami.Theme.positiveTextColor
    property font subCellFont: Qt.font({
        pixelSize: ThemeManager.selectedTheme.typography.small - 3
    })

    // --- General Cell Properties ---
    property color cellBackgroundColor: Kirigami.Theme.backgroundColor
    property color alternatingCellBackgroundColor: Kirigami.Theme.alternateBackgroundColor
    property color cellBorderColor: Kirigami.Theme.positiveBackgroundColor
    property int cellBorderWidth: 1
    property int rowHeight: Kirigami.Units.gridUnit * 3
    property int cellColumnSpacing: 0
    property int cellRowSpacing: 1

    // --- General Table Properties ---
    property var columns: []
    property int cellLeftMargin: Kirigami.Units.smallSpacing
    property int cellRightMargin: Kirigami.Units.smallSpacing
    property bool showVerticalGridLines: true
    property bool showHorizontalGridLines: true

    color: tableBackgroundColor
    border.color: tableBorderColor
    border.width: tableBorderWidth > 0 ? tableBorderWidth : 0
    radius: tableRadius

    ColumnLayout {
        id: tableContentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0

        RowLayout {
            id: headerRowLayout
            Layout.fillWidth: true
            height: tableRoot.headerHeight
            spacing: tableRoot.headerCellSpacing

            Repeater {
                id: headerRepeater
                model: tableRoot.columns
                delegate: Rectangle {
                    // ... (Header delegate remains unchanged) ...
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
                        anchors.leftMargin: columnDef.leftMargin !== undefined ? columnDef.leftMargin : tableRoot.cellLeftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: columnDef.rightMargin !== undefined ? columnDef.rightMargin : tableRoot.cellRightMargin
                    }
                }
            }
        }

        GridLayout {
            id: dataGridLayout
            Layout.fillWidth: true
            columns: tableRoot.columns.length > 0 ? tableRoot.columns.length : 1
            columnSpacing: tableRoot.cellColumnSpacing
            rowSpacing: tableRoot.cellRowSpacing

            Repeater {
                id: allDataCellsRepeater
                model: (tableRoot.model && tableRoot.columns.length > 0) ? (tableRoot.model.count * tableRoot.columns.length) : 0
                delegate: Rectangle {
                    readonly property int rowIndex: Math.floor(index / tableRoot.columns.length)
                    readonly property int colIndex: index % tableRoot.columns.length
                    readonly property var columnDef: tableRoot.columns[colIndex]
                    readonly property var rowData: tableRoot.model.get(rowIndex)
                    readonly property bool isFirstCellInCol: colIndex === 0
                    readonly property bool isLastCellInCol: colIndex === (tableRoot.columns.length - 1)
                    readonly property bool isLastRow: (tableRoot.model && rowIndex === (tableRoot.model.count - 1))

                    readonly property bool hasSubValue: !!(rowData && rowData.subRole) && isLastCellInCol

                    Layout.preferredHeight: tableRoot.rowHeight
                    Layout.preferredWidth: columnDef.width ? columnDef.width : ((dataGridLayout.width - (tableRoot.cellColumnSpacing * (tableRoot.columns.length - 1))) / (tableRoot.columns.length || 1))
                    Layout.fillWidth: true
                    color: rowIndex % 2 === 0 ? tableRoot.cellBackgroundColor : tableRoot.alternatingCellBackgroundColor
                    border.color: tableRoot.cellBorderColor
                    border.width: (tableRoot.cellBorderWidth > 0 && (tableRoot.showVerticalGridLines || tableRoot.showHorizontalGridLines)) ? tableRoot.cellBorderWidth : 0
                    clip: true
                    bottomLeftRadius: (isFirstCellInCol && isLastRow) ? tableRoot.tableRadius : 0
                    bottomRightRadius: (isLastCellInCol && isLastRow) ? tableRoot.tableRadius : 0

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: columnDef.leftMargin !== undefined ? columnDef.leftMargin : tableRoot.cellLeftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: columnDef.rightMargin !== undefined ? columnDef.rightMargin : tableRoot.cellRightMargin

                        spacing: -8

                        Text {
                            text: rowData && columnDef ? (rowData[columnDef.role] ?? "") : ""
                            font: columnDef.cellFont !== undefined ? columnDef.cellFont : tableRoot.cellFont
                            color: columnDef.cellTextColor !== undefined ? columnDef.cellTextColor : tableRoot.cellTextColor
                            elide: columnDef.cellElideMode !== undefined ? columnDef.cellElideMode : tableRoot.cellElideMode
                            wrapMode: columnDef.cellWrapMode !== undefined ? columnDef.cellWrapMode : tableRoot.cellWrapMode
                            horizontalAlignment: columnDef.alignment !== undefined ? columnDef.alignment : Text.AlignLeft
                            Layout.alignment: horizontalAlignment
                        }

                        Text {
                            readonly property int mainAlignment: columnDef.alignment !== undefined ? columnDef.alignment : Text.AlignLeft

                            visible: hasSubValue
                            text: hasSubValue ? rowData.subRole : ""
                            font: columnDef.subCellFont !== undefined ? columnDef.subCellFont : tableRoot.subCellFont
                            color: columnDef.subCellTextColor !== undefined ? columnDef.subCellTextColor : tableRoot.subCellTextColor
                            elide: columnDef.cellElideMode !== undefined ? columnDef.cellElideMode : tableRoot.cellElideMode
                            wrapMode: columnDef.cellWrapMode !== undefined ? columnDef.cellWrapMode : tableRoot.cellWrapMode
                            horizontalAlignment: mainAlignment
                            Layout.alignment: mainAlignment
                        }
                    }
                }
            }
        }
    }
}
