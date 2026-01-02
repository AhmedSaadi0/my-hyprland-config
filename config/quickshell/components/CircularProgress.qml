import QtQuick

Item {
    id: root

    property real startAt: 0.0
    property real endAt: 1.0
    property real value: 0.5
    property int thickness: 2
    property int margin: 1
    property bool inverted: false
    property bool rounded: true
    property bool showText: false

    property color backgroundColor: palette.accent.alpha(0.3)
    property color foregroundColor: palette.accent

    implicitWidth: 20
    implicitHeight: 20

    property bool enableAnimation: true
    property real _animatedValue: value

    // هذا هو كود الأنميشن
    Behavior on _animatedValue {
        enabled: root.enableAnimation
        NumberAnimation {
            duration: 800             // مدة الحركة بالميلي ثانية
            easing.type: Easing.OutCubic // نوع الحركة (سلسة في النهاية)
        }
    }

    // إعادة الرسم عند تغير القيمة المتحركة
    on_AnimatedValueChanged: canvas.requestPaint()

    // بقية التريغرز كما هي
    onStartAtChanged: canvas.requestPaint()
    onEndAtChanged: canvas.requestPaint()
    // onValueChanged: canvas.requestPaint() // لم نعد بحاجة لهذا لأن _animatedValue ستقوم بالمهمة
    onThicknessChanged: canvas.requestPaint()
    onMarginChanged: canvas.requestPaint()
    onInvertedChanged: canvas.requestPaint()
    onRoundedChanged: canvas.requestPaint()
    onBackgroundColorChanged: canvas.requestPaint()
    onForegroundColorChanged: canvas.requestPaint()
    onPaletteChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var bgStroke = root.thickness + root.margin;
            var fgStroke = root.thickness;
            var radius = Math.min(width, height) / 2 - Math.max(bgStroke, fgStroke) / 2;

            function percentToRad(percent) {
                return 2 * Math.PI * percent;
            }

            var normalizedValue = Math.max(0, Math.min(1, root._animatedValue));

            var startAngle = (root.startAt % 1 + 1) % 1;
            var endAngle = (root.endAt % 1 + 1) % 1;
            var isFullCircle = Math.abs(startAngle - endAngle) < 1e-10;
            var arcLength = isFullCircle ? 1 : (endAngle - startAngle + 1) % 1;
            var scaledValue = isFullCircle ? normalizedValue : normalizedValue * arcLength;

            var startRad = percentToRad(startAngle);
            var endRad = isFullCircle ? startRad + 2 * Math.PI : percentToRad(endAngle);

            var progressStartRad, progressEndRad;
            if (root.inverted) {
                progressStartRad = endRad - percentToRad(scaledValue);
                progressEndRad = endRad;
            } else {
                progressStartRad = startRad;
                progressEndRad = startRad + percentToRad(scaledValue);
            }

            ctx.lineCap = root.rounded ? "round" : "butt";

            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, startRad, endRad);
            ctx.lineWidth = bgStroke;
            ctx.strokeStyle = root.backgroundColor;
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, progressStartRad, progressEndRad);
            ctx.lineWidth = fgStroke;
            ctx.strokeStyle = root.foregroundColor;
            ctx.stroke();
        }
    }
}
