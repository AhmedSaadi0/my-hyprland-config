// windows/leftwindow/todo/TodoView.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"
import "root:/components"
import "root:/services"
import "../base"

BaseMenuView {
    id: root

    menuTitle: qsTr("Todo")
    menuIcon: "󰄳"
    showPrimaryAction: false

    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    property date selectedDate: new Date()
    property int activeCalendarIndex: -1

    function addTask(title, urgent) {
        TodoService.addTask(title, root.selectedDate, urgent);
    }

    headerContent: TodoHeader {
        width: root.width
        selectedDate: root.selectedDate
        onOpenCalendar: {
            root.activeCalendarIndex = -1;
            calendarPopup.open();
        }
        onAddTask: (title, urgent) => root.addTask(title, urgent)
    }

    // المحتوى الرئيسي
    ColumnLayout {
        Layout.fillWidth: true
        spacing: root.dims.spacingLarge

        Layout.leftMargin: root.dims.menuWidgetsMargin
        Layout.rightMargin: root.dims.menuWidgetsMargin
        Layout.topMargin: root.dims.menuWidgetsMargin

        // --- 1. كرت الذكاء الاصطناعي ---
        AISummaryCard {
            id: smartTodoCard
            Layout.fillWidth: true
            visible: TodoService.aiSummaryText !== ""

            title: TodoService.aiSummaryTitle !== "" ? TodoService.aiSummaryTitle : qsTr("المحلل الذكي")
            summaryText: TodoService.aiSummaryText
            iconText: "✨"

            showDataRefreshButton: false
            showAiRefreshButton: true

            bottomContent: Flow {
                Layout.fillWidth: true
                spacing: 6
                visible: TodoService.aiSummaryTags && TodoService.aiSummaryTags.length > 0

                Repeater {
                    model: TodoService.aiSummaryTags
                    delegate: Rectangle {
                        height: 24
                        width: tagText.contentWidth + 16
                        color: smartTodoCard.aiBorderColor.alpha(0.1)
                        radius: 6
                        border.color: smartTodoCard.aiBorderColor.alpha(0.2)
                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 11
                            color: smartTodoCard.aiTextColor
                        }
                    }
                }
            }
        }

        // --- 2. المهام العاجلة (Due Now) ---
        ColumnLayout {
            Layout.fillWidth: true
            visible: TodoService.dueNowModel.count > 0
            spacing: 10

            Text {
                text: qsTr("Due Now")
                font.family: root.typo.bodyFont
                font.pixelSize: 13
                font.bold: true
                color: root.colors.error
                opacity: 0.9
                Layout.leftMargin: 4
            }

            Repeater {
                model: TodoService.dueNowModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: root.dims.elementRadius
                    color: Qt.rgba(root.colors.error.r, root.colors.error.g, root.colors.error.b, 0.08)
                    border.width: 1
                    border.color: Qt.rgba(root.colors.error.r, root.colors.error.g, root.colors.error.b, 0.15)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: isUrgent ? "🔥" : "⏰"
                            font.pixelSize: 16
                        }

                        Text {
                            text: title
                            font.family: root.typo.bodyFont
                            font.pixelSize: root.typo.small
                            color: root.colors.leftMenuFgColorV1
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: date
                            font.family: root.typo.bodyFont
                            font.pixelSize: 10
                            color: root.colors.error
                            opacity: 0.8
                        }
                    }
                }
            }
        }

        // --- 3. بقية المهام
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            Layout.bottomMargin: root.dims.menuWidgetsMargin

            TodoItems {
                id: tasksList
                Layout.fillWidth: true
                // TODO: -> Convert 64 to a const and use it instead
                Layout.preferredHeight: contentHeight + 4

                listModel: TodoService.tasksModel
                onRequestSave: TodoService.saveAndSort()
                onRequestCalendar: index => {
                    root.activeCalendarIndex = index;
                    calendarPopup.open();
                }
            }
        }
    }

    CustomCalendar {
        id: calendarPopup
        x: (root.width - width) / 2
        y: 80
        z: 100
        onDateSelected: date => {
            if (root.activeCalendarIndex === -1) {
                root.selectedDate = date;
            } else {
                TodoService.updateTaskDate(root.activeCalendarIndex, date);
            }
        }
    }
}
