import ShowWindow from '../utils/ShowWindow.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import brightness from '../services/BrightnessService.js';

const Box = Widget.Box;
const Stack = Widget.Stack;
const Icon = Widget.Icon;
const Slider = Widget.Slider;
const Window = Widget.Window;
const Label = Widget.Label;

var oldValue = 0;

import { local } from '../utils/helpers.js';
const margin = local === 'RTL' ? 'margin-right:0.5rem;' : 'margin-left:0.5rem;';

export const Volume = () =>
    Box({
        className: 'vol-osd shadow',
        css: 'min-width: 140px',
        children: [
            Stack({
                className: 'vol-stack',
                children: {
                    // brightness icons
                    b_100: Label({ css: margin, label: '󰃠' }),
                    b_67: Label({ css: margin, label: '󰃝' }),
                    b_634: Label({ css: margin, label: '󰃟' }),
                    b_61: Label({ css: margin, label: '󰃞' }),
                    b_60: Label({ css: margin, label: '󰃞' }),

                    // volume icons
                    v_101: Icon('audio-volume-overamplified-symbolic'),
                    v_67: Icon('audio-volume-high-symbolic'),
                    v_34: Icon('audio-volume-medium-symbolic'),
                    v_1: Icon('audio-volume-low-symbolic'),
                    v_0: Icon('audio-volume-muted-symbolic'),
                },
            })
                .hook(
                    Audio,
                    (stack) => {
                        if (!Audio.speaker) return;

                        if (Audio.speaker.isMuted) {
                            stack.shown = '0';
                            return;
                        }

                        const show = [101, 67, 34, 1, 0].find(
                            (threshold) =>
                                threshold <= Audio.speaker.volume * 100
                        );

                        stack.shown = `v_${show}`;
                    },
                    'speaker-changed'
                )
                .hook(
                    brightness,
                    (stack) => {
                        const val = brightness.screen_value;

                        const show = [100, 67, 34, 1, 0].find(
                            (threshold) => threshold <= val * 100
                        );

                        stack.shown = `b_${show}`;
                    },
                    'screen-changed'
                ),
            Slider({
                hexpand: true,
                className: 'unset',
                drawValue: false,
                onChange: ({ value }) => (Audio.speaker.volume = value),
            })
                .hook(
                    Audio,
                    (slider) => {
                        if (
                            !Audio.speaker ||
                            oldValue === Audio.speaker.volume
                        ) {
                            return;
                        }
                        // App.closeWindow('brightness_osd');
                        ShowWindow('vol_osd');
                        oldValue = Audio.speaker.volume;
                        slider.value = oldValue;
                    },
                    'speaker-changed'
                )
                .hook(
                    brightness,
                    (slider) => {
                        const val = brightness.screen_value;

                        // App.closeWindow('vol_osd');
                        ShowWindow('vol_osd');

                        oldValue = val;
                        slider.value = oldValue;
                    },
                    'screen-changed'
                ),
        ],
    });

export const VolumeOSD = () =>
    Window({
        name: `vol_osd`,
        focusable: false,
        margins: [0, 0, 140, 0],
        layer: 'overlay',
        // popup: true,
        anchor: ['bottom'],
        child: Volume(),
    });
