import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../utils"
import "../../themes"

Item {
    id: root
    width: 400
    height: 600

    ListModel {
        id: notifModel
    }

    Connections {
        target: NotifManager
        function onNotificationReceived(n) {
            notifModel.insert(0, n);
        }
    }

    ListView {
        id: notifList
        anchors.fill: parent
        spacing: ThemeManager.selectedTheme.typography.spacingLarge
        clip: true
        // smooth: true
        model: notifModel
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 2000  // يخفف التوقف المفاجئ
        maximumFlickVelocity: 2000
        snapMode: ListView.NoSnap

        ScrollBar.vertical: ScrollBar {
            width: 6
            policy: ScrollBar.AlwaysOn  // غيّر إلى AsNeeded إذا أردت إخفاءه عند عدم الحاجة
            active: true
            hoverEnabled: true
        }
        delegate: Item {
            width: notifList.width
            height: card.implicitHeight + ThemeManager.selectedTheme.typography.spacingLarge

            Rectangle {
                id: card
                width: parent.width
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: ThemeManager.selectedTheme.colors.topbarBgColorV1
                border.color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: ThemeManager.selectedTheme.typography.spacingLarge

                ColumnLayout {
                    id: contentLayout
                    anchors {
                        fill: parent
                        margins: 16
                    }
                    spacing: ThemeManager.selectedTheme.typography.spacingMedium

                    // الصف الأول: اسم التطبيق + الوقت + إكس الإغلاق

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ThemeManager.selectedTheme.typography.spacingMedium

                        Item {
                            width: 16
                            height: 16
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                id: closeText
                                text: "✕"
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                color: ThemeManager.selectedTheme.colors.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    notifModel.remove(index);
                                }
                            }
                        }
                        Text {
                            text: appName
                            font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                            color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: time
                            font.pixelSize: ThemeManager.selectedTheme.typography.small
                            color: ThemeManager.selectedTheme.colors.subtleText
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // الصف الثاني: أيقونة التطبيق + الملخص

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ThemeManager.selectedTheme.typography.spacingMedium

                        Item {
                            width: 24
                            height: 24
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.fill: parent
                                source: image
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }
                        }

                        Text {
                            text: summary
                            font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
                            font.bold: true
                            color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // الصف الثالث: الجسم (body)
                    Text {
                        text: body
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.pixelSize: ThemeManager.selectedTheme.typography.medium
                        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
                        Layout.fillWidth: true
                    }

                    // الصف الرابع: الأكشن
                    RowLayout {
                        visible: actions && actions.length > 0
                        spacing: ThemeManager.selectedTheme.typography.spacingMedium

                        Repeater {
                            model: actions
                            Button {
                                text: modelData.label
                                font.pixelSize: ThemeManager.selectedTheme.typography.small
                                onClicked: modelData.trigger()
                            }
                        }
                    }
                }

                implicitHeight: contentLayout.implicitHeight + 32
            }
        }
    }
}
