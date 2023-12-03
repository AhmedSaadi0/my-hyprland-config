import ShowWindow from '../utils/ShowWindow.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js'
import { Box, Stack, Icon, Slider, Window } from 'resource:///com/github/Aylur/ags/widget.js'

var oldValue = 0;

export const Volume = () => Box({
    className: 'vol-osd shadow',
    css: 'min-width: 140px',
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
                if (!Audio.speaker || oldValue === Audio.speaker.volume) {
                    return;
                }
                ShowWindow("vol_osd");
                oldValue = Audio.speaker.volume;
                slider.value = oldValue;
            }, 'speaker-changed']],
        }),
    ],
});

export const VolumeOSD = () => Window({
    name: `vol_osd`,
    focusable: false,
    margins: [0, 0, 140, 0],
    layer: 'overlay',
    popup: true,
    anchor: ['bottom'],
    child: Volume()
})