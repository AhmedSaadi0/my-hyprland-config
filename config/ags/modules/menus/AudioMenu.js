import tableRow from '../components/TableRow.js';
import { TitleText, local, notify } from '../utils/helpers.js';
import settings from '../settings.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import strings from '../strings.js';
import {
    Box,
    Stack,
    Slider,
    Icon,
    Revealer,
    Window,
    Label
} from 'resource:///com/github/Aylur/ags/widget.js';

let oldValue = 0;

const volumelable = Box({
    className: 'popup-box',
    vertical: true,
    visible: false,
    children: [
        Label({
            label: strings.volumeLevel,
            className: 'popup-label',
        }),
    ],
});

export const Volume = () =>
    Box({
        className: 'vol-osd shadow',
        css: 'min-width: 140px',
        children: [
            Stack({
                className: 'vol-stack',
                children: {
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
                    if (!Audio.speaker || oldValue === Audio.speaker.volume) {
                        return;
                    }
                    oldValue = Audio.speaker.volume;
                    slider.value = oldValue;
                },
                'speaker-changed'
            ),
        ],
    }
);

const menuRevealer = Revealer({
    transition: settings.theme.menuTransitions.audioMenu,
    transitionDuration: settings.theme.menuTransitions.audioMenuDuration,
    child: Box({
        className: 'hardware-menu-box',
        vertical: true,
        children: [
            volumelable,
            Volume()
        ],
    }),
});

export const AudioMenu = () =>
    Window({
        name: `Audio_menu`,
        margins: [2, 450],
        anchor: ['top', local === 'RTL' ? 'right' : 'left'],
        child: Box({
            css: `min-height: 2px;`,
            children: [menuRevealer],
        }),
    });

let menuIsOpen = false;

globalThis.showAudioMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild;
    menuIsOpen = menuRevealer.revealChild;
};
