import QtQuick
import QtQuick.Shapes // ضروري للرسم

Item {
    id: root

    property color color: "white"

    // خصائص العين
    property int eyeW: 8
    property int eyeH: 14
    property int eyeR: 4

    // الأشكال المتاحة
    property bool isHappyShape: false
    property bool isHeartShape: false
    property bool isSadShape: false
    property bool isThinkingShape: false
    property bool isDeadShape: false
    property bool isListeningShape: false

    // خصائص الحاجب
    property int browH: 2
    property int browW: 12
    property int browY: -3
    property int browAngle: 0
    property bool showBrow: true

    property int animDur: 300

    height: 24
    width: Math.max(eyeW, browW)
    anchors.verticalCenter: parent.verticalCenter

    // 1. الحاجب (كما هو)
    Rectangle {
        id: brow
        color: root.color
        width: root.browW
        height: root.browH
        radius: 1
        visible: root.showBrow

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: eyeContainer.top
        anchors.bottomMargin: -root.browY

        transform: Rotation {
            origin.x: brow.width / 2
            origin.y: brow.height / 2
            angle: root.browAngle
            Behavior on angle {
                NumberAnimation {
                    duration: root.animDur
                    easing.type: Easing.OutBack
                }
            }
        }

        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: root.animDur
                easing.type: Easing.OutBack
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: root.animDur
            }
        }
    }

    // 2. حاوية العين
    Item {
        id: eyeContainer
        width: root.eyeW
        height: root.eyeH
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        // أ) العين العادية
        Rectangle {
            id: normalEye
            color: root.color
            anchors.fill: parent
            radius: root.eyeR

            // نخفيها إذا كان أي شكل خاص مفعلاً
            // opacity: (root.isHappyShape || root.isHeartShape || root.isSadShape || root.isThinkingShape) ? -1 : 1
            opacity: (root.isHappyShape || root.isHeartShape || root.isSadShape || root.isThinkingShape || root.isDeadShape || root.isListeningShape) ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            Behavior on radius {
                NumberAnimation {
                    duration: root.animDur
                }
            }
        }

        // ب) عين السعادة (الهلال)
        Item {
            id: happyEye
            anchors.fill: parent

            // تظهر فقط إذا كانت isHappyShape مفعلة و isHeartShape غير مفعلة
            opacity: (root.isHappyShape && !root.isHeartShape) ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            clip: true
            Rectangle {
                width: root.eyeW
                height: root.eyeW + (root.eyeW / 4)
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                border.color: root.color
                border.width: root.eyeW * 0.2
                radius: width / 2
            }
        }

        // ج) عين الحب (القلب) - جديد!
        // ج) عين الحب (القلب) - نسخة محسنة وناعمة
        Item {
            id: heartEye
            anchors.centerIn: parent
            width: root.eyeW
            height: root.eyeH

            opacity: root.isHeartShape ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            // خصائص داخلية للتحكم بالأنيميشن
            property real pulseScale: 1.0
            property color currentHeartColor: root.color

            // أنيميشن النبض (Heartbeat)
            SequentialAnimation {
                running: root.isHeartShape // يعمل فقط عندما يكون الشكل قلباً
                loops: Animation.Infinite
                alwaysRunToEnd: false // يتوقف فوراً عند تغيير الحالة

                // النبضة الأولى (الكبيرة)
                ParallelAnimation {
                    NumberAnimation {
                        target: heartEye
                        property: "pulseScale"
                        to: 1.2
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                    ColorAnimation {
                        target: heartEye
                        property: "currentHeartColor"
                        to: "#FF2A68"
                        duration: 150
                    } // أحمر وردي
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: heartEye
                        property: "pulseScale"
                        to: 1.0
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                    ColorAnimation {
                        target: heartEye
                        property: "currentHeartColor"
                        to: root.color
                        duration: 150
                    } // عودة للون الأصلي
                }

                // وقفة قصيرة
                PauseAnimation {
                    duration: 100
                }

                // النبضة الثانية (الصغيرة)
                ParallelAnimation {
                    NumberAnimation {
                        target: heartEye
                        property: "pulseScale"
                        to: 1.1
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                    ColorAnimation {
                        target: heartEye
                        property: "currentHeartColor"
                        to: "#FF2A68"
                        duration: 150
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: heartEye
                        property: "pulseScale"
                        to: 1.0
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                    ColorAnimation {
                        target: heartEye
                        property: "currentHeartColor"
                        to: root.color
                        duration: 150
                    }
                }

                // وقفة طويلة قبل الدورة التالية
                PauseAnimation {
                    duration: 600
                }

                // إعادة تعيين الألوان عند التوقف (لضمان عدم توقفها على الأحمر)
                onRunningChanged: {
                    if (!running) {
                        heartEye.pulseScale = 1.0;
                        heartEye.currentHeartColor = root.color;
                    }
                }
            }

            Shape {
                // نستخدم مربعاً قياسياً 24x24
                width: 24
                height: 24
                anchors.centerIn: parent

                preferredRendererType: Shape.CurveRenderer
                layer.enabled: true
                layer.samples: 8
                layer.smooth: true

                // التحجيم يجمع بين حجم العين + تأثير النبض
                transform: Scale {
                    xScale: (root.eyeW / 24) * heartEye.pulseScale
                    yScale: (root.eyeH / 24) * heartEye.pulseScale
                    origin.x: 12
                    origin.y: 12
                }

                ShapePath {
                    strokeWidth: 0
                    // نربط اللون بالخاصية المتحركة بدلاً من اللون الثابت
                    fillColor: heartEye.currentHeartColor

                    // مسار القلب (Material Design)
                    PathSvg {
                        path: "M12,21.35 L10.55,20.03 C5.4,15.36 2,12.27 2,8.5 C2,5.41 4.42,3 7.5,3 C9.24,3 10.91,3.81 12,5.08 C13.09,3.81 14.76,3 16.5,3 C19.58,3 22,5.41 22,8.5 C22,12.27 18.6,15.36 13.45,20.03 L12,21.35 Z"
                    }
                }
            }
        }

        Item {
            id: thinkingEye
            anchors.centerIn: parent
            width: root.eyeW
            height: root.eyeW // مربعة لتكون دائرية

            opacity: root.isThinkingShape ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            // الحلقة الخارجية (تدور ببطء)
            Rectangle {
                id: outerRing
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.color: root.color
                border.width: 2

                // نجعلها مقطوعة (Arc) لتبدو كحلقة تحميل
                // خدعة بسيطة: نستخدم Canvas أو Shape، أو نستخدم مستطيل للقص
                // للأبسط والأداء: نستخدم Dash pattern إذا أمكن، أو نستخدم ShapePath
            }

            // الطريقة الأفضل لرسم حلقات مقطوعة (Arcs) هي Shape
            Shape {
                anchors.fill: parent
                // تدوير الشكل بالكامل باستمرار
                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 1500
                    loops: Animation.Infinite
                    running: root.isThinkingShape
                }

                ShapePath {
                    strokeWidth: 2
                    strokeColor: root.color
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    // رسم قوس بزاوية 270 درجة (حلقة مفتوحة)
                    PathAngleArc {
                        centerX: thinkingEye.width / 2
                        centerY: thinkingEye.height / 2
                        radiusX: (thinkingEye.width / 2) - 2
                        radiusY: (thinkingEye.height / 2) - 2
                        startAngle: 0
                        sweepAngle: 270
                    }
                }
            }

            // الحلقة الداخلية (تدور عكس الاتجاه وبسرعة)
            Shape {
                anchors.fill: parent
                // تصغيرها قليلاً
                scale: 0.6

                RotationAnimator on rotation {
                    from: 360
                    to: 0
                    duration: 800
                    loops: Animation.Infinite
                    running: root.isThinkingShape
                }

                ShapePath {
                    strokeWidth: 3 // أسمك قليلاً
                    strokeColor: root.color
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    // قوس أصغر
                    PathAngleArc {
                        centerX: thinkingEye.width / 2
                        centerY: thinkingEye.height / 2
                        radiusX: (thinkingEye.width / 2) - 2
                        radiusY: (thinkingEye.height / 2) - 2
                        startAngle: 45
                        sweepAngle: 180
                    }
                }
            }
        }

        Item {
            id: sadEye
            anchors.fill: parent
            // تدوير العنصر بالكامل ليصبح القوس للأسفل
            rotation: 180

            opacity: root.isSadShape ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            clip: true

            // نفس رسمة الهلال السعيد تماماً
            Rectangle {
                width: root.eyeW
                height: root.eyeW + (root.eyeW / 4)
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                color: "transparent"
                border.color: root.color
                border.width: root.eyeW * 0.2
                radius: width / 2
            }
        }

        Item {
            id: deadEye
            anchors.centerIn: parent
            width: root.eyeW
            height: root.eyeH

            opacity: root.isDeadShape ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Shape {
                // نحدد مساحة رسم ثابتة 100x100
                width: 100
                height: 100
                anchors.centerIn: parent

                // تحسين الجودة
                preferredRendererType: Shape.CurveRenderer
                layer.enabled: true
                layer.samples: 4

                // تحجيم الرسم ليناسب حجم العين الفعلي
                transform: Scale {
                    xScale: root.eyeW / 100
                    yScale: root.eyeH / 100
                    origin.x: 50 // منتصف الـ 100
                    origin.y: 50
                }

                ShapePath {
                    // جعل الخط سميكاً ليظهر بوضوح
                    strokeWidth: 15
                    strokeColor: root.color
                    fillColor: "transparent" // مهم جداً
                    capStyle: ShapePath.RoundCap // حواف ناعمة للخطوط

                    // رسم خطين متقاطعين (X)
                    PathSvg {
                        // الخط الأول من (20,20) إلى (80,80)
                        // الخط الثاني من (80,20) إلى (20,80)
                        path: "M 20 20 L 80 80 M 80 20 L 20 80"
                    }
                }
            }
        }

        Item {
            id: listeningEye
            anchors.centerIn: parent
            opacity: root.isListeningShape ? 1 : 0
            visible: opacity > 0

            // الدائرة الثابتة في الوسط
            Rectangle {
                anchors.centerIn: parent
                width: root.eyeW * 0.6
                height: width
                radius: width / 2
                color: root.color
            }

            // دائرة الصدى (تتمدد وتختفي)
            Rectangle {
                id: echoRing
                anchors.centerIn: parent
                width: root.eyeW * 0.6
                height: width
                radius: width / 2
                color: "transparent"
                border.color: root.color
                border.width: 1.5
                opacity: 0.8

                SequentialAnimation {
                    running: root.isListeningShape
                    loops: Animation.Infinite
                    ParallelAnimation {
                        NumberAnimation {
                            target: echoRing
                            property: "scale"
                            from: 1
                            to: 2.5
                            duration: 1000
                        }
                        NumberAnimation {
                            target: echoRing
                            property: "opacity"
                            from: 0.8
                            to: 0
                            duration: 1000
                        }
                    }
                    PropertyAction {
                        target: echoRing
                        property: "scale"
                        value: 1
                    }
                    PropertyAction {
                        target: echoRing
                        property: "opacity"
                        value: 0.8
                    }
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: root.animDur
                easing.type: Easing.OutBack
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: root.animDur
                easing.type: Easing.OutBack
            }
        }
    }
}
