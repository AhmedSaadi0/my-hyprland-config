import MaterialYouOne from "./MaterialYouOne.js"
import { Box, Window } from 'resource:///com/github/Aylur/ags/widget.js';


export default desktop => Window({
    name: `desktop_widget`,
    margin: [12, 0, 0, 12],
    layer: 'background',
    anchor: ['top', "left"],
    child: MaterialYouOne(),
})