// windows/leftwindow/monitoring/components/SolutionCard.qml

import QtQuick
import QtQuick.Layouts
import "root:/themes"

Rectangle {
    id: root

    property string solutionId: ""
    property string relatedLog: ""
    property string solutionTitle: ""
    property string difficulty: "easy"
    property string priority: "important"
    property string description: ""
    property string whyThisWorks: ""
    property var steps: []

    property bool isExpanded: false

    readonly property var theme: ThemeManager.selectedTheme

    Layout.fillWidth: true
    implicitHeight: collapsedRow.implicitHeight + (isExpanded ? expandedContent.implicitHeight + 12 : 0) + 12

    radius: theme.dimensions.shapeExtraSmall
    color: isExpanded
        ? Qt.rgba(difficultyColor().r, difficultyColor().g, difficultyColor().b, theme.systemSettings.themeMode == "dark" ? 0.12 : 0.06)
        : (hoverArea.containsMouse ? theme.colors.onSurface.alpha(0.04) : "transparent")
    border.color: isExpanded ? Qt.rgba(difficultyColor().r, difficultyColor().g, difficultyColor().b, 0.3) : "transparent"
    border.width: isExpanded ? 1 : 0
    clip: true

    Behavior on implicitHeight {
        NumberAnimation { duration: 280; easing.type: Easing.InOutQuad }
    }

    function difficultyColor() {
        if (difficulty === "hard") return theme.colors.error;
        if (difficulty === "medium") return theme.colors.secondary;
        return theme.colors.tertiary;
    }

    function priorityColor() {
        if (priority === "critical") return theme.colors.error;
        if (priority === "important") return theme.colors.secondary;
        return theme.colors.onSurfaceVariant;
    }

    function stepsCountText() {
        if (!steps || steps.length === 0) return "No steps";
        return steps.length + " step" + (steps.length > 1 ? "s" : "");
    }

    function hasRebootWarning() {
        if (!steps) return false;
        for (var i = 0; i < steps.length; i++) {
            if (steps[i].warning && steps[i].warning.toLowerCase().indexOf("reboot") !== -1)
                return true;
        }
        return false;
    }

    // --- Collapsed Row (always visible) ---
    ColumnLayout {
        id: collapsedRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Expand arrow
            Text {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 1
                text: root.isExpanded ? "" : ""
                font.family: theme.typography.iconFont
                font.pixelSize: 11
                color: theme.colors.onSurfaceVariant
                opacity: 0.6
            }

            // Badges
            Row {
                spacing: 4
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 1

                // Difficulty badge
                Rectangle {
                    width: diffText.implicitWidth + 10
                    height: 16
                    radius: 8
                    color: Qt.rgba(difficultyColor().r, difficultyColor().g, difficultyColor().b, 0.18)
                    border.color: Qt.rgba(difficultyColor().r, difficultyColor().g, difficultyColor().b, 0.4)
                    border.width: 1
                    Text {
                        id: diffText
                        anchors.centerIn: parent
                        text: root.difficulty.toUpperCase()
                        font.pixelSize: 8
                        font.bold: true
                        color: difficultyColor()
                    }
                }

                // Priority badge
                Rectangle {
                    width: priText.implicitWidth + 10
                    height: 16
                    radius: 8
                    color: Qt.rgba(priorityColor().r, priorityColor().g, priorityColor().b, 0.18)
                    border.color: Qt.rgba(priorityColor().r, priorityColor().g, priorityColor().b, 0.4)
                    border.width: 1
                    Text {
                        id: priText
                        anchors.centerIn: parent
                        text: root.priority.toUpperCase()
                        font.pixelSize: 8
                        font.bold: true
                        color: priorityColor()
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Steps count
            Text {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 1
                text: stepsCountText() + (hasRebootWarning() ? " · Reboot" : "")
                font.pixelSize: theme.typography.small - 3
                color: theme.colors.onSurfaceVariant
                opacity: 0.6
            }
        }

        // Title
        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 19
            text: root.solutionTitle
            font.pixelSize: theme.typography.small + 1
            font.bold: true
            color: theme.colors.onSurface
            elide: Text.ElideRight
        }

        // Description (collapsed only)
        Text {
            visible: !root.isExpanded
            Layout.fillWidth: true
            Layout.leftMargin: 19
            text: root.description
            font.pixelSize: theme.typography.small - 1
            color: theme.colors.onSurfaceVariant
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            opacity: 0.8
        }
    }

    // --- Expanded Content ---
    ColumnLayout {
        id: expandedContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: collapsedRow.bottom
        anchors.leftMargin: 19
        anchors.rightMargin: 8
        spacing: 10
        visible: root.isExpanded
        opacity: root.isExpanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(difficultyColor().r, difficultyColor().g, difficultyColor().b, 0.2)
        }

        // Full description
        Text {
            Layout.fillWidth: true
            text: root.description
            font.pixelSize: theme.typography.small
            color: theme.colors.onSurfaceVariant
            wrapMode: Text.WordWrap
            lineHeight: 1.3
        }

        // Why this works
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: qsTr("Why this works")
                font.pixelSize: theme.typography.small - 1
                font.bold: true
                color: theme.colors.tertiary
                opacity: 0.85
            }

            Text {
                Layout.fillWidth: true
                text: root.whyThisWorks
                font.pixelSize: theme.typography.small - 1
                color: theme.colors.onSurfaceVariant
                wrapMode: Text.WordWrap
                lineHeight: 1.3
                opacity: 0.75
            }
        }

        // Steps header
        Text {
            text: qsTr("Steps")
            font.pixelSize: theme.typography.small - 1
            font.bold: true
            color: theme.colors.tertiary
            opacity: 0.85
        }

        // Steps repeater
        Repeater {
            model: root.isExpanded ? root.steps : []
            delegate: CommandBox {
                Layout.fillWidth: true
                command: modelData.command || ""
                warning: modelData.warning || ""
            }
        }
    }

    // Click to expand/collapse
    MouseArea {
        id: hoverArea
        z: -1
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: root.isExpanded = !root.isExpanded
    }
}
