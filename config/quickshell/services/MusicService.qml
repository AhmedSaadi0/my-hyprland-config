pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

import "root:/config"
import "root:/services"

Singleton {
    id: root

    // ============================================================
    //  SIGNALS
    // ============================================================
    signal analysisCompleted(string emotion, string comment, var tags)

    readonly property var players: Mpris.players.values
    property int activeIndex: 0
    readonly property var activePlayer: (players.length > 0) ? players[activeIndex < players.length ? activeIndex : 0] : null
    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false

    // بيانات الأغنية
    readonly property string title: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "Unknown"
    readonly property string artist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""
    readonly property string coverArt: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""

    readonly property string fullInfo: artist ? (artist + " - " + title) : title

    property string lastProcessedSong: ""

    property string aiComment: ""
    property string aiEmotion: ""
    property var aiTags: ["test", "hi"]

    readonly property double position: activePlayer ? activePlayer.position : 0
    readonly property double length: (activePlayer && activePlayer.length > 0) ? activePlayer.length : 1
    readonly property double progress: position / length

    property var recentTracks: []

    // ============================================================
    //  مراقبة التغييرات
    // ============================================================
    onPlayersChanged: {
        if (activeIndex >= players.length)
            activeIndex = 0;
    }

    onFullInfoChanged: {
        if (fullInfo && fullInfo !== "Unknown") {
            console.info("[DEBUG] New song detected:", fullInfo);
        }

        if (isPlaying) {
            analysisDebouncer.restart();
        }
    }

    onIsPlayingChanged: {
        console.info("[DEBUG] IsPlaying changed to:", isPlaying);
        if (isPlaying) {
            if (root.fullInfo === root.lastProcessedSong) {
                root.checkRandomResumeComment();
            } else {
                analysisDebouncer.restart();
            }
        }
    }

    // ============================================================
    //  المنطق والمؤقتات
    // ============================================================
    Timer {
        id: analysisDebouncer
        interval: 1000 * 10
        repeat: false
        onTriggered: {
            root.processCurrentSong(false); // false تعني هذا ليس تعليق استئناف
        }
    }

    function checkRandomResumeComment() {
        if (Math.random() > 0.85) {
            console.info("[DEBUG] Random Resume Triggered!");
            root.processCurrentSong(true); // true تعني هذا تعليق استئناف
        } else {
            console.info("[DEBUG] Random Resume Skipped (Saving tokens).");
        }
    }

    function processCurrentSong(isResumeContext) {
        if (!root.fullInfo || root.fullInfo === "Unknown" || !root.isPlaying) {
            return;
        }

        root.analyzeWithAI(isResumeContext);
    }

    // ============================================================
    //  الذكاء الاصطناعي
    // ============================================================
    function analyzeWithAI(isResumeContext) {
        if (!App.scripts.python || !App.scripts.python.callMusicAi)
            return;

        aiProcess.currentProcessingInfo = root.fullInfo;

        const currentTime = new Date().toLocaleTimeString(Qt.locale(), "hh:mm ap");

        console.info(`[DEBUG] Formatting time for position: ${root.position}`);
        const timestamp = formatTime(root.position);
        const resumeTimeStr = isResumeContext ? `Resumed at timestamp ${timestamp}` : "Start of track";
        console.info(`[DEBUG] resumeTimeStr: ${resumeTimeStr}`);

        let historyContextMsg = "";

        let lastIndex = root.recentTracks.indexOf(root.fullInfo);

        if (lastIndex !== -1) {
            let songsAgo = lastIndex + 1;
            historyContextMsg = `User played this specific song ${songsAgo} tracks ago. Mention this repetition in the comment.`;
        }

        const historyStr = root.recentTracks.slice(0, 5).join(", ");

        let message = "";

        if (isResumeContext) {
            message = `
            Action: User RESUMED playback.
            Song: ${title} by ${artist}
            Resume Time: ${resumeTimeStr}
            `;
        } else {
            message = `
            Current Song: ${title} by ${artist}
            Context:
            - Time: ${currentTime}
            - Play History: [${historyStr}]
            - Repetition Info: ${historyContextMsg}`;
        }

        console.info(`[DEBUG] message to send -> ${message}`);

        const command = App.scripts.python.callMusicAi;
        aiProcess.command = [...command, "--provider", "gemini", "--message", message];
        aiProcess.running = true;
    }

    // ============================================================
    //  معالجة الرد
    // ============================================================

    Process {
        id: aiProcess
        property string currentProcessingInfo: ""

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(this.text.toString());

                    console.info(`[MusicService][DEBUG] -> ai row result ${this.text.toString()}`);

                    if (result.success && result.response) {
                        var finalResponse = result.response;

                        if (typeof finalResponse === 'string') {
                            console.info("[DEBUG] Response is a string, attempting to parse inner JSON...");

                            var cleanJson = finalResponse.replace(/```json/g, "").replace(/```/g, "").trim();

                            var firstBrace = cleanJson.indexOf("{");
                            var lastBrace = cleanJson.lastIndexOf("}");

                            if (firstBrace !== -1 && lastBrace !== -1) {
                                cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
                            }

                            try {
                                finalResponse = JSON.parse(cleanJson);
                            } catch (e2) {
                                console.error("[DEBUG] Inner JSON Parse Failed:", e2);
                                console.error("[DEBUG] Bad content:", cleanJson);
                                return;
                            }
                        }

                        const emotion = finalResponse.emotion ? finalResponse.emotion.toString().trim() : "thinking";
                        const comment = finalResponse.comment ? finalResponse.comment.toString().trim() : "...";
                        const tags = finalResponse.tags ? finalResponse.tags : [];

                        root.aiEmotion = emotion;
                        root.aiComment = comment;
                        root.aiTags = tags;

                        console.info("[DEBUG] Final Result -> Emotion:", emotion, "| Comment:", comment);

                        root.analysisCompleted(emotion, comment, tags);

                        if (aiProcess.currentProcessingInfo !== "") {
                            root.addToHistory(aiProcess.currentProcessingInfo);
                            root.lastProcessedSong = aiProcess.currentProcessingInfo;
                        }
                    } else {
                        console.error("[DEBUG] AI returned success:false or missing response.", result);
                    }
                } catch (e) {
                    console.error("[DEBUG] Fatal JSON Parse Error:", e);
                }
            }
        }
    }

    // ============================================================
    //  دوال مساعدة
    // ============================================================
    function addToHistory(trackName) {
        if (recentTracks.length > 0 && recentTracks[0] === trackName)
            return;

        const timeNow = new Date().toLocaleTimeString(Qt.locale(), "hh:mm ap");
        var newHistory = [`${trackName}:: Played at${timeNow}`];
        for (var i = 0; i < recentTracks.length && i < 19; i++) {
            newHistory.push(recentTracks[i]);
        }
        recentTracks = newHistory;
        console.info("[DEBUG] History Updated. Last played:", trackName);
    }

    function formatTime(secondsInput) {
        let totalSeconds = Math.floor(secondsInput);

        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;

        let secStr = seconds < 10 ? "0" + seconds : seconds;

        return minutes + ":" + secStr;
    }

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
        if (players.length > 1)
            activeIndex = (activeIndex + 1) % players.length;
    }

    NibrasShellShortcut {
        name: "nextSong"
        onPressed: root.next()
    }
    NibrasShellShortcut {
        name: "previousSong"
        onPressed: previous()
    }
    NibrasShellShortcut {
        name: "togglePlaying"
        onPressed: toggle()
    }
    NibrasShellShortcut {
        name: "stopPlay"
        onPressed: stop()
    }
}
