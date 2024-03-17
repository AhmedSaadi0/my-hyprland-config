import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import {
    Box,
    Stack,
    Icon,
    Slider,
} from 'resource:///com/github/Aylur/ags/widget.js';

export const Volume = () =>
    Box({
        className: 'volume',
        css: 'min-width: 100px',
        children: [
            Stack({
                className: 'vol-stack',
                items: {
                    // tuples of [string, Widget]
                    101: Icon('audio-volume-overamplified-symbolic'),
                    67: Icon('audio-volume-high-symbolic'),
                    34: Icon('audio-volume-medium-symbolic'),
                    1: Icon('audio-volume-low-symbolic'),
                    0: Icon('audio-volume-muted-symbolic'),
                },
            }).hook(
                Audio,
                (stack) => {
                    if (!Audio.speaker) return;

                    if (Audio.speaker.isMuted) {
                        stack.shown = '0';
                        return;
                    }

                    const show = [101, 67, 34, 1, 0].find(
                        (threshold) => threshold <= Audio.speaker.volume * 100
                    );

                    stack.shown = `${show}`;
                },
                'speaker-changed'
            ),
            Slider({
                hexpand: true,
                className: 'unset',
                drawValue: false,
                onChange: ({ value }) => (Audio.speaker.volume = value),
            }).hook(
                Audio,
                (slider) => {
                    if (!Audio.speaker) return;
                    slider.value = Audio.speaker.volume;
                },
                'speaker-changed'
            ),
        ],
    });
