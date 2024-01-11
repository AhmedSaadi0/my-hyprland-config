import { App, Utils, Widget } from './imports.js';

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

    const _title = Widget.Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
    });

    const _text = Widget.Label({
        label: text,
        className: textClass,
        xalign: textXalign,
    });

    return Widget.Box({
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

export const notify = ({
    tonePath,
    title,
    message,
    icon,
    priority = 'normal',
}) => {

    Utils.execAsync([
        `paplay`,
        tonePath,
    ]).catch(print)

    Utils.execAsync([
        `notify-send`,
        "-u",
        priority,
        "-i",
        icon,
        title,
        message,
    ]);
};
