// services/Audio.qml

pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    function setVolume(newVolume: real): void {
        if (sink?.ready && sink?.audio) {
            // حصر القيمة بين 0.0 و 1.0 لضمان سلامة المدخلات
            let targetVolume = Math.max(0.0, Math.min(1.0, newVolume));

            // شرط الحماية لمنع حلقة التكرار (Binding Loop)
            if (Math.abs(sink.audio.volume - targetVolume) > 0.001) {
                sink.audio.muted = false;
                sink.audio.volume = targetVolume;
            }
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}
