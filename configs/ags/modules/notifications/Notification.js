const { GLib } = imports.gi;
const { Notifications } = ags.Service;
const { lookUpIcon, timeout } = ags.Utils;
const { Box, Icon, Label, EventBox, Button, Revealer } = ags.Widget;

const NotificationIcon = ({ appEntry, appIcon, image }) => {
    if (image) {
        return Box({
            valign: 'start',
            hexpand: false,
            className: 'notification-img',
            style: `
                background-image: url("${image}");
                background-size: contain;
                background-repeat: no-repeat;
                background-position: center;
                min-width: 78px;
                min-height: 78px;
                margin-left: 1rem;
                border-radius: 2rem;
            `,
        });
    }

    let icon = 'dialog-information-symbolic';
    if (lookUpIcon(appIcon))
        icon = appIcon;

    if (lookUpIcon(appEntry))
        icon = appEntry;

    return Box({
        valign: 'start',
        hexpand: false,
        style: `
                min-width: 78px;
                min-height: 78px;
                margin-left: 1rem;
        `,
        children: [Icon({
            icon, size: 58,
            halign: 'center', hexpand: true,
            valign: 'center', vexpand: true,
        })],
    });
};

export default ({ id, summary, body, actions, urgency, time, ...icon }) => {
    const hovered = ags.Variable(false);

    const hover = () => {
        hovered.value = true;
        hovered._block = true;

        timeout(100, () => hovered._block = false);
    };

    const hoverLost = () => GLib.idle_add(0, () => {
        if (hovered._block)
            return GLib.SOURCE_REMOVE;

        hovered.value = false;
        Notifications.dismiss(id);
        return GLib.SOURCE_REMOVE;
    });

    const content = Box({
        style:`min-width: 400px;`,
        children: [
            NotificationIcon(icon),
            Box({
                hexpand: true,
                vertical: true,
                children: [
                    Box({
                        children: [
                            Label({
                                className: 'notification-title',
                                style:`margin-left: 1rem;`,
                                xalign: 0,
                                justification: 'left',
                                hexpand: true,
                                maxWidthChars: 24,
                                truncate: 'end',
                                wrap: true,
                                label: summary,
                                useMarkup: summary.startsWith('<'),
                            }),
                            Label({
                                className: 'notification-time',
                                style:`margin-left: 1rem; margin-top: 0.5rem;`,
                                valign: 'start',
                                label: GLib.DateTime.new_from_unix_local(time).format('%H:%M'),
                            }),
                            Button({
                                onHover: hover,
                                className: 'notification-close-button',
                                style:`border-radius: 2rem;`,
                                valign: 'start',
                                child: Icon('window-close-symbolic'),
                                onClicked: () => Notifications.close(id),
                            }),
                        ],
                    }),
                    Label({
                        style:`margin-top: 1rem;`,
                        className: 'notification-description',
                        hexpand: true,
                        useMarkup: true,
                        xalign: 0,
                        justification: 'left',
                        label: body,
                        wrap: true,
                    }),
                ],
            }),
        ],
    });

    const actionsbox = Revealer({
        transition: 'slide_up',
        binds: [['revealChild', hovered]],
        child: EventBox({
            onHover: hover,
            child: Box({
                className: 'notification-actions',
                children: actions.map(action => Button({
                    onHover: hover,
                    style:`border-radius: 2rem; margin-top: 1rem;`,
                    className: 'action-button',
                    onClicked: () => Notifications.invoke(id, action.id),
                    hexpand: true,
                    child: Label(action.label),
                })),
            }),
        }),
    });

    const mainbox = EventBox({
        className: `notification ${urgency}`,
        vexpand: false,
        onPrimaryClick: () => {
            hovered.value = false;
            Notifications.dismiss(id);
        },
        properties: [['hovered', hovered]],
        onHover: hover,
        onHoverLost: hoverLost,
        child: Box({
            vertical: true,
            children: [
                content,
                actions.length > 0 && actionsbox,
            ],
        }),
    });

    return mainbox;
};
