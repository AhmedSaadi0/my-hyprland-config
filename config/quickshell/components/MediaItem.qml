// components/MediaItem.qml
import QtQuick
import QtQuick.Effects
import QtMultimedia

Item {
    id: mItem

    // --- Public API ---
    property string source: ""
    property bool active: false
    // القيم المتاحة: "High", "Low"
    property string quality: "High"

    // --- State & Getters ---
    readonly property bool isVideoType: isVideo(source)

    property bool isReady: {
        if (!loader.item)
            return false;
        if (isVideoType) {
            return loader.item.playbackState === MediaPlayer.PlayingState || loader.item.mediaStatus === MediaPlayer.Buffered || loader.item.mediaStatus === MediaPlayer.Loaded;
        }
        return loader.item.status === Image.Ready;
    }

    property bool isError: {
        if (!loader.item)
            return false;
        return isVideoType ? loader.item.error !== MediaPlayer.NoError : loader.item.status === Image.Error;
    }

    // --- Helper Functions (Internal) ---
    function toFileUrl(path) {
        if (!path)
            return "";
        const str = path.toString();
        return (str.startsWith("file://") || str.startsWith("http")) ? str : "file://" + str;
    }

    function isVideo(path) {
        if (!path)
            return false;
        const p = path.toString().toLowerCase();
        return p.endsWith(".mp4") || p.endsWith(".mkv") || p.endsWith(".webm") || p.endsWith(".avi");
    }

    // --- Main Loader ---
    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (!mItem.source)
                return undefined;
            return mItem.isVideoType ? videoComp : imageComp;
        }
    }

    // --- Components ---

    // 1. Video Component
    Component {
        id: videoComp
        VideoOutput {
            id: vOut
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop

            // High: يستخدم LastFrame لأقصى سلاسة (يستهلك GPU أكثر)
            // Low: يستخدم التزامن التلقائي (أوفر للبطارية والمعالج)
            // flushMode: mItem.quality === "High" ? VideoOutput.LastFrame : VideoOutput.FirstFrame

            MediaPlayer {
                id: player
                videoOutput: vOut
                source: mItem.source ? Qt.resolvedUrl(mItem.toFileUrl(mItem.source)) : ""
                loops: MediaPlayer.Infinite
                autoPlay: true

                audioOutput: AudioOutput {
                    volume: 0
                }

                Component.onCompleted: if (mItem.active)
                    play()
            }

            Connections {
                target: mItem
                function onActiveChanged() {
                    mItem.active ? player.play() : player.pause();
                }
            }
        }
    }

    // 2. Image/GIF Component
    Component {
        id: imageComp
        AnimatedImage {
            id: img
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true

            source: mItem.source
            playing: mItem.active
            paused: !mItem.active

            // High: تحميل الصورة بكامل دقتها وتنعيمها
            // Low: تحميل نصف الدقة (يوفر 75% من الرام) وإيقاف التنعيم
            sourceSize: mItem.quality === "Low" ? Qt.size(parent.width / 2, parent.height / 2) : Qt.size(parent.width, parent.height)

            smooth: mItem.quality === "High"
            mipmap: mItem.quality === "High" // يحسن الجودة عند التصغير لكن يستهلك GPU

            onStatusChanged: if (status === Image.Ready)
                playing = true
        }
    }
}
