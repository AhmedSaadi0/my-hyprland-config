import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

ColumnLayout {
    id: headerRoot

    // --- Signals ---
    signal addTask(string title, bool urgent)
    signal openCalendar

    // --- Properties ---
    property date selectedDate

    // Theme Helpers
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    // --- Layout Settings ---
    Layout.fillWidth: true
    spacing: dims.spacingLarge

    // --- Functions ---
    // دالة لجمع منطق الإضافة من الزر ومن مفتاح Enter
    function submitNewTask() {
        if (taskInput.text.trim() !== "") {
            headerRoot.addTask(taskInput.text, urgentBtn.checked);
            taskInput.text = "";
            urgentBtn.checked = false;
        }
    }

    // --- Visual Elements ---

    // 1. Header Title
    Text {
        text: "Tasks"
        font.family: typo.bodyFont
        font.pixelSize: typo.heading2Size
        font.bold: true
        color: colors.leftMenuFgColorV1
        opacity: 0.9
        Layout.leftMargin: 4
    }

    // 2. Input Card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 140

        color: colors.tertiary.alpha(0.2)
        radius: dims.elementRadius

        // Border styling with focus state
        border.width: taskInput.activeFocus ? 1.5 : 1
        border.color: taskInput.activeFocus ? Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.4) : Qt.rgba(colors.leftMenuFgColorV1.r, colors.leftMenuFgColorV1.g, colors.leftMenuFgColorV1.b, 0.05)

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            // Input Area
            TextArea {
                id: taskInput

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 10

                placeholderText: "Add a new task..."
                placeholderTextColor: colors.subtleText
                color: colors.leftMenuFgColorV1
                font.family: typo.bodyFont
                font.pixelSize: 15
                wrapMode: Text.Wrap
                background: null

                // Shift+Enter لسطر جديد، و Enter للإرسال
                Keys.onReturnPressed: event => {
                    if ((event.modifiers & Qt.ShiftModifier) == 0) {
                        headerRoot.submitNewTask();
                        event.accepted = true;
                    }
                }
            }

            // Bottom Toolbar
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Date Selector
                Button {
                    id: dateBtn
                    text: "📅 " + headerRoot.selectedDate.toLocaleDateString(Qt.locale(), "MMM d")

                    Layout.preferredHeight: 34
                    leftPadding: 14
                    rightPadding: 14
                    flat: true

                    onClicked: headerRoot.openCalendar()

                    background: Rectangle {
                        radius: dims.elementRadius
                        color: dateBtn.hovered ? Qt.rgba(colors.leftMenuFgColorV1.r, colors.leftMenuFgColorV1.g, colors.leftMenuFgColorV1.b, 0.08) : Qt.rgba(colors.leftMenuFgColorV1.r, colors.leftMenuFgColorV1.g, colors.leftMenuFgColorV1.b, 0.04)
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font.family: typo.bodyFont
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: colors.leftMenuFgColorV1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 0.8
                    }
                }

                // Urgent Toggle
                Button {
                    id: urgentBtn
                    checkable: true

                    Layout.preferredHeight: 36
                    Layout.preferredWidth: checked ? 100 : 90

                    // Button Animations
                    scale: pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    background: Rectangle {
                        radius: 18
                        color: urgentBtn.checked ? colors.error : "transparent"
                        border.width: urgentBtn.checked ? 0 : 1.5
                        border.color: urgentBtn.checked ? colors.error : colors.subtleText

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: urgentBtn.checked ? "🔥" : "🏳️"
                            font.pixelSize: 14
                            color: urgentBtn.checked ? "white" : colors.subtleText
                            Layout.leftMargin: 10

                            rotation: urgentBtn.checked ? 0 : -15
                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutBack
                                }
                            }
                        }

                        Text {
                            text: urgentBtn.checked ? "URGENT" : "Normal"
                            font.family: typo.bodyFont
                            font.pixelSize: 12
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                            color: urgentBtn.checked ? "white" : colors.subtleText
                            Layout.rightMargin: 5
                        }
                    }
                }

                // Spacer
                Item {
                    Layout.fillWidth: true
                }

                // Submit Button
                Button {
                    id: addTaskBtn

                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 34

                    onClicked: headerRoot.submitNewTask()

                    background: Rectangle {
                        radius: 17
                        color: addTaskBtn.pressed ? Qt.darker(colors.primary, 1.1) : colors.primary
                        layer.enabled: true
                    }

                    contentItem: Text {
                        text: "➤"
                        font.pixelSize: 16
                        color: colors.onPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        bottomPadding: 2
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "Add Task"
                    ToolTip.delay: 500
                }
            }
        }
    }
}
