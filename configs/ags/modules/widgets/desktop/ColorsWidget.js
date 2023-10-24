// import MaterialYouOne from "./MaterialYouOne.js"
import { Box, Window } from 'resource:///com/github/Aylur/ags/widget.js';
// import MusicPlayer from "../MusicPLayer.js";
import FuzzyClock from "../FuzzyClock.js";
import Saying from "../Saying.js";
import { Mpris, Widget } from "../../utils/imports.js";


const DesktopWidget = Widget.Box({
    spacing: 18,
    homogeneous: false,
    children: [
        Widget.Box({
            vertical: true,
            className: "colors-wd-music-player-box",
            homogeneous: true,
            children: [
                Widget.Label({
                    className: "colors-wd-music-player-title",
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
                Widget.Label({
                    className: "colors-wd-music-player-artist",
                    justification: 'left',
                    xalign: 1,
                    maxWidthChars: 10,
                    truncate: 'end',
                }),
            ],
            connections: [[Mpris, box => {
                box.children[0].label = Mpris?.players[0].trackTitle;
                box.children[1].label = Mpris?.players[0].trackArtists[0];
            }]]
        }),
        Widget.Box({
            className: "color-wd-separator",
        }),
        FuzzyClock(),
        Widget.Box({
            className: "color-wd-separator",
        }),
        Saying(),
    ]
})

const FinalWidget = () => Window({
    name: `desktop_color_widget`,
    margin: [80, 0, 0, 80],
    layer: 'background',
    visible: false,
    focusable: false,
    anchor: ['top'],
    child: DesktopWidget,
})

const ColorWidget = FinalWidget();

globalThis.ViewColorWidget = () => ColorWidget.visible = true;
globalThis.HideColorWidget = () => ColorWidget.visible = false;

export default ColorWidget;