// desktop/NotchShape.qml
import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    preferredRendererType: Shape.CurveRenderer
    antialiasing: true

    property real notchHeight: 0
    property real notchWidth: 0
    property real cornerRadius: 0
    property color fillColor: "white"

    readonly property real nh: notchHeight
    readonly property real nw: notchWidth

    // ---------------------------------------------------------
    // ربط انحناء زوايا النوتش (rN) ديناميكياً مع راديوس النظام (cornerRadius)
    // ---------------------------------------------------------
    // إذا كان الراديوس 1 أو أقل (مربع)، يصبح انحناء النوتش 0 ليرسم زوايا حادة 90 درجة.
    // خلاف ذلك، يتناسب انحناء النوتش طردياً مع راديوس النظام بحد أقصى 24 بكسل.
    readonly property real rN: root.cornerRadius <= 1 ? 0 : Math.min(root.cornerRadius * 1.2, notchHeight, 24)

    readonly property real midX: (width / 2) - 19
    readonly property real rOuter: cornerRadius

    ShapePath {
        fillColor: root.fillColor
        strokeColor: "transparent"
        fillRule: ShapePath.OddEvenFill

        startX: root.rOuter
        startY: 0

        // 1. الحافة العلوية للشاشة (أفقي لليمين)
        PathLine {
            x: root.width - root.rOuter
            y: 0
        }

        // 2. الزاوية العلوية اليمنى للشاشة
        PathArc {
            x: root.width
            y: root.rOuter
            radiusX: root.rOuter
            radiusY: root.rOuter
            direction: PathArc.Clockwise
        }

        // 3. الحافة اليمنى للشاشة (رأسي للأسفل)
        PathLine {
            x: root.width
            y: root.height - root.rOuter
        }

        // 4. الزاوية السفلية اليمنى للشاشة
        PathArc {
            x: root.width - root.rOuter
            y: root.height
            radiusX: root.rOuter
            radiusY: root.rOuter
            direction: PathArc.Clockwise
        }

        // 5. خط مستقيم يساراً على الحافة السفلية حتى بداية انحناء النوتش الأيمن
        PathLine {
            x: root.midX + (root.nw / 2) + root.rN
            y: root.height
        }

        // 6. القوس الأيمن الخارجي (يربط الأرضية بالحائط الرأسي الصاعد)
        PathArc {
            x: root.midX + (root.nw / 2)
            y: root.height - root.rN
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Clockwise
        }

        // 7. الحائط الأيمن للنوتش (صعود رأسي للأعلى)
        PathLine {
            x: root.midX + (root.nw / 2)
            y: root.height - root.nh + root.rN
        }

        // 8. القوس الأيمن الداخلي (يربط الحائط الرأسي بسقف الدوك الأفقي)
        PathArc {
            x: root.midX + (root.nw / 2) - root.rN
            y: root.height - root.nh
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Counterclockwise
        }

        // 9. سقف الدوك الأفقي المستقيم (متجهاً لليسار)
        PathLine {
            x: root.midX - (root.nw / 2) + root.rN
            y: root.height - root.nh
        }

        // 10. القوس الأيسر الداخلي (يربط السقف بالحائط الرأسي الأيسر النازل)
        PathArc {
            x: root.midX - (root.nw / 2)
            y: root.height - root.nh + root.rN
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Counterclockwise
        }

        // 11. الحائط الأيسر للنوتش (نزول رأسي للأسفل)
        PathLine {
            x: root.midX - (root.nw / 2)
            y: root.height - root.rN
        }

        // 12. القوس الأيسر الخارجي (يربط الحائط الرأسي الأيسر بالأرضية السفلية اليسرى)
        PathArc {
            x: root.midX - (root.nw / 2) - root.rN
            y: root.height
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Clockwise
        }

        // 13. خط مستقيم يساراً على الأرضية السفلية حتى زاوية الشاشة اليسرى
        PathLine {
            x: root.rOuter
            y: root.height
        }

        // 14. الزاوية السفلية اليسرى للشاشة
        PathArc {
            x: 0
            y: root.height - root.rOuter
            radiusX: root.rOuter
            radiusY: root.rOuter
            direction: PathArc.Clockwise
        }

        // 15. الحافة اليسرى للشاشة (رأسي للأعلى)
        PathLine {
            x: 0
            y: root.rOuter
        }

        // 16. الزاوية العلوية اليسرى (نقطة النهاية للغلق التام)
        PathArc {
            x: root.rOuter
            y: 0
            radiusX: root.rOuter
            radiusY: root.rOuter
            direction: PathArc.Clockwise
        }
    }
}
