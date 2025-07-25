// windows/leftwindow/Menus.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "./dashboard" as Dashboard
import "./monitoring" as Monitoring
import "./animations"

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
        NotificationsList {}
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

    Component {
        id: clipboardComponent
        Clipboard {}
    }

    // العناصر التي يتم إنشاؤها مرة واحدة
    property var dashboardPage
    property var notiListPage
    property var weatherPage
    property var monitorPage
    property var networkPage
    property var clipboardPage

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

        dashboardPage.visible = true;
        stackView.push(dashboardPage);
    }

    function getPage(index) {
        return [dashboardPage, notiListPage, weatherPage, monitorPage, networkPage, clipboardPage][index];
    }

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex >= 0 && newIndex !== currentIndex) {
                previousIndex = currentIndex;
                currentIndex = newIndex;
                stackView.replace(getPage(newIndex));
            }
        }
    }

    replaceEnter: ZoomIn {}
    replaceExit: ZoomOut {}
}
