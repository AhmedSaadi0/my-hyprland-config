// settings/AppearanceSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("Layout & Fonts")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    signal openFontDialog(string targetedProperty)
    signal applyChanges
    signal saveChanges
    signal cancelChanges
    signal resetToDefault

    function createSizeField(parent, label, property) {
        var qmlString = `
            import QtQuick;
            import QtQuick.Layouts;
            import QtQuick.Controls as Controls;
            import "root:/components";

            ColumnLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("` + label + `") }
                EditableField {
                    Layout.fillWidth: true; Layout.preferredHeight: 30
                    text: workingTheme.` + property + `.toString()
                    selectedTheme: root.selectedTheme
                    validator: IntValidator { bottom: 1 }
                    onEditingFinished: { workingTheme.` + property + ` = Number(text); root.applyChanges(); }
                }
            }
        `;

        return Qt.createQmlObject(qmlString, parent);
    }

    ColumnLayout {
        id: mainLayout
        spacing: selectedTheme.dimensions.spacingSmall

        // ====================================================================
        // --- القسم الأول: الطباعة (Typography) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Typography")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        // --- أسماء الخطوط ---
        RowLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            ColumnLayout {
                Layout.fillWidth: true
                Controls.Label {
                    text: qsTr("Icon Font")
                    font.bold: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: workingTheme._iconFont
                        selectedTheme: root.selectedTheme
                        onEditingFinished: {
                            workingTheme._iconFont = text;
                            root.applyChanges();
                        }
                    }
                    MButton {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 30
                        text: ""
                        font.family: selectedTheme.typography.iconFont
                        onClicked: root.openFontDialog("_iconFont")
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Controls.Label {
                    text: qsTr("Body Font")
                    font.bold: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    EditableField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: workingTheme._bodyFont
                        selectedTheme: root.selectedTheme
                        onEditingFinished: {
                            workingTheme._bodyFont = text;
                            root.applyChanges();
                        }
                    }
                    MButton {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 30
                        text: ""
                        font.family: selectedTheme.typography.iconFont
                        onClicked: root.openFontDialog("_bodyFont")
                    }
                }
            }
        }

        // --- أحجام الخطوط ---
        Controls.Label {
            text: qsTr("Font Sizes")
            font.bold: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }
        GridLayout {
            id: fontSizesGrid
            Layout.fillWidth: true
            columns: 3
            columnSpacing: selectedTheme.dimensions.spacingMedium
            rowSpacing: selectedTheme.dimensions.spacingSmall

            Component.onCompleted: {
                createSizeField(fontSizesGrid, "Base", "_baseFontSize");
                createSizeField(fontSizesGrid, "Medium", "_mediumFontSize");
                createSizeField(fontSizesGrid, "Small", "_smallFontSize");
                createSizeField(fontSizesGrid, "Heading 1", "_heading1Size");
                createSizeField(fontSizesGrid, "Heading 2", "_heading2Size");
                createSizeField(fontSizesGrid, "Heading 3", "_heading3Size");
                createSizeField(fontSizesGrid, "Heading 4", "_heading4Size");
            }
        }

        Kirigami.Separator {
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // ====================================================================
        // --- القسم الثاني: الأبعاد والمسافات (Dimensions & Spacing) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Dimensions & Spacing")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }

        // --- المسافات ---
        Controls.Label {
            text: qsTr("Spacing")
            font.bold: true
            Layout.topMargin: Kirigami.Units.mediumSpacing
        }
        GridLayout {
            id: spacingGrid
            Layout.fillWidth: true
            columns: 3
            columnSpacing: selectedTheme.dimensions.spacingMedium
            Component.onCompleted: {
                createSizeField(spacingGrid, "Small", "_spacingSmall");
                createSizeField(spacingGrid, "Medium", "_spacingMedium");
                createSizeField(spacingGrid, "Large", "_spacingLarge");
            }
        }

        // --- أنصاف الأقطار ---
        Controls.Label {
            text: qsTr("Corner Radii")
            font.bold: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }
        GridLayout {
            id: radiiGrid
            Layout.fillWidth: true
            columns: 2
            columnSpacing: selectedTheme.dimensions.spacingMedium
            Component.onCompleted: {
                // createSizeField(radiiGrid, "Base Radius", "_baseRadius");
                createSizeField(radiiGrid, "Element Radius", "_elementRadius");
            }
        }

        // --- الشريط والقائمة ---
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            spacing: selectedTheme.dimensions.spacingMedium

            ColumnLayout {
                // Bar Settings
                Layout.fillWidth: true
                Controls.Label {
                    text: qsTr("Bar")
                    font.bold: true
                }
                GridLayout {
                    id: barGrid
                    Layout.fillWidth: true
                    columns: 1
                    rowSpacing: selectedTheme.dimensions.spacingSmall
                    Component.onCompleted: {
                        createSizeField(barGrid, "Height", "_barHeight");
                        createSizeField(barGrid, "Bottom Margin", "_barBottomMargin");
                        createSizeField(barGrid, "Widgets Height", "_barWidgetsHeight");
                    }
                }
            }

            ColumnLayout {
                // Menu Settings
                Layout.fillWidth: true
                Controls.Label {
                    text: qsTr("Menu")
                    font.bold: true
                }
                GridLayout {
                    id: menuGrid
                    Layout.fillWidth: true
                    columns: 1
                    rowSpacing: selectedTheme.dimensions.spacingSmall
                    Component.onCompleted: {
                        createSizeField(menuGrid, "Height", "_menuHeight");
                        createSizeField(menuGrid, "Width", "_menuWidth");
                        createSizeField(menuGrid, "Widgets Margin", "_menuWidgetsMargin");
                    }
                }
            }
        }
    }

    footer: RowLayout {
        spacing: selectedTheme.dimensions.spacingMedium

        MButton {
            text: "Reset to default"
            Layout.preferredWidth: 150
            onClicked: resetToDefault()
        }
        MButton {
            text: "Cancel"
            Layout.preferredWidth: 80
            onClicked: cancelChanges()
        }

        Item {
            Layout.fillWidth: true
        }

        MButton {
            text: "Save"
            Layout.preferredWidth: 80
            highlighted: true
            onClicked: saveChanges()
        }
    }
}
