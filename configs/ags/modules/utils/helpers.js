import { Box, Label } from 'resource:///com/github/Aylur/ags/widget.js';

export const TitleText = ({
    title,
    titleClass = "",
    text,
    textClass = "",
    boxClass = "",
    homogeneous = false,
    titleXalign = 0.5,
    textXalign = 0.5,
}) => {

    const _title = Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
    })

    const _text = Label({
        label: text,
        className: textClass,
        xalign: textXalign,
    })

    return Box({
        className: boxClass,
        vertical: true,
        homogeneous: homogeneous,
        children: [
            _title,
            _text,
        ]
    })
}