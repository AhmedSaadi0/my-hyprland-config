import QtQuick

Item {
    id: circularProgress

    // Properties matching C++ class
    property real startAt: 0.0  // 0.0-1.0 (0°-360°)
    property real endAt: 1.0    // 0.0-1.0 (0°-360°)
    property real value: 0.5    // 0.0-1.0
    property int thickness: 2
    property int margin: 1
    property bool inverted: false
    property bool rounded: true

    // Colors from style context
    property color backgroundColor: palette.accent.alpha(0.3)
    property color foregroundColor: palette.accent

    width: 25
    height: 25

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            // Calculate dimensions
            var center = {
                x: width / 2,
                y: height / 2
            };
            var bgStroke = thickness + margin;
            var fgStroke = thickness;
            var radius = Math.min(width, height) / 2 - Math.max(bgStroke, fgStroke) / 2;

            // Convert percentage (0-1) to radians (0-2π)
            function percentToRad(percent) {
                return 2 * Math.PI * percent;
            }

            // Normalize value between 0-1
            var normalized = Math.max(0, Math.min(1, value));

            // Normalize angles (0-1) with modulo
            var start = (startAt % 1 + 1) % 1;
            var end = (endAt % 1 + 1) % 1;

            // Detect full circle case
            var isFullCircle = Math.abs(start - end) < 1e-10;

            // Calculate arc length
            var arcLength = isFullCircle ? 1 : end - start;
            if (arcLength < 0)
                arcLength += 1;

            // Calculate scaled value
            var scaledValue = isFullCircle ? normalized : normalized * arcLength;

            if (!isFullCircle) {
                scaledValue = (scaledValue % 1 + 1) % 1;
            }

            // Calculate angles
            var startBackground = percentToRad(start);
            var endBackground = isFullCircle ? startBackground + 2 * Math.PI : percentToRad(end);

            // Calculate progress angles
            var startProgress, endProgress;
            if (inverted) {
                startProgress = isFullCircle ? endBackground - percentToRad(scaledValue) : endBackground - percentToRad(scaledValue);
                endProgress = endBackground;
            } else {
                startProgress = startBackground;
                endProgress = isFullCircle ? startBackground + percentToRad(scaledValue) : startBackground + percentToRad(scaledValue);
            }

            // Set line style
            ctx.lineCap = rounded ? "round" : "butt";

            // Draw background arc
            ctx.beginPath();
            ctx.arc(center.x, center.y, radius, startBackground, endBackground);
            ctx.lineWidth = bgStroke;
            ctx.strokeStyle = backgroundColor;
            ctx.stroke();

            // Draw progress arc
            ctx.beginPath();
            ctx.arc(center.x, center.y, radius, startProgress, endProgress);
            ctx.lineWidth = fgStroke;
            ctx.strokeStyle = foregroundColor;
            ctx.stroke();
        }
    }

    // Trigger redraw on property changes
    onValueChanged: update()
    onStartAtChanged: update()
    onEndAtChanged: update()
    onInvertedChanged: update()
    onRoundedChanged: update()

    function update() {
        canvas.requestPaint();
    }

    onPaletteChanged: {
        update();
    }
}
