import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "./dashboard" as Dashboard
import "./monitoring" as Monitoring

import "root:/themes"
import "root:/utils"

StackView {
    id: stackView

    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    smooth: true

    property int transitionDuration: 350
    property var outEasing: Easing.OutQuad
    property var inEasing: Easing.InQuart

    property int currentIndex: 0
    property int previousIndex: 0

    // المكونات الأصلية (Component فقط)
    Component {
        id: dashboardComponent
        Dashboard.Dashboard {}
    }
    Component {
        id: notiListComponent
        NotiList {}
    }
    Component {
        id: weatherComponent
        Dashboard.Dashboard2 {}
    }
    Component {
        id: monitorComponent
        Monitoring.Main {}
    }
    Component {
        id: networkComponent
        Dashboard.Dashboard3 {}
    }

    // العناصر التي يتم إنشاؤها مرة واحدة
    property var dashboardPage
    property var notiListPage
    property var weatherPage
    property var monitorPage
    property var networkPage

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

        dashboardPage.visible = true;
        stackView.push(dashboardPage);
    }

    function getPage(index) {
        return [dashboardPage, notiListPage, weatherPage, monitorPage, networkPage][index];
    }

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex >= 0 && newIndex < 5 && newIndex !== currentIndex) {
                previousIndex = currentIndex;
                currentIndex = newIndex;
                stackView.replace(getPage(newIndex));
            }
        }
    }

    replaceEnter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "x"
                from: stackView.previousIndex < stackView.currentIndex ? stackView.width : -stackView.width
                to: 0
                duration: 350
                easing.type: stackView.outEasing
            }
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1.0
                duration: 350
                easing.type: stackView.outEasing
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 350
                easing.type: stackView.outEasing
            }
        }
    }

    replaceExit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "x"
                from: 0
                to: stackView.previousIndex < stackView.currentIndex ? -stackView.width / 4 : stackView.width / 4
                duration: 250
                easing.type: stackView.inEasing
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.9
                duration: 250
                easing.type: stackView.inEasing
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
                easing.type: stackView.inEasing
            }
        }
    }
}
