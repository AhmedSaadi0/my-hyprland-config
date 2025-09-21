// settings/HyprlandSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("Hyprland Settings")
    titleTopMargin: 10
    titlePixelSize: selectedTheme.typography.heading1Size
    titleFontWeight: Font.ExtraBold

    property var workingTheme
    property var selectedTheme

    signal applyChanges
    signal saveChanges
    signal cancelChanges
    signal resetToDefault

    ColumnLayout {
        id: mainLayout
        spacing: selectedTheme.dimensions.spacingSmall

        // ====================================================================
        // --- القسم الأول: المظهر والتخطيط (Appearance & Layout) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Appearance & Layout")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium

            SliderWithLabel {
                label: qsTr("Rounding")
                from: 0
                to: 50
                value: workingTheme._hyprRounding
                onEditingFinished: finalValue => {
                    workingTheme._hyprRounding = finalValue;
                    root.applyChanges();
                }
            }
            SliderWithLabel {
                label: qsTr("Border Width")
                from: 0
                to: 10
                value: workingTheme._hyprBorderWidth
                onEditingFinished: finalValue => {
                    workingTheme._hyprBorderWidth = finalValue;
                    root.applyChanges();
                }
            }
            SliderWithLabel {
                label: qsTr("Gaps In")
                from: 0
                to: 50
                value: workingTheme._hyprGapsIn
                onEditingFinished: finalValue => {
                    workingTheme._hyprGapsIn = finalValue;
                    root.applyChanges();
                }
            }

            Controls.Label {
                text: qsTr("Gaps Out")
                font.bold: true
            }
            SettingsHelperText {
                text: qsTr("The gap between windows and the screen edge. Can be one value, or four for top, right, bottom, left (e.g., '10, 20, 10, 20').")
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: workingTheme._hyprGapsOut
                selectedTheme: root.selectedTheme
                onEditingFinished: {
                    workingTheme._hyprGapsOut = text;
                    root.applyChanges();
                }
            }

            Controls.Label {
                text: qsTr("Layout Name")
                font.bold: true
            }
            SettingsHelperText {
                text: qsTr("The algorithm used to arrange windows. 'dwindle' creates a spiral layout, 'master' creates a main window with a stack.")
            }
            SettingsComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                model: ["dwindle", "master"]
                editText: workingTheme._hyprLayout
                editable: true
                onAccepted: {
                    if (editText !== workingTheme._hyprLayout) {
                        workingTheme._hyprLayout = editText;
                        root.applyChanges();
                    }
                }
            }

            Controls.Label {
                text: qsTr("Active Border Color")
                font.bold: true
            }
            SettingsHelperText {
                text: qsTr("Supports color gradients. Format: 'rgba(color1) rgba(color2) angle'. Example: 'rgba(ff0000ff) rgba(00ff00ff) 45deg'.")
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: workingTheme._hyprActiveBorder
                selectedTheme: root.selectedTheme
                onEditingFinished: {
                    workingTheme._hyprActiveBorder = text;
                    root.applyChanges();
                }
            }

            Controls.Label {
                text: qsTr("Inactive Border Color")
                font.bold: true
            }
            EditableField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: workingTheme._hyprInactiveBorder
                selectedTheme: root.selectedTheme
                onEditingFinished: {
                    workingTheme._hyprInactiveBorder = text;
                    root.applyChanges();
                }
            }
        }

        Kirigami.Separator {
            Layout.topMargin: selectedTheme.dimensions.spacingLarge
        }

        // ====================================================================
        // --- القسم الثاني: المؤثرات البصرية (Visual Effects) ---
        // ====================================================================
        Controls.Label {
            text: qsTr("Visual Effects")
            font.pixelSize: selectedTheme.typography.heading2Size
            font.bold: true
            Layout.topMargin: selectedTheme.dimensions.spacingMedium
        }

        SettingSwitch {
            id: _blurSwitch
            label: qsTr("Enable Background Blur")
            isChecked: workingTheme._hyprBlurEnabled
            onIsCheckedChanged: {
                workingTheme._hyprBlurEnabled = isChecked;
                root.applyChanges();
            }
        }
        ColumnLayout {
            enabled: _blurSwitch.isChecked
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            SliderWithLabel {
                label: qsTr("Blur Size")
                from: 1
                to: 30
                value: workingTheme._hyprBlurSize
                onEditingFinished: finalValue => {
                    workingTheme._hyprBlurSize = finalValue;
                    root.applyChanges();
                }
            }
            SliderWithLabel {
                label: qsTr("Blur Passes")
                from: 1
                to: 5
                value: workingTheme._hyprBlurPasses
                onEditingFinished: finalValue => {
                    workingTheme._hyprBlurPasses = finalValue;
                    root.applyChanges();
                }
            }
            SettingsHelperText {
                text: qsTr("More passes improve blur quality but use more GPU resources. 2-3 passes is often a good balance.")
            }
        }

        SettingSwitch {
            id: _dropShadowSwitch
            label: qsTr("Enable Drop Shadow")
            isChecked: workingTheme._hyprDropShadow === 'yes'
            onIsCheckedChanged: {
                workingTheme._hyprDropShadow = isChecked ? 'yes' : 'no';
                root.applyChanges();
            }
            Layout.topMargin: selectedTheme.dimensions.spacingMedium
        }
        ColumnLayout {
            enabled: _dropShadowSwitch.isChecked
            Layout.fillWidth: true
            spacing: selectedTheme.dimensions.spacingMedium
            SliderWithLabel {
                label: qsTr("Shadow Range")
                from: 0
                to: 60
                value: workingTheme._hyprShadowRange
                onEditingFinished: finalValue => {
                    workingTheme._hyprShadowRange = finalValue;
                    root.applyChanges();
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: selectedTheme.dimensions.spacingMedium
                Controls.Label {
                    text: qsTr("Shadow Offset (X, Y)")
                    font.bold: true
                }
                EditableField {
                    text: workingTheme._hyprShadowOffset.x.toString()
                    validator: IntValidator {}
                    selectedTheme: root.selectedTheme
                    onEditingFinished: {
                        workingTheme._hyprShadowOffset.x = Number(text);
                        root.applyChanges();
                    }
                }
                EditableField {
                    text: workingTheme._hyprShadowOffset.y.toString()
                    validator: IntValidator {}
                    selectedTheme: root.selectedTheme
                    onEditingFinished: {
                        workingTheme._hyprShadowOffset.y = Number(text);
                        root.applyChanges();
                    }
                }
            }
            Controls.Label {
                text: qsTr("Shadow Color")
                font.bold: true
            }
            EditableField {
                Layout.fillWidth: true
                text: workingTheme._hyprShadowColor
                selectedTheme: root.selectedTheme
                onEditingFinished: {
                    workingTheme._hyprShadowColor = text;
                    root.applyChanges();
                }
            }
        }

        SettingSwitch {
            id: _dimSwitch
            label: qsTr("Dim Inactive Windows")
            isChecked: workingTheme._hyprDimInactive
            onIsCheckedChanged: {
                workingTheme._hyprDimInactive = isChecked;
                root.applyChanges();
            }
            Layout.topMargin: selectedTheme.dimensions.spacingMedium
        }
        ColumnLayout {
            enabled: _dimSwitch.isChecked
            Layout.fillWidth: true
            SliderWithLabel {
                label: qsTr("Dim Strength")
                from: 0.0
                to: 1.0
                stepSize: 0.01
                decimals: 2
                value: workingTheme._hyprDimStrength
                onEditingFinished: finalValue => {
                    workingTheme._hyprDimStrength = finalValue;
                    root.applyChanges();
                }
            }
        }

        Kirigami.Separator {
            Layout.topMargin: selectedTheme.dimensions.spacingLarge
        }

        // ====================================================================
        // --- القسم الثالث: الحركات (Animations) ---
        // ====================================================================
        SettingSwitch {
            id: _animationsSwitch
            label: qsTr("Enable Animations")
            isChecked: workingTheme._hyprAnimationsEnabled
            onIsCheckedChanged: {
                workingTheme._hyprAnimationsEnabled = isChecked;
                root.applyChanges();
            }
        }
        // ColumnLayout {
        //     enabled: _animationsSwitch.isChecked
        //     Layout.fillWidth: true
        //     spacing: selectedTheme.dimensions.spacingMedium
        //
        //     Controls.Label {
        //         text: qsTr("Bézier Curve")
        //         font.bold: true
        //     }
        //     SettingsHelperText {
        //         text: qsTr("Defines the 'feel' of the animation (e.g., speed up, slow down, bounce). You can define multiple curves.")
        //     }
        //     EditableField {
        //         Layout.fillWidth: true
        //         text: workingTheme._hyprBezier
        //         selectedTheme: root.selectedTheme
        //         onEditingFinished: {
        //             workingTheme._hyprBezier = text;
        //             root.applyChanges();
        //         }
        //     }
        //
        //     Controls.Label {
        //         text: qsTr("Windows Animation Style")
        //         font.bold: true
        //     }
        //     SettingsHelperText {
        //         text: qsTr("Controls how windows appear/disappear. Format: 'speed, curve, style'. Speed is 1-10. Curve is a Bézier name. Style e.g. 'slide', 'fade'.")
        //     }
        //     EditableField {
        //         Layout.fillWidth: true
        //         text: workingTheme._hyprAnimWindows
        //         selectedTheme: root.selectedTheme
        //         onEditingFinished: {
        //             workingTheme._hyprAnimWindows = text;
        //             root.applyChanges();
        //         }
        //     }
        //
        //     Controls.Label {
        //         text: qsTr("Workspaces Animation Style")
        //         font.bold: true
        //     }
        //     SettingsHelperText {
        //         text: qsTr("Controls the transition between workspaces. Uses the same format as windows animations. Example: '6, default, slide'.")
        //     }
        //     EditableField {
        //         Layout.fillWidth: true
        //         text: workingTheme._hyprAnimWorkspaces
        //         selectedTheme: root.selectedTheme
        //         onEditingFinished: {
        //             workingTheme._hyprAnimWorkspaces = text;
        //             root.applyChanges();
        //         }
        //     }
        // }
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
