import { TitleText, local } from '../../utils/helpers.js';
import settings from '../../settings.js';
import strings from '../../strings.js';
import brightness from '../../services/BrightnessService.js';
const Audio = await Service.import('audio');
import MusicPLayer from '../../widgets/MusicPLayer.js';
import { Widget } from '../../utils/imports.js';

const margin = local === 'RTL' ? 'margin-right:0.5rem;' : 'margin-left:0.5rem;';

export const AudioSlider = () =>
    Widget.Box({
        className: 'audio-menu-slider',
        css: 'min-width: 140px',
        children: [
            Widget.Stack({
                className: 'vol-stack',
                children: {
                    v_101: Widget.Icon('audio-volume-overamplified-symbolic'),
                    v_67: Widget.Icon('audio-volume-high-symbolic'),
                    v_34: Widget.Icon('audio-volume-medium-symbolic'),
                    v_1: Widget.Icon('audio-volume-low-symbolic'),
                    v_0: Widget.Icon('audio-volume-muted-symbolic'),
                },
            }).hook(
                Audio,
                (stack) => {
                    if (!Audio.speaker) return;

                    if (Audio.speaker.isMuted) {
                        stack.shown = 'v_0';
                        return;
                    }

                    const show = [101, 67, 34, 1, 0].find(
                        (threshold) => threshold <= Audio.speaker.volume * 100
                    );

                    stack.shown = `v_${show}`;
                },
                'speaker-changed'
            ),
            Widget.Slider({
                hexpand: true,
                className: 'unset',
                drawValue: false,
                onChange: ({ value }) => (Audio.speaker.volume = value),
            }).hook(
                Audio,
                (slider) => {
                    slider.value = Audio.speaker.volume;
                },
                'speaker-changed'
            ),
        ],
    });

export const BrightnessSlider = () =>
    Widget.Box({
        className: 'brightness-menu-slider',
        css: 'min-width: 140px',
        children: [
            Widget.Stack({
                className: 'vol-stack',
                children: {
                    b_100: Widget.Label({ css: margin, label: '󰃠' }),
                    b_67: Widget.Label({ css: margin, label: '󰃝' }),
                    b_34: Widget.Label({ css: margin, label: '󰃟' }),
                    b_1: Widget.Label({ css: margin, label: '󰃞' }),
                    b_0: Widget.Label({ css: margin, label: '󰃞' }),
                },
            }).hook(
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
            Widget.Slider({
                hexpand: true,
                className: 'unset',
                drawValue: false,
                onChange: ({ value }) => (brightness.screen_value = value),
            }).hook(
                brightness,
                (slider) => {
                    const val = brightness.screen_value;
                    slider.value = val;
                },
                'screen-changed'
            ),
        ],
    });

const audio_brightness = Widget.Box({
    className: 'audio-menu-header-box',
    spacing: 30,
    vertical: true,
    children: [AudioSlider(), BrightnessSlider()],
});

const mediaControlRevaler = Widget.Revealer({
    revealChild: false,
    transitionDuration: 500,
    transition: 'slide_down',
    child: audio_brightness,
});

const MediaControl = () =>
    Widget.Box({
        vertical: true,
        children: [
            Widget.Button({
                className: 'media-control-revaler-button',
                child: TitleText({
                    title: strings.musicPlayer,
                    text: '',
                    vertical: false,
                    textXalign: 0.93,
                    titleXalign: 0.18,
                    homogeneous: true,
                }),
                onClicked: (self, value) => {
                    mediaControlRevaler.reveal_child =
                        !mediaControlRevaler.reveal_child;

                    self.child.children[1].label = '';
                    if (mediaControlRevaler.reveal_child) {
                        self.child.children[1].label = '';
                    }
                },
            }),
            mediaControlRevaler,
            MusicPLayer('left-menu-music-wd'),
        ],
    });

export default MediaControl;
