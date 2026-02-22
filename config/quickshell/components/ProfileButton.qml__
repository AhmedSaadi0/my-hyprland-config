// components/ProfileButton.qml

import QtQuick
// import QtQuick.Controls
import org.kde.kirigami as Kirigami

MButton {
    id: root
    width: parent.parent.buttonWidth
    height: parent.parent.buttonHeight
    text: buttonText
    property var profileValue: 0
    property string buttonText: ""

    normalBackground: {
        if (parent.parent.selectedProfile === profileValue) {
            return parent.parent.highlightColor;
        }
        return Kirigami.Theme.activeBackgroundColor;
    }

    normalForeground: {
        if (parent.parent.selectedProfile === profileValue) {
            return parent.parent.textHighlightColor;
        }
        return parent.parent.textColor;
    }

    onClicked: {
        parent.parent.selectedProfileText = profileText;
        parent.parent.profileProcess.running = true;
    }
}
