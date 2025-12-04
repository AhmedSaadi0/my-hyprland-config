// services/MusicService.qml
pragma Singleton

import QtQuick
import Quickshell.Services.Mpris
import "root:/config"

QtObject {
    id: root

    // ============================================================
    //  PROPERTIES (البيانات العامة)
    // ============================================================

    // قائمة المشغلات المتاحة
    readonly property var players: Mpris.players.values
    property int activeIndex: 0

    // المشغل النشط حالياً
    readonly property var activePlayer: (players.length > 0) ? players[activeIndex < players.length ? activeIndex : 0] : null

    // هل يوجد مشغل حالياً؟
    readonly property bool hasPlayer: activePlayer !== null

    // readonly property bool isPlaying: activePlayer ? activePlayer.playbackStatus === Mpris.PlaybackStatus.Playing : false
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false

    // بيانات الأغنية
    readonly property string title: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "Unknown"
    readonly property string artist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""
    readonly property string coverArt: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""

    readonly property string fullInfo: artist ? (artist + " - " + title) : title

    // بيانات الوقت
    readonly property double position: activePlayer ? activePlayer.position : 0
    readonly property double length: (activePlayer && activePlayer.length > 0) ? activePlayer.length : 1
    readonly property double progress: position / length

    // ============================================================
    //  LOGIC (المنطق)
    // ============================================================

    onPlayersChanged: {
        // إعادة ضبط المؤشر إذا اختفى المشغل الحالي
        if (activeIndex >= players.length) {
            activeIndex = 0;
        }
    }

    // ============================================================
    //  CONTROLS (التحكم)
    // ============================================================

    function next() {
        if (activePlayer)
            activePlayer.next();
    }
    function previous() {
        if (activePlayer)
            activePlayer.previous();
    }
    function toggle() {
        if (activePlayer)
            activePlayer.togglePlaying();
    }
    function stop() {
        if (activePlayer)
            activePlayer.stop();
    }

    function cyclePlayers() {
        if (players.length > 1) {
            activeIndex = (activeIndex + 1) % players.length;
        }
    }

    property var _nextSongCall: NibrasShellShortcut {
        name: "nextSong"
        onPressed: root.next()
    }

    property var _prevSongCall: NibrasShellShortcut {
        name: "previousSong"
        onPressed: prev()
    }

    property var _toggleSongCall: NibrasShellShortcut {
        name: "togglePlaying"
        onPressed: toggle()
    }

    property var _stopPlayerCall: NibrasShellShortcut {
        name: "stopPlay"
        onPressed: stop()
    }
}
