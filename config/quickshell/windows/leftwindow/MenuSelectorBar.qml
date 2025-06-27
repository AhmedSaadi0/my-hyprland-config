// windows/leftwindow/MenuSelectorBar.qml

import QtQuick
import QtQuick.Layouts
import "../../themes"
import "../../components/tab"
import "./dashboard" as Dashboard
import "./monitoring" as Monitoring
import "./notificatoin"

ColumnLayout {
    id: root
    spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

    // --- State & Animation Control ---
    property int currentIndex: 0
    property int inAnimationDuration: 100
    property int outAnimationDuration: 300
    property var inAnimationEasing: Easing.InCurve
    property var outAnimationEasing: Easing.OutExpo

    // --- نموذج التابات ---
    property ListModel tabModel: ListModel {
        ListElement {
            text: "Control"
            icon: "󰨝"
            onClick: function () {
                root.changeTab(0);
            }
        }
        ListElement {
            text: "Notifications"
            icon: "󰂞"
            onClick: function () {
                root.changeTab(1);
            }
        }
        ListElement {
            text: "Weather"
            icon: "󰨹"
            onClick: function () {
                root.changeTab(2);
            }
        }
        ListElement {
            text: "Monitors"
            icon: ""
            onClick: function () {
                root.changeTab(3);
            }
        }
        ListElement {
            text: "Network"
            icon: ""
            onClick: function () {
                root.changeTab(4);
            }
        }
    }

    function changeTab(newIndex) {
        if (newIndex === currentIndex)
            return;
        var oldIndex = currentIndex;
        var direction = (newIndex > oldIndex) ? 1 : -1;
        var oldPage = viewContainer.itemAt(oldIndex);
        var newPage = viewContainer.itemAt(newIndex);

        mainTabBar.currentIndex = newIndex;
        currentIndex = newIndex;
        // وضع الصفحة الجديدة خارج الشاشة في الجهة الصحيحة ثم إظهارها
        newPage.x = direction * viewContainer.width;
        newPage.visible = true;

        // رسوم الخروج للصفحة القديمة
        var exitAnim = Qt.createQmlObject('import QtQuick ; NumberAnimation { }', viewContainer);
        exitAnim.target = oldPage;
        exitAnim.property = "x";
        exitAnim.from = 0;
        exitAnim.to = -direction * viewContainer.width;
        exitAnim.duration = inAnimationDuration;
        exitAnim.easing.type = inAnimationEasing;

        // استبدال onFinished بتوصيل الإشارة finished
        exitAnim.finished.connect(function () {
            // إخفاء الصفحة القديمة وتدمير الرسوم
            oldPage.visible = false;
            exitAnim.destroy();

            // رسوم الدخول للصفحة الجديدة
            var enterAnim = Qt.createQmlObject('import QtQuick ; NumberAnimation { }', viewContainer);
            enterAnim.target = newPage;
            enterAnim.property = "x";
            enterAnim.from = direction * viewContainer.width;
            enterAnim.to = 0;
            enterAnim.duration = outAnimationDuration;
            enterAnim.easing.type = outAnimationEasing;

            // عند انتهاء الدخول نخّلي الرسوم وتحدّث currentIndex
            enterAnim.finished.connect(function () {
                enterAnim.destroy();
            // currentIndex = newIndex;
            // mainTabBar.currentIndex = newIndex;
            });

            enterAnim.start();
        });

        exitAnim.start();
    }

    // --- شريط التابات ---
    TabBar {
        id: mainTabBar
        model: tabModel
        Layout.fillWidth: true
        barHeight: 35
        Component.onCompleted: currentIndex = root.currentIndex
    }

    StackLayout {
        id: viewContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: root.currentIndex
        clip: true
        smooth: true

        // تعريف الصفحات (في البداية جميعها مرئية لكن خارج المشهد ما عدا الأولى)
        Dashboard.Dashboard {
            id: dashboardPage
            x: 0
            visible: true
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        NotiList {
            id: notiPage
            x: viewContainer.width
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Dashboard.Dashboard2 {
            id: weatherPage
            x: viewContainer.width
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Monitoring.Main {
            id: monitorPage
            x: viewContainer.width
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Dashboard.Dashboard3 {
            id: networkPage
            x: viewContainer.width
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
