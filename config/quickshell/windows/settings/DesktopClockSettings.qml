pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("Desktop Clock Settings")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    property bool isCreatingOverlayImage: false

    property bool alphaMatting: false
    property int foregroundThreshold: 240
    property int backgroundThreshold: 10
    property int erodeSize: 10

    signal applyChanges
    signal saveChanges
    signal cancelChanges
    signal openOverlayFileDialog
    signal openFontDialog
    signal openShadowColorDialog
    signal openClockColorDialog
    signal resetToDefault
    signal createOverlayImageButtonClicked(var data)
    signal clearUnusedCache

    ColumnLayout {
        id: mainLayout
        spacing: selectedTheme.dimensions.spacingSmall

        // --- بداية: قسم تفعيل ساعة سطح المكتب ---
        SettingSwitch {
            id: _clockEnabledSwitch
            label: qsTr("Enable Desktop Clock")
            isChecked: workingTheme._desktopClockEnabled
            font.bold: true
            font.pixelSize: selectedTheme.typography.heading3Size
            onIsCheckedChanged: {
                workingTheme._desktopClockEnabled = isChecked;
                root.applyChanges();
            }
        }
        Controls.Label {
            text: qsTr("Display a customizable clock on the desktop.")
            font.pixelSize: selectedTheme.typography.small
            color: selectedTheme.colors.subtleText
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 500
        }

        // --- بداية: القسم العام (الخط، الصيغة، اللغة) ---
        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            enabled: _clockEnabledSwitch.isChecked
            spacing: 0

            Controls.Label {
                text: qsTr("General")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            Controls.Label {
                text: qsTr("Font")
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
            }
            RowLayout {
                Layout.fillWidth: true
                EditableField {
                    text: workingTheme._desktopClockFont
                    selectedTheme: root.selectedTheme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    onEditingFinished: {
                        workingTheme._desktopClockFont = text;
                        root.applyChanges();
                    }
                }
                MButton {
                    text: ""
                    font: selectedTheme.typography.iconFont
                    onClicked: root.openFontDialog()
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 40
                }
            }

            RowLayout {
                Layout.topMargin: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Format")
                        font.bold: true
                    }
                    EditableField {
                        text: workingTheme._desktopClockFormat
                        selectedTheme: root.selectedTheme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            workingTheme._desktopClockFormat = text;
                            root.applyChanges();
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: qsTr("Locale")
                        font.bold: true
                    }
                    EditableField {
                        text: workingTheme._desktopClockLocal
                        selectedTheme: root.selectedTheme
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onEditingFinished: {
                            workingTheme._desktopClockLocal = text;
                            root.applyChanges();
                        }
                    }
                }
            }
        }

        // --- بداية: قسم المظهر (الألوان، الظل، الحركة) ---
        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            enabled: _clockEnabledSwitch.isChecked
            spacing: 0

            Controls.Label {
                text: qsTr("Appearance")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            RowLayout {
                Layout.topMargin: Kirigami.Units.mediumSpacing
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    SettingSwitch {
                        id: _useThemeColorSwitch
                        label: qsTr("Use theme color")
                        isChecked: workingTheme._desktopClockUseThemeColor
                        font.bold: true
                        onIsCheckedChanged: {
                            workingTheme._desktopClockUseThemeColor = isChecked;
                            root.applyChanges();
                        }
                    }
                    ColumnLayout {
                        enabled: !_useThemeColorSwitch.isChecked
                        Layout.fillWidth: true
                        Controls.Label {
                            text: qsTr("Clock Color")
                            font.bold: true
                        }
                        RowLayout {

                            EditableField {
                                text: workingTheme._desktopClockColor.toString()
                                selectedTheme: root.selectedTheme
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                onEditingFinished: {
                                    workingTheme._desktopClockColor = text;
                                    root.applyChanges();
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                color: workingTheme._desktopClockColor.toString()
                                border.color: "gray"
                                border.width: 1
                                radius: selectedTheme.dimensions.elementRadius
                            }
                            MButton {
                                text: "󰃉"
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                onClicked: root.openClockColorDialog()
                            }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: selectedTheme.dimensions.spacingLarge
                    SettingSwitch {
                        id: _shadowEnabledSwitch
                        label: qsTr("Enable shadow")
                        isChecked: workingTheme._desktopClockSahdowEnabled
                        font.bold: true
                        onIsCheckedChanged: {
                            workingTheme._desktopClockSahdowEnabled = isChecked;
                            root.applyChanges();
                        }
                    }
                    ColumnLayout {
                        enabled: _shadowEnabledSwitch.isChecked
                        Layout.fillWidth: true
                        Controls.Label {
                            text: qsTr("Shadow Color")
                            font.bold: true
                        }
                        RowLayout {
                            EditableField {
                                text: workingTheme._desktopClockSahdowColor.toString()
                                selectedTheme: root.selectedTheme
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                onEditingFinished: {
                                    workingTheme._desktopClockSahdowColor = text;
                                    root.applyChanges();
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                color: workingTheme._desktopClockSahdowColor.toString()
                                border.color: "gray"
                                border.width: 1
                                radius: selectedTheme.dimensions.elementRadius
                            }
                            MButton {
                                text: "󰃉"
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 30
                                onClicked: root.openShadowColorDialog()
                            }
                        }
                    }
                }
            }

            SettingSwitch {
                label: qsTr("Use animation")
                isChecked: workingTheme._desktopClockUseAnimation
                font.bold: true
                Layout.topMargin: Kirigami.Units.largeSpacing
                onIsCheckedChanged: {
                    workingTheme._desktopClockUseAnimation = isChecked;
                    root.applyChanges();
                }
            }
            Controls.Label {
                text: qsTr("Memory usage may increase with animation due to Qt text caching")
                font.pixelSize: selectedTheme.typography.small
                color: selectedTheme.colors.subtleText
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 500
            }

            ColumnLayout {
                visible: false
                Controls.Label {
                    text: qsTr("Position (X, Y)")
                    font.bold: true
                    Layout.topMargin: Kirigami.Units.mediumSpacing
                }
                RowLayout {
                    EditableField {
                        text: workingTheme._desktopClockPosition.x
                    }
                    EditableField {
                        text: workingTheme._desktopClockPosition.y
                    }
                }
            }

            ColumnLayout {
                visible: false
                Controls.Label {
                    text: qsTr("Size (Width, Height)")
                    font.bold: true
                    Layout.topMargin: Kirigami.Units.mediumSpacing
                }
                RowLayout {
                    EditableField {
                        text: workingTheme._desktopClockSize.width
                    }
                    EditableField {
                        text: workingTheme._desktopClockSize.height
                    }
                }
            }
        }

        // --- بداية: قسم تأثير العمق ---
        ColumnLayout {
            Layout.topMargin: Kirigami.Units.largeSpacing
            enabled: _clockEnabledSwitch.isChecked
            spacing: Kirigami.Units.smallSpacing

            Controls.Label {
                text: qsTr("Depth Effect")
                font.pixelSize: selectedTheme.typography.heading2Size
                font.bold: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            SettingSwitch {
                id: _depthEffectSwitch
                label: qsTr("Enable depth effect")
                isChecked: workingTheme._desktopClockDepthEffectEnabled
                font.bold: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
                onIsCheckedChanged: {
                    workingTheme._desktopClockDepthEffectEnabled = isChecked;
                    root.applyChanges();
                }
            }

            ColumnLayout {
                enabled: _depthEffectSwitch.isChecked && workingTheme._desktopClockDepthEffectEnabled

                RowLayout {
                    spacing: selectedTheme.dimensions.spacingLarge

                    Controls.Label {
                        text: qsTr("Model")
                        font.bold: true
                        Layout.topMargin: Kirigami.Units.mediumSpacing
                    }
                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["u2net", "isnet-general-use"]
                        Component.onCompleted: {
                            currentIndex = find(workingTheme._desktopClockDepthModel);
                        }
                        onCurrentTextChanged: {
                            if (workingTheme._desktopClockDepthModel !== currentText) {
                                workingTheme._desktopClockDepthModel = currentText;
                                root.applyChanges();
                            }
                        }
                    }

                    MButton {
                        text: "Create Overlay Image"
                        iconText: "󰙴"
                        enabled: _depthEffectSwitch.isChecked && !isCreatingOverlayImage
                        highlighted: true
                        textPreferredWidth: 4
                        iconPreferredWidth: 1
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 180
                        onClicked: {
                            const data = {
                                model: workingTheme._desktopClockDepthModel,
                                alphaMatting: root.alphaMatting,
                                foregroundThreshold: root.foregroundThreshold,
                                backgroundThreshold: root.backgroundThreshold,
                                erodeSize: root.erodeSize
                            };
                            root.createOverlayImageButtonClicked(data);
                        }
                    }
                }

                SettingSwitch {
                    id: _alphaMattingSwitch
                    label: "Alpha Matting"
                    isChecked: root.alphaMatting
                    enabled: _depthEffectSwitch.isChecked
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    onIsCheckedChanged: alphaMatting = isChecked
                }

                RowLayout {
                    enabled: _depthEffectSwitch.isChecked && _alphaMattingSwitch.isChecked
                    Layout.fillWidth: true
                    spacing: selectedTheme.dimensions.spacingMedium

                    ColumnLayout {
                        Controls.Label {
                            text: qsTr("BG Threshold")
                            font.bold: true
                            Layout.topMargin: Kirigami.Units.mediumSpacing
                        }

                        EditableField {
                            text: root.backgroundThreshold
                            selectedTheme: root.selectedTheme
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 170
                            onEditingFinished: root.backgroundThreshold = text
                        }
                    }

                    ColumnLayout {
                        Controls.Label {
                            text: qsTr("FG Threshold")
                            font.bold: true
                            Layout.topMargin: Kirigami.Units.mediumSpacing
                        }
                        EditableField {
                            text: root.foregroundThreshold
                            selectedTheme: root.selectedTheme
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 170
                            onEditingFinished: root.foregroundThreshold = text
                        }
                    }

                    ColumnLayout {
                        Controls.Label {
                            text: qsTr("Erode Size")
                            font.bold: true
                            Layout.topMargin: Kirigami.Units.mediumSpacing
                        }
                        EditableField {
                            text: root.erodeSize
                            selectedTheme: root.selectedTheme
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 170
                            onEditingFinished: root.erodeSize = text
                        }
                    }
                }

                Controls.Label {
                    text: qsTr("Overlay image path")
                    font.bold: true
                    Layout.topMargin: Kirigami.Units.mediumSpacing
                }
                RowLayout {
                    Layout.fillWidth: true
                    EditableField {
                        text: workingTheme._desktopClockDepthOverlayPath
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        selectedTheme: root.selectedTheme
                    }
                    MButton {
                        text: ""
                        font: selectedTheme.typography.iconFont
                        onClicked: root.openOverlayFileDialog()
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 40
                    }
                }
            }
        }
    }

    // --- بداية: قسم الأزرار السفلية (حفظ، إلغاء، استعادة) ---
    footer: RowLayout {
        spacing: selectedTheme.dimensions.spacingMedium

        MButton {
            text: "Reset to default"
            Layout.preferredWidth: 150
            onClicked: resetToDefault()
        }
        MButton {
            text: "Clear unused cache"
            Layout.preferredWidth: 150
            onClicked: clearUnusedCache()
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
