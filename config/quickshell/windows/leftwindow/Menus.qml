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

StackView {
    id: stackView

    Layout.fillWidth: true
    Layout.fillHeight: true

    clip: true
    smooth: true

    // property int transitionDuration: 350
    // property var outEasing: Easing.OutQuad
    // property var inEasing: Easing.InQuart

    property int currentIndex: 0
    property int previousIndex: 0
    readonly property int appLauncherIndex: 9

    // المكونات الأصلية (Component فقط)
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

    // العناصر التي يتم إنشاؤها مرة واحدة
    property var dashboardPage
    property var notiListPage
    property var weatherPage
    property var monitorPage
    property var networkPage
    property var clipboardPage
    property var appLauncherPage

    Component.onCompleted: {
        dashboardPage = dashboardComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });
        notiListPage = notiListComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });
        weatherPage = weatherComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });
        monitorPage = monitorComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });
        networkPage = networkComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });

        clipboardPage = clipboardComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });

        appLauncherPage = appLauncherComponent.createObject(stackView, {
            "visible": false
            // "anchors.fill": stackView
        });

        dashboardPage.visible = true;
        stackView.push(dashboardPage);
    }

    function getPage(index) {
        return [dashboardPage, notiListPage, weatherPage, monitorPage, networkPage, clipboardPage, null, null, null, appLauncherPage][index];
    }

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex >= 0 && newIndex !== currentIndex) {
                if (newIndex > currentIndex) {
                    stackView.replaceEnter = enterFromBottom;
                    stackView.replaceExit = exitToTop;
                } else {
                    stackView.replaceEnter = enterFromTop;
                    stackView.replaceExit = exitToBottom;
                }

                currentIndex = newIndex;
                stackView.replace(getPage(newIndex));
            }

            if (newIndex == stackView.appLauncherIndex) {
                appLauncherPage.gainFocus();
            }
        }
    }

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
            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    from: stackView.height * 0.6
                    to: 0
                    duration: 420
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 350
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.92
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
                from: 0
                to: -stackView.height * 0.3
                duration: 300
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 280
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.95
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }

    // --- الدخول من الأعلى ---
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
            PropertyAction {
                property: "y"
                value: -stackView.height * 0.3
            }
            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    from: -stackView.height * 0.3
                    to: 0
                    duration: 420
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 350
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.92
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
                from: 0
                to: stackView.height * 0.6
                duration: 300
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 280
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.95
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }
}
