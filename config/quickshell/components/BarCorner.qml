// BarCorners.qml
import QtQuick

Item {
    id: root

    property string position: "top-left"
    // لون الشكل

    property color shapeColor: palette.window
    property real cornerRadius: 30

    width: cornerRadius
    height: cornerRadius

    Canvas {
        id: cornerCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = root.shapeColor; // استخدم لون الشكل
            ctx.beginPath();

            // --- منطق الرسم الجديد باستخدام quadraticCurveTo ---

            if (root.position === "top-left") {
                // خط أعلى، خط أيسر، منحنى مقعر يربط النهايتين
                ctx.moveTo(width, 0); // ابدأ من أعلى اليمين
                ctx.lineTo(0, 0);     // خط إلى أعلى اليسار
                ctx.lineTo(0, height);    // خط إلى أسفل اليسار
                // ارسم منحنى مقعر من النقطة الحالية (0, height) إلى (width, 0)
                // باستخدام نقطة التحكم (0, 0) لسحبه للداخل
                ctx.quadraticCurveTo(0, 0, width, 0);
            } else if (root.position === "top-right") {
                // خط أعلى، خط أيمن، منحنى مقعر
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width, height);
                // منحنى من (width, height) إلى (0, 0) بنقطة تحكم (width, 0)
                ctx.quadraticCurveTo(width, 0, 0, 0);
            } else if (root.position === "bottom-left") {
                ctx.moveTo(0, 0);
                ctx.lineTo(0, height);
                ctx.lineTo(width, height);
                // منحنى من (width, height) إلى (0, 0) بنقطة تحكم (0, height)
                ctx.quadraticCurveTo(0, height, 0, 0);
            } else if (root.position === "bottom-right") {
                ctx.moveTo(width, 0);
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                // منحنى من (0, height) إلى (width, 0) بنقطة تحكم (width, height)
                ctx.quadraticCurveTo(width, height, width, 0);
            }

            ctx.closePath(); // أغلق المسار
            ctx.fill();      // املأ الشكل باللون
        }

        // إعادة الرسم عند التغيير
        Component.onCompleted: requestPaint()
        // onPositionChanged: requestPaint()
        // onCornerRadiusChanged: requestPaint()
        // Component.onShapeColorChanged: requestPaint()
    }
    onShapeColorChanged: cornerCanvas.requestPaint()
}
