// windows/smart_capsule/ui/components /AIEyes.qml

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
            EyeController.showEmotion("sleeping", 5000);
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
            EyeController.showEmotion("wink");
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
    SequentialAnimation {
        id: winkLoopAnim
        running: root.state === "wink"
        loops: Animation.Infinite
        alwaysRunToEnd: false

        // 1. ثبات الغمزة (مغلقة) لفترة
        PauseAnimation {
            duration: 800
        }

        // 2. فتح العين بسرعة (انتهاء الغمزة)
        NumberAnimation {
            target: rightEye
            property: "eyeH"
            to: 12 // نفس ارتفاع العين اليسرى
            duration: 150
            easing.type: Easing.OutQuad
        }

        // 3. بقاء العين مفتوحة قليلاً
        PauseAnimation {
            duration: 1000
        }

        // 4. إغلاق العين (غمزة جديدة)
        NumberAnimation {
            target: rightEye
            property: "eyeH"
            to: 2 // الارتفاع المغلق
            duration: 150
            easing.type: Easing.InQuad
        }

        // 5. تكرار بعد فترة عشوائية أو ثابتة (هنا نكرر)
    }

    // دالة: إجبار العين على أخذ شكل الحالة الحالية (لإصلاح العين بعد الرمش)
    function fixEyeState() {
        // إعادة التعيين لإجبار التحديث
        var current = root.state;
        root.state = "";
        root.state = current;
    }

    // دالة: إعادة تعيين روابط الخصائص
    // function resetEyeBindings() {
    //     leftEye.eyeH = Qt.binding(function () {
    //         return leftEye.eyeH;
    //     });
    //     rightEye.eyeH = Qt.binding(function () {
    //         return rightEye.eyeH;
    //     });
    // }

    Connections {
        target: EyeController
        function onCurrentEmotionChanged() {
            root.state = EyeController.currentEmotion;
            // نوقف الرمش العشوائي إذا كانت الحالة خاصة
            if (root.state === "thinking" || root.state === "wink" || root.state === "sleeping") {
                blinkTimer.stop();
            } else {
                blinkTimer.restart();
            }
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
            isLeftEye: true
        }

        AIEyePart {
            id: rightEye
            color: root.eyeColor
            animDur: 200
            isLeftEye: false
        }
    }

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
        }

        onExited: {
            EyeController.isHovered = false;
        }

        onClicked: {
            EyeController.think(2000);
        }
    }

    // =========================================================
    // 5. منطق الرمش (BLINK LOGIC)
    // =========================================================
    Timer {
        id: blinkTimer
        interval: 3000
        // لا يرمش في الحالات التي تتطلب عيون مغلقة أو خاصة
        running: root.emotion !== "thinking" && root.emotion !== "sleeping" && root.emotion !== "music" && root.emotion !== "wink"
        repeat: true
        onTriggered: {
            blinkAnim.start();
            interval = 1000 + Math.random() * 3000;
        }
    }

    SequentialAnimation {
        id: blinkAnim
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
        PauseAnimation {
            duration: 100
        }
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
                browW: 13
                isHappyShape: true
            }
            PropertyChanges {
                target: rightEye
                eyeW: 14
                eyeH: 8
                eyeR: 0
                browY: -2
                browAngle: 0
                browW: 13
                isHappyShape: true
            }
            PropertyChanges {
                target: eyesRow
                spacing: 4
            }
        },
        State {
            name: "suspicious"
            PropertyChanges {
                target: leftEye
                eyeW: 10
                eyeH: 7
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
                eyeW: 10
                eyeH: 2

                // نخفي الحاجب أو نتركه مسترخياً
                browY: 0
                browAngle: 0
                browW: 10
                showBrow: false

                // تصفير الأشكال الأخرى
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false
                isListeningShape: false
                isFocusedShape: false

                // تفعيل شكل النوم
                isSleepingShape: true
            }
            PropertyChanges {
                target: rightEye
                eyeW: 10
                eyeH: 2
                browY: 0
                browAngle: 0
                browW: 10
                showBrow: false
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false
                isListeningShape: false
                isFocusedShape: false
                isSleepingShape: true
            }
            PropertyChanges {
                target: eyesRow
                spacing: 3
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
                browAngle: 10 // رفع الحاجب قليلاً للتعبير
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 12
                eyeH: 2 // البداية مغلقة، والأنيميشن winkLoopAnim سيتولى الحركة
                eyeR: 6
                browY: -2 // الحاجب نازل مع الغمزة
                browAngle: 0
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
                eyeW: 12        // عرض متوسط
                eyeH: 3         // ارتفاع صغير جداً (خط سميك قليلاً)
                eyeR: 0         // زوايا قائمة (مستطيل)

                // الحاجب ملاصق تماماً للعين
                browY: -1
                browAngle: 0
                browW: 12
                showBrow: true  // الحاجب يظهر كأنه الجفن العلوي الثقيل

                // استخدام العين العادية (NormalEye) بشكل مستطيل
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false
                isListeningShape: false
                isFocusedShape: false
                isSleepingShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 12
                eyeH: 3
                eyeR: 0

                browY: -1
                browAngle: 0
                browW: 12
                showBrow: true

                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false
                isListeningShape: false
                isFocusedShape: false
                isSleepingShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6
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
                // أبعاد العين الإجمالية
                eyeW: 14
                eyeH: 10 // ارتفاع كلي متوسط
                eyeR: 0

                // === ضبط الحاجب (الأهم) ===
                // إنزاله لأسفل ليلامس أعلى العين تقريباً
                browY: 1
                // زاوية ميلان خفيفة (ليست حادة مثل الغضب 25، بل خفيفة 8)
                browAngle: 8
                browW: 12
                showBrow: true

                // إطفاء الأشكال الأخرى
                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false
                isListeningShape: false

                // تشغيل شكل التحديق
                isFocusedShape: true
            }
            PropertyChanges {
                target: rightEye
                eyeW: 14
                eyeH: 10
                eyeR: 0

                // الحاجب الأيمن
                browY: 1
                browAngle: -8 // عكس الزاوية
                browW: 12
                showBrow: true

                isHappyShape: false
                isHeartShape: false
                isSadShape: false
                isThinkingShape: false
                isDeadShape: false
                isListeningShape: false

                isFocusedShape: true
            }
            PropertyChanges {
                target: eyesRow
                spacing: 6 // تقريب العيون قليلاً يزيد من حدة التركيز
            }
        },
        State {
            name: "thinking"
            PropertyChanges {
                target: leftEye
                eyeW: 14
                eyeH: 14 // حجم مناسب للنقاط
                eyeR: 0
                // الحاجب الأيسر عادي
                browY: -2
                browAngle: 0
                browW: 14
                showBrow: true
                // تفعيل شكل التفكير
                isThinkingShape: true
                isHappyShape: false
            }
            PropertyChanges {
                target: rightEye
                eyeW: 14
                eyeH: 14
                eyeR: 0
                // الحاجب الأيمن مرفوع للأعلى (تعبير فضولي)
                browY: -4 // رفعة قوية
                browAngle: -15 // ميلان
                browW: 14
                showBrow: true

                isThinkingShape: true
                isHappyShape: false
            }
            PropertyChanges {
                target: eyesRow
                spacing: 5
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
