import { Gtk } from 'astal/gtk3';
import { Box, Button, Label, Revealer } from 'astal/gtk3/widget';
import Pango from 'gi://Pango?version=1.0';

/**
 * Helper to map truncation mode strings to Pango.EllipsizeMode values.
 */
const mapEllipsize = (mode: string) => {
    switch (mode) {
        case 'start':
            return Pango.EllipsizeMode.START;
        case 'middle':
            return Pango.EllipsizeMode.MIDDLE;
        case 'end':
            return Pango.EllipsizeMode.END;
        case 'none':
        default:
            return Pango.EllipsizeMode.NONE;
    }
};

interface TitleTextProps {
    title: string;
    titleClass?: string;
    text: string;
    textClass?: string;
    boxClass?: string;
    homogeneous?: boolean;
    titleXalign?: number;
    titleYalign?: number;
    textXalign?: number;
    textYalign?: number;
    titleTruncate?: string;
    textTruncate?: string;
    vertical?: boolean;
    spacing?: number;
    ltr?: boolean;
    titleWidget?: any;
    textWidget?: any;
    titleCss?: string;
    textCss?: string;
    boxCss?: string;
}

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
    titleTruncate = 'none',
    textTruncate = 'none',
    vertical = true,
    spacing = 0,
    ltr = false,
    titleWidget = null,
    textWidget = null,
    titleCss = '',
    textCss = '',
    boxCss = '',
}: TitleTextProps) => {
    const _title = new Label({
        css: titleCss,
        label: title,
        className: titleClass,
        xalign: titleXalign,
        yalign: titleYalign,
        ellipsize: mapEllipsize(titleTruncate),
    });

    const _text = new Label({
        css: textCss,
        label: text,
        className: textClass,
        xalign: textXalign,
        yalign: textYalign,
        ellipsize: mapEllipsize(textTruncate),
    });

    const children = ltr
        ? [textWidget || _text, titleWidget || _title]
        : [titleWidget || _title, textWidget || _text];

    return new Box({
        css: boxCss,
        className: boxClass,
        // Use GTK3 orientation property instead of a simple boolean
        orientation: vertical
            ? Gtk.Orientation.VERTICAL
            : Gtk.Orientation.HORIZONTAL,
        homogeneous,
        spacing,
        children,
    });
};

interface TitleTextRevealerProps extends TitleTextProps {
    buttonCss?: string;
    buttonClass?: string;
    revealerClass?: string;
    transitionDuration?: number;
    onHover?: (btn: any) => void;
    onHoverLost?: (btn: any) => void;
    onClicked?: (() => void) | null;
    reveal_child?: boolean;
}

export const TitleTextRevealer = ({
    title,
    titleClass = '',
    text,
    textClass = '',
    boxClass = '',
    buttonCss = '',
    buttonClass = '',
    revealerClass = '',
    transitionDuration = 300,
    homogeneous = false,
    titleXalign = 0.5,
    textXalign = 0.5,
    titleTruncate = 'none',
    textTruncate = 'none',
    vertical = true,
    spacing = 0,
    onHover = (btn: Button) => {
        const child = btn.get_child();
        if (child && child.children && child.children.length > 1) {
            child.children[1].reveal_child = true;
        }
    },
    onHoverLost = (btn: Button) => {
        const child = btn.get_child();
        if (child && child.children && child.children.length > 1) {
            child.children[1].reveal_child = false;
        }
    },
    onClicked = null,
    titleWidget = null,
    textWidget = null,
    reveal_child = false,
}: TitleTextRevealerProps) => {
    const _title = new Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        ellipsize: mapEllipsize(titleTruncate),
    });
    const _text = new Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        ellipsize: mapEllipsize(textTruncate),
    });

    const revealedText = new Revealer({
        // Use proper GTK naming for the property
        reveal_child: reveal_child,
        className: revealerClass,
        transition_duration: transitionDuration,
        // Use the GTK enum for the transition type:
        transition_type: vertical
            ? Gtk.RevealerTransitionType.SLIDE_DOWN
            : Gtk.RevealerTransitionType.SLIDE_LEFT,
        child: textWidget || _text,
    });

    const box = new Box({
        className: boxClass,
        // Use orientation instead of a boolean "vertical"
        orientation: vertical
            ? Gtk.Orientation.VERTICAL
            : Gtk.Orientation.HORIZONTAL,
        homogeneous,
        spacing,
        children: [titleWidget || _title, revealedText],
    });

    return new Button({
        css: buttonCss,
        child: box,
        className: buttonClass,
        onHover,
        onHoverLost,
        onClicked,
    });
};

// TODO: -> Rename to a better name
export const TitleTextRevealer2 = ({
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
    onHover = (btn) => (btn.get_parent().children[1].reveal_child = true),
    onHoverLost = (btn) => (btn.get_parent().children[1].reveal_child = false),
    onClicked = null,
    titleWidget = null,
    textWidget = null,
    boxCss = '',
    reveal_child = false,
}: TitleTextRevealerProps) => {
    const _title = new Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        ellipsize: mapEllipsize(titleTruncate),
    });
    const _text = new Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        ellipsize: mapEllipsize(textTruncate),
    });

    const revealedText = new Revealer({
        reveal_child: reveal_child,
        className: revealerClass,
        transition_duration: 500,
        transition_type: vertical
            ? Gtk.RevealerTransitionType.SLIDE_DOWN
            : Gtk.RevealerTransitionType.SLIDE_LEFT,
        child: textWidget || _text,
    });

    return new Box({
        css: boxCss,
        // Use GTK3 orientation property
        orientation: vertical
            ? Gtk.Orientation.VERTICAL
            : Gtk.Orientation.HORIZONTAL,
        homogeneous,
        spacing,
        className: boxClass,
        children: [
            new Button({
                child: titleWidget || _title,
                className: buttonClass,
                onHover,
                onHoverLost,
                onClicked,
            }),
            revealedText,
        ],
    });
};
