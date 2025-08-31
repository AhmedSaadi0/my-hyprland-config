import QtQuick
import QtQuick.Layouts
import "root:/themes"

Item {
    id: root

    property string appName: "Application Name"
    property var appIcon: "application-x-executable" // Default icon name
    property string appExec: "" // The command to execute

    width: gridView.cellWidth
    height: 100

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 5

        // Application Icon
        Image {
            id: iconImage
            source: "image://theme/" + appIcon
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            fillMode: Image.PreserveAspectFit
        }

        // Application Name
        Text {
            text: appName
            font.pixelSize: 12
            color: ThemeManager.selectedTheme.colors.primaryTextColor
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // This is where you would launch the application
            // For a real implementation, you'd call a C++ function here.
            console.log("Launching:", appExec);
        }
    }
}
