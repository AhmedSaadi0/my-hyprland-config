import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell.Services.Mpris

// استيراد الخدمات
import "root:/services"
import "root:/themes"
import "root:/components"
import "root:/config"

Item {
    id: root

    // ============================================================
    //  1. CONFIGURATION (Style) - لم يتم تغيير الألوان
    // ============================================================
    QtObject {
        id: style
        property color textPrimary: ThemeManager.selectedTheme.colors.onPrimary
        property color textSecondary: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.7)
        property color bgSurface: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)
        property color bgHover: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)

        property string iconFont: ThemeManager.selectedTheme.typography.iconFont
        property int fontSizeTitle: 15
        property int fontSizeSub: 13
        property int fontSizeTiny: 10
        property real radius: ThemeManager.selectedTheme.dimensions.elementRadius
    }

    // ============================================================
    //  2. LOGIC & STATE - نفس المنطق السابق تماماً
    // ============================================================
    signal switchPlayerClicked

    readonly property var player: MediaController.activePlayer
    property int availablePlayersCount: MediaController.players.length

    readonly property string identity: (player && player.identity) ? player.identity : "Media Player"
    readonly property string title: (player && player.trackTitle) ? player.trackTitle : "No Media"
    readonly property string artist: (player && player.trackArtist) ? player.trackArtist : "Unknown Artist"
    readonly property string albumArt: (player && player.trackArtUrl) ? player.trackArtUrl : ""
    readonly property bool isPlaying: player ? player.isPlaying : false

    readonly property double position: player ? player.position : 0
    readonly property double length: (player && player.length > 0) ? player.length : 1
    readonly property double progress: position / length

    property bool isScrubbing: seekSlider.pressed
    property alias pressed: mouseArea.pressed

    // الأبعاد المطلوبة
    implicitHeight: 160
    // implicitWidth: 410

    Timer {
        interval: 1000
        running: root.player && root.player.playbackState === MprisPlaybackState.Playing && !root.isScrubbing
        repeat: true
        onTriggered: if (root.player)
            root.player.positionChanged()
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "0:00";
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" + s : s);
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        preventStealing: false
    }

    // ============================================================
    //  3. VISUAL LAYOUT
    // ============================================================

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // ------------------------------------
        // القسم الأيسر: صورة الألبوم (كبيرة)
        // ------------------------------------
        Rectangle {
            Layout.preferredHeight: 130
            Layout.preferredWidth: 130
            Layout.alignment: Qt.AlignVCenter

            radius: style.radius
            color: style.bgSurface
            clip: true

            Image {
                anchors.fill: parent
                source: root.albumArt
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready && source !== ""
            }

            // أيقونة افتراضية في حال عدم وجود صورة
            Text {
                anchors.centerIn: parent
                visible: parent.children[0].status !== Image.Ready || root.albumArt === ""
                text: "󰝚"
                font.family: style.iconFont
                font.pixelSize: 40
                color: style.textPrimary
                opacity: 0.5
            }
        }

        // ------------------------------------
        // القسم الأيمن: التفاصيل والتحكم
        // ------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2 // تقليل المسافات لجعل التصميم مدمجاً

            // 1. العنوان والفنان + اسم المشغل
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    // اسم المشغل بخط صغير جداً
                    Text {
                        text: root.identity
                        font.pixelSize: 9
                        color: style.textSecondary
                        opacity: 0.8
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }

                    // العنوان
                    Text {
                        text: root.title
                        Layout.fillWidth: true
                        font.bold: true
                        font.pixelSize: 16
                        color: style.textPrimary
                        elide: Text.ElideRight
                    }

                    // الفنان
                    Text {
                        text: root.artist
                        Layout.fillWidth: true
                        font.pixelSize: 12
                        color: style.textSecondary
                        elide: Text.ElideRight
                    }
                }

                // زر تبديل المشغل (في الزاوية العلوية اليمنى)
                MButton {
                    visible: root.availablePlayersCount > 1
                    text: "󰌳"
                    font.family: style.iconFont
                    font.pixelSize: 14
                    implicitWidth: 24
                    implicitHeight: 24
                    normalBackground: "transparent"
                    normalForeground: style.textSecondary
                    onClicked: MediaController.cyclePlayers()
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                }
            }

            // مسافة مرنة لدفع العناصر للأسفل قليلاً
            Item {
                Layout.fillHeight: true
            }

            // 2. شريط التقدم والوقت
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -5 // تقليل المسافة بين السلايدر والنص

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.formatTime(root.position)
                        font.pixelSize: 9
                        color: style.textSecondary
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.formatTime(root.length)
                        font.pixelSize: 9
                        color: style.textSecondary
                    }
                }

                FlatSlider {
                    id: seekSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    value: (!pressed) ? root.progress : value
                    enableChangeOnWheel: false

                    onMoved: {
                        if (root.player && root.player.canSeek) {
                            if (root.player.positionSupported)
                                root.player.position = value * root.player.length;
                            else
                                root.player.seek((value * root.player.length) - root.player.position);
                            root.player.positionChanged();
                        }
                    }

                    activeColor: style.textPrimary
                    inactiveColor: style.bgSurface
                    lineWidth: 4
                }
            }

            // 3. أزرار التحكم + الصوت (في صف واحد)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 5
                spacing: 10

                // أزرار التحكم
                RowLayout {
                    spacing: 15
                    MButton {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 18
                        implicitWidth: 30
                        implicitHeight: 30
                        normalBackground: "transparent"
                        normalForeground: style.textPrimary
                        enabled: root.player && root.player.canGoPrevious
                        opacity: enabled ? 1 : 0.5
                        onClicked: MediaController.previous()
                    }

                    // زر التشغيل بخلفية دائرية
                    MButton {
                        text: root.isPlaying ? "" : ""
                        font.family: style.iconFont
                        font.pixelSize: 20
                        implicitWidth: 50
                        implicitHeight: 40
                        // radius: 18
                        normalBackground: style.bgSurface
                        hoveredBackground: style.bgHover
                        normalForeground: style.textPrimary
                        enabled: root.player && root.player.canTogglePlaying
                        onClicked: MediaController.togglePlaying()
                    }

                    MButton {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 18
                        implicitWidth: 30
                        implicitHeight: 30
                        normalBackground: "transparent"
                        normalForeground: style.textPrimary
                        enabled: root.player && root.player.canGoNext
                        opacity: enabled ? 1 : 0.5
                        onClicked: MediaController.next()
                    }
                }

                Item {
                    Layout.fillWidth: true
                } // دافع للمسافة

                // التحكم بالصوت (صغير وأنيق)
                RowLayout {
                    spacing: 10

                    Text {
                        text: Audio.muted ? "" : (Audio.volume > 0.5 ? "" : "")
                        font.family: style.iconFont
                        font.pixelSize: 14
                        color: style.textSecondary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Audio.setVolume(Audio.volume > 0 ? 0 : 0.5)
                        }
                    }

                    FlatSlider {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 20

                        value: Audio.volume
                        onMoved: Audio.setVolume(value)

                        onValueChanged: {
                            if (Audio.volume !== value) {
                                Audio.setVolume(value);
                            }
                        }

                        activeColor: style.textSecondary
                        inactiveColor: style.bgSurface
                        lineWidth: 4
                    }
                }
            }
        }
    }
}
