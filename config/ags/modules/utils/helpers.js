import { Utils, Widget } from './imports.js';

export const TitleText = ({
    title,
    titleClass = '',
    text,
    textClass = '',
    boxClass = '',
    homogeneous = false,
    titleXalign = 0.5,
    textXalign = 0.5,
    //titleMaxWidthChars = 100,
    //textMaxWidthChars = 100,
    titleTruncate = 'none',
    textTruncate = 'none',
    vertical = true,
    spacing = 0,
    ltr = false,
}) => {
    const _title = Widget.Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        //maxWidthChars: titleMaxWidthChars,
        truncate: titleTruncate,
    });

    const _text = Widget.Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        //maxWidthChars: textMaxWidthChars,
        truncate: textTruncate,
    });

    const children = ltr ? [_text, _title] : [_title, _text];

    return Widget.Box({
        className: boxClass,
        vertical: vertical,
        homogeneous: homogeneous,
        spacing: spacing,
        children: children,
    });
};

export const local = Utils.exec(
    `/home/${Utils.USER}/.config/ags/scripts/lang.sh`
);

export const notify = ({
    tonePath,
    title,
    message,
    icon,
    priority = 'normal',
}) => {
    Utils.execAsync([`paplay`, tonePath]).catch(print);

    Utils.execAsync([
        `notify-send`,
        '-u',
        priority,
        '-i',
        icon,
        title,
        message,
    ]);
};
/**
Widget({
    replacement for properties
    attribute: {
        'custom-prop': 123,
        'another': 'xyz',
    },

    setup: self => self
        .on('some-signal-on-this', self => { }) // replacement for connections
        .hook(gobject, self => { }, 'event') // replacement for connections
        .poll(1000, self => { }) // replacement connections
        .bind('prop', gobject, 'target_prop', v => v) // replacement for binds
    })
 * 
 */
