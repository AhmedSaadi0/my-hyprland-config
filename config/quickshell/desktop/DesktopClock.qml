import QtQuick
import Quickshell
import QtQuick.Effects

Item {
    id: root

    // ================= الخصائص القادمة من الثيم =================
    property point position: Qt.point(0, 0)
    property size size: Qt.size(400, 200)
    property bool editMode: false
    property bool pressed: false

    // إعدادات الثيم
    property bool enableAnimation: false
    property bool shadowEnabled: false
    property color shadowColor: "#40000000"
    property color clockColor: "white"
    property string clockFont: "sans-serif"
    property string clockFormat: "hh:mm"
    property string clockLocale: "en_US"

    property color _displayedColor: root.clockColor
    property string _displayedFont: root.clockFont
    property string _displayedFormat: root.clockFormat

    // متغير للتحقق من التحميل الأولي
    property bool _isReady: false

    signal requestNewGeometry(point newPosition, size newSize)
    signal themeChanged

    // ================= إعدادات النافذة والتحريك =================
    x: position.x
    y: position.y
    width: size.width
    height: size.height

    Behavior on x {
        enabled: !root.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InExpo
        }
    }
    Behavior on y {
        enabled: !root.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InExpo
        }
    }

    Behavior on width {
        enabled: !root.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InExpo
        }
    }
    Behavior on height {
        enabled: !root.editMode
        NumberAnimation {
            duration: 600
            easing.type: Easing.InExpo
        }
    }

    function updateClockStyle() {
        if (!root._isReady) {
            root._displayedColor = root.clockColor;
            root._displayedFont = root.clockFont;
            root._displayedFormat = root.clockFormat;
            return;
        }

        // إذا كان هناك تغيير فعلي، شغل أنيميشن التحول
        if (root._displayedFont !== root.clockFont || root._displayedColor !== root.clockColor || root._displayedFormat !== root.clockFormat) {
            styleChangeAnim.restart();
        }
    }

    onClockColorChanged: updateClockStyle()
    onClockFontChanged: updateClockStyle()
    onClockFormatChanged: updateClockStyle()

    SequentialAnimation {
        id: styleChangeAnim

        // 1. الخروج: تصغير + اختفاء (يخفي القفزة القديمة)
        ParallelAnimation {
            NumberAnimation {
                target: contentContainer
                property: "opacity"
                to: 0
                duration: 450
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: contentContainer
                property: "scale"
                to: 0.8
                duration: 450
                easing.type: Easing.InQuad
            }
        }

        // 2. التبديل: تغيير القيم والخط والنص مختفي تماماً
        ScriptAction {
            script: {
                root._displayedColor = root.clockColor;
                root._displayedFont = root.clockFont;
                root._displayedFormat = root.clockFormat;
            }
        }

        // 3. الدخول: تكبير + ظهور (بالشكل الجديد)
        ParallelAnimation {
            NumberAnimation {
                target: contentContainer
                property: "opacity"
                to: 1
                duration: 550
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: contentContainer
                property: "scale"
                to: 1
                duration: 550
                easing.type: Easing.OutBack
            }
        }
    }

    // مصدر الوقت
    SystemClock {
        id: systemClock
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        transformOrigin: Item.Center

        Text {
            id: timeText
            anchors.centerIn: parent

            text: systemClock.date.toLocaleString(Qt.locale(root.clockLocale), root._displayedFormat)
            color: root._displayedColor
            font.family: root._displayedFont

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            property int fixedSize: 1000
            font.pixelSize: fixedSize
            fontSizeMode: Text.FixedSize

            property real widthRatio: (root.width / implicitWidth)
            property real heightRatio: (root.height / implicitHeight)

            scale: Math.min(widthRatio, heightRatio) * 0.95

            antialiasing: true
            smooth: true
            renderType: Text.QtRendering
            font.hintingPreference: Font.PreferFullHinting

            layer.enabled: root.shadowEnabled && !root.pressed
            layer.smooth: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.shadowColor

                // 1. التنعيم الكامل للحصول على تأثير التوهج
                shadowBlur: 1.0

                shadowOpacity: 0.8

                // 3. جعل الظل في المنتصف تماماً
                shadowVerticalOffset: 0
                shadowHorizontalOffset: 0

                // 4. عدم تغيير الحجم لمنع التشوه
                shadowScale: 1.0
            }
        }
    }

    // ================= التهيئة الأولية =================
    Component.onCompleted: {
        // مزامنة فورية عند البدء
        root._displayedColor = root.clockColor;
        root._displayedFont = root.clockFont;
        root._displayedFormat = root.clockFormat;

        // تأخير بسيط لتفعيل الأنيميشن المستقبلي
        initTimer.start();
    }

    Timer {
        id: initTimer
        interval: 100
        repeat: false
        onTriggered: root._isReady = true
    }

    // ================= أدوات التحرير (Edit Mode) =================
    Rectangle {
        visible: root.editMode
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        border.width: 2
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.2
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        property point startDragPos
        property point startComponentPos

        onDoubleClicked: root.editMode = !root.editMode

        onPressed: mouse => {
            if (!root.editMode) {
                mouse.accepted = true;
                return;
            }
            startComponentPos = Qt.point(root.x, root.y);
            startDragPos = mapToItem(null, mouse.x, mouse.y);
            mouse.accepted = true;
        }

        onPositionChanged: mouse => {
            if (pressed && root.editMode) {
                var currentDragPos = mapToItem(null, mouse.x, mouse.y);
                var newPos = Qt.point(startComponentPos.x + (currentDragPos.x - startDragPos.x), startComponentPos.y + (currentDragPos.y - startDragPos.y));
                root.requestNewGeometry(newPos, root.size);
            }
        }
    }

    Rectangle {
        id: resizeHandle
        visible: root.editMode
        width: 20
        height: 20
        color: "white"
        radius: 10
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: -10
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            property point startMousePos
            property size startComponentSize
            onPressed: {
                startMousePos = mapToItem(null, mouseX, mouseY);
                startComponentSize = Qt.size(root.width, root.height);
                root.pressed = true;
            }
            onReleased: root.pressed = false
            onPositionChanged: {
                if (pressed) {
                    var currentPos = mapToItem(null, mouseX, mouseY);
                    var newWidth = Math.max(100, startComponentSize.width + (currentPos.x - startMousePos.x));
                    var newHeight = Math.max(50, startComponentSize.height + (currentPos.y - startMousePos.y));
                    root.requestNewGeometry(root.position, Qt.size(newWidth, newHeight));
                }
            }
        }
    }
}
