import Audio from 'resource:///com/github/Aylur/ags/service/audio.js'
import { Box, Stack, Icon, Slider, Window } from 'resource:///com/github/Aylur/ags/widget.js'
import Brightness from '../services/BrightnessService.js';

export const Volume = () => Box({
    className: 'brightness-osd',
    css: 'min-width: 140px',
    children: [
        // Stack({
        //     className: "vol-stack",
        //     items: [
        //         // tuples of [string, Widget]
        //         ['101', Icon('audio-volume-overamplified-symbolic')],
        //         ['67', Icon('audio-volume-high-symbolic')],
        //         ['34', Icon('audio-volume-medium-symbolic')],
        //         ['1', Icon('audio-volume-low-symbolic')],
        //         ['0', Icon('audio-volume-muted-symbolic')],
        //     ],
        //     connections: [[Brightness, stack => {
                
        //     }, 'speaker-changed']],
        // }),
        Slider({
            hexpand: true,
            className: "unset",
            drawValue: false,
            onChange: ({ value }) => Audio.speaker.volume = value,
            connections: [[Brightness, slider => {
                console.log(Brightness);
            }, 'speaker-changed']],
        }),
    ],
});

export const BrightnessOSD = () => Window({
    name: `brightness_osd`,
    className: "brightness-osd",
    focusable: false,
    margins: [0, 0, 140, 0],
    layer: 'overlay',
    popup: true,
    visible: false,
    anchor: ['bottom'],
    child: Volume()
})