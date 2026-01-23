// windows/settings/LayoutSettings.qml

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import Qt.labs.platform

import "root:/components"
import "root:/config"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    // --- Header ---
    title: qsTr("Layout & Fonts")
    icon: ""
    showApplyButton: true

    // --- Local State ---
    // Typography
    property string localIconFont: ""
    property string localBodyFont: ""

    // Font Sizes
    property int localBaseFontSize: 12
    property int localMediumFontSize: 14
    property int localSmallFontSize: 12
    property int localHeading1Size: 22
    property int localHeading2Size: 20
    property int localHeading3Size: 18
    property int localHeading4Size: 16

    // Spacing
    property int localSpacingSmall: 4
    property int localSpacingMedium: 8
    property int localSpacingLarge: 12

    // Dimensions (Radii & Layout)
    property int localElementRadius: 12
    property int localBarHeight: 30
    property int localBarBottomMargin: 10
    property int localBarWidgetsHeight: 22
    property int localMenuHeight: 900
    property int localMenuWidth: 380
    property int localMenuWidgetsMargin: 15

    function syncFromTheme() {
        // Fonts
        localIconFont = theme._iconFont;
        localBodyFont = theme._bodyFont;

        // Font Sizes
        localBaseFontSize = theme._baseFontSize;
        localMediumFontSize = theme._mediumFontSize;
        localSmallFontSize = theme._smallFontSize;
        localHeading1Size = theme._heading1Size;
        localHeading2Size = theme._heading2Size;
        localHeading3Size = theme._heading3Size;
        localHeading4Size = theme._heading4Size;

        // Spacing
        localSpacingSmall = theme._spacingSmall;
        localSpacingMedium = theme._spacingMedium;
        localSpacingLarge = theme._spacingLarge;

        // Dimensions
        localElementRadius = theme._elementRadius;
        localBarHeight = theme._barHeight;
        localBarBottomMargin = theme._barBottomMargin;
        localBarWidgetsHeight = theme._barWidgetsHeight;
        localMenuHeight = theme._menuHeight;
        localMenuWidth = theme._menuWidth;
        localMenuWidgetsMargin = theme._menuWidgetsMargin;
    }

    function serializeData() {
        return {
            // Typography
            "_iconFont": localIconFont,
            "_bodyFont": localBodyFont,

            // Sizes
            "_baseFontSize": localBaseFontSize,
            "_mediumFontSize": localMediumFontSize,
            "_smallFontSize": localSmallFontSize,
            "_heading1Size": localHeading1Size,
            "_heading2Size": localHeading2Size,
            "_heading3Size": localHeading3Size,
            "_heading4Size": localHeading4Size,

            // Spacing
            "_spacingSmall": localSpacingSmall,
            "_spacingMedium": localSpacingMedium,
            "_spacingLarge": localSpacingLarge,

            // Dimensions
            "_elementRadius": localElementRadius,
            "_barHeight": localBarHeight,
            "_barBottomMargin": localBarBottomMargin,
            "_barWidgetsHeight": localBarWidgetsHeight,
            "_menuHeight": localMenuHeight,
            "_menuWidth": localMenuWidth,
            "_menuWidgetsMargin": localMenuWidgetsMargin
        };
    }

    // --- Font Dialog ---
    FontDialog {
        id: fontDialog
        property var activeCallback: null
        onAccepted: {
            if (activeCallback)
                activeCallback(font.family);
            activeCallback = null;
        }
        onRejected: activeCallback = null
    }

    // 1. Size Field Component (للأرقام)
    component SizeRow: ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        property string label
        property int value: 0
        signal userChanged(int newValue)

        Controls.Label {
            text: qsTr(parent.label)
        }

        EditableField {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.minimumWidth: 50
            text: value.toString()
            selectedTheme: root.theme
            validator: IntValidator {
                bottom: 0
            }
            onEditingFinished: {
                let num = parseInt(text);
                if (!isNaN(num))
                    userChanged(num);
            }
        }
    }

    // 2. Font Field Component (للخطوط)
    component FontRow: ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        property string label
        property string value: ""
        property bool isIconFont: false
        signal userChanged(string newValue)

        Controls.Label {
            text: qsTr(parent.label)
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.minimumWidth: 50
                text: value
                selectedTheme: root.theme
                onEditingFinished: userChanged(text)
            }
            MButton {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 30
                text: ""
                font.family: isIconFont ? value : root.theme.typography.iconFont
                onClicked: {
                    fontDialog.currentFont.family = value;
                    fontDialog.activeCallback = f => userChanged(f);
                    fontDialog.open();
                }
            }
        }
    }

    // --- Main Layout ---
    ColumnLayout {
        spacing: root.dim("spacingMedium", 10)
        Layout.preferredWidth: 590

        // ==========================
        // --- Typography Section ---
        // ==========================
        Controls.Label {
            text: qsTr("Typography")
            font.pixelSize: root.typ("heading2Size", 18)
            font.bold: true
            Layout.topMargin: 10
        }

        // Fonts Name
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            FontRow {
                label: "Icon Font"
                value: root.localIconFont
                isIconFont: true
                onUserChanged: v => {
                    root.localIconFont = v;
                    root.applySingleProperty("_iconFont", v);
                }
            }
            FontRow {
                label: "Body Font"
                value: root.localBodyFont
                onUserChanged: v => {
                    root.localBodyFont = v;
                    root.applySingleProperty("_bodyFont", v);
                }
            }
        }

        // Font Sizes
        Controls.Label {
            text: qsTr("Font Sizes")
            font.bold: true
            Layout.topMargin: 15
        }

        GridLayout {
            columns: 3
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 10
            uniformCellWidths: true

            SizeRow {
                label: "Base"
                value: root.localBaseFontSize
                onUserChanged: v => {
                    root.localBaseFontSize = v;
                    root.applySingleProperty("_baseFontSize", v);
                }
            }
            SizeRow {
                label: "Medium"
                value: root.localMediumFontSize
                onUserChanged: v => {
                    root.localMediumFontSize = v;
                    root.applySingleProperty("_mediumFontSize", v);
                }
            }
            SizeRow {
                label: "Small"
                value: root.localSmallFontSize
                onUserChanged: v => {
                    root.localSmallFontSize = v;
                    root.applySingleProperty("_smallFontSize", v);
                }
            }

            SizeRow {
                label: "Heading 1"
                value: root.localHeading1Size
                onUserChanged: v => {
                    root.localHeading1Size = v;
                    root.applySingleProperty("_heading1Size", v);
                }
            }
            SizeRow {
                label: "Heading 2"
                value: root.localHeading2Size
                onUserChanged: v => {
                    root.localHeading2Size = v;
                    root.applySingleProperty("_heading2Size", v);
                }
            }
            SizeRow {
                label: "Heading 3"
                value: root.localHeading3Size
                onUserChanged: v => {
                    root.localHeading3Size = v;
                    root.applySingleProperty("_heading3Size", v);
                }
            }
            SizeRow {
                label: "Heading 4"
                value: root.localHeading4Size
                onUserChanged: v => {
                    root.localHeading4Size = v;
                    root.applySingleProperty("_heading4Size", v);
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: 15
        }

        // ===================================
        // --- Dimensions & Spacing Section ---
        // ===================================
        Controls.Label {
            text: qsTr("Dimensions & Spacing")
            font.pixelSize: root.typ("heading2Size", 18)
            font.bold: true
            Layout.topMargin: 10
        }

        // Spacing
        Controls.Label {
            text: qsTr("Spacing")
            font.bold: true
        }
        GridLayout {
            columns: 3
            Layout.fillWidth: true
            columnSpacing: 15
            uniformCellWidths: true

            SizeRow {
                label: "Small"
                value: root.localSpacingSmall
                onUserChanged: v => {
                    root.localSpacingSmall = v;
                    root.applySingleProperty("_spacingSmall", v);
                }
            }
            SizeRow {
                label: "Medium"
                value: root.localSpacingMedium
                onUserChanged: v => {
                    root.localSpacingMedium = v;
                    root.applySingleProperty("_spacingMedium", v);
                }
            }
            SizeRow {
                label: "Large"
                value: root.localSpacingLarge
                onUserChanged: v => {
                    root.localSpacingLarge = v;
                    root.applySingleProperty("_spacingLarge", v);
                }
            }
        }

        // Radii
        Controls.Label {
            text: qsTr("Corner Radii")
            font.bold: true
            Layout.topMargin: 10
        }
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 15

            SizeRow {
                label: "Element Radius"
                value: root.localElementRadius
                onUserChanged: v => {
                    root.localElementRadius = v;
                    root.applySingleProperty("_elementRadius", v);
                }
            }
        }

        // Bar & Menu Layouts
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 15
            spacing: 20

            // Bar Settings Column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Controls.Label {
                    text: qsTr("Bar")
                    font.bold: true
                }
                GridLayout {
                    columns: 1
                    Layout.fillWidth: true
                    rowSpacing: 10

                    SizeRow {
                        label: "Height"
                        value: root.localBarHeight
                        onUserChanged: v => {
                            root.localBarHeight = v;
                            root.applySingleProperty("_barHeight", v);
                        }
                    }
                    SizeRow {
                        label: "Bottom Margin"
                        value: root.localBarBottomMargin
                        onUserChanged: v => {
                            root.localBarBottomMargin = v;
                            root.applySingleProperty("_barBottomMargin", v);
                        }
                    }
                    SizeRow {
                        label: "Widgets Height"
                        value: root.localBarWidgetsHeight
                        onUserChanged: v => {
                            root.localBarWidgetsHeight = v;
                            root.applySingleProperty("_barWidgetsHeight", v);
                        }
                    }
                }
            }

            // Menu Settings Column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Controls.Label {
                    text: qsTr("Menu")
                    font.bold: true
                }
                GridLayout {
                    columns: 1
                    Layout.fillWidth: true
                    rowSpacing: 10

                    SizeRow {
                        label: "Height"
                        value: root.localMenuHeight
                        onUserChanged: v => {
                            root.localMenuHeight = v;
                            root.applySingleProperty("_menuHeight", v);
                        }
                    }
                    SizeRow {
                        label: "Width"
                        value: root.localMenuWidth
                        onUserChanged: v => {
                            root.localMenuWidth = v;
                            root.applySingleProperty("_menuWidth", v);
                        }
                    }
                    SizeRow {
                        label: "Widgets Margin"
                        value: root.localMenuWidgetsMargin
                        onUserChanged: v => {
                            root.localMenuWidgetsMargin = v;
                            root.applySingleProperty("_menuWidgetsMargin", v);
                        }
                    }
                }
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
            width: 1
        }
    }
}
