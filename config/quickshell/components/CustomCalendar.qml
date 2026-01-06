import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/config"

Popup {
    id: root
    width: 320
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    // --- خصائص التكوين ---
    property date selectedDate: new Date()
    property date viewDate: new Date()
    // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    property int firstDayOfWeek: App.firstDayOfWeek

    // --- الثيم ---
    readonly property var colors: ThemeManager.selectedTheme.colors
    readonly property var dims: ThemeManager.selectedTheme.dimensions
    readonly property var typo: ThemeManager.selectedTheme.typography

    signal dateSelected(date date)

    property int direction: 0

    // --- أنيميشن فتح النافذة (Elastic Pop) ---
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1.0
                duration: 400
                easing.type: Easing.OutElastic
                easing.period: 0.8
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 150
        }
    }

    background: Rectangle {
        color: root.colors.leftMenuBgColorV2
        radius: root.dims.elementRadius
        border.color: Qt.rgba(root.colors.leftMenuFgColorV1.r, root.colors.leftMenuFgColorV1.g, root.colors.leftMenuFgColorV1.b, 0.1)
        border.width: 1

        // TODO: ظل قوي للنافذة المنبثقة
        // layer.enabled: true
        // Use Shadow
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.dims.spacingLarge
        spacing: root.dims.spacingLarge

        // 1. الرأس (Header)
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // زر السابق
            Button {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                flat: true
                onClicked: changeMonth(-1)

                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(root.colors.leftMenuFgColorV1.r, root.colors.leftMenuFgColorV1.g, root.colors.leftMenuFgColorV1.b, 0.08) : "transparent"
                    radius: root.dims.elementRadius
                }
                contentItem: Text {
                    text: "‹"
                    color: root.colors.leftMenuFgColorV1
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    bottomPadding: 4
                }
            }

            // الشهر والسنة
            Text {
                Layout.fillWidth: true
                text: root.viewDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                color: root.colors.leftMenuFgColorV1
                font.family: root.typo.bodyFont
                font.pixelSize: root.typo.heading4Size
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // زر التالي
            Button {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                flat: true
                onClicked: changeMonth(1)

                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(root.colors.leftMenuFgColorV1.r, root.colors.leftMenuFgColorV1.g, root.colors.leftMenuFgColorV1.b, 0.08) : "transparent"
                    radius: root.dims.elementRadius
                }
                contentItem: Text {
                    text: "›"
                    color: root.colors.leftMenuFgColorV1
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    bottomPadding: 4
                }
            }
        }

        // 2. أيام الأسبوع (ديناميكية حسب بداية الأسبوع)
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: 7
                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    property int dayIndex: (index + root.firstDayOfWeek) % 7
                    // مصفوفة أسماء الأيام القصيرة
                    readonly property var days: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    Text {
                        anchors.centerIn: parent
                        text: days[dayIndex].charAt(0) // الحرف الأول فقط
                        color: root.colors.primary
                        font.family: root.typo.bodyFont
                        font.pixelSize: root.typo.small
                        font.bold: true
                        opacity: 0.8
                    }
                }
            }
        }

        // 3. منطقة الشبكة (الحاوية للأنيميشن)
        Item {
            id: gridContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true // مهم جداً لقص الأنيميشن عند الحواف

            GridView {
                id: calendarGrid
                anchors.fill: parent
                cellWidth: width / 7
                cellHeight: cellWidth
                interactive: false

                model: 42 // 6 rows * 7 cols

                delegate: Item {
                    width: calendarGrid.cellWidth
                    height: calendarGrid.cellHeight

                    // حساب التاريخ (نفس المنطق السابق)
                    property var dayDate: {
                        let year = root.viewDate.getFullYear();
                        let month = root.viewDate.getMonth();
                        let firstDayOfMonth = new Date(year, month, 1);
                        let startOffset = (firstDayOfMonth.getDay() - root.firstDayOfWeek + 7) % 7;
                        let d = new Date(year, month, 1);
                        d.setDate(d.getDate() - startOffset + index);
                        return d;
                    }

                    property bool isCurrentMonth: dayDate.getMonth() === root.viewDate.getMonth()
                    property bool isSelected: dayDate.toDateString() === root.selectedDate.toDateString()
                    property bool isToday: dayDate.toDateString() === new Date().toDateString()

                    // المستطيل الذي يحتوي الرقم
                    Rectangle {
                        id: dayRect
                        width: Math.min(parent.width, parent.height) - 8
                        height: width
                        anchors.centerIn: parent
                        radius: root.dims.elementRadius

                        // إذا كان اليوم خارج الشهر، اجعل الشفافية 0.3 (باهت جداً)
                        // وإلا 1.0 (واضح تماماً)
                        opacity: isCurrentMonth ? 1.0 : 0.35

                        // لون الخلفية
                        color: {
                            if (isSelected)
                                return root.colors.primary;
                            if (dayMouseArea.containsMouse)
                                return Qt.rgba(root.colors.primary.r, root.colors.primary.g, root.colors.primary.b, 0.15);
                            return "transparent";
                        }

                        // حدود لليوم الحالي
                        border.color: isToday && !isSelected ? root.colors.primary : "transparent"
                        border.width: 1.5

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        // الرقم
                        Text {
                            anchors.centerIn: parent
                            text: dayDate.getDate()
                            font.family: root.typo.bodyFont
                            font.pixelSize: root.typo.medium
                            font.bold: isSelected || isToday

                            color: {
                                if (isSelected)
                                    return root.colors.onPrimary;
                                // هنا نستخدم لون النص العادي لأننا تحكمنا في الشفافية (Opacity) في العنصر الأب
                                // لكن يمكنك ابقاؤه subtleText لزيادة التأثير
                                return root.colors.leftMenuFgColorV1;
                            }
                        }

                        // تأثير النبض
                        ScaleAnimator {
                            id: pulseAnim
                            target: dayRect
                            from: 0.9
                            to: 1.0
                            duration: 300
                            easing.type: Easing.OutBack
                            running: false
                        }

                        MouseArea {
                            id: dayMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                pulseAnim.start();

                                if (dayDate.getMonth() !== root.viewDate.getMonth()) {
                                    root.direction = dayDate > root.viewDate ? 1 : -1;
                                    root.viewDate = dayDate;
                                    slideAnim.start();
                                }

                                root.dateSelected(dayDate);
                                closeTimer.start();
                            }
                        }
                    }
                }
            }

            // المؤقت للإغلاق
            Timer {
                id: closeTimer
                interval: 150
                onTriggered: root.close()
            }

            // --- أنيميشن تغيير الشهر (Slide Transition) ---

            // هذه الخاصية الوهمية تستخدم للتحكم في حركة الـ Grid
            // عندما نغير الشهر، نحرك الـ Grid خارجاً ونعيده من الجهة الأخرى

            SequentialAnimation {
                id: slideAnim

                // 1. خروج الشبكة الحالية (Fade Out + Slide)
                ParallelAnimation {
                    NumberAnimation {
                        target: calendarGrid
                        property: "opacity"
                        to: 0
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: calendarGrid
                        property: "x"
                        to: root.direction * -50 // يتحرك عكس الاتجاه قليلاً
                        duration: 150
                    }
                }

                // 2. تحديث البيانات (يحدث لحظياً هنا لأننا غيرنا viewDate بالفعل، لكننا نجهز الشبكة للدخول)
                PropertyAction {
                    target: calendarGrid
                    property: "x"
                    value: root.direction * 50
                } // الانتقال للجهة المقابلة

                // 3. دخول الشبكة الجديدة (Fade In + Slide to 0)
                ParallelAnimation {
                    NumberAnimation {
                        target: calendarGrid
                        property: "opacity"
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: calendarGrid
                        property: "x"
                        to: 0
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }

    // دالة مساعدة لتغيير الشهر وتشغيل الأنيميشن
    function changeMonth(dir) {
        root.direction = dir; // 1 (Next) or -1 (Prev)

        // نبدأ الأنيميشن
        // ملاحظة: نقوم بتغيير التاريخ في منتصف الأنيميشن لتبدو سلسة
        // لكن هنا سنستخدم خدعة بسيطة:

        // 1. نشغل انيميشن الخروج
        // 2. عند انتهاء الخروج، نغير التاريخ
        // 3. نشغل انيميشن الدخول

        step1Anim.start();
    }

    // تقسيم الأنيميشن للتحكم اليدوي في الأزرار
    SequentialAnimation {
        id: step1Anim
        ParallelAnimation {
            NumberAnimation {
                target: calendarGrid
                property: "opacity"
                to: 0
                duration: 120
            }
            NumberAnimation {
                target: calendarGrid
                property: "x"
                to: root.direction * -40
                duration: 120
            }
        }
        ScriptAction {
            script: {
                // تغيير الشهر الفعلي
                root.viewDate = new Date(root.viewDate.getFullYear(), root.viewDate.getMonth() + root.direction, 1);
                // إعادة التموضع للجهة الأخرى
                calendarGrid.x = root.direction * 40;
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: calendarGrid
                property: "opacity"
                to: 1
                duration: 200
            }
            NumberAnimation {
                target: calendarGrid
                property: "x"
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
