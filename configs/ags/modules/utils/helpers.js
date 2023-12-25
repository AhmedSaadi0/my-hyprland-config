import { Box, Label } from 'resource:///com/github/Aylur/ags/widget.js';
import { Utils } from './imports.js';


export const TitleText = ({
    title,
    titleClass = "",
    text,
    textClass = "",
    boxClass = "",
    homogeneous = false,
    titleXalign = 0.5,
    textXalign = 0.5,
    connections = [],
    vertical = true,
    spacing = 0,
}) => {

    const _title = Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
    });

    const _text = Label({
        label: text,
        className: textClass,
        xalign: textXalign,
    });

    return Box({
        className: boxClass,
        vertical: vertical,
        homogeneous: homogeneous,
        spacing: spacing,
        children: [
            _title,
            _text,
        ],
        connections: connections,
    });
};

export const local = Utils.exec(`/home/${Utils.USER}/.config/ags/scripts/lang.sh`);
