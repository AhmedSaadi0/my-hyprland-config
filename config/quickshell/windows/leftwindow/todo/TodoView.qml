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

    // ─── TodoHeader كهيدر يتمرر مع المحتوى ───────────────────────
    TodoHeader {
        width: parent.width
        selectedDate: root.selectedDate

        onOpenCalendar: {
            root.activeCalendarIndex = -1;
            calendarPopup.open();
        }
        onAddTask: (title, urgent) => root.addTask(title, urgent)
    }

    // ─── المحتوى ─────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: root.dims.menuWidgetsMargin
        Layout.rightMargin: root.dims.menuWidgetsMargin
        Layout.topMargin: root.dims.spacingMedium
        spacing: root.dims.spacingMedium

        // كرت الذكاء الاصطناعي
        AISummaryCard {
            id: smartTodoCard
            Layout.fillWidth: true
            visible: TodoService.aiSummaryText !== ""

            title: TodoService.aiSummaryTitle !== "" ? TodoService.aiSummaryTitle : qsTr("محلل المهام الذكي")
            summaryText: TodoService.aiSummaryText
            iconText: "✨📋"

            showDataRefreshButton: false
            showAiRefreshButton: true

            onRefreshAiClicked: {
                console.log("طلب إعادة تحليل المهام من الذكاء الاصطناعي...");
            }

            bottomContent: Flow {
                width: smartTodoCard.width - (root.dims.menuWidgetsMargin * 2)
                spacing: 6
                topPadding: 4
                visible: TodoService.aiSummaryTags && TodoService.aiSummaryTags.length > 0

                Repeater {
                    model: TodoService.aiSummaryTags
                    delegate: Rectangle {
                        height: 24
                        width: tagText.contentWidth + 16
                        color: smartTodoCard.aiBorderColor.alpha(0.3)
                        radius: 6
                        border.color: smartTodoCard.aiBorderColor.alpha(0.5)
                        border.width: 1

                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: modelData
                            font.family: root.typo.bodyFont
                            font.pixelSize: 12
                            color: smartTodoCard.aiTextColor
                        }
                    }
                }
            }
        }

        // المهام العاجلة
        ColumnLayout {
            Layout.fillWidth: true
            visible: TodoService.dueNowModel.count > 0
            spacing: 8

            Text {
                text: qsTr("Due Now")
                font.family: root.typo.bodyFont
                font.pixelSize: root.typo.small
                font.bold: true
                color: root.colors.leftMenuFgColorV1
                opacity: 0.8
                Layout.leftMargin: 4
            }

            Repeater {
                model: TodoService.dueNowModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: root.dims.elementRadius
                    color: Qt.rgba(root.colors.error.r, root.colors.error.g, root.colors.error.b, 0.08)
                    border.width: 1
                    border.color: Qt.rgba(root.colors.error.r, root.colors.error.g, root.colors.error.b, isUrgent ? 0.35 : 0.15)

                    layer.enabled: isUrgent
                    layer.effect: Shadow {
                        alpha: 0.15
                        color: root.colors.error
                    }

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
                            font.bold: isUrgent
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: date
                            font.family: root.typo.bodyFont
                            font.pixelSize: 11
                            color: root.colors.error
                            opacity: 0.8
                        }
                    }
                }
            }
        }

        // قائمة المهام
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            TodoItems {
                listModel: TodoService.tasksModel

                onRequestSave: TodoService.saveAndSort()
                onRequestCalendar: index => {
                    root.activeCalendarIndex = index;
                    calendarPopup.open();
                }
            }
        }
    }

    // ─── التقويم ──────────────────────────────────────────────────
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
