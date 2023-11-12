const { GLib } = imports.gi;
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';
import { Box, Icon, Label, EventBox, Button } from 'resource:///com/github/Aylur/ags/widget.js';

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
                border-radius: 1rem;
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

export default (notification) => {
    const bodyLabel = Label({
        style: `margin-top: 1rem;`,
        className: 'notification-description',
        hexpand: true,
        useMarkup: true,
        xalign: 0,
        justification: 'left',
        wrap: true,
    })

    try {
        bodyLabel.label = notification.body;
    } catch (error) {
        bodyLabel.label = "...";
    }

    const content = Box({
        style: `min-width: 330px;`,
        children: [
            NotificationIcon(notification),
            Box({
                hexpand: true,
                vertical: true,
                children: [
                    Box({
                        children: [
                            // Notification Title
                            Label({
                                className: 'notification-title',
                                style: `margin-left: 1rem;`,
                                xalign: 0,
                                justification: 'left',
                                hexpand: true,
                                maxWidthChars: 24,
                                truncate: 'end',
                                wrap: true,
                                label: notification.summary,
                                useMarkup: notification.summary.startsWith('<'),
                            }),
                            // Notification Body
                            Label({
                                className: 'notification-time',
                                style: `margin-left: 1rem; margin-top: 0.5rem;`,
                                valign: 'start',
                                label: GLib.DateTime.new_from_unix_local(notification.time).format('%H:%M'),
                            }),
                            // Notification Close Button
                            Button({
                                className: 'notification-close-button',
                                valign: 'start',
                                child: Icon('window-close-symbolic'),
                                onClicked: () => { notification.close() },
                            }),
                        ],
                    }),
                    bodyLabel,
                ],
            }),
        ],
    });

    // Notification Action Button
    const actionsbox = Box({
        className: 'notification-actions',
        children: notification.actions.map(action => Button({
            // onHover: hover,
            style: `margin-bottom: 0.5rem; margin-top: 1rem; margin-left: 0.5rem; margin-right: 0.5rem`,
            className: 'action-button',
            onClicked: () => notification.invoke(action.id),
            hexpand: true,
            child: Label(action.label),
        })),
    });

    const mainbox = EventBox({
        className: `menu-notification ${notification.urgency}`,
        vexpand: false,
        onPrimaryClick: () => {
            // hovered.value = false;
            // notification.dismiss();
            // notification.close();
            // notification.invoke();
        },
        child: Box({
            vertical: true,
            children: [
                content,
                notification.actions.length > 0 && actionsbox,
            ],
        }),
    });

    return mainbox;
};
