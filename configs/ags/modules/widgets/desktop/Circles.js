import FuzzyClock from "../FuzzyClock.js";
import Saying from "../Saying.js";
import { Mpris, Widget } from "../../utils/imports.js";
import { selectedMusicPlayer } from "../MusicPLayer.js";


const MusicWidget = Widget.Box({
    spacing: 18,
    homogeneous: false,
    vertical: true,
    children: [
        Widget.Box({
            vertical: true,
            className: "desktop-wd-music-player-box",
            homogeneous: true,
            children: [
                Widget.Label({
                    className: "desktop-wd-music-player-title",
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
                Widget.Label({
                    className: "desktop-wd-music-player-artist",
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
            ],
            connections: [[Mpris, box => {
                if (Mpris?.players.length > 0 && Mpris?.getPlayer(selectedMusicPlayer)) {
                    box.children[0].label = Mpris?.getPlayer(selectedMusicPlayer)?.trackTitle;
                    box.children[1].label = Mpris?.getPlayer(selectedMusicPlayer)?.trackArtists[0];
                } else {
                    box.children[0].label = "لا توجد موسيقى قيد التشغبل";
                    box.children[1].label = "لا توجد موسيقى قيد التشغبل";
                }
            }]]
        }),
    ]
})

const CircleMusicWidget = () => Widget.Window({
    name: `desktop_circles_widget`,
    margins: [135, 60],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['bottom', "right"],
    child: MusicWidget,
})

const SayingWidget = () => Widget.Window({
    name: `desktop_circles_saying_widget`,
    margins: [920, 30],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['top', "right"],
    child: Saying(),
})

// const FuzzyClockWidget = () => Widget.Window({
//     name: `desktop_circles_saying_widget`,
//     margins: [460, 1170],
//     layer: 'background',
//     visible: false,
//     focusable: false,
//     anchor: ['bottom', "right"],
//     child: FuzzyClock(),
// })
const FuzzyClockWidget = () => Widget.Window({
    name: `desktop_circles_saying_widget`,
    margins: [230, 60],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['bottom', "right"],
    child: FuzzyClock(),
})

const circlesMusicWidget = CircleMusicWidget();
const circlesSayingWidget = SayingWidget();
const fuzzyClockWidget = FuzzyClockWidget();

globalThis.ShowCirclesWidget = () => {
    circlesMusicWidget.visible = true
    circlesSayingWidget.visible = true
    fuzzyClockWidget.visible = true
};
globalThis.HideCirclesWidget = () => {
    circlesMusicWidget.visible = false
    circlesSayingWidget.visible = false
    fuzzyClockWidget.visible = false
};

export default circlesMusicWidget;