import QtQuick
import QtQuick.Effects

Item {
    id: root

    // الخصائص العامة
    property string wallpaperSource: ""
    property string overlaySource: ""
    property bool depthEnabled: false
    property bool blurEnabled: false
    property bool isMenuOpen: false
    property real blurValue: 0.9

    default property alias content: widgetsContainer.data

    // متغيرات التحكم
    property bool bgShowChannel1: true
    property bool fgShowChannel1: true

    // ---------------------------------------------------------
    // 1. الخلفية
    // ---------------------------------------------------------
    Item {
        id: backgroundLayer
        z: 0
        anchors.fill: parent
        transformOrigin: Item.Center
        scale: root.isMenuOpen ? 1.05 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuart
            }
        }

        layer.enabled: root.blurEnabled
        layer.effect: MultiEffect {
            // تفعيل الضبابية
            blurEnabled: root.blurEnabled

            // 1. هذا الرقم يحجز الذاكرة. يجب أن يكون مساوياً لأقصى رقم تريد الوصول إليه (32 بكسل كافية جداً وناعمة)
            blurMax: 32

            // 2. المعادلة:
            // إذا كانت القائمة مفتوحة: نأخذ القيمة من الإعدادات (مثلاً 0.8) ونضربها في 32 لنحصل على قوة الضبابية (25.6 بكسل)
            // إذا كانت مغلقة: 0
            blur: root.isMenuOpen ? (root.blurValue) : 0

            // تحسين النعومة (اختياري)
            saturation: 0.2 // يمكن تقليل التشبع ليعطي مظهراً زجاجياً أكثر

            Behavior on blur {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutCubic
                }
            }
        }

        Image {
            id: bg1
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)

            states: [
                State {
                    name: "active"
                    when: root.bgShowChannel1
                    PropertyChanges {
                        target: bg1
                        opacity: 1.0
                        z: 2
                    }
                },
                State {
                    name: "inactive"
                    when: !root.bgShowChannel1
                    PropertyChanges {
                        target: bg1
                        opacity: 0.0
                        z: 1
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "inactive"
                    to: "active"
                    NumberAnimation {
                        property: "opacity"
                        duration: 800
                    }
                },
                Transition {
                    from: "active"
                    to: "inactive"
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 800
                        }
                        PropertyAction {
                            property: "opacity"
                            value: 0.0
                        }
                    }
                }
            ]
        }

        Image {
            id: bg2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)

            states: [
                State {
                    name: "active"
                    when: !root.bgShowChannel1
                    PropertyChanges {
                        target: bg2
                        opacity: 1.0
                        z: 2
                    }
                },
                State {
                    name: "inactive"
                    when: root.bgShowChannel1
                    PropertyChanges {
                        target: bg2
                        opacity: 0.0
                        z: 1
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "inactive"
                    to: "active"
                    NumberAnimation {
                        property: "opacity"
                        duration: 800
                    }
                },
                Transition {
                    from: "active"
                    to: "inactive"
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 800
                        }
                        PropertyAction {
                            property: "opacity"
                            value: 0.0
                        }
                    }
                }
            ]
        }
    }

    // ---------------------------------------------------------
    // 2. حاوية الويدجت
    // ---------------------------------------------------------
    Item {
        id: widgetsContainer
        z: 1
        anchors.fill: parent
    }

    // ---------------------------------------------------------
    // 3. طبقة العمق
    // ---------------------------------------------------------
    Item {
        id: foregroundLayer
        z: 2
        anchors.fill: parent

        // يظهر فقط إذا كان التأثير مفعلاً وهناك صورة
        property bool shouldBeVisible: root.depthEnabled && (root.overlaySource !== "")
        opacity: shouldBeVisible ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                duration: 600
            }
        }

        transformOrigin: Item.Center
        scale: root.isMenuOpen ? 1.15 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuart
            }
        }

        // layer.enabled: root.blurEnabled
        // layer.effect: MultiEffect {
        //     blurEnabled: root.blurEnabled
        //     blurMax: 32
        //     blur: root.isMenuOpen ? 0.2 : 0
        //     Behavior on blur {
        //         NumberAnimation {
        //             duration: 800
        //             easing.type: Easing.OutCubic
        //         }
        //     }
        // }

        Image {
            id: fg1
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)
            opacity: root.fgShowChannel1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                }
            }
        }

        Image {
            id: fg2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(parent.width, parent.height)
            opacity: !root.fgShowChannel1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                }
            }
        }
    }

    Timer {
        id: cleanupTimer
        interval: 900
        repeat: false
        onTriggered: {
            if (root.bgShowChannel1) {
                bg2.source = "";
            } else {
                bg1.source = "";
            }

            if (root.fgShowChannel1) {
                fg2.source = "";
            } else {
                fg1.source = "";
            }
        }
    }

    function checkReadinessAndSwapBg() {
        // تحديد الصور التي يتم تحميلها حالياً (التي سننتقل إليها)
        let pendingBg = root.bgShowChannel1 ? bg2 : bg1;

        // ---------------------------------------------------------
        // التحقق من الخلفية
        // ---------------------------------------------------------
        // نعتبرها جاهزة إذا: نجح التحميل (Ready) أو فشل تماماً (Error)
        // المهم ألا تكون في حالة تحميل (Loading)
        let bgFinished = (pendingBg.status === Image.Ready || pendingBg.status === Image.Error);

        // ---------------------------------------------------------
        // قرار التبديل
        // ---------------------------------------------------------
        if (bgFinished) {
            // (اختياري) تسجيل أخطاء في الكونسول للمطور
            if (pendingBg.status === Image.Error) {
                console.warn("Wallpaper failed to load: " + pendingBg.source);
            }

            // تنفيذ التبديل
            root.bgShowChannel1 = !root.bgShowChannel1;

            // تشغيل مؤقت التنظيف لحذف الصور القديمة
            cleanupTimer.restart();
        }
    }

    function checkReadinessAndSwapFg() {
        let pendingFg = root.fgShowChannel1 ? fg2 : fg1;

        // هل نحتاج الطبقة الأمامية؟
        let needOverlay = root.depthEnabled && (root.overlaySource !== "");

        // ---------------------------------------------------------
        // التحقق من الطبقة الأمامية
        // ---------------------------------------------------------
        // نعتبرها جاهزة إذا:
        // 1. لا نحتاجها أصلاً
        // 2. أو نجح تحميلها
        // 3. أو فشل تحميلها
        let fgFinished = !needOverlay || (pendingFg.status === Image.Ready || pendingFg.status === Image.Error);

        // ---------------------------------------------------------
        // قرار التبديل
        // ---------------------------------------------------------
        if (fgFinished) {
            if (needOverlay && pendingFg.status === Image.Error) {
                console.warn("Overlay failed to load: " + pendingFg.source);
            }
            root.fgShowChannel1 = !root.fgShowChannel1;
            cleanupTimer.restart();
        }
    }

    function updateBgSources() {
        let targetBg = root.bgShowChannel1 ? bg2 : bg1;
        targetBg.source = "";
        targetBg.source = root.wallpaperSource;
    }

    function updateFgSources() {
        let targetFg = root.fgShowChannel1 ? fg2 : fg1;
        targetFg.source = "";
        targetFg.source = root.overlaySource;
    }

    // نراقب تغيير أي من المصدرين ونستدعي دالة التحديث الموحدة
    onWallpaperSourceChanged: updateBgSources()
    onOverlaySourceChanged: updateFgSources()

    // مراقبة حالات التحميل (كما كانت)
    Connections {
        target: bg1
        function onStatusChanged() {
            if (!root.bgShowChannel1)
                root.checkReadinessAndSwapBg();
        }
    }
    Connections {
        target: bg2
        function onStatusChanged() {
            if (root.bgShowChannel1)
                root.checkReadinessAndSwapBg();
        }
    }
    Connections {
        target: fg1
        function onStatusChanged() {
            if (!root.fgShowChannel1)
                root.checkReadinessAndSwapFg();
        }
    }
    Connections {
        target: fg2
        function onStatusChanged() {
            if (root.fgShowChannel1)
                root.checkReadinessAndSwapFg();
        }
    }

    Component.onCompleted: {
        // تحميل أولي مباشر
        if (root.bgShowChannel1)
            bg1.source = root.wallpaperSource;

        if (root.fgShowChannel1)
            fg1.source = root.overlaySource;
    }
}
