import themeService from '../services/ThemeService.js';
import settings from '../settings.js';
import { Utils, Widget } from './imports.js';

export const TitleText = ({
    title,
    titleClass = '',
    text,
    textClass = '',
    boxClass = '',
    homogeneous = false,
    titleXalign = 0.5,
    titleYalign = 0.5,
    textXalign = 0.5,
    textYalign = 0.5,
    //titleMaxWidthChars = 100,
    //textMaxWidthChars = 100,
    titleTruncate = 'none',
    textTruncate = 'none',
    vertical = true,
    spacing = 0,
    ltr = false,
    titleWidget = null,
    textWidget = null,
}) => {
    const _title = Widget.Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        yalign: titleYalign,
        //maxWidthChars: titleMaxWidthChars,
        truncate: titleTruncate,
    });

    const _text = Widget.Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        yalign: textYalign,
        //maxWidthChars: textMaxWidthChars,
        truncate: textTruncate,
    });

    const children = ltr
        ? [textWidget ? textWidget : _text, titleWidget ? titleWidget : _title]
        : [titleWidget ? titleWidget : _title, textWidget ? textWidget : _text];

    return Widget.Box({
        className: boxClass,
        vertical: vertical,
        homogeneous: homogeneous,
        spacing: spacing,
        children: children,
    });
};

export const TitleTextRevealer = ({
    title,
    titleClass = '',
    text,
    textClass = '',
    boxClass = '',
    buttonClass = '',
    revealerClass = '',
    homogeneous = false,
    titleXalign = 0.5,
    textXalign = 0.5,
    titleTruncate = 'none',
    textTruncate = 'none',
    vertical = true,
    spacing = 0,
    onHover = (btn) => (btn.child.children[1].reveal_child = true),
    onHoverLost = (btn) => (btn.child.children[1].reveal_child = false),
    onClicked = null,
    titleWidget = null,
    textWidget = null,
}) => {
    const _title = Widget.Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        truncate: titleTruncate,
    });

    const _text = Widget.Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        truncate: textTruncate,
    });

    const revealedText = Widget.Revealer({
        revealChild: false,
        className: revealerClass,
        transitionDuration: 500,
        transition: vertical
            ? 'slide_down'
            : vertical
              ? 'slide_left'
              : 'slide_right',
        child: textWidget ? textWidget : _text,
    });

    const box = Widget.Box({
        className: boxClass,
        vertical: vertical,
        homogeneous: homogeneous,
        spacing: spacing,
        children: [titleWidget ? titleWidget : _title, revealedText],
    });

    return Widget.Button({
        child: box,
        className: buttonClass,
        onHover: onHover,
        onHoverLost: onHoverLost,
        onClicked: onClicked,
    });
};

export const local = Utils.exec(settings.scripts.deviceLocal);

export const notify = ({
    tonePath = settings.assets.audio.notificationAlert,
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

export function truncateString(str, maxLength) {
    if (str === undefined) return '';

    if (str.length <= maxLength) {
        return str;
    } else {
        return str.substring(0, maxLength) + '...';
    }
}

export const ThemeButton = ({
    label,
    icon,
    theme,
    label_css = 'theme-btn-label',
    icon_css = 'theme-btn-icon',
    end = local === 'RTL' ? 'margin-left: 1.1rem;' : 'margin-right: 1.1rem;',
    css = `
    min-width: 5rem;
    min-height: 2rem;
    ${end}
    border-radius: 1rem;
`,
}) => {
    const _label = Widget.Label({
        className: `unset ${label_css}`,
        label: label,
    });

    const _icon = Widget.Label({
        className: `unset ${icon_css}`,
        label: icon,
        xalign: 0.5,
    });

    const box = Widget.Box({
        className: 'unset theme-btn-box',
        children: [_label, _icon],
    });

    const button = Widget.Button({
        css: css,
        child: box,
        onClicked: () => {
            themeService.changeTheme(theme);
            setTimeout(() => {
                hideMainMenu();
            }, 700);
        },
    }).hook(themeService, (btn) => {
        btn.className = 'theme-btn';
        if (themeService.selectedTheme === theme) {
            btn.className = 'selected-theme';
        }
    });

    return button;
};

export function getMinutesBetweenDates(date1, date2) {
    // Calculate the difference in milliseconds
    const differenceInMilliseconds = date2 - date1;

    // Convert milliseconds to minutes
    const differenceInMinutes = differenceInMilliseconds / (1000 * 60);

    return Math.abs(differenceInMinutes); // Return the absolute value of the difference
}
