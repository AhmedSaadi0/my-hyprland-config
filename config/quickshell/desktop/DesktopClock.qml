import QtQuick
import Quickshell
import QtQuick.Effects
import "root:/config"
import "root:/themes"

Item {
    id: root

    // ================= الخصائص القادمة من الثيم =================
    property point position: Qt.point(0, 0)
    property size size: Qt.size(400, 200)
    property bool editMode: false
    property bool pressed: false

    property bool enableAnimation: false
    property bool shadowEnabled: false
    property color shadowColor: ThemeManager.selectedTheme.colors.shadowColor
    property color clockColor: ThemeManager.selectedTheme.colors.primary
    property string clockFont: "sans-serif"
    property string clockFormat: "hh:mm"
    property string clockLocale: "en_US"

    // متغيرات العرض الداخلية (لفصلها عن التحديث الفوري للثيم)
    property color _displayedColor: root.clockColor
    property string _displayedFont: root.clockFont
    property string _displayedFormat: root.clockFormat
    property bool _isReady: false
    property var shadowEffectItem: null

    QtObject {
        id: shadowAnimationFallback
        property real blur: 0
    }

    signal requestNewGeometry(point newPosition, size newSize)
    signal themeChanged

    // ================= متغيرات تحريك النافذة (الموقع والحجم) =================
    property real _currentX: position.x
    property real _currentY: position.y
    property real _currentW: size.width
    property real _currentH: size.height

    x: _currentX
    y: _currentY
    width: _currentW + 20
    height: _currentH

    // ================= مؤقتات الاستجابة (Debounce) =================

    // 1. مؤقت تحديث الموقع والحجم
    Timer {
        id: movementDelayTimer
        interval: 450
        repeat: false
        onTriggered: {
            root._currentX = root.position.x;
            root._currentY = root.position.y;
            root._currentW = root.size.width;
            root._currentH = root.size.height;
        }
    }

    onPositionChanged: {
        if (root.editMode) {
            root._currentX = root.position.x;
            root._currentY = root.position.y;
        } else if (root._isReady)
            movementDelayTimer.restart();
    }
    onSizeChanged: {
        if (root.editMode) {
            root._currentW = root.size.width;
            root._currentH = root.size.height;
        } else if (root._isReady)
            movementDelayTimer.restart();
    }

    // 2. مؤقت تحديث المظهر (اللون والخط)
    Timer {
        id: styleDelayTimer
        interval: 450
        repeat: false
        onTriggered: {
            // اللون يتحدث فوراً لأن له ColorAnimation خاص به في الأسفل
            root._displayedColor = root.clockColor;

            // إذا تغير الخط أو التنسيق، شغل تأثير "النبض الطبيعي"
            if (root._displayedFont !== root.clockFont || root._displayedFormat !== root.clockFormat) {
                cinematicMorph.restart();
            }
        }
    }

    onClockColorChanged: if (root._isReady)
        styleDelayTimer.restart()
    onClockFontChanged: {
        console.info("[Clock] clockFont:", root.clockFont, "| previewing:", ThemeManager.isClockFontPreviewing, "| previewFont:", ThemeManager.clockPreviewFont);
        if (!root._isReady)
            return;
        // أثناء المعاينة من منتقي الخطوط: تطبيق فوري دون مؤقت أو أنيميشن
        if (ThemeManager.isClockFontPreviewing) {
            root._displayedFont = root.clockFont;
        } else {
            styleDelayTimer.restart();
        }
    }

    // مؤقت تشخيص مؤقت — يعرض حالة الخط الفعلية أثناء المعاينة
    Timer {
        interval: 300
        repeat: true
        running: ThemeManager.isClockFontPreviewing
        onTriggered: console.info("[ClockDebug] preview:", ThemeManager.clockPreviewFont, "| displayed:", root._displayedFont, "| actualTextFont:", timeText.font.family)
    }
    onClockFormatChanged: if (root._isReady)
        styleDelayTimer.restart()

    // ================= أنميشن النبض الطبيعي (Natural Morphing) =================
    SequentialAnimation {
        id: cinematicMorph

        ParallelAnimation {
            NumberAnimation {
                target: contentContainer
                property: "scale"
                to: 0.75
                duration: 180
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: contentContainer
                property: "opacity"
                to: 0.3
                duration: 180
            }
            NumberAnimation {
                target: root.shadowEffectItem || shadowAnimationFallback
                property: "blur"
                to: 2.5
                duration: 180
            }
        }

        ScriptAction {
            script: {
                root._displayedFont = root.clockFont;
                root._displayedFormat = root.clockFormat;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: contentContainer
                property: "scale"
                to: 1.0
                duration: 500
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: contentContainer
                property: "opacity"
                to: 1.0
                duration: 500
            }
            NumberAnimation {
                target: root.shadowEffectItem || shadowAnimationFallback
                property: "blur"
                to: 0.0
                duration: 500
            }
        }
    }

    // ================= أنميشن تحريك الودجت =================
    Behavior on x {
        enabled: !root.editMode && root._isReady
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
    }
    Behavior on y {
        enabled: !root.editMode && root._isReady
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
    }
    Behavior on width {
        enabled: !root.editMode && root._isReady
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
    }
    Behavior on height {
        enabled: !root.editMode && root._isReady
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
    }

    SystemClock {
        id: systemClock
    }

    // ================= محتوى الساعة =================
    Item {
        id: contentContainer
        anchors.fill: parent
        transformOrigin: Item.Center

        Text {
            id: timeText
            anchors.centerIn: parent

            text: systemClock.date.toLocaleString(Qt.locale(root.clockLocale), root._displayedFormat)
            // أثناء المعاينة: ربط مباشر بخط المعاينة (فوري وموثوق)
            // خارج المعاينة: الخط الحالي عبر _displayedFont مع أنيميشن النبض
            font.family: ThemeManager.isClockFontPreviewing && ThemeManager.clockPreviewFont !== ""
                        ? ThemeManager.clockPreviewFont
                        : root._displayedFont

            // ================= السر البصري لتغير اللون =================
            // ColorAnimation يقوم بمزج الألوان كيميائياً بدلاً من التبديل الفوري
            color: root._displayedColor
            Behavior on color {
                ColorAnimation {
                    duration: 450
                    easing.type: Easing.InOutQuad
                }
            }

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

            layer.enabled: root.shadowEnabled || root.editMode || root.pressed
            layer.smooth: true
            layer.effect: MultiEffect {
                id: shadowEffect

                Component.onCompleted: root.shadowEffectItem = shadowEffect

                blurEnabled: true
                blurMax: 8 // تمكين التمويه للأنميشن
                blur: 0

                shadowEnabled: root.shadowEnabled && !root.pressed
                shadowColor: root.shadowColor
                shadowBlur: 1.0
                shadowOpacity: 0.6
                shadowVerticalOffset: 0
                shadowHorizontalOffset: 0
                shadowScale: 1.0
            }
        }
    }

    // ================= التهيئة الأولية =================
    Component.onCompleted: {
        root._currentX = root.position.x;
        root._currentY = root.position.y;
        root._currentW = root.size.width;
        root._currentH = root.size.height;

        root._displayedColor = root.clockColor;
        root._displayedFont = root.clockFont;
        root._displayedFormat = root.clockFormat;

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
        border.color: ThemeManager.selectedTheme.colors.primary
        border.width: 2
        Rectangle {
            anchors.fill: parent
            color: ThemeManager.selectedTheme.colors.surface
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
        color: ThemeManager.selectedTheme.colors.primary
        radius: 10
        opacity: root.editMode ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

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
