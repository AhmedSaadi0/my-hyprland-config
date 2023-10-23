import MaterialYouOne from "./MaterialYouOne.js"
import { Box, Window } from 'resource:///com/github/Aylur/ags/widget.js';
import MusicPlayer from "../MusicPLayer.js";
import FuzzyClock from "../FuzzyClock.js";


export default desktop => Window({
    name: `desktop_widget`,
    margin: [100, 0, 0, 80],
    layer: 'background',
    focusable:true,
    anchor: ['top', "left"],
    child: FuzzyClock(),
})