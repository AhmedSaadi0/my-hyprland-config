import { Gtk } from 'astal/gtk3';
import { EventBox } from 'astal/gtk3/widget';
import Pango from 'gi://Pango?version=1.0';

type EllipsizeMode = 'start' | 'middle' | 'end' | 'none';

const getEllipsizeMode = (mode?: EllipsizeMode): Pango.EllipsizeMode =>
    ({
        start: Pango.EllipsizeMode.START,
        middle: Pango.EllipsizeMode.MIDDLE,
        end: Pango.EllipsizeMode.END,
        none: Pango.EllipsizeMode.NONE,
    })[mode || 'none'];

interface TitleTextProps {
    title: string;
    text: string;
    vertical?: boolean;
    ltr?: boolean;
    homogeneous?: boolean;
    spacing?: number;
    boxClass?: string;
    boxCss?: string;
    titleClass?: string;
    textClass?: string;
    titleXalign?: number;
    textXalign?: number;
    titleTruncate?: EllipsizeMode;
    textTruncate?: EllipsizeMode;
}

interface TitleTextEventBoxProps extends TitleTextProps {
    buttonClass?: string;
    buttonCss?: string;
    onClicked?: (self: EventBox, event: any) => void;
}

export const TitleText = (props: TitleTextEventBoxProps) => {
    const orientation = props.vertical
        ? Gtk.Orientation.VERTICAL
        : Gtk.Orientation.HORIZONTAL;

    const titleLabel = (
        <label
            label={props.title}
            className={props.titleClass}
            xalign={props.titleXalign}
            ellipsize={getEllipsizeMode(props.titleTruncate)}
            css={props.boxCss}
        />
    );

    const textLabel = (
        <label
            label={props.text}
            className={props.textClass}
            xalign={props.textXalign}
            ellipsize={getEllipsizeMode(props.textTruncate)}
            css={props.boxCss}
        />
    );

    return (
        <button
            onClick={props.onClicked}
            className={props.buttonClass}
            css={props.buttonCss}
        >
            <box
                className={props.boxClass}
                css={props.boxCss}
                orientation={orientation}
                homogeneous={props.homogeneous}
                spacing={props.spacing}
            >
                {props.ltr ? [textLabel, titleLabel] : [titleLabel, textLabel]}
            </box>
        </button>
    );
};

interface TitleTextRevealerProps extends TitleTextProps {
    revealChild?: boolean;
    transitionDuration?: number;
    buttonClass?: string;
    buttonCss?: string;
    revealerClass?: string;
    onClicked?: () => void;
}

export const TitleTextRevealer = (props: TitleTextRevealerProps) => {
    const transitionType = props.vertical
        ? Gtk.RevealerTransitionType.SLIDE_DOWN
        : Gtk.RevealerTransitionType.SLIDE_LEFT;

    return (
        <button
            className={props.buttonClass}
            css={props.buttonCss}
            onClicked={props.onClicked}
        >
            <box
                className={props.boxClass}
                orientation={
                    props.vertical
                        ? Gtk.Orientation.VERTICAL
                        : Gtk.Orientation.HORIZONTAL
                }
                homogeneous={props.homogeneous}
                spacing={props.spacing}
            >
                <label
                    label={props.title}
                    className={props.titleClass}
                    xalign={props.titleXalign}
                    ellipsize={getEllipsizeMode(props.titleTruncate)}
                />
                <revealer
                    className={props.revealerClass}
                    reveal_child={props.revealChild}
                    transition_duration={props.transitionDuration}
                    transition_type={transitionType}
                >
                    <label
                        label={props.text}
                        className={props.textClass}
                        xalign={props.textXalign}
                        ellipsize={getEllipsizeMode(props.textTruncate)}
                    />
                </revealer>
            </box>
        </button>
    );
};

export const TitleTextRevealer2 = (props: TitleTextRevealerProps) => {
    const transitionType = props.vertical
        ? Gtk.RevealerTransitionType.SLIDE_DOWN
        : Gtk.RevealerTransitionType.SLIDE_LEFT;

    return (
        <box
            className={props.boxClass}
            css={props.boxCss}
            orientation={
                props.vertical
                    ? Gtk.Orientation.VERTICAL
                    : Gtk.Orientation.HORIZONTAL
            }
            homogeneous={props.homogeneous}
            spacing={props.spacing}
        >
            <button
                className={props.buttonClass}
                onHover={(btn) =>
                    (btn.get_parent().children[1].reveal_child = true)
                }
                onHoverLost={(btn) =>
                    (btn.get_parent().children[1].reveal_child = false)
                }
                onClicked={props.onClicked}
            >
                <label
                    label={props.title}
                    className={props.titleClass}
                    xalign={props.titleXalign}
                    ellipsize={getEllipsizeMode(props.titleTruncate)}
                />
            </button>
            <revealer
                className={props.revealerClass}
                reveal_child={props.revealChild}
                transition_duration={props.transitionDuration ?? 500}
                transition_type={transitionType}
            >
                <label
                    label={props.text}
                    className={props.textClass}
                    xalign={props.textXalign}
                    ellipsize={getEllipsizeMode(props.textTruncate)}
                />
            </revealer>
        </box>
    );
};
