import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Shapes 1.15
import Quickshell.Services.Mpris

// استيراد الخدمات
import "root:/services"
import "root:/themes"
import "root:/components"
import "root:/config"

Item {
    id: root

    // ============================================================
    //  1. CONFIGURATION (Style)
    // ============================================================
    QtObject {
        id: style
        property color textPrimary: ThemeManager.selectedTheme.colors.onPrimary
        property color textSecondary: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.7)
        property color bgSurface: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.1)
        property color bgHover: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.2)
        property color bgActive: ThemeManager.selectedTheme.colors.onPrimary.alpha(0.3)

        property string iconFont: ThemeManager.selectedTheme.typography.iconFont
        property int fontSizeTitle: 15
        property int fontSizeSub: 13
        property int fontSizeTiny: 10
        property real radius: ThemeManager.selectedTheme.dimensions.elementRadius
    }

    // ============================================================
    //  2. LOGIC & STATE
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

    // الأبعاد الأصلية
    implicitHeight: 170
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
    //  3. ANIMATED COMPONENTS (مع ضبط الأحجام الأصلية داخلها)
    // ============================================================

    // --- مكون النص المتحرك (Queue) ---
    component QueueText: Item {
        property string text: ""
        property font font
        property color color
        property bool fontBold: false
        property int pixelSize: 12
        property var capitalization: Font.MixedCase
        property real opacityValue: 1.0

        Layout.fillWidth: true
        implicitHeight: currentText.implicitHeight
        clip: true

        Item {
            id: slideContainer
            height: parent.height
            width: parent.width * 2
            x: 0

            Text {
                id: currentText
                width: parent.width / 2
                height: parent.height
                text: parent.parent.text
                font: parent.parent.font
                color: parent.parent.color
                elide: Text.ElideRight
                // font.bold: parent.parent.fontBold
                // font.pixelSize: parent.parent.pixelSize
                // font.capitalization: parent.parent.capitalization
                verticalAlignment: Text.AlignVCenter
                opacity: parent.parent.opacityValue
            }

            Text {
                id: nextText
                x: parent.width / 2
                width: parent.width / 2
                height: parent.height
                font: currentText.font
                color: currentText.color
                elide: currentText.elide
                // font.bold: currentText.font.bold
                // font.pixelSize: currentText.font.pixelSize
                // font.capitalization: currentText.font.capitalization
                verticalAlignment: Text.AlignVCenter
                opacity: currentText.opacity
            }

            NumberAnimation {
                id: slideAnim
                target: slideContainer
                property: "x"
                to: -root.width // ديناميكي
                duration: 400
                easing.type: Easing.OutCirc

                onFinished: {
                    currentText.text = nextText.text;
                    slideContainer.x = 0;
                }
            }
        }

        onTextChanged: {
            if (currentText.text !== text) {
                nextText.text = text;
                slideAnim.to = -width;
                slideAnim.start();
            }
        }
    }

    // --- زر التشغيل المتحول (Morphing) ---
    // تم ضبطه ليطابق أبعاد MButton الأصلية (50x40) وحجم الخط (20)
    component MorphPlayButton: MouseArea {
        property bool playing: false
        property color iconColor: "white"

        implicitWidth: 50
        implicitHeight: 40
        hoverEnabled: true

        // الخلفية (مطابقة لـ MButton الأصلي)
        Rectangle {
            anchors.fill: parent
            color: parent.pressed ? style.bgActive : (parent.containsMouse ? style.bgHover : style.bgSurface)
            radius: height / 2 // ليكون دائرياً من الجوانب كما هو شائع، أو يمكن جعلها style.radius
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        // الأيقونة المتحولة
        Item {
            anchors.centerIn: parent
            width: 20
            height: 20 // حجم الحاوية للأيقونة
            clip: true
            smooth: true

            // Pause Icon (||)
            Item {
                anchors.fill: parent
                opacity: playing ? 1 : 0
                rotation: playing ? 0 : -90
                // scale: playing ? 1 : 0.5

                clip: true
                smooth: true
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
                Behavior on rotation {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }
                // Behavior on scale {
                //     NumberAnimation {
                //         duration: 400
                //         easing.type: Easing.OutBack
                //     }
                // }

                // رسم خطي Pause يطابق حجم أيقونة الخط 20 تقريباً
                Rectangle {
                    x: 5
                    height: 16
                    width: 4
                    y: 2
                    color: iconColor
                    radius: 1
                }
                Rectangle {
                    x: 13
                    height: 16
                    width: 4
                    y: 2
                    color: iconColor
                    radius: 1
                }
            }

            // Play Icon (Triangle)
            Text {
                anchors.centerIn: parent
                text: "" // نفس الأيقونة المستخدمة في الكود الأصلي
                font.family: style.iconFont
                font.pixelSize: 20 // نفس الحجم الأصلي
                color: iconColor

                clip: true
                smooth: true
                opacity: playing ? 0 : 1
                rotation: playing ? 90 : 0
                // scale: playing ? 0.5 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
                Behavior on rotation {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                }
                // Behavior on scale {
                //     NumberAnimation {
                //         duration: 400
                //         easing.type: Easing.OutBack
                //     }
                // }
            }
        }
    }

    // ============================================================
    //  4. VISUAL LAYOUT
    // ============================================================

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15 // نفس المسافة الأصلية

        // ------------------------------------
        // صورة الألبوم
        // ------------------------------------
        Rectangle {
            Layout.preferredHeight: 130
            Layout.preferredWidth: 130
            Layout.alignment: Qt.AlignVCenter

            radius: style.radius
            color: style.bgSurface
            clip: true

            Image {
                id: albumImage
                anchors.fill: parent
                source: root.albumArt
                fillMode: Image.PreserveAspectCrop

                onSourceChanged: {
                    scale = 1.1;
                    opacity = 0;
                }
                onStatusChanged: {
                    if (status === Image.Ready)
                        imageAppearAnim.start();
                }

                ParallelAnimation {
                    id: imageAppearAnim
                    NumberAnimation {
                        target: albumImage
                        property: "opacity"
                        to: 1
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: albumImage
                        property: "scale"
                        to: 1.0
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: albumImage.opacity < 0.1
                text: "󰝚"
                font.family: style.iconFont
                font.pixelSize: 40 // نفس الحجم الأصلي
                color: style.textPrimary
                opacity: 0.5
            }
        }

        // ------------------------------------
        // القسم الأيمن
        // ------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0 // نفس المسافة الأصلية

            // 1. العنوان والفنان
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0 // نفس المسافة الأصلية

                    // اسم المشغل
                    QueueText {
                        text: root.identity
                        pixelSize: 9 // الأصلي
                        color: style.textSecondary
                        opacityValue: 0.8
                        fontBold: true
                        capitalization: Font.AllUppercase
                    }

                    // العنوان
                    QueueText {
                        text: root.title
                        fontBold: true
                        pixelSize: 14 // الأصلي
                        color: style.textPrimary
                    }

                    // الفنان
                    QueueText {
                        text: root.artist
                        pixelSize: 12 // الأصلي
                        color: style.textSecondary
                    }
                }

                MButton {
                    visible: root.availablePlayersCount > 1
                    text: "󰌳"
                    font.family: style.iconFont
                    font.pixelSize: 14 // الأصلي
                    implicitWidth: 24
                    implicitHeight: 24
                    normalBackground: "transparent"
                    normalForeground: style.textSecondary
                    onClicked: MediaController.cyclePlayers()
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                }
            }

            // فاصل
            Item {
                Layout.fillHeight: true
            }

            // 2. شريط التقدم
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -5 // نفس المسافة الأصلية

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.formatTime(root.position)
                        font.pixelSize: 9 // الأصلي
                        color: style.textSecondary
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.formatTime(root.length)
                        font.pixelSize: 9 // الأصلي
                        color: style.textSecondary
                    }
                }

                FlatSlider {
                    id: seekSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10 // الأصلي
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

            // 3. أزرار التحكم والصوت
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 5 // الأصلي
                spacing: 10 // الأصلي

                RowLayout {
                    spacing: 15 // الأصلي

                    MButton {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 18 // الأصلي
                        implicitWidth: 30
                        implicitHeight: 30
                        normalBackground: "transparent"
                        normalForeground: style.textPrimary
                        enabled: root.player && root.player.canGoPrevious
                        opacity: enabled ? 1 : 0.5
                        onClicked: MediaController.previous()
                    }

                    // زر التشغيل (المتحول) - تم ضبط أبعاده داخلياً لتطابق الأصلي
                    MorphPlayButton {
                        playing: root.isPlaying
                        iconColor: style.textPrimary
                        enabled: root.player && root.player.canTogglePlaying
                        onClicked: MediaController.togglePlaying()
                    }

                    MButton {
                        text: ""
                        font.family: style.iconFont
                        font.pixelSize: 18 // الأصلي
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
                }

                // التحكم بالصوت
                RowLayout {
                    spacing: 10 // الأصلي

                    Text {
                        text: Audio.muted ? "" : (Audio.volume > 0.5 ? "" : "")
                        font.family: style.iconFont
                        font.pixelSize: 14 // الأصلي
                        color: style.textSecondary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Audio.setVolume(Audio.volume > 0 ? 0 : 0.5)
                        }
                    }

                    FlatSlider {
                        id: volSlider
                        Layout.preferredWidth: 50 // الأصلي
                        Layout.preferredHeight: 20 // الأصلي

                        Component.onCompleted: volSlider.value = Audio.volume
                        Connections {
                            target: Audio
                            function onVolumeChanged() {
                                if (!volSlider.pressed && Math.abs(volSlider.value - Audio.volume) > 0.01) {
                                    volSlider.value = Audio.volume;
                                }
                            }
                        }
                        onMoved: Audio.setVolume(value)
                        onValueChanged: {
                            if (Math.abs(Audio.volume - value) > 0.01) {
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
