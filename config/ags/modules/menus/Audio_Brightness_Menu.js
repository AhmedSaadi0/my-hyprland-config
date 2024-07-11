import {  local  } from '../utils/helpers.js';
import settings from '../settings.js';
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
import brightness from '../services/BrightnessService.js';
const audio = await Service.import('audio');
import MusicPLayer from '../widgets/MusicPLayer.js';


export const AudioWidget = () => {
    const label = Widget.Label({
        className: 'menu-audio-icon',
        label: '',
    });

    const button = Widget.Button({
        onClicked: () => showAudioMenu(),
        className: 'unset no-hover',
        child: label,
    });

    const progress = Widget.CircularProgress({
        className: 'menu-audio',
        child: button,
        startAt: 0,
        rounded: false,
        // inverted: true,
    });

    return Widget.Box({
        children: [progress],
    }).hook(audio, (box) => {
        const vol = audio.speaker.volume;
        progress.value = vol;

        if (audio.speaker.is_muted) {
            label.label = '';
        } else if (vol > 0.7) {
            label.label = '';
        } else if (vol > 0.3 && vol < 0.7) {
            label.label = '';
        } else {
            label.label = '';
        }

        box.show_all();
        label.tooltipMarkup = `<span weight='bold'>${strings.volumeLevel} (${parseInt(vol * 100)})</span>`;
    });
};

export const BrightnessWidget = () => {
    const label = Widget.Label({
        className: 'menu-brightness-icon',
        label: '󰃠',
    });

    const button = Widget.Button({
        onClicked: () => showAudioMenu(),
        className: 'unset no-hover',
        child: label,
    });

    const progress = Widget.CircularProgress({
        className: 'menu-brightness',
        child: button,
        startAt: 0,
        rounded: false,
        // inverted: true,
    });

    return Widget.Box({
        className: 'bar-hw-brightness-box',
        children: [progress],
    }).hook(brightness, (box) => {
        const val = brightness.screen_value;
        progress.value = val;
        label.tooltipMarkup = `<span weight='bold'>${strings.brightnessLevel} (${val * 100})</span>`;

        if (val === 1) {
            label.label = '󰃠';
        } else if (val > 0.67) {
            label.label = '󰃝';
        } else if (val > 0.34) {
            label.label = '󰃟';
        } else {
            label.label = '󰃞';
        }

        box.show_all();
    });
};

const audio_brightness = Widget.Box({
    className: 'audio-menu-header-box',
    spacing: 30,
    children: [ AudioWidget(), BrightnessWidget() ],
});

const menuRevealer = Revealer({
    transition: settings.theme.menuTransitions.audioMenu,
    transitionDuration: settings.theme.menuTransitions.audioMenuDuration,
    child: Box({
        className: 'hardware-menu-box',
        vertical: true,
        children: [
            audio_brightness,
            MusicPLayer('left-menu-music-wd'),
        ],
    }),
});

export const AudioMenu = () =>
    Window({
        name: `Audio_menu`,
        margins: [2, 400],
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
