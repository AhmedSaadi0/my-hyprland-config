// windows/leftwindow/todo/TodoView.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"
import "root:/components"
import "root:/services"

Item {
    id: root

    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    property date selectedDate: new Date()
    property int activeCalendarIndex: -1

    Layout.fillWidth: true
    Layout.fillHeight: true

    function addTask(title, urgent) {
        TodoService.addTask(title, root.selectedDate, urgent);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0    // صفر لأن TopAppBar يجب أن يكون ملتصقاً بالأعلى

        // ① TopAppBar — الشريط العلوي الحديث
        TopAppBar {
            Layout.fillWidth: true
            title: qsTr("Todo")
            icon: "󰄳"
            // scrollY: bodyItems.ScrollBar.vertical.position * bodyItems.contentHeight
            // primaryActionVisible: false
            // actions:
        }

        // --- حاوية المحتوى الداخلي (لضبط الهوامش الجانبية للكل) ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: dims.menuWidgetsMargin
            Layout.rightMargin: dims.menuWidgetsMargin
            Layout.topMargin: dims.spacingMedium
            spacing: dims.spacingMedium

            // ② AISummaryCard — كرت الذكاء الاصطناعي الفخم
            AISummaryCard {
                id: smartTodoCard
                Layout.fillWidth: true
                visible: TodoService.aiSummaryText !== ""

                // البيانات
                title: TodoService.aiSummaryTitle !== "" ? TodoService.aiSummaryTitle : qsTr("محلل المهام الذكي")
                summaryText: TodoService.aiSummaryText
                iconText: "✨📋"

                // الأزرار
                showDataRefreshButton: false // لا نحتاج زر لتحديث المهام لأنها تتحدث محلياً غالباً
                showAiRefreshButton: true

                onRefreshAiClicked: {
                    // استدعِ الدالة الخاصة بإعادة تحليل المهام من الـ Backend هنا
                    // مثال: TodoService.requestAiAnalysis();
                    console.log("طلب إعادة تحليل المهام من الذكاء الاصطناعي...");
                }

                // الكلمات الدلالية (Tags) في أسفل الكرت
                bottomContent: Flow {
                    width: smartTodoCard.width - (dims.menuWidgetsMargin * 2)
                    spacing: 6
                    topPadding: 4
                    visible: TodoService.aiSummaryTags && TodoService.aiSummaryTags.length > 0

                    Repeater {
                        model: TodoService.aiSummaryTags
                        delegate: Rectangle {
                            height: 24
                            width: tagText.contentWidth + 16
                            // استخدام ألوان الذكاء الاصطناعي المستخرجة من الكرت
                            color: smartTodoCard.aiBorderColor.alpha(0.3)
                            radius: 6
                            border.color: smartTodoCard.aiBorderColor.alpha(0.5)
                            border.width: 1

                            Text {
                                id: tagText
                                anchors.centerIn: parent
                                text: modelData
                                font.family: typo.bodyFont
                                font.pixelSize: 12
                                color: smartTodoCard.aiTextColor
                            }
                        }
                    }
                }
            }

            // ③ TodoHeader — حقل إدخال مهمة جديدة
            TodoHeader {
                id: header
                Layout.fillWidth: true
                selectedDate: root.selectedDate

                onOpenCalendar: {
                    root.activeCalendarIndex = -1;
                    calendarPopup.open();
                }
                onAddTask: (title, urgent) => {
                    root.addTask(title, urgent);
                }
            }

            // ④ Due Now — المهام العاجلة (تم تحسين مظهرها قليلاً)
            ColumnLayout {
                Layout.fillWidth: true
                visible: TodoService.dueNowModel.count > 0
                spacing: 8

                Text {
                    text: qsTr("Due Now")
                    font.family: typo.bodyFont
                    font.pixelSize: typo.small
                    font.bold: true
                    color: root.colors.leftMenuFgColorV1
                    opacity: 0.8
                    Layout.leftMargin: 4
                }

                Repeater {
                    model: TodoService.dueNowModel
                    delegate: Rectangle {
                        width: parent.width
                        height: 44 // زيادة الارتفاع قليلاً لراحة العين
                        radius: dims.elementRadius
                        color: Qt.rgba(root.colors.error.r, root.colors.error.g, root.colors.error.b, 0.08)
                        border.width: 1
                        border.color: Qt.rgba(root.colors.error.r, root.colors.error.g, root.colors.error.b, isUrgent ? 0.35 : 0.15)

                        // إضافة ظل خفيف للمهام العاجلة
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
                                font.family: typo.bodyFont
                                font.pixelSize: typo.small
                                color: root.colors.leftMenuFgColorV1
                                font.bold: isUrgent // الخط غامق للمهام العاجلة
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: date
                                font.family: typo.bodyFont
                                font.pixelSize: 11
                                color: root.colors.error
                                opacity: 0.8
                            }
                        }
                    }
                }
            }

            // ⑤ ScrollView + TodoItems — قائمة المهام الرئيسية
            ScrollView {
                id: bodyItems
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                TodoItems {
                    listModel: TodoService.tasksModel

                    onRequestSave: {
                        TodoService.saveAndSort();
                    }
                    onRequestCalendar: index => {
                        root.activeCalendarIndex = index;
                        calendarPopup.open();
                    }
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
