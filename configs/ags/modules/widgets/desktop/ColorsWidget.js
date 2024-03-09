import FuzzyClock from '../FuzzyClock.js';
import Saying from '../Saying.js';
import { Mpris, Widget } from '../../utils/imports.js';
import { selectedMusicPlayer } from '../MusicPLayer.js';

const DesktopWidget = Widget.Box({
    spacing: 38,
    homogeneous: false,
    children: [
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
        }),
        FuzzyClock(),
        Widget.Box({
            className: 'desktop-wd-separator',
        }),
        Saying(),
    ],
});

const FinalWidget = () =>
    Widget.Window({
        name: `desktop_color_widget`,
        margins: [80, 0, 0, 80],
        layer: 'background',
        visible: false,
        focusable: false,
        anchor: ['top'],
        child: DesktopWidget,
    });

const ColorWidget = FinalWidget();

globalThis.ShowColorWidget = () => (ColorWidget.visible = true);
globalThis.HideColorWidget = () => (ColorWidget.visible = false);

export default ColorWidget;
