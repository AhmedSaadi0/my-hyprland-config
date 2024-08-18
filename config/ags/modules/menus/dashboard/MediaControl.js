import { TitleText, local } from '../../utils/helpers.js';
import strings from '../../strings.js';
import MusicPLayer from '../../widgets/MusicPLayer.js';
import { AudioSlider } from '../../components/AudioSlider.js';
import { BrightnessSlider } from '../../components/BrightnessSlider.js';

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

globalThis.revealMediaControls = (reveal_child = true) =>
    (mediaControlRevaler.reveal_child = reveal_child);

const mediaControl = Widget.Box({
    vertical: true,
    children: [
        Widget.Button({
            className: 'media-control-revaler-button',
            child: TitleText({
                titleWidget: TitleText({
                    titleClass: 'icon-font',
                    title: '',
                    // titleClass: 'themes-buttons-icon',
                    text: strings.musicPlayer,
                    // textClass: 'themes-buttons-title',
                    vertical: false,
                    spacing: 10,
                    titleYalign: 0.5,
                    textYalign: 0.5,
                }),
                text: '',
                vertical: false,
                textXalign: 0.9,
                titleXalign: 0.18,
                homogeneous: true,
            }),
            onClicked: (self, value) => {
                mediaControlRevaler.reveal_child =
                    !mediaControlRevaler.reveal_child;

                self.child.children[1].label = '';
                if (mediaControlRevaler.reveal_child) {
                    self.child.children[1].label = '';
                    revealPowerButtons(false);
                    revealAllThemes(false);
                }
            },
        }),
        mediaControlRevaler,
        MusicPLayer('left-menu-music-wd'),
    ],
});

export default mediaControl;
