import QtQuick
import QtQuick.Shapes 1.15
import "root:/themes"

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

    property color backgroundColor: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
    property color foregroundColor: ThemeManager.selectedTheme.colors.primary

    implicitWidth: 20
    implicitHeight: 20

    property bool enableAnimation: false
    property real _animatedValue: value

    // أنميشن سلسة ومدعومة عتادياً
    Behavior on _animatedValue {
        enabled: root.enableAnimation
        NumberAnimation {
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    // =========================================================================
    // حسابات رياضية تلقائية (Bindings) تتم بسلاسة فائقة داخل محرك Qt دون تكرار
    // =========================================================================
    readonly property real _bgStroke: root.thickness + root.margin
    readonly property real _fgStroke: root.thickness

    // حساب نصف القطر مع حماية من القيم السالبة في حال كان العرض/الارتفاع صفراً
    readonly property real _radius: Math.max(0, Math.min(root.width, root.height) / 2 - Math.max(_bgStroke, _fgStroke) / 2)

    readonly property real _normalizedValue: Math.max(0, Math.min(1, root._animatedValue))

    // تحويل النسبة المئوية للمدخلات إلى نطاق [0, 1)
    readonly property real _startPct: ((root.startAt % 1) + 1) % 1
    readonly property real _endPct: ((root.endAt % 1) + 1) % 1
    readonly property bool _isFullCircle: Math.abs(_startPct - _endPct) < 1e-10

    // حساب طول القوس الإجمالي ونسبة التقدم
    readonly property real _arcLengthPct: _isFullCircle ? 1.0 : ((_endPct - _startPct + 1.0) % 1.0)
    readonly property real _scaledValuePct: _isFullCircle ? _normalizedValue : (_normalizedValue * _arcLengthPct)

    // تحويل الحسابات إلى درجات (Degrees) لأن مكتبة Shapes تعتمد الدرجات وليس الراديان
    readonly property real _startDeg: _startPct * 360
    readonly property real _endDeg: _isFullCircle ? (_startDeg + 360) : (_endPct * 360)

    // زوايا قوس الخلفية
    readonly property real _bgStartAngle: _startDeg
    readonly property real _bgSweepAngle: _isFullCircle ? 360 : (_arcLengthPct * 360)

    // زوايا قوس التقدم الفعلي (يدعم الاتجاه العكسي Inverted)
    readonly property real _fgStartAngle: root.inverted ? _endDeg : _startDeg
    readonly property real _fgSweepAngle: root.inverted ? -(_scaledValuePct * 360) : (_scaledValuePct * 360)

    // =========================================================================
    // الرسم المسرع عتادياً (GPU-Accelerated Drawing)
    // =========================================================================
    Shape {
        id: shape
        anchors.fill: parent

        // 1. تفعيل التنعيم العام
        antialiasing: true

        // 2. تعطيل امتدادات كرت الشاشة (مهم جداً لحل مشكلة التعرج على بعض الأجهزة)
        vendorExtensionsEnabled: false

        // 3. رفع جودة العينات إلى 8 عينات (8x MSAA) وتفعيل فلترة التنعيم المتقدمة
        layer.enabled: true
        layer.samples: 8
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer

        // ----------------- قوس الخلفية -----------------
        ShapePath {
            strokeColor: root.backgroundColor
            strokeWidth: root._bgStroke
            fillColor: "transparent"
            capStyle: root.rounded ? ShapePath.RoundCap : ShapePath.FlatCap

            PathAngleArc {
                centerX: rectCenterX
                centerY: rectCenterY
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root._bgStartAngle
                sweepAngle: root._bgSweepAngle

                readonly property real rectCenterX: shape.width / 2
                readonly property real rectCenterY: shape.height / 2
            }
        }

        // ----------------- قوس التقدم -----------------
        ShapePath {
            strokeColor: root.foregroundColor
            strokeWidth: root._fgStroke
            fillColor: "transparent"
            capStyle: root.rounded ? ShapePath.RoundCap : ShapePath.FlatCap

            PathAngleArc {
                centerX: rectCenterX
                centerY: rectCenterY
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root._fgStartAngle
                sweepAngle: root._fgSweepAngle

                readonly property real rectCenterX: shape.width / 2
                readonly property real rectCenterY: shape.height / 2
            }
        }
    }
}
