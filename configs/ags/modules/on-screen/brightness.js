const { Audio } = ags.Service
const { Box, Stack, Icon, Slider, Window } = ags.Widget

export const Volume = () => Box({
    className: 'vol-osd',
    style: 'min-width: 140px',
    children: [
        Stack({
            className: "vol-stack",
            items: [
                // tuples of [string, Widget]
                ['101', Icon('audio-volume-overamplified-symbolic')],
                ['67', Icon('audio-volume-high-symbolic')],
                ['34', Icon('audio-volume-medium-symbolic')],
                ['1', Icon('audio-volume-low-symbolic')],
                ['0', Icon('audio-volume-muted-symbolic')],
            ],
            connections: [[Audio, stack => {
                if (!Audio.speaker)
                    return;

                if (Audio.speaker.isMuted) {
                    stack.shown = '0';
                    return;
                }

                const show = [101, 67, 34, 1, 0].find(
                    threshold => threshold <= Audio.speaker.volume * 100
                );

                stack.shown = `${show}`;
            }, 'speaker-changed']],
        }),
        Slider({
            hexpand: true,
            className: "unset",
            drawValue: false,
            onChange: ({ value }) => Audio.speaker.volume = value,
            connections: [[Audio, slider => {
                if (!Audio.speaker)
                    return;
                showVol()
                slider.value = Audio.speaker.volume;
            }, 'speaker-changed']],
        }),
    ],
});

let isProcessing = false; // Flag to track processing status
let timeoutId; // Store the timeout ID


function showVol() {
    if (isProcessing) {
        // If processing, reset the timer and do something else
        clearTimeout(timeoutId);
    } else {
        // If not processing, do something
        ags.App.toggleWindow('vol_osd');
    }

    // Set a 5-second delay before doing something else
    timeoutId = setTimeout(() => {
        ags.App.toggleWindow('vol_osd');
        isProcessing = false; // Reset the processing flag
    }, 5000);

    isProcessing = true; // Set the processing flag
}

export const VolumeOSD = () => Window({
    name: `vol_osd`,
    className: "vol-osd",
    focusable: false,
    margin: [0, 0, 140, 0],
    layer: 'overlay',
    popup: true,
    anchor: ['bottom'],
    child: Volume()
})