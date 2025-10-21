import QtQuick
import Quickshell
// import QtQuick.Layouts

import "root:/themes"
import "root:/components"
import "root:/utils"
import "root:/config/EventNames.js" as Events
import "root:/config"

PanelWindow {
    id: root

    property bool isShown: false
    property var menuSelectorRef: menus

    implicitWidth: ThemeManager.selectedTheme.dimensions.menuWidth
    // implicitHeight: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight

    // exclusiveZone: ThemeManager.selectedTheme.dimensions.menuWidth - 40

    color: "transparent"
    visible: false

    // focusable: menus.currentIndex == 0 || menus.currentIndex == 6
    focusable: menus.currentIndex == 6 || menus.currentIndex == 4
    exclusionMode: ExclusionMode.Ignore
    // exclusionMode: ExclusionMode.Auto

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex === -1) {
                root.close();
            } else {
                root.open();
            }
        }
    }

    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        left: 40 + 10
        top: ThemeManager.selectedTheme.dimensions.barHeight + 10
        bottom: 10
    }

    CorneredBox {
        id: contentContainer
        implicitWidth: parent.width
        implicitHeight: parent.height

        radius: ThemeManager.selectedTheme.dimensions.elementRadius * 1.3
        border.color: ThemeManager.selectedTheme.colors.primary
        border.width: 2

        // Canvas-based rotating-color border (colors move around the box, box itself stays still)
        // Canvas {
        //     id: borderCanvas
        //     anchors.fill: parent
        //     z: contentContainer.z + 1
        //     property real strokeW: 4
        //     property int segments: 320         // عدد المقاطع على المحيط — زِده لتحسين النعومة، اخفض للأداء
        //     property real offset: 0.0          // يتراوح من 0..1 لتدوير الألوان
        //     property var colorStops: [
        //         {
        //             pos: 0.00,
        //             color: "#ff4d4d"
        //         },
        //         {
        //             pos: 0.20,
        //             color: "#ffb86b"
        //         },
        //         {
        //             pos: 0.40,
        //             color: "#7ee787"
        //         },
        //         {
        //             pos: 0.60,
        //             color: "#6ec0ff"
        //         },
        //         {
        //             pos: 0.80,
        //             color: "#b38bff"
        //         },
        //         {
        //             pos: 1.00,
        //             color: "#ff4d4d"
        //         }
        //     ]
        //     property real cornerR: Math.max(0, contentContainer.radius)
        //
        //     onPaint: {
        //         var ctx = getContext("2d");
        //         ctx.reset();
        //         var w = width;
        //         var h = height;
        //         var r = cornerR;
        //         var stroke = strokeW;
        //         var half = stroke / 2;
        //
        //         // حساب محيط المستطيل المزوايا:
        //         var straightW = Math.max(0, w - 2 * r);
        //         var straightH = Math.max(0, h - 2 * r);
        //         var perimeter = 2 * straightW + 2 * straightH + 2 * Math.PI * r; // 4 أرباع تساوي دائرة كاملة
        //
        //         // دالة تحويل (distance along perimeter) -> نقطة (x,y)
        //         function pointAtDistance(d) {
        //             // نجعل d داخل [0, perimeter)
        //             d = ((d % perimeter) + perimeter) % perimeter;
        //             // أعلى الحافة (من اليسار إلى اليمين) تبدأ عند زاوية (r,0) ثم يمين
        //             var seg = 0;
        //             // top straight
        //             if (d < straightW) {
        //                 return {
        //                     x: half + r + d,
        //                     y: half
        //                 };
        //             }
        //             d -= straightW;
        //             // top-right corner (quarter arc): angle from -90deg to 0deg
        //             if (d < (Math.PI / 2) * r) {
        //                 var ang = (-Math.PI / 2) + (d / (r * Math.PI / 2)) * (Math.PI / 2);
        //                 var cx = w - r - half;
        //                 var cy = r + half;
        //                 return {
        //                     x: cx + Math.cos(ang) * r,
        //                     y: cy + Math.sin(ang) * r
        //                 };
        //             }
        //             d -= (Math.PI / 2) * r;
        //             // right straight (top->bottom)
        //             if (d < straightH) {
        //                 return {
        //                     x: w - half,
        //                     y: half + r + d
        //                 };
        //             }
        //             d -= straightH;
        //             // bottom-right corner (0 -> 90 deg)
        //             if (d < (Math.PI / 2) * r) {
        //                 var ang = 0 + (d / (r * Math.PI / 2)) * (Math.PI / 2);
        //                 var cx = w - r - half;
        //                 var cy = h - r - half;
        //                 return {
        //                     x: cx + Math.cos(ang) * r,
        //                     y: cy + Math.sin(ang) * r
        //                 };
        //             }
        //             d -= (Math.PI / 2) * r;
        //             // bottom straight (right->left)
        //             if (d < straightW) {
        //                 return {
        //                     x: w - half - r - d,
        //                     y: h - half
        //                 };
        //             }
        //             d -= straightW;
        //             // bottom-left corner (90 -> 180 deg)
        //             if (d < (Math.PI / 2) * r) {
        //                 var ang = Math.PI / 2 + (d / (r * Math.PI / 2)) * (Math.PI / 2);
        //                 var cx = r + half;
        //                 var cy = h - r - half;
        //                 return {
        //                     x: cx + Math.cos(ang) * r,
        //                     y: cy + Math.sin(ang) * r
        //                 };
        //             }
        //             d -= (Math.PI / 2) * r;
        //             // left straight (bottom->top)
        //             if (d < straightH) {
        //                 return {
        //                     x: half,
        //                     y: h - half - r - d
        //                 };
        //             }
        //             d -= straightH;
        //             // top-left corner (180 -> 270 deg)
        //             // remaining arc
        //             var ang = Math.PI + (d / (r * Math.PI / 2)) * (Math.PI / 2);
        //             var cx = r + half;
        //             var cy = r + half;
        //             return {
        //                 x: cx + Math.cos(ang) * r,
        //                 y: cy + Math.sin(ang) * r
        //             };
        //         }
        //
        //         // تحويل لون HEX إلى rgba object
        //         function hexToRgba(hx) {
        //             var h = hx.replace("#", "");
        //             if (h.length === 3) {
        //                 h = h.split('').map(function (c) {
        //                     return c + c;
        //                 }).join('');
        //             }
        //             var bigint = parseInt(h, 16);
        //             return {
        //                 r: (bigint >> 16) & 255,
        //                 g: (bigint >> 8) & 255,
        //                 b: bigint & 255,
        //                 a: 1
        //             };
        //         }
        //
        //         // مزج لونين بنسبة t [0..1]
        //         function lerpColor(c1, c2, t) {
        //             return {
        //                 r: Math.round(c1.r + (c2.r - c1.r) * t),
        //                 g: Math.round(c1.g + (c2.g - c1.g) * t),
        //                 b: Math.round(c1.b + (c2.b - c1.b) * t),
        //                 a: c1.a + (c2.a - c1.a) * t
        //             };
        //         }
        //
        //         // إعطاء لون عند موضع بالنسبة (posNormalized 0..1) مع مراعاة offset دوّار
        //         function colorAt(posNormalized) {
        //             // نطبق الإزاحة
        //             var p = (posNormalized + borderCanvas.offset) % 1.0;
        //             // إيجاد وقفين في colorStops
        //             var stops = borderCanvas.colorStops;
        //             // إيجاد i بحيث stops[i].pos <= p <= stops[i+1].pos
        //             for (var i = 0; i < stops.length - 1; ++i) {
        //                 var a = stops[i], b = stops[i + 1];
        //                 if (p >= a.pos && p <= b.pos) {
        //                     var localT = (p - a.pos) / (b.pos - a.pos);
        //                     var ca = hexToRgba(a.color), cb = hexToRgba(b.color);
        //                     var c = lerpColor(ca, cb, localT);
        //                     return "rgba(" + c.r + "," + c.g + "," + c.b + "," + c.a + ")";
        //                 }
        //             }
        //             // fallback
        //             return borderCanvas.colorStops[0].color;
        //         }
        //
        //         ctx.lineWidth = stroke;
        //         ctx.lineCap = "round";
        //         ctx.lineJoin = "round";
        //
        //         // رسم كل قطعة بلونها
        //         var segCount = Math.max(8, borderCanvas.segments);
        //         var step = perimeter / segCount;
        //
        //         // تجنب الـ aliasing عند استخدام stroke متعددة: نرسم مقاطع متصلة
        //         ctx.beginPath();
        //         for (var i = 0; i < segCount; ++i) {
        //             var d1 = i * step;
        //             var d2 = (i + 1) * step;
        //             var p1 = pointAtDistance(d1);
        //             var p2 = pointAtDistance(d2);
        //             // نرسم مقطع مستقيم من p1 إلى p2 مع لون مخصّص
        //             ctx.strokeStyle = colorAt((d1 / perimeter)); // لون اعتماداً على موضع بداية المقطع
        //             ctx.beginPath();
        //             ctx.moveTo(p1.x, p1.y);
        //             ctx.lineTo(p2.x, p2.y);
        //             ctx.stroke();
        //         }
        //     }
        //
        //     // عند تغيير offset نعيد الرسم
        //     onOffsetChanged: requestPaint()
        //
        //     // أنيميشن دائري سلس: offset من 0..1 بشكل لا نهائي
        //     NumberAnimation on offset {
        //         from: 0
        //         to: 1
        //         duration: 2500
        //         loops: Animation.Infinite
        //         easing.type: Easing.Linear
        //     }
        //
        //     // تحسين أوليّة الرسم بعد التحميل
        //     Component.onCompleted: requestPaint()
        // }

        // color: "#000000"

        // opacity: 1.0
        // scale: 0.98

        // layer.enabled: true
        // layer.effect: Shadow {}

        Column {
            id: col
            width: parent.width
            height: root.implicitHeight

            spacing: 10
            // anchors.fill: parent

            property int sideMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            Header {
                id: menuHeader

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: col.sideMargin
                anchors.rightMargin: col.sideMargin
            }

            Menus {
                id: menus
                height: contentContainer.height - menuHeader.height - col.sideMargin

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: col.sideMargin
                anchors.rightMargin: col.sideMargin
            }
        }

        transformOrigin: Item.Left

        states: [
            State {
                name: "SHOWN"
                when: root.isShown
                PropertyChanges {
                    target: contentContainer
                    x: 0
                    opacity: 1.0
                    scale: 1.0
                }
            },
            State {
                name: "HIDDEN"
                when: !root.isShown
                PropertyChanges {
                    target: contentContainer
                    x: -contentContainer.width  // يخرج من الشاشة كلياً
                    opacity: 0.0
                    scale: 0.95  // تصغير خفيف
                }
            }
        ]

        transitions: [
            Transition {
                from: "HIDDEN"
                to: "SHOWN"
                ParallelAnimation {
                    NumberAnimation {
                        properties: "x"
                        duration: 600
                        easing.type: Easing.OutExpo
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        properties: "scale"
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }
            },
            Transition {
                from: "SHOWN"
                to: "HIDDEN"
                ParallelAnimation {
                    NumberAnimation {
                        properties: "x"
                        duration: 400
                        easing.type: Easing.InExpo
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 900
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        properties: "scale"
                        duration: 360
                        easing.type: Easing.InCubic
                    }
                }
            }
        ]
    }

    // عند التغيير في isShown، نهيّئ الظهور أو بدء الإخفاء المؤجل
    onIsShownChanged: {
        if (isShown) {
            root.visible = true;
            hideTimer.stop();
        } else {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 500
        repeat: false
        onTriggered: root.visible = false
    }

    Component.onCompleted: {
        if (!isShown) {
            root.visible = false;
        }

        EventBus.on(Events.CLOSE_LEFTBAR, function () {
            // root.close();
            isShown = false;
        });

        EventBus.on(Events.OPEN_LEFTBAR, function () {
            // root.open();
            isShown = true;
        });
    }

    function open() {
        EventBus.emit(Events.OPEN_LEFTBAR);
    }
    function close() {
        EventBus.emit(Events.CLOSE_LEFTBAR);
    }
}
