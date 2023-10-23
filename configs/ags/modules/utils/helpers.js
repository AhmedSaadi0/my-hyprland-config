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
    connections = [],
}) => {

    // Create the _title and _text Labels with the state values
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

    const updateLabels = (newTitle, newText) => {
        _title.label = newTitle;
        _text.set_label(newText);
    };

    return Box({
        className: boxClass,
        vertical: true,
        homogeneous: homogeneous,
        children: [
            _title,
            _text,
        ],
        connections: connections,
    });
};