pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/components"

M3GroupBox {
    id: root
    title: "Clock Widget Settings"
    Layout.fillWidth: true

    property var selectedTheme
    property var workingTheme

    cornerRadius: selectedTheme.dimensions.elementRadius

    property bool alphaMatting: false
    property int foregroundThreshold: 240
    property int backgroundThreshold: 10
    property int erodeSize: 10

    signal createOverlayImageButtonClicked(var data)
    signal openOverlayImageDialog
    signal themeChanged

    GridLayout {
        columns: 1
        Layout.fillWidth: true
        rowSpacing: 5
        columnSpacing: 10

        SettingSwitch {
            id: _enableClockWidget
            label: "Enable Clock Widget"
            isChecked: workingTheme._desktopClockEnabled
            onIsCheckedChanged: {
                workingTheme._desktopClockEnabled = isChecked;
                root.themeChanged();
            }
        }

        SettingSwitch {
            id: _enableClockThemeColor
            label: "Theme Color"
            isChecked: workingTheme._desktopClockUseThemeColor
            onIsCheckedChanged: {
                workingTheme._desktopClockUseThemeColor = isChecked;
                root.themeChanged();
            }
            enabled: _enableClockWidget.isChecked
        }

        ColorableSettingTextField {
            label: "Clock Color"
            textValue: Qt.color(workingTheme._desktopClockColor).toString()
            enabled: _enableClockWidget.isChecked && !_enableClockThemeColor.isChecked
            onColorUpdated: {
                workingTheme._desktopClockColor = newColor;
            }
            onAccepted: {
                root.themeChanged();
            }
        }

        SettingSwitch {
            id: _enableShadow
            label: "Enable Shadow"
            isChecked: workingTheme._desktopClockSahdowEnabled
            onIsCheckedChanged: {
                workingTheme._desktopClockSahdowEnabled = isChecked;
                root.themeChanged();
            }
            enabled: _enableClockWidget.isChecked
        }

        ColorableSettingTextField {
            label: "Shadow Color"
            textValue: Qt.color(workingTheme._desktopClockSahdowColor).toString()
            onColorUpdated: {
                workingTheme._desktopClockSahdowColor = newColor;
            }
            onAccepted: {
                root.themeChanged();
            }
            enabled: _enableShadow.isChecked && _enableClockWidget.isChecked
        }

        SettingTextField {
            label: "Clock Format"
            textValue: workingTheme._desktopClockFormat
            selectedTheme: root.selectedTheme
            enabled: _enableClockWidget.isChecked
            onEditFinished: {
                workingTheme._desktopClockFormat = text;
            }
            onAccepted: {
                root.themeChanged();
            }
        }

        SettingTextField {
            label: "Clock Local"
            textValue: workingTheme._desktopClockLocal
            selectedTheme: root.selectedTheme
            enabled: _enableClockWidget.isChecked
            onEditFinished: {
                workingTheme._desktopClockLocal = text;
            }
            onAccepted: {
                root.themeChanged();
            }
        }

        SettingTextField {
            label: "Clock Font"
            textValue: workingTheme._desktopClockFont
            selectedTheme: root.selectedTheme
            enabled: _enableClockWidget.isChecked
            onEditFinished: {
                workingTheme._desktopClockFont = text;
            }
            onAccepted: {
                root.themeChanged();
            }
        }

        Rectangle {
            Layout.fillWidth: true
            // Layout.columnSpan: 2
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.preferredHeight: 1
            color: root.selectedTheme.colors.topbarFgColorV1.alpha(0.2)
            enabled: workingTheme._desktopClockEnabled
        }

        SettingSwitch {
            id: _enableDepthEffectSwitch
            label: "Enable Depth Effect"
            isChecked: workingTheme._desktopClockDepthEffectEnabled
            onIsCheckedChanged: {
                workingTheme._desktopClockDepthEffectEnabled = isChecked;
                root.themeChanged();
            }
            enabled: _enableClockWidget.isChecked
        }

        RowLayout {
            Label {
                text: "AI Model"
                Layout.alignment: Qt.AlignVCenter
            }
            ComboBox {
                id: modelComboBox
                Layout.fillWidth: true
                enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked

                model: ["u2net", "isnet-general-use"]

                currentIndex: workingTheme._desktopClockDepthModel ? model.indexOf(workingTheme._desktopClockDepthModel) : 0

                onCurrentTextChanged: {
                    workingTheme._desktopClockDepthModel = currentText;
                }

                background: Rectangle {
                    anchors.fill: parent
                    radius: selectedTheme.dimensions.elementRadius
                    color: modelComboBox.enabled ? selectedTheme.colors.topbarBgColorV2 : Theme.ThemeManager.selectedTheme.colors.topbarBgColorV2.alpha(0.5)
                    // border.color: modelComboBox.enabled ? selectedTheme.colors.secondary : Theme.ThemeManager.selectedTheme.colors.secondary.alpha(0.5)
                    // border.width: 1

                }

                contentItem: Text {
                    text: modelComboBox.displayText

                    font: modelComboBox.font

                    color: modelComboBox.enabled ? selectedTheme.colors.topbarFgColorV2 : selectedTheme.colors.topbarFgColorV2.alpha(0.5)

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft

                    elide: Text.ElideRight

                    rightPadding: modelComboBox.indicator.width + modelComboBox.spacing
                }
            }
        }

        SettingSwitch {
            id: _enableAlphaMatting
            label: "Alpha Matting"
            isChecked: root.alphaMatting
            onIsCheckedChanged: {
                root.alphaMatting = isChecked;
                workingTheme.alphaMatting = isChecked;
            }
            enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked
        }

        SettingTextField {
            label: "BG Threshold"
            textValue: root.backgroundThreshold
            selectedTheme: root.selectedTheme
            enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked && _enableAlphaMatting.isChecked
            onEditFinished: workingTheme.backgroundThreshold = text
        }

        SettingTextField {
            label: "FG Threshold"
            textValue: root.foregroundThreshold
            selectedTheme: root.selectedTheme
            enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked && _enableAlphaMatting.isChecked
            onEditFinished: workingTheme.foregroundThreshold = text
        }

        SettingTextField {
            label: "Erode Size"
            textValue: root.erodeSize
            selectedTheme: root.selectedTheme
            enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked && _enableAlphaMatting.isChecked
            onEditFinished: workingTheme.erodeSize = text
        }

        SettingButton {
            label: "Create Overlay Image"
            enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked
            buttonText: "Create..."
            buttonIcon: ""
            onClicked: root.createOverlayImageButtonClicked({
                model: workingTheme._desktopClockDepthModel,
                alphaMatting: root.alphaMatting,
                foregroundThreshold: root.foregroundThreshold,
                backgroundThreshold: root.backgroundThreshold,
                erodeSize: root.erodeSize
            })
        }

        SettingButton {
            label: "Overlay Image"
            enabled: _enableClockWidget.isChecked && _enableDepthEffectSwitch.isChecked
            buttonText: workingTheme._desktopClockDepthOverlayPath || "Select Image..."
            buttonIcon: ""
            onClicked: root.openOverlayImageDialog()
        }
    }
}
