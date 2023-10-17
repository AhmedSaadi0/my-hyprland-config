import { TitleText } from "../utils/helpers.js";
import { Box, Icon, Label } from 'resource:///com/github/Aylur/ags/widget.js';



const RowOne = () => {
    return Box({
        className: "",
        children: [
        ]
    })
}

const RowTwo = () => {
    return Box({
        className: "",
        children: [
        ]
    })
}

const ButtonsRow = () => {
    return Box({
        className: "",
        spacing: 15,
        homogeneous: true,
        children: []
    })
}

export default widget => Box({
    className: "",
    vertical: true,
    children: [
        RowOne(),
        RowTwo(),
        ButtonsRow(),
    ]

})