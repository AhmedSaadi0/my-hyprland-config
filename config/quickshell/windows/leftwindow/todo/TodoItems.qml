import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

ListView {
    id: todoList

    // --- Signals ---
    signal requestSave
    signal requestCalendar(int index)

    // --- Properties ---
    property var listModel

    // Theme Helpers
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    // --- Layout Settings ---
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true

    spacing: dims.spacingMedium
    topMargin: dims.spacingSmall
    bottomMargin: dims.spacingLarge

    // --- Model ---
    model: listModel

    // --- Transitions ---
    add: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 400
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            property: "y"
            from: -50
            duration: 400
            easing.type: Easing.OutBack
        }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 300
            }
            NumberAnimation {
                property: "height"
                to: 0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
    displaced: Transition {
        NumberAnimation {
            property: "y"
            duration: 400
            easing.type: Easing.OutQuint
        }
    }

    // --- Delegate ---
    delegate: MouseArea {
        id: itemRoot
        width: todoList.width

        // حساب الارتفاع: المحتوى + هوامش
        height: bgRect.height

        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: mouse => mouse.accepted = false

        property bool isEditing: false

        ListView.onRemove: removeAnim.start()

        SequentialAnimation {
            id: removeAnim
            PropertyAction {
                target: itemRoot
                property: "ListView.delayRemove"
                value: true
            }
            NumberAnimation {
                target: itemRoot
                property: "height"
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
            PropertyAction {
                target: itemRoot
                property: "ListView.delayRemove"
                value: false
            }
        }

        // --- Background Card (Original Styles) ---
        Rectangle {
            id: bgRect
            width: parent.width
            height: mainLayout.implicitHeight + 24 // Dynamic height based on content
            radius: dims.elementRadius

            // 1. Original Border Logic
            border.width: 1
            border.color: isEditing ? Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.5) : Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.05)

            // 2. Original Color Logic
            color: {
                if (model.completed)
                    return Qt.rgba(colors.leftMenuBgColorV3.r, colors.leftMenuBgColorV3.g, colors.leftMenuBgColorV3.b, 0.5);
                if (itemRoot.containsMouse || isEditing)
                    return Qt.lighter(colors.leftMenuBgColorV2, 1.2);
                return colors.leftMenuBgColorV1;
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            // 3. Original Side Bar
            Rectangle {
                width: 4
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 8
                anchors.leftMargin: 6
                radius: 2
                color: {
                    if (model.completed)
                        return colors.subtleText;
                    if (model.isUrgent)
                        return colors.error;
                    return colors.primary;
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
                }
            }

            // --- Main Content Column ---
            ColumnLayout {
                id: mainLayout
                anchors.fill: parent
                anchors.leftMargin: 20 // Space for side bar
                anchors.rightMargin: dims.spacingLarge
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 8 // Space between Title Row and Footer Row

                // --- TOP ROW: Checkbox + Title ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: dims.spacingLarge
                    Layout.alignment: Qt.AlignTop

                    // Checkbox (Original Style)
                    CheckBox {
                        id: completionCheck
                        checked: model.completed
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 2
                        enabled: !isEditing

                        onClicked: {
                            model.completed = checked;
                            if (checked)
                                isEditing = false;
                            todoList.requestSave();
                        }

                        indicator: Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 8
                            color: completionCheck.checked ? colors.success : "transparent"
                            border.width: 1.5
                            border.color: completionCheck.checked ? colors.success : colors.subtleText
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                color: colors.onSuccess
                                font.pixelSize: 14
                                font.bold: true
                                visible: completionCheck.checked
                                scale: visible ? 1 : 0
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }
                        }
                    }

                    // Title Text (View Mode)
                    Text {
                        visible: !isEditing
                        text: model.title
                        font.family: typo.bodyFont
                        font.pixelSize: typo.medium
                        font.strikeout: model.completed
                        font.bold: !model.completed
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        opacity: model.completed ? 0.6 : 1
                        color: model.completed ? colors.subtleText : colors.leftMenuFgColorV1
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    // Title Input (Edit Mode)
                    TextArea {
                        id: editInput
                        visible: isEditing
                        Layout.fillWidth: true
                        text: model.title
                        font.family: typo.bodyFont
                        font.pixelSize: typo.medium
                        font.bold: true
                        wrapMode: Text.Wrap
                        color: colors.leftMenuFgColorV1
                        // Original Edit Background
                        background: Rectangle {
                            color: Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.05)
                            radius: 4
                        }
                        Keys.onReturnPressed: event => {
                            if ((event.modifiers & Qt.ShiftModifier) == 0) {
                                model.title = editInput.text;
                                isEditing = false;
                                todoList.requestSave();
                                event.accepted = true;
                            }
                        }
                    }
                }

                // --- BOTTOM ROW: Metadata & Actions ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // --- Left Side: Date & Urgent Badge ---

                    // Date (View Mode)
                    Text {
                        visible: !isEditing
                        text: model.date
                        font.family: typo.bodyFont
                        font.pixelSize: typo.small - 1
                        color: colors.subtleText
                        opacity: 0.8
                    }

                    // Urgent Badge (View Mode)
                    Rectangle {
                        visible: !isEditing && model.isUrgent && !model.completed
                        width: urgentText.implicitWidth + 10
                        height: urgentText.implicitHeight + 4
                        radius: 4
                        color: Qt.rgba(colors.error.r, colors.error.g, colors.error.b, 0.15)
                        Text {
                            id: urgentText
                            anchors.centerIn: parent
                            text: "URGENT"
                            font.family: typo.bodyFont
                            font.pixelSize: 9
                            font.bold: true
                            color: colors.error
                        }
                    }

                    // Date Button (Edit Mode - Original Style reused)
                    Button {
                        id: dateBtnItem
                        visible: isEditing
                        text: "📅 " + model.date
                        Layout.preferredHeight: 30 // Slightly smaller for footer
                        leftPadding: 10
                        rightPadding: 10
                        flat: true
                        onClicked: todoList.requestCalendar(index)

                        background: Rectangle {
                            radius: dims.elementRadius
                            color: dateBtnItem.hovered ? Qt.rgba(colors.leftMenuFgColorV1.r, colors.leftMenuFgColorV1.g, colors.leftMenuFgColorV1.b, 0.08) : Qt.rgba(colors.leftMenuFgColorV1.r, colors.leftMenuFgColorV1.g, colors.leftMenuFgColorV1.b, 0.04)
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

                    // Urgent Toggle (Edit Mode - Original Style reused)
                    Button {
                        id: urgentBtnItem
                        visible: isEditing
                        checkable: true
                        checked: model.isUrgent
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: checked ? 90 : 80
                        onClicked: model.isUrgent = !model.isUrgent

                        background: Rectangle {
                            radius: 15
                            color: urgentBtnItem.checked ? colors.error : "transparent"
                            border.width: urgentBtnItem.checked ? 0 : 1.5
                            border.color: urgentBtnItem.checked ? colors.error : colors.subtleText
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Text {
                                text: urgentBtnItem.checked ? "🔥" : "🏳️"
                                font.pixelSize: 12
                                color: urgentBtnItem.checked ? "white" : colors.subtleText
                            }
                            Text {
                                text: urgentBtnItem.checked ? "URGENT" : "Normal"
                                font.pixelSize: 10
                                font.bold: true
                                color: urgentBtnItem.checked ? "white" : colors.subtleText
                            }
                        }
                    }

                    // Spacer to push buttons to right
                    Item {
                        Layout.fillWidth: true
                    }

                    // --- Right Side: Action Buttons (Original Logic) ---

                    // Edit/Save Button
                    Button {
                        id: editBtn
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        visible: !model.completed

                        // Original Opacity Logic
                        flat: true
                        opacity: isEditing || itemRoot.containsMouse || editBtn.hovered ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }

                        onClicked: {
                            if (isEditing) {
                                if (editInput.text.trim() !== "") {
                                    model.title = editInput.text;
                                    isEditing = false;
                                    todoList.requestSave();
                                }
                            } else {
                                editInput.text = model.title;
                                isEditing = true;
                                editInput.forceActiveFocus();
                            }
                        }

                        background: Rectangle {
                            radius: dims.elementRadius
                            color: editBtn.hovered ? Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.1) : "transparent"
                        }

                        contentItem: Text {
                            text: isEditing ? "✓" : "✎"
                            color: editBtn.hovered ? colors.primary : colors.subtleText
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: isEditing ? "Save" : "Edit"
                    }

                    // Delete Button
                    Button {
                        id: deleteBtn
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        visible: !isEditing

                        // Original Opacity Logic
                        flat: true
                        opacity: itemRoot.containsMouse || deleteBtn.hovered ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }

                        onClicked: {
                            todoList.listModel.remove(index);
                            todoList.requestSave();
                        }

                        background: Rectangle {
                            radius: dims.elementRadius
                            color: deleteBtn.hovered ? Qt.rgba(colors.error.r, colors.error.g, colors.error.b, 0.1) : "transparent"
                        }

                        contentItem: Text {
                            text: "✕"
                            color: deleteBtn.hovered ? colors.error : colors.subtleText
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "Delete"
                    }
                }
            }
        }
    }
}
