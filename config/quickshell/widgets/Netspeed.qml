import QtQuick
import QtQuick.Controls

// import QtQuick.Layouts

Rectangle {
    id: netspeedToolbarWidget
    width: 125 + children[0].width
    height: parent.height - 8
    color: palette.light
    radius: 15

    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        margins: 4
    }

    Rectangle {
        id: networkIconName
        width: children[1].implicitWidth + 45
        height: 18
        color: palette.mid
        radius: 15

        anchors {
            left: parent.left
            margins: 2
            // horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Text {
            id: icon
            text: "󰤨"
            color: palette.text
            font.pixelSize: 13
            // width: 2
            font.family: "FantasqueSansM Nerd Font Propo"
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 8
            }
        }

        Text {
            id: networkName
            text: "Ahmed"
            color: palette.text
            anchors {
                right: parent.right
                margins: 13
                verticalCenter: parent.verticalCenter
            }
            // font.family: ""
        }
    }

    Rectangle {
        width: 60

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 25
        }

        Rectangle {
            // width: 50
            // height: 22
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 11
            }
            Label {
                text: "↑"
                color: palette.text
                // color: "red"
                // font.family: "icon-font"
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            Text {
                id: uoloadSpeed
                text: "0.000"
                color: palette.text
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            // width: 50
            // height: 22
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 25
            }
            Label {
                text: "↓"
                color: palette.text
                // font.family: "icon-font" // Set your icon font if needed
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
            Text {
                id: downloadSpeed
                text: "0.000"
                color: palette.text
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
