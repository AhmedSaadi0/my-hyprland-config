// windows/leftwindow/applauncher/CommandsList.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/components"

Item {
    id: rootCmdList

    property var listModel
    property int selectedIndex: -1
    signal commandClicked(var commandData)

    ListView {
        id: commandListView
        anchors.fill: parent
        model: rootCmdList.listModel
        clip: true
        spacing: 4

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                positionViewAtIndex(currentIndex, ListView.Contain);
            }
        }

        Connections {
            target: rootCmdList
            function onSelectedIndexChanged() {
                commandListView.currentIndex = rootCmdList.selectedIndex;
            }
        }

        delegate: CommandItem {
            id: cmdDelegate
            width: commandListView.width
            commandData: modelData
            isHighlighted: index === (rootCmdList.selectedIndex >= 0 ? rootCmdList.selectedIndex : 0)

            onClicked: rootCmdList.commandClicked(modelData)

            opacity: 0
            transform: Translate {
                id: cmdTrans
                x: -10
            }

            Component.onCompleted: cmdAnim.start()

            ParallelAnimation {
                id: cmdAnim
                NumberAnimation {
                    target: cmdDelegate
                    property: "opacity"
                    to: 1
                    duration: 150
                }
                NumberAnimation {
                    target: cmdTrans
                    property: "x"
                    to: 0
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: rootCmdList.listModel.length === 0
            text: qsTr("No commands found")
            font.pixelSize: 14
            color: ThemeManager.selectedTheme.colors.subtleText
        }
    }
}
