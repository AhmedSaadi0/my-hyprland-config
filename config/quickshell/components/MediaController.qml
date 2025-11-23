// components/MediaController.qml
pragma Singleton

import QtQuick
import Quickshell.Services.Mpris
import "root:/config"

Item {
    id: controller

    // ============================================================
    //  STATE VARIABLES (Editable logic settings)
    // ============================================================

    // The index of the currently selected music player
    property int activePlayerIndex: 0

    // ============================================================
    //  READ-ONLY PROPERTIES (Data from System/MPRIS)
    // ============================================================

    // List of all detected media players (Spotify, Browser, VLC, etc.)
    readonly property var availablePlayers: Mpris.players.values
    readonly property int playersCount: availablePlayers.length

    // The actual active player object (Safe check ensures it's not null)
    property var activePlayer: (playersCount > 0) ? availablePlayers[activePlayerIndex < playersCount ? activePlayerIndex : 0] : null

    // ============================================================
    //  LOGIC HANDLERS (Safety Checks)
    // ============================================================

    // Reset index to 0 if the selected player is closed to avoid crashes
    onPlayersCountChanged: {
        if (activePlayerIndex >= playersCount && playersCount > 0) {
            activePlayerIndex = 0;
        }
    }

    // ============================================================
    //  CONTROL FUNCTIONS (Playback Actions)
    // ============================================================

    function next() {
        if (activePlayer)
            activePlayer.next();
    }

    function previous() {
        if (activePlayer)
            activePlayer.previous();
    }

    function togglePlaying() {
        if (activePlayer)
            activePlayer.togglePlaying();
    }

    function stop() {
        if (activePlayer)
            activePlayer.stop();
    }

    // Switch between different media players (e.g. Spotify -> Chrome)
    function cyclePlayers() {
        if (playersCount > 1) {
            activePlayerIndex = (activePlayerIndex + 1) % playersCount;
        }
    }

    // ============================================================
    //  GLOBAL SHORTCUTS (Keyboard bindings)
    // ============================================================

    NibrasShellShortcut {
        name: "nextSong"
        onPressed: controller.next()
    }

    NibrasShellShortcut {
        name: "previousSong"
        onPressed: controller.previous()
    }

    NibrasShellShortcut {
        name: "togglePlaying"
        onPressed: controller.togglePlaying()
    }

    NibrasShellShortcut {
        name: "stopPlay"
        onPressed: controller.stop()
    }

    NibrasShellShortcut {
        name: "switchPlayer"
        onPressed: controller.cyclePlayers()
    }
}
