pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform

import "root:/components"
import "root:/themes"
import "root:/windows/settings/components"

BaseThemeSettings {
    id: root

    title: qsTr("Layout & Fonts")
    icon: ""
    showApplyButton: true

    property string localIconFont: ""
    property string localBodyFont: ""

    property int localBaseFontSize: 12
    property int localMediumFontSize: 14
    property int localSmallFontSize: 12
    property int localHeading1Size: 22
    property int localHeading2Size: 20
    property int localHeading3Size: 18
    property int localHeading4Size: 16

    property int localSpacingSmall: 4
    property int localSpacingMedium: 8
    property int localSpacingLarge: 12

    property int localElementRadius: 12
    property int localBarHeight: 30
    property int localBarBottomMargin: 10
    property int localBarWidgetsHeight: 22
    property int localMenuHeight: 900
    property int localMenuWidth: 380
    property int localMenuWidgetsMargin: 15

    function syncFromTheme() {
        localIconFont = theme._iconFont;
        localBodyFont = theme._bodyFont;

        localBaseFontSize = theme._baseFontSize;
        localMediumFontSize = theme._mediumFontSize;
        localSmallFontSize = theme._smallFontSize;
        localHeading1Size = theme._heading1Size;
        localHeading2Size = theme._heading2Size;
        localHeading3Size = theme._heading3Size;
        localHeading4Size = theme._heading4Size;

        localSpacingSmall = theme._spacingSmall;
        localSpacingMedium = theme._spacingMedium;
        localSpacingLarge = theme._spacingLarge;

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
            "_iconFont": localIconFont,
            "_bodyFont": localBodyFont,
            "_baseFontSize": localBaseFontSize,
            "_mediumFontSize": localMediumFontSize,
            "_smallFontSize": localSmallFontSize,
            "_heading1Size": localHeading1Size,
            "_heading2Size": localHeading2Size,
            "_heading3Size": localHeading3Size,
            "_heading4Size": localHeading4Size,
            "_spacingSmall": localSpacingSmall,
            "_spacingMedium": localSpacingMedium,
            "_spacingLarge": localSpacingLarge,
            "_elementRadius": localElementRadius,
            "_barHeight": localBarHeight,
            "_barBottomMargin": localBarBottomMargin,
            "_barWidgetsHeight": localBarWidgetsHeight,
            "_menuHeight": localMenuHeight,
            "_menuWidth": localMenuWidth,
            "_menuWidgetsMargin": localMenuWidgetsMargin
        };
    }

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

    component PreviewBox: Rectangle {
        property alias text: previewLabel.text
        property alias previewFont: previewLabel.font

        Layout.fillWidth: true
        color: root.theme.colors.leftMenuBgColorV2.alpha(0.65)
        radius: root.theme.dimensions.baseRadius / 1.5
        border.color: root.theme.colors.primary.alpha(0.14)
        border.width: 1
        implicitHeight: previewLabel.implicitHeight + 22

        Controls.Label {
            id: previewLabel
            anchors.fill: parent
            anchors.margins: 11
            color: root.theme.colors.leftMenuFgColorV1
            wrapMode: Text.WordWrap
        }
    }

    component FontPickerRow: ColumnLayout {
        property string label: ""
        property string value: ""
        property string previewText: ""
        property bool isIconFont: false
        signal userChanged(string newValue)

        Layout.fillWidth: true
        spacing: 6

        Controls.Label {
            text: label
            font.bold: true
            color: root.theme.colors.leftMenuFgColorV1
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                selectedTheme: root.theme
                horizontalAlignment: Text.AlignLeft
                text: value
                onEditingFinished: userChanged(text)
            }

            MButton {
                text: qsTr("Choose")
                Layout.preferredWidth: 88
                onClicked: {
                    fontDialog.currentFont.family = value;
                    fontDialog.activeCallback = fontFamily => userChanged(fontFamily);
                    fontDialog.open();
                }
            }
        }

        PreviewBox {
            text: previewText
            previewFont.family: value
            previewFont.pixelSize: isIconFont ? 18 : root.localBaseFontSize
        }
    }

    ColumnLayout {
        spacing: root.dim("spacingMedium", 8)
        Layout.preferredWidth: 620

        SettingsHelperText {
            Layout.fillWidth: true
            Layout.preferredWidth: 580
            text: qsTr("This page controls typography and shell proportions. The controls below focus on the values that affect readability and spacing the most.")
        }

        SectionCard {
            title: qsTr("Fonts")
            subtitle: qsTr("Choose the body font for normal text and the icon font used in workspace indicators, buttons, and glyph-based widgets.")

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                FontPickerRow {
                    Layout.fillWidth: true
                    label: qsTr("Body Font")
                    value: root.localBodyFont
                    previewText: qsTr("The quick brown fox jumps over the lazy dog. 1234567890")
                    onUserChanged: newValue => {
                        root.localBodyFont = newValue;
                        root.applySingleProperty("_bodyFont", newValue);
                    }
                }

                FontPickerRow {
                    Layout.fillWidth: true
                    label: qsTr("Icon Font")
                    value: root.localIconFont
                    isIconFont: true
                    previewText: "󰋜 󰿣 󰂔 󰉋 󱙋 󰭹"
                    onUserChanged: newValue => {
                        root.localIconFont = newValue;
                        root.applySingleProperty("_iconFont", newValue);
                    }
                }
            }
        }

        SectionCard {
            title: qsTr("Typography Scale")
            subtitle: qsTr("These values control how large text appears across widgets, menus, and section headers.")

            SliderWithLabel {
                Layout.fillWidth: true
                label: qsTr("Base Text")
                from: 10
                to: 20
                value: root.localBaseFontSize
                onEditingFinished: v => {
                    root.localBaseFontSize = v;
                    root.applySingleProperty("_baseFontSize", v);
                }
            }

            SliderWithLabel {
                Layout.fillWidth: true
                label: qsTr("Medium Text")
                from: 10
                to: 24
                value: root.localMediumFontSize
                onEditingFinished: v => {
                    root.localMediumFontSize = v;
                    root.applySingleProperty("_mediumFontSize", v);
                }
            }

            SliderWithLabel {
                Layout.fillWidth: true
                label: qsTr("Small Text")
                from: 8
                to: 18
                value: root.localSmallFontSize
                onEditingFinished: v => {
                    root.localSmallFontSize = v;
                    root.applySingleProperty("_smallFontSize", v);
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 8

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Heading 1")
                    from: 16
                    to: 34
                    value: root.localHeading1Size
                    onEditingFinished: v => {
                        root.localHeading1Size = v;
                        root.applySingleProperty("_heading1Size", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Heading 2")
                    from: 14
                    to: 30
                    value: root.localHeading2Size
                    onEditingFinished: v => {
                        root.localHeading2Size = v;
                        root.applySingleProperty("_heading2Size", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Heading 3")
                    from: 12
                    to: 26
                    value: root.localHeading3Size
                    onEditingFinished: v => {
                        root.localHeading3Size = v;
                        root.applySingleProperty("_heading3Size", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Heading 4")
                    from: 11
                    to: 24
                    value: root.localHeading4Size
                    onEditingFinished: v => {
                        root.localHeading4Size = v;
                        root.applySingleProperty("_heading4Size", v);
                    }
                }
            }

            PreviewBox {
                text: qsTr("Preview: headings and labels will follow the body font and size scale you choose here.")
                previewFont.family: root.localBodyFont
                previewFont.pixelSize: root.localMediumFontSize
            }
        }

        SectionCard {
            title: qsTr("Spacing & Radius")
            subtitle: qsTr("Use these controls to make the interface denser or more relaxed without touching every component manually.")

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 8

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Small Spacing")
                    from: 0
                    to: 24
                    value: root.localSpacingSmall
                    onEditingFinished: v => {
                        root.localSpacingSmall = v;
                        root.applySingleProperty("_spacingSmall", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Medium Spacing")
                    from: 0
                    to: 32
                    value: root.localSpacingMedium
                    onEditingFinished: v => {
                        root.localSpacingMedium = v;
                        root.applySingleProperty("_spacingMedium", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Large Spacing")
                    from: 0
                    to: 40
                    value: root.localSpacingLarge
                    onEditingFinished: v => {
                        root.localSpacingLarge = v;
                        root.applySingleProperty("_spacingLarge", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Element Radius")
                    from: 0
                    to: 36
                    value: root.localElementRadius
                    onEditingFinished: v => {
                        root.localElementRadius = v;
                        root.applySingleProperty("_elementRadius", v);
                    }
                }
            }
        }

        SectionCard {
            title: qsTr("Shell Layout")
            subtitle: qsTr("These values control the physical size of bars and menus across the shell.")

            Controls.Label {
                text: qsTr("Bar")
                font.bold: true
                color: root.theme.colors.primary
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 8

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Bar Height")
                    from: 22
                    to: 64
                    value: root.localBarHeight
                    onEditingFinished: v => {
                        root.localBarHeight = v;
                        root.applySingleProperty("_barHeight", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Bottom Margin")
                    from: 0
                    to: 40
                    value: root.localBarBottomMargin
                    onEditingFinished: v => {
                        root.localBarBottomMargin = v;
                        root.applySingleProperty("_barBottomMargin", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Widgets Height")
                    from: 16
                    to: 44
                    value: root.localBarWidgetsHeight
                    onEditingFinished: v => {
                        root.localBarWidgetsHeight = v;
                        root.applySingleProperty("_barWidgetsHeight", v);
                    }
                }
            }

            Controls.Label {
                text: qsTr("Menu")
                font.bold: true
                color: root.theme.colors.primary
                Layout.topMargin: 8
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 8

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Menu Height")
                    from: 420
                    to: 1400
                    stepSize: 10
                    value: root.localMenuHeight
                    onEditingFinished: v => {
                        root.localMenuHeight = v;
                        root.applySingleProperty("_menuHeight", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Menu Width")
                    from: 240
                    to: 720
                    stepSize: 10
                    value: root.localMenuWidth
                    onEditingFinished: v => {
                        root.localMenuWidth = v;
                        root.applySingleProperty("_menuWidth", v);
                    }
                }

                SliderWithLabel {
                    Layout.fillWidth: true
                    label: qsTr("Widgets Margin")
                    from: 0
                    to: 48
                    value: root.localMenuWidgetsMargin
                    onEditingFinished: v => {
                        root.localMenuWidgetsMargin = v;
                        root.applySingleProperty("_menuWidgetsMargin", v);
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
            width: 1
        }
    }
}
