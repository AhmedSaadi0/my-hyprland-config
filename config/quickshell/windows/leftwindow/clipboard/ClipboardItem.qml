import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/services"
import "root:/themes"

Item {
    id: wrapper

    property var lv: ListView.view

    width: lv.width
    height: 50

    transform: [
        Translate {
            x: wrapper.lv.pullOffset + wrapper.lv.shockOffset
        }
    ]

    Item {
        id: swipeContainer
        width: parent.width
        height: parent.height
        Behavior on x {
            enabled: !dragArea.drag.active
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.0
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: swipeContainer
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: 600
            drag.filterChildren: true

            onPressed: wrapper.lv.userIsDragging = true
            onPositionChanged: {
                if (drag.active) {
                    var tension = Math.max(0, swipeContainer.x / 12);
                    wrapper.lv.pullOffset = Math.min(tension, 30);
                }
            }
            onReleased: {
                wrapper.lv.userIsDragging = false;
                if (swipeContainer.x > 120) {
                    wrapper.lv.pullOffset = 0;
                    swipeContainer.x = 600;
                    wrapper.lv.triggerSway();
                    ClipboardService.remove(index, clipId);
                } else {
                    swipeContainer.x = 0;
                    wrapper.lv.pullOffset = 0;
                }
            }

            onClicked: {
                if (!drag.active)
                    ClipboardService.activate(clipId);
            }
        }

        Rectangle {
            id: req
            anchors.fill: parent
            color: dragArea.containsMouse && !dragArea.drag.active ? ThemeManager.selectedTheme.colors.secondary.alpha(0.1) : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            opacity: 1 - (swipeContainer.x / 300)

            Rectangle {
                width: parent.width - 40
                height: 1
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.05)
            }

            property color accColor: {
                switch (model.type) {
                case 1:
                    return ThemeManager.selectedTheme.colors.secondary;
                case 2:
                    return ThemeManager.selectedTheme.colors.tertiary;
                case 4:
                    return ThemeManager.selectedTheme.colors.warning;
                default:
                    return ThemeManager.selectedTheme.colors.primary;
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                // 1. شريط اللون الجانبي
                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.preferredHeight: 25
                    radius: 2
                    color: req.accColor
                }

                // 2. النص
                Label {
                    Layout.fillWidth: true
                    text: model.text
                    elide: Text.ElideRight
                    font.family: ThemeManager.selectedTheme.typography.bodyFont
                    color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                }

                // 3. زر الحذف
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    Layout.rightMargin: 10
                    radius: 4
                    color: deleteMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.error.alpha(0.1) : "transparent"

                    Label {
                        anchors.centerIn: parent
                        text: "󰆴" // أيقونة الحذف
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 18
                        color: ThemeManager.selectedTheme.colors.error
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        // منع انتقال حدث الضغط إلى منطقة السحب الخلفية
                        preventStealing: true

                        onClicked: {
                            ClipboardService.remove(index, clipId);
                        }
                    }
                }
            }
        }
    }
}
