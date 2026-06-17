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
    property real notchOffset: 0 // <-- إضافة خاصية الإزاحة الرأسية الجديدة لسحب النوتش للأسفل

    readonly property real nh: notchHeight
    readonly property real nw: notchWidth

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

        // 5. خط مستقيم أفقي تماماً حتى بداية انحناء النوتش الأيمن (لحماية استقامة الشاشة)
        PathLine {
            x: root.midX + (root.nw / 2) + root.rN
            y: root.height
        }

        // [تعديل جديد] 5b. خط عمودي ينزل لأسفل الشاشة الفيزيائية بمقدار الإزاحة المطلوبة
        PathLine {
            x: root.midX + (root.nw / 2) + root.rN
            y: root.height + root.notchOffset
        }

        // 6. القوس الأيمن الخارجي - مزاح للأسفل بمقدار الإزاحة
        PathArc {
            x: root.midX + (root.nw / 2)
            y: root.height + root.notchOffset - root.rN
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Clockwise
        }

        // 7. الحائط الأيمن للنوتش (صعود رأسي للأعلى) - مزاح للأسفل
        PathLine {
            x: root.midX + (root.nw / 2)
            y: root.height + root.notchOffset - root.nh + root.rN
        }

        // 8. القوس الأيمن الداخلي (يربط الحائط بسقف الدوك) - مزاح للأسفل
        PathArc {
            x: root.midX + (root.nw / 2) - root.rN
            y: root.height + root.notchOffset - root.nh
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Counterclockwise
        }

        // 9. سقف الدوك الأفقي المستقيم (متجهاً لليسار) - مزاح للأسفل
        PathLine {
            x: root.midX - (root.nw / 2) + root.rN
            y: root.height + root.notchOffset - root.nh
        }

        // 10. القوس الأيسر الداخلي - مزاح للأسفل
        PathArc {
            x: root.midX - (root.nw / 2)
            y: root.height + root.notchOffset - root.nh + root.rN
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Counterclockwise
        }

        // 11. الحائط الأيسر للنوتش (نزول رأسي للأسفل) - مزاح للأسفل
        PathLine {
            x: root.midX - (root.nw / 2)
            y: root.height + root.notchOffset - root.rN
        }

        // 12. القوس الأيسر الخارجي - مزاح للأسفل
        PathArc {
            x: root.midX - (root.nw / 2) - root.rN
            y: root.height + root.notchOffset
            radiusX: root.rN
            radiusY: root.rN
            direction: PathArc.Clockwise
        }

        // [تعديل جديد] 12b. خط عمودي يصعد للأعلى ليعود لمستوى حافة الشاشة الأساسية بعد انتهاء النوتش
        PathLine {
            x: root.midX - (root.nw / 2) - root.rN
            y: root.height
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
