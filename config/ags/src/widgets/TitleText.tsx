import { Gtk } from 'astal/gtk3';
import { EventBox } from 'astal/gtk3/widget';
import Pango from 'gi://Pango?version=1.0';
import { Widget } from '../../types/@girs/gtk-3.0/gtk-3.0.cjs';

type EllipsizeMode = 'start' | 'middle' | 'end' | 'none';

const getEllipsizeMode = (mode: EllipsizeMode = 'none'): Pango.EllipsizeMode =>
    ({
        start: Pango.EllipsizeMode.START,
        middle: Pango.EllipsizeMode.MIDDLE,
        end: Pango.EllipsizeMode.END,
        none: Pango.EllipsizeMode.NONE,
    })[mode];

const getOrientation = (vertical?: boolean): Gtk.Orientation =>
    vertical ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL;

interface TitleTextBaseProps {
    vertical?: boolean;
    homogeneous?: boolean;
    spacing?: number;
    boxClass?: string;
    boxCss?: string;
    titleXalign?: number;
    textXalign?: number;
}

interface TitleTextContentProps {
    title?: string;
    text?: string;
    titleClass?: string;
    textClass?: string;
    titleTruncate?: EllipsizeMode;
    textTruncate?: EllipsizeMode;
    titleCss?: string;
    textCss?: string;
}

interface TitleTextWidgetProps {
    titleWidget?: Widget;
    textWidget?: Widget;
}

type TitleTextProps = TitleTextBaseProps &
    TitleTextContentProps &
    TitleTextWidgetProps;

interface TitleTextEventBoxProps extends TitleTextProps {
    buttonClass?: string;
    buttonCss?: string;
    onClicked?: (self: EventBox, event: Gtk.ButtonPressEvent) => void;
    reverseOrder?: boolean;
}

const createLabel = (
    content?: string,
    widget?: Widget,
    className?: string,
    xalign?: number,
    truncate?: EllipsizeMode,
    css?: string
) => {
    if (content !== undefined) {
        return (
            <label
                key={content}
                label={content}
                className={className}
                xalign={xalign}
                ellipsize={getEllipsizeMode(truncate)}
                css={css}
            />
        );
    }
    return widget;
};

export const TitleText = ({
    vertical = false,
    homogeneous = false,
    spacing = 0,
    reverseOrder = false,
    onClicked,
    ...props
}: TitleTextEventBoxProps) => {
    const orientation = getOrientation(vertical);

    const titleLabel = createLabel(
        props.title,
        props.titleWidget,
        props.titleClass,
        props.titleXalign,
        props.titleTruncate,
        props.titleCss
    );

    const textLabel = createLabel(
        props.text,
        props.textWidget,
        props.textClass,
        props.textXalign,
        props.textTruncate,
        props.textCss
    );

    const content = reverseOrder
        ? [textLabel, titleLabel]
        : [titleLabel, textLabel];

    return (
        <button
            onClicked={onClicked}
            className={props.buttonClass}
            css={props.buttonCss}
        >
            <box
                className={props.boxClass}
                css={props.boxCss}
                orientation={orientation}
                homogeneous={homogeneous}
                spacing={spacing}
            >
                {content}
            </box>
        </button>
    );
};

interface TitleTextRevealerProps extends TitleTextProps {
    revealChild?: boolean;
    transitionDuration?: number;
    transitionType?: Gtk.RevealerTransitionType;
    buttonClass?: string;
    buttonCss?: string;
    revealerClass?: string;
    onClicked?: () => void;
}

export const TitleTextRevealer = ({
    vertical = false,
    homogeneous = false,
    spacing = 0,
    revealChild = false,
    transitionDuration = 300,
    transitionType = Gtk.RevealerTransitionType.CROSSFADE,
    ...props
}: TitleTextRevealerProps) => {
    const orientation = getOrientation(vertical);

    return (
        <button
            className={props.buttonClass}
            css={props.buttonCss}
            onClicked={props.onClicked}
        >
            <box
                className={props.boxClass}
                orientation={orientation}
                homogeneous={homogeneous}
                spacing={spacing}
            >
                {createLabel(
                    props.title,
                    props.titleWidget,
                    props.titleClass,
                    props.titleXalign,
                    props.titleTruncate,
                    props.titleCss
                )}
                <revealer
                    className={props.revealerClass}
                    reveal_child={revealChild}
                    transition_duration={transitionDuration}
                    transition_type={transitionType}
                >
                    {createLabel(
                        props.text,
                        props.textWidget,
                        props.textClass,
                        props.textXalign,
                        props.textTruncate,
                        props.textCss
                    )}
                </revealer>
            </box>
        </button>
    );
};
