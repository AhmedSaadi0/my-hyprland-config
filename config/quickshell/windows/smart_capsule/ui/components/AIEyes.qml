import QtQuick
import "root:/config"
import "../../logic"

Item {
    id: root

    // =========================================================
    // 1. خصائص التكوين (CONFIGURATION PROPERTIES)
    // =========================================================
    implicitHeight: 26
    implicitWidth: 60

    // الحالات المتاحة: "idle", "happy", "suspicious", "shocked", "sleeping", "thinking", "music"
    property string emotion: EyeController.currentEmotion
    property color eyeColor: "white"
    property int animDur: 200
    property bool enableMouseInteraction: true

    property real gazeX: 0
    property real gazeY: 0

    // ربط الحالة الحالية للمكون بالشعور القادم من المتحكم
    state: EyeController.currentEmotion

    Behavior on eyeColor {
        ColorAnimation {
            duration: 200
        }
    }

    // تحديث اللون عند تغير الحالة
    // onStateChanged: {
    //     // if (state === "angry")
    //     //     eyeColor = "#FF4444";
    //     // else
    //     // // أحمر
    //     // if (state === "sad")
    //     //     eyeColor = "#4444FF";
    //     // else
    //     // // أزرق
    //     // if (state === "love")
    //     //     eyeColor = "#FF69B4";
    //     // else
    //     //     // وردي
    //     eyeColor = "white"; // اللون الطبيعي
    // }

    NibrasShellShortcut {
        name: "setIdle"
        onPressed: {
            EyeController.showEmotion("idle");
        }
    }

    // 2. Happy (سعيد)
    NibrasShellShortcut {
        name: "setHappy"
        onPressed: {
            EyeController.showEmotion("happy");
        }
    }

    // 3. Suspicious (مشكك)
    NibrasShellShortcut {
        name: "setSuspicious"
        onPressed: {
            EyeController.showEmotion("suspicious");
        }
    }

    // 4. Shocked (مصدوم)
    NibrasShellShortcut {
        name: "setShocked"
        onPressed: {
            EyeController.showEmotion("shocked");
        }
    }

    // 5. Sleeping (نائم)
    NibrasShellShortcut {
        name: "setSleeping"
        onPressed: {
            EyeController.showEmotion("sleeping");
        }
    }

    // 6. Thinking (يفكر)
    NibrasShellShortcut {
        name: "setThinking"
        onPressed: {
            EyeController.showEmotion("thinking");
        }
    }

    // 7. Music (موسيقى)
    NibrasShellShortcut {
        name: "setMusic"
        onPressed: {
            EyeController.showEmotion("music");
        }
    }

    // 8. Angry (غاضب)
    NibrasShellShortcut {
        name: "setAngry"
        onPressed: {
            EyeController.showEmotion("angry");
        }
    }

    // 9. Sad (حزين)
    NibrasShellShortcut {
        name: "setSad"
        onPressed: {
            EyeController.showEmotion("sad");
        }
    }

    // 10. Confused (محتار)
    NibrasShellShortcut {
        name: "setConfused"
        onPressed: {
            EyeController.showEmotion("confused");
        }
    }

    // 11. Wink (غمزة)
    NibrasShellShortcut {
        name: "setWink"
        onPressed: {
            EyeController.showEmotion("wink", 700);
        }
    }

    // 12. Bored (ممل/ضجر)
    NibrasShellShortcut {
        name: "setBored"
        onPressed: {
            EyeController.showEmotion("bored");
        }
    }

    // 13. Love (حب)
    NibrasShellShortcut {
        name: "setLove"
        onPressed: {
            EyeController.showEmotion("love");
        }
    }

    // 14. Focused (مركز)
    NibrasShellShortcut {
        name: "setFocused"
        onPressed: {
            EyeController.showEmotion("focused");
        }
    }

    NibrasShellShortcut {
        name: "setDead"
        onPressed: {
            EyeController.showEmotion("dead");
        }
    }

    // تجربة وضع الاستماع
    NibrasShellShortcut {
        name: "setListening"
        onPressed: {
            EyeController.showEmotion("listening");
        }
    }

    // =========================================================
    // 2. المنطق والدوال المساعدة (LOGIC & HELPER FUNCTIONS)
    // =========================================================

    // دالة: إجبار العين على أخذ شكل الحالة الحالية (لإصلاح العين بعد الرمش)
    function fixEyeState() {
        // 1. إعادة ربط الخصائص بالـ State
        leftEye.eyeH = Qt.binding(function () {
            return leftEye.eyeH;
        });
        rightEye.eyeH = Qt.binding(function () {
            return rightEye.eyeH;
        });

        // 2. تحديث الحالة لفرض إعادة الرسم
        var current = root.state;
        root.state = "";      // نلغي الحالة لحظياً
        root.state = current; // نعيد تفعيلها
    }

    // دالة: إعادة تعيين روابط الخصائص
    function resetEyeBindings() {
        leftEye.eyeH = Qt.binding(function () {
            return leftEye.eyeH;
        });
        rightEye.eyeH = Qt.binding(function () {
            return rightEye.eyeH;
        });
    }

    Connections {
        target: EyeController

        function onCurrentEmotionChanged() {
            // 1. تحديث الحالة
            root.state = EyeController.currentEmotion;

            // 2. إيقاف الرمش إذا كان يعمل
            if (blinkAnim.running) {
                blinkAnim.stop();
            }

            // 3. إصلاح شكل العين فوراً
            root.fixEyeState();

            // 4. إعادة تشغيل مؤقت الرمش
            blinkTimer.restart();
        }
    }

    // =========================================================
    // 3. العناصر المرئية (VISUAL ELEMENTS)
    // =========================================================

    // أ) العيون (الأساسية)
    Row {
        id: eyesRow
        anchors.centerIn: parent
        spacing: 10

        // الظهور والإخفاء
        visible: root.emotion !== "music"
        opacity: visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
        Behavior on spacing {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }
        }

        AIEyePart {
            id: leftEye
            color: root.eyeColor
            animDur: 200
        }

        AIEyePart {
            id: rightEye
            color: root.eyeColor
            animDur: 200
        }
    }

    // ب) نقاط التفكير
    // ThinkingDots {
    //     anchors.centerIn: parent
    //     visible: root.emotion === "thinking"
    //     opacity: visible ? 1 : 0
    //     color: root.eyeColor
    // }

    // ج) معادل الموسيقى (Visualizer)
    Row {
        id: musicVisualizer
        anchors.centerIn: parent
        spacing: 4

        visible: root.emotion === "music"
        opacity: visible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Repeater {
            model: 4
            Rectangle {
                id: bar
                width: 4
                height: 4
                radius: 2
                color: root.eyeColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }

                Timer {
                    running: root.emotion === "music"
                    repeat: true
                    interval: 100 + Math.random() * 200
                    triggeredOnStart: true
                    onTriggered: {
                        bar.height = 4 + Math.random() * 16;
                        interval = 100 + Math.random() * 150;
                    }
                    onRunningChanged: if (!running)
                        bar.height = 4
                }
            }
        }
    }

    // =========================================================
    // 4. التفاعل (INTERACTION)
    // =========================================================
    MouseArea {
        anchors.fill: parent
        // ملاحظة: تم تعديل eyeRoot إلى root هنا لأنه المعرف الصحيح في هذا الملف
        enabled: root.enableMouseInteraction
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            EyeController.isHovered = true;
            // CapsuleManager.request(...)
        }

        onExited: {
            EyeController.isHovered = false;
            // CapsuleManager.reset(...)
        }

        onClicked: {
            EyeController.think(2000);
            // root.requestExpand(...)
        }
    }

    // =========================================================
    // 5. منطق الرمش (BLINK LOGIC)
    // =========================================================
    Timer {
        id: blinkTimer
        interval: 3000
        running: root.emotion !== "thinking" && root.emotion !== "sleeping" && root.emotion !== "music"
        repeat: true
        onTriggered: {
            blinkAnim.start();
            interval = 2000 + Math.random() * 3000;
        }
    }

    SequentialAnimation {
        id: blinkAnim
        // 1. الإغلاق
        ParallelAnimation {
            NumberAnimation {
                target: leftEye
                property: "eyeH"
                to: 1
                duration: 50
            }
            NumberAnimation {
                target: rightEye
                property: "eyeH"
                to: 1
                duration: 50
            }
        }
        // 2. الانتظار
        PauseAnimation {
            duration: 100
        }
        // 3. الاستعادة
        ScriptAction {
            script: root.fixEyeState()
        }
    }

    // =========================================================
    // 6. الحالات (STATES)
    // =========================================================
    states: [
        State {
            name: "idle"
            PropertyChanges {
                target: leftEye
                eyeW: 6
                eyeH: 10
                eyeR: 3
                browY: -3
                browAngle: 0
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 6
                eyeH: 10
                eyeR: 3
                browY: -3
                browAngle: 0
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "happy"
            PropertyChanges {
                target: leftEye
                eyeW: 14
                eyeH: 8
                eyeR: 0
                browY: -2
                browAngle: 0
                browW: 14
                isHappyShape: true
            }
            PropertyChanges {
                target: rightEye
                eyeW: 14
                eyeH: 8
                eyeR: 0
                browY: -2
                browAngle: 0
                browW: 14
                isHappyShape: true
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6
            }
        },
        State {
            name: "suspicious"
            PropertyChanges {
                target: leftEye
                eyeW: 10
                eyeH: 4
                eyeR: 2
                browY: -2
                browAngle: 15
                browW: 12
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 10
                eyeH: 10
                eyeR: 4
                browY: -4
                browAngle: -5
                browW: 12
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6
            }
        },
        State {
            name: "shocked"
            PropertyChanges {
                target: leftEye
                eyeW: 9
                eyeH: 9
                eyeR: 4
                browY: -4
                browAngle: -20
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 9
                eyeH: 9
                eyeR: 4
                browY: -4
                browAngle: 20
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 5
            }
        },
        State {
            name: "sleeping"
            PropertyChanges {
                target: leftEye
                eyeW: 8
                eyeH: 2
                eyeR: 1
                browY: 0
                browAngle: 0
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 8
                eyeH: 2
                eyeR: 1
                browY: 0
                browAngle: 0
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6
            }
        },
        State {
            name: "music"
            PropertyChanges {
                target: leftEye
                eyeH: 0
            }
            PropertyChanges {
                target: rightEye
                eyeH: 0
            }
        },
        State {
            name: "angry"
            PropertyChanges {
                target: leftEye
                eyeW: 8
                eyeH: 7
                eyeR: 2
                browY: -1
                browAngle: 25
                browW: 10
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 8
                eyeH: 7
                eyeR: 2
                browY: -1
                browAngle: -25
                browW: 10
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "sad" // أو EyeState.SAD
            PropertyChanges {
                target: leftEye
                eyeW: 12        // عين واسعة قليلاً
                eyeH: 8         // ارتفاع مناسب للقوس
                eyeR: 0
                browY: -4       // رفع الحاجب للأعلى
                browAngle: -30  // ميلان قوي للحاجب (/)
                browW: 12
                isHappyShape: false
                isHeartShape: false
                isSadShape: true // <-- تفعيل الشكل الجديد
            }
            PropertyChanges {
                target: rightEye
                eyeW: 12
                eyeH: 8
                eyeR: 0
                browY: -4
                browAngle: 30   // ميلان عكسي للحاجب (\)
                browW: 12
                isHappyShape: false
                isHeartShape: false
                isSadShape: true // <-- تفعيل الشكل الجديد
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
            // اللون الأزرق يتم تعيينه عبر onStateChanged
        },
        State {
            name: "confused"
            PropertyChanges {
                target: leftEye
                eyeW: 8
                eyeH: 8
                eyeR: 3
                browY: -2
                browAngle: 0
                browW: 8 // حاجب عادي
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 10
                eyeH: 10
                eyeR: 4
                browY: -8
                browAngle: -10
                browW: 8 // حاجب مرفوع جداً
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6
            }
        },
        State {
            name: "wink"
            PropertyChanges {
                target: leftEye
                eyeW: 12
                eyeH: 12
                eyeR: 6
                browY: -4
                browAngle: 0
                browW: 10
                isHappyShape: false // عين مفتوحة
            }
            PropertyChanges {
                target: rightEye
                eyeW: 12
                eyeH: 2
                eyeR: 1 // عين مغلقة (خط)
                browY: 1
                browAngle: 0
                browW: 10
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "bored"
            PropertyChanges {
                target: leftEye
                eyeW: 8
                eyeH: 4
                eyeR: 1
                browY: -1
                browAngle: 0
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 8
                eyeH: 4
                eyeR: 1
                browY: -1
                browAngle: 0
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "love"
            PropertyChanges {
                target: leftEye
                eyeW: 13 // تعريض العين قليلاً لإظهار القلب
                eyeH: 12
                eyeR: 0
                browY: -2 // رفع الحاجب للأعلى
                browAngle: 0
                browW: 12
                browH: 2
                isHappyShape: false
                isHeartShape: true // <-- تفعيل شكل القلب
            }
            PropertyChanges {
                target: rightEye
                eyeW: 13
                eyeH: 12
                eyeR: 0
                browY: -2
                browAngle: 0
                browW: 12
                browH: 2
                isHappyShape: false
                isHeartShape: true // <-- تفعيل شكل القلب
            }
            PropertyChanges {
                target: eyesRow
                spacing: 3
            }
            // ملاحظة: اللون يتغير تلقائياً إلى الوردي بفضل الكود الموجود في onStateChanged
        },
        State {
            name: "focused"
            PropertyChanges {
                target: leftEye
                eyeW: 6
                eyeH: 6
                eyeR: 3
                browY: 0
                browAngle: 5
                browW: 8 // حاجب منخفض ومائل قليلاً للداخل
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 6
                eyeH: 6
                eyeR: 3
                browY: 0
                browAngle: -5
                browW: 8
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "thinking"
            PropertyChanges {
                target: leftEye
                eyeW: 12 // حجم كبير ومناسب للدوران
                eyeH: 12
                eyeR: 5
                browY: -2
                browAngle: 0
                browW: 9
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: true // <-- تفعيل الشكل الجديد
            }
            PropertyChanges {
                target: rightEye
                eyeW: 12 // حجم كبير ومناسب للدوران
                eyeH: 12
                eyeR: 5
                browY: -2
                browAngle: 0
                browW: 9
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: true // <-- تفعيل الشكل الجديد
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "dead" // أو EyeState.DEAD
            PropertyChanges {
                target: leftEye
                eyeW: 14    // حجم مناسب للـ X
                eyeH: 14
                eyeR: 0

                // حواجب محايدة أو منخفضة قليلاً
                browY: -2
                browAngle: 0
                browW: 10
                showBrow: true

                // تصفير الأشكال الأخرى
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false

                // تفعيل الشكل الجديد
                isDeadShape: true
                isListeningShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 14
                eyeH: 14
                eyeR: 0
                browY: -2
                browAngle: 0
                browW: 10
                showBrow: true

                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false

                isDeadShape: true
                isListeningShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },

        // 2. حالة الاستماع (Listening)
        State {
            name: "listening" // أو EyeState.LISTENING
            PropertyChanges {
                target: leftEye
                eyeW: 12    // حجم أكبر لاستيعاب التموجات
                eyeH: 12
                eyeR: 8

                // رفع الحواجب لتبدو منتبهاً
                browY: -5
                browAngle: 0
                browW: 10
                showBrow: true

                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false

                // تفعيل شكل الاستماع
                isListeningShape: true
            }
            PropertyChanges {
                target: rightEye
                eyeW: 12
                eyeH: 12
                eyeR: 8
                browY: -5
                browAngle: 0
                browW: 10
                showBrow: true

                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false

                isListeningShape: true
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6
            }
        }
    ]
}
