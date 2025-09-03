// File: DesktopClock.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import org.kde.kirigami as Kirigami

Item {
    id: root

    // --- 1. الخصائص التي يستقبلها من الأب ---
    // هذه هي "واجهة برمجة التطبيقات" للمكون الخاص بنا.
    property point position: Qt.point(0, 0)
    property size size: Qt.size(400, 200)
    property bool editMode: false
    property bool enableAnimation: false

    // الخصائص الجمالية
    property color clockColor: "white"
    property string clockFont: "sans-serif"
    property string clockFormat: "hh:mm"
    property string clockLocale: "en_US"

    signal requestNewGeometry(point newPosition, size newSize)
    signal themeChanged

    // --- 3. ربط الخصائص بالعنصر ---
    // واجهة المستخدم تعكس دائمًا قيم الخصائص أعلاه.
    x: position.x
    y: position.y
    width: size.width
    height: size.height

    Behavior on x {
        enabled: !root.editMode
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }
    Behavior on y {
        enabled: !root.editMode
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }

    Behavior on width {
        enabled: root.enableAnimation
        NumberAnimation {
            id: widthAnim
            duration: 500
            easing.type: Easing.InOutQuad
            // onStopped: timeText.updateFontSize()
        }
    }
    Behavior on height {
        enabled: root.enableAnimation
        NumberAnimation {
            id: heightAnim
            duration: 500
            easing.type: Easing.InOutQuad
            // onStopped: timeText.updateFontSize()
        }
    }

    // ساعة النظام (غير مرئية، فقط للحصول على الوقت)
    SystemClock {
        id: systemClock
    }

    // نص الساعة
    Text {
        id: timeText
        anchors.fill: parent
        text: systemClock.date.toLocaleString(Qt.locale(root.clockLocale), root.clockFormat)

        // ربط الخصائص الجمالية
        color: root.clockColor
        font.family: root.clockFont

        // لتوسيط النص وجعله يملأ المساحة
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 500 // حجم كبير مبدئي
        fontSizeMode: Text.Fit // سيقوم QML بتصغيره ليناسب العرض
    }

    // إطار يظهر في وضع التعديل
    Rectangle {
        visible: root.editMode
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        border.width: 2
    }

    // --- 4. منطقة التفاعل (للسحب وتغيير الحجم) ---
    MouseArea {
        id: dragArea
        anchors.fill: parent

        // متغيرات لتخزين نقطة بداية السحب
        property point startDragPos
        property point startComponentPos

        onDoubleClicked: {
            console.log("Double-click detected! Toggling edit mode.");
            root.editMode = !root.editMode;
        }

        onPressed: mouse => {
            if (!root.editMode) {
                // الإصلاح: اقبل النقرة دائمًا لمنع انتشارها للخلف.
                // هذا يضمن أن onDoubleClicked سيعمل بشكل صحيح.
                mouse.accepted = true;
                return;
            }

            // هذا الكود سيعمل فقط إذا كان editMode هو true
            startComponentPos = Qt.point(root.x, root.y);
            startDragPos = mapToItem(null, mouse.x, mouse.y);
            mouse.accepted = true; // قبول النقرة مهم أيضًا هنا
        }

        onPositionChanged: mouse => {
            if (pressed && root.editMode) {
                var currentDragPos = mapToItem(null, mouse.x, mouse.y);
                var deltaX = currentDragPos.x - startDragPos.x;
                var deltaY = currentDragPos.y - startDragPos.y;
                var newPos = Qt.point(startComponentPos.x + deltaX, startComponentPos.y + deltaY);
                root.requestNewGeometry(newPos, root.size);
            }
        }

        // onReleased: {
        //     if (root.editMode) {
        //         // عند الانتهاء من السحب، نرسل الإشارة "saveGeometry" إلى الأب
        //         root.saveGeometry(Qt.point(root.x, root.y), root.size);
        //     }
        // }
    }

    // مقبض تغيير الحجم (مثال بسيط)
    Rectangle {
        id: resizeHandle
        visible: root.editMode
        width: 20
        height: 20
        color: "white"
        radius: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -10 // يظهر خارج الإطار قليلاً

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor

            property point startMousePos
            property size startComponentSize

            onPressed: {
                startMousePos = mapToItem(null, mouseX, mouseY);
                startComponentSize = Qt.size(root.width, root.height);
            }

            onPositionChanged: {
                if (pressed) {
                    var currentPos = mapToItem(null, mouseX, mouseY);
                    var deltaX = currentPos.x - startMousePos.x;
                    var deltaY = currentPos.y - startMousePos.y;

                    var newSize = Qt.size(Math.max(100, startComponentSize.width + deltaX), Math.max(50, startComponentSize.height + deltaY));

                    // إرسال الإشارة بالطلب الجديد
                    root.requestNewGeometry(root.position, newSize);
                }
            }

            // onReleased: {
            //     // عند الانتهاء، نرسل الإشارة "saveGeometry" إلى الأب
            //     root.saveGeometry(root.position, Qt.size(root.width, root.height));
            // }
        }
    }
}
