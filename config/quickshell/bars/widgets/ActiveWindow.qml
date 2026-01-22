// TODO: -> finish this

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ===============================================================
    // 1. ESTILOS
    // ===============================================================
    QtObject {
        id: style
        // Fondo: Intenta usar el tema, si falla usa el gris oscuro
        property color background: {
            try {
                return ThemeManager.selectedTheme.colors.topbarBgColorV1;
            } catch (e) {
                return "#1e1e2e";
            }
        }

        // ⚪ TEXTO BLANCO
        property color text: "#ffffff"

        // ⚪ SUBTEXTO (Gris muy claro, casi blanco)
        property color subtext: "#eeeeee"
    }

    // ===============================================================
    // 2. HYPRLAND
    // ===============================================================
    property string currentClass: ""
    property string currentTitle: ""
    property bool hasWindow: false

    Process {
        id: activeWinProc
        command: ["sh", "-c", "hyprctl activewindow -j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (text.trim() === "{}" || text.trim() === "") {
                        root.hasWindow = false;
                        root.currentClass = "Escritorio";
                        root.currentTitle = "";
                    } else {
                        var data = JSON.parse(text);
                        root.currentClass = data.class || data.initialClass || "Unknown";
                        root.currentTitle = data.title || data.initialTitle || "";
                        root.hasWindow = true;
                    }
                } catch (e) {
                    root.hasWindow = false;
                }
                restartTimer.start();
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 300
        repeat: false
        onTriggered: activeWinProc.running = true
    }

    // ===============================================================
    // 3. LA BARRITA GRIS (Visual Bubble)
    // ===============================================================
    Rectangle {
        id: visualBubble

        height: 32

        // Ancho que se ajusta al texto
        width: Math.min(contentRow.implicitWidth + 34, root.width)

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        //  bordes quedan totalmente curvos
        radius: height / 2

        color: style.background

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            width: parent.width - 24 // Margen interno
            spacing: 10

            // A. ICONO
            Image {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter

                source: root.hasWindow ? Quickshell.iconPath(root.currentClass, "application-x-executable") : Quickshell.iconPath("user-desktop", "computer")

                fillMode: Image.PreserveAspectFit
                smooth: true
                // Opacidad alta para que se vea bien claro
                opacity: root.hasWindow ? 1 : 0.8

                onStatusChanged: {
                    if (status === Image.Error)
                        source = Quickshell.iconPath("application-x-executable", "unknown");
                }
            }

            // B. CLASE
            Text {
                text: root.currentClass
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: 150
                elide: Text.ElideRight

                font.family: "Sans"
                font.weight: Font.Bold
                font.pixelSize: 12

                // Color Blanco
                color: style.text

                function capitalize(s) {
                    return s && s[0].toUpperCase() + s.slice(1);
                }
                onTextChanged: text = capitalize(text)
            }

            Rectangle {
                visible: root.hasWindow && root.currentTitle !== ""
                width: 1
                height: 14
                color: style.subtext
                Layout.alignment: Qt.AlignVCenter
                opacity: 0.6
            }

            Text {
                text: root.currentTitle
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                visible: text !== ""

                font.family: "Sans"
                font.pixelSize: 12

                // Color Blanco
                color: style.text
                opacity: 1.0 // Sin transparencia para máxima visibilidad

                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    // Tooltip
    MouseArea {
        anchors.fill: visualBubble
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        ToolTip.visible: containsMouse && contentRow.implicitWidth > visualBubble.width
        ToolTip.text: root.currentTitle
        ToolTip.delay: 500
    }
}
