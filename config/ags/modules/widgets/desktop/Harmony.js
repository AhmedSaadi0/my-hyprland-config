import FuzzyClock from '../FuzzyClock.js';
import Saying from '../Saying.js';
import { Mpris, Widget } from '../../utils/imports.js';
import { selectedMusicPlayer } from '../MusicPLayer.js';

const DesktopWidget = Widget.Box({
    spacing: 18,
    homogeneous: false,
    vertical: true,
    children: [
        FuzzyClock(),
        Widget.Box({
            className: 'desktop-wd-separator',
        }),
        Widget.Box({
            vertical: true,
            className: 'desktop-wd-music-player-box',
            homogeneous: true,
            children: [
                Widget.Label({
                    className: 'desktop-wd-music-player-title',
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
                Widget.Label({
                    className: 'desktop-wd-music-player-artist',
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
            ],
        }).hook(Mpris, (box) => {
            if (
                Mpris?.players.length > 0 &&
                Mpris?.getPlayer(selectedMusicPlayer)
            ) {
                box.children[0].label =
                    Mpris?.getPlayer(selectedMusicPlayer)?.trackTitle;
                box.children[1].label =
                    Mpris?.getPlayer(selectedMusicPlayer)?.trackArtists[0];
            } else {
                box.children[0].label = 'لا توجد موسيقى قيد التشغبل';
                box.children[1].label = 'لا توجد موسيقى قيد التشغبل';
            }
        }),
        Widget.Box({
            className: 'desktop-wd-separator',
            css: `
                margin-top: 0.5rem;
            `,
        }),
        Saying(),
    ],
});

const FinalWidget = () =>
    Widget.Window({
        name: `desktop_harmony_widget`,
        margins: [100, 100],
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['bottom', 'left'],
        child: DesktopWidget,
    });

const harmonyWidget = FinalWidget();

globalThis.ShowHarmonyWidget = () => (harmonyWidget.visible = true);
globalThis.HideHarmonyWidget = () => (harmonyWidget.visible = false);

export default harmonyWidget;
