// windows/leftwindow/Menus.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "./dashboard" as Dashboard
import "./monitoring" as Monitoring
import "./weather"
import "./applauncher"
import "./animations"
import "./network"

import "root:/utils"
import "root:/config"
import "root:/config/EventNames.js" as Events

StackView {
    id: stackView

    Layout.fillWidth: true
    Layout.fillHeight: true

    clip: true
    smooth: true

    property int currentIndex: 0
    readonly property int appLauncherIndex: 9

    property var _instantiatedPages: ({})

    Component {
        id: dashboardComponent
        Dashboard.Dashboard {}
    }
    Component {
        id: notiListComponent
        NotificationsList {}
    }
    Component {
        id: weatherComponent
        WeatherMenu {}
    }
    Component {
        id: monitorComponent
        Monitoring.Main {}
    }
    Component {
        id: networkComponent
        WifiList {}
    }
    Component {
        id: clipboardComponent
        Clipboard {}
    }
    Component {
        id: appLauncherComponent
        AppLauncher {}
    }

    // ---------------------------------------------------------
    // Lazy Loading Logic
    // ---------------------------------------------------------
    function getPage(index) {
        // إذا كانت الصفحة مخلوقة مسبقاً في الذاكرة، أعد استخدامها فوراً
        if (_instantiatedPages[index]) {
            return _instantiatedPages[index];
        }

        // خريطة تربط الإندكس بالمكون المناسب
        let componentMap = {
            0: dashboardComponent,
            1: notiListComponent,
            2: weatherComponent,
            3: monitorComponent,
            4: networkComponent,
            5: clipboardComponent,
            9: appLauncherComponent
        };

        let selectedComponent = componentMap[index];

        if (selectedComponent) {
            // إنشاء الصفحة لأول مرة
            let newPage = selectedComponent.createObject(stackView, {
                "visible": false
            });

            if (newPage) {
                // حفظها في الكاش للمرات القادمة
                _instantiatedPages[index] = newPage;
                console.log("Lazy Loaded Page Index:", index); // للمراقبة (اختياري)
                return newPage;
            }
        }

        console.warn("Error: requested page index not found or failed to create:", index);
        return null;
    }

    // ---------------------------------------------------------
    // التهيئة والأحداث
    // ---------------------------------------------------------
    Component.onCompleted: {
        // تحميل الصفحة الرئيسية فقط عند البدء
        let initialPage = getPage(0);
        if (initialPage) {
            initialPage.visible = true;
            stackView.push(initialPage);
        }

        // Init notiListComponent to start register
        const notificationCompoObj = notiListComponent.createObject(stackView, {
            "visible": false
        });
        _instantiatedPages[1] = notificationCompoObj;

        EventBus.on(Events.LEFT_MENU_IS_OPENED, function (newIndex) {
            // تجاهل إذا كان نفس الاندكس أو اندكس غير صالح
            if (newIndex < 0 || newIndex === currentIndex)
                return;

            // تحديد اتجاه الحركة (للأعلى أم للأسفل)
            if (newIndex > currentIndex) {
                stackView.replaceEnter = enterFromBottom;
                stackView.replaceExit = exitToTop;
            } else {
                stackView.replaceEnter = enterFromTop;
                stackView.replaceExit = exitToBottom;
            }

            // جلب الصفحة (سواء من الكاش أو إنشاء جديد)
            let targetPage = getPage(newIndex);

            if (targetPage) {
                currentIndex = newIndex;
                stackView.replace(targetPage);

                if (newIndex === stackView.appLauncherIndex && typeof targetPage.gainFocus === "function") {
                    targetPage.gainFocus();
                }
            }
        });
    }

    // ---------------------------------------------------------
    // تأثيرات الحركة (Transitions)
    // ---------------------------------------------------------

    // 1. قادم من الأسفل (عند النزول في القائمة)
    Transition {
        id: enterFromBottom
        SequentialAnimation {
            PropertyAction {
                property: "opacity"
                value: 0
            }
            PropertyAction {
                property: "scale"
                value: 0.92
            }
            // نضمن أن يبدأ من الأسفل
            PropertyAction {
                property: "y"
                value: stackView.height * 0.6
            }

            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    to: 0
                    duration: 420
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "opacity"
                    to: 1
                    duration: 350
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    to: 1.0
                    duration: 380
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    Transition {
        id: exitToTop
        ParallelAnimation {
            NumberAnimation {
                property: "y"
                to: -stackView.height * 0.3
                duration: 300
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 280
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                to: 0.95
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }

    // 2. قادم من الأعلى (عند الصعود في القائمة)
    Transition {
        id: enterFromTop
        SequentialAnimation {
            PropertyAction {
                property: "opacity"
                value: 0
            }
            PropertyAction {
                property: "scale"
                value: 0.92
            }
            // نضمن أن يبدأ من الأعلى
            PropertyAction {
                property: "y"
                value: -stackView.height * 0.3
            }

            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    to: 0
                    duration: 420
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "opacity"
                    to: 1
                    duration: 350
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    to: 1.0
                    duration: 380
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    Transition {
        id: exitToBottom
        ParallelAnimation {
            NumberAnimation {
                property: "y"
                to: stackView.height * 0.6
                duration: 300
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 280
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                to: 0.95
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }
}
