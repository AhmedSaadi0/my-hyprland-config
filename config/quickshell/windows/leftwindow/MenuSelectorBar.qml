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

    property var pageComponents: [dashboardComponent, notiListComponent, weatherComponent, monitorComponent, networkComponent]

    initialItem: pageComponents.length > 0 ? pageComponents[0] : null

    Connections {
        target: LeftMenuStatus
        function onSelectedIndexTargeted(newIndex) {
            if (newIndex >= 0 && newIndex < pageComponents.length && newIndex !== currentIndex) {
                previousIndex = currentIndex;
                currentIndex = newIndex;
                stackView.replace(pageComponents[newIndex]);
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

    Component {
        id: dashboardComponent
        Dashboard.Dashboard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component {
        id: notiListComponent
        NotiList {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component {
        id: weatherComponent
        Dashboard.Dashboard2 {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component {
        id: monitorComponent
        Monitoring.Main {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component {
        id: networkComponent
        Dashboard.Dashboard3 {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
