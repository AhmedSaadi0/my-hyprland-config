import { Box, Button, Label, Revealer } from 'astal/gtk3/widget';

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
        truncate: titleTruncate,
    });

    const _text = new Label({
        css: textCss,
        label: text,
        className: textClass,
        xalign: textXalign,
        yalign: textYalign,
        truncate: textTruncate,
    });

    const children = ltr
        ? [textWidget || _text, titleWidget || _title]
        : [titleWidget || _title, textWidget || _text];

    return new Box({
        css: boxCss,
        className: boxClass,
        vertical,
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
}: TitleTextRevealerProps) => {
    const _title = new Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        truncate: titleTruncate,
    });
    const _text = new Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        truncate: textTruncate,
    });

    const revealedText = new Revealer({
        revealChild: false,
        className: revealerClass,
        transitionDuration,
        transition: vertical ? 'slide_down' : 'slide_right',
        child: textWidget || _text,
    });

    const box = new Box({
        className: boxClass,
        vertical,
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
}: TitleTextRevealerProps) => {
    const _title = new Label({
        label: title,
        className: titleClass,
        xalign: titleXalign,
        truncate: titleTruncate,
    });
    const _text = new Label({
        label: text,
        className: textClass,
        xalign: textXalign,
        truncate: textTruncate,
    });

    const revealedText = new Revealer({
        revealChild: false,
        className: revealerClass,
        transitionDuration: 500,
        transition: vertical ? 'slide_down' : 'slide_right',
        child: textWidget || _text,
    });

    return new Box({
        css: boxCss,
        vertical,
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
