const { GLib } = imports.gi;
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { lookUpIcon, timeout } from 'resource:///com/github/Aylur/ags/utils.js';
import {
    Box,
    Icon,
    Label,
    EventBox,
    Button,
    Revealer,
} from 'resource:///com/github/Aylur/ags/widget.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import { local } from '../utils/helpers.js';

const rtlMargin =
    local === 'RTL' ? 'margin-left: 1rem;' : 'margin-right: 1rem;';

const NotificationIcon = ({ appEntry, appIcon, image }) => {
    if (image) {
        return Box({
            vpack: 'start',
            hexpand: false,
            className: 'notification-img',
            css: `
              background-image: url("${image}");
              background-size: contain;
              background-repeat: no-repeat;
              background-position: center;
              min-width: 78px;
              min-height: 78px;
              ${rtlMargin}
              border-radius: 1rem;
            `,
        });
    }

    let icon = 'dialog-information-symbolic';
    if (lookUpIcon(appIcon)) icon = appIcon;

    if (lookUpIcon(appEntry)) icon = appEntry;

    return Box({
        vpack: 'start',
        hexpand: false,
        css: `
            min-width: 78px;
            min-height: 78px;
            ${rtlMargin}
        `,
        children: [
            Icon({
                icon,
                size: 58,
                hpack: 'center',
                hexpand: true,
                vpack: 'center',
                vexpand: true,
            }),
        ],
    });
};

export default (notification) => {
    const hovered = Variable(false);
    let timeoutId;

    const bodyLabel = Label({
        css: `margin-top: 1rem;`,
        className: 'notification-description',
        hexpand: true,
        useMarkup: true,
        xalign: 0,
        justification: 'left',
        wrap: true,
    });

    try {
        bodyLabel.label = notification.body;
    } catch (error) {
        bodyLabel.label = '...';
    }

    const hover = () => {
        hovered.value = true;
        hovered._block = true;
        clearTimeout(timeoutId);

        timeout(100, () => (hovered._block = false));
    };

    const hoverLost = () =>
        GLib.idle_add(0, () => {
            timeoutId = setTimeout(() => {
                if (hovered._block) return GLib.SOURCE_REMOVE;

                hovered.value = false;
                notification.dismiss();
                return GLib.SOURCE_REMOVE;
            }, 3000);
        });

    const content = Box({
        css: `min-width: 400px;`,
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
                                css: `${rtlMargin}`,
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
                                css: `${rtlMargin} margin-top: 0.5rem;`,
                                vpack: 'start',
                                label: GLib.DateTime.new_from_unix_local(
                                    notification.time
                                ).format('%H:%M'),
                            }),
                            // Notification Close Button
                            Button({
                                onHover: hover,
                                className: 'notification-close-button',
                                vpack: 'start',
                                child: Icon('window-close-symbolic'),
                                onClicked: () => {
                                    notification.close();
                                },
                            }),
                        ],
                    }),
                    bodyLabel,
                ],
            }),
        ],
    });

    // Notification Action Button
    const actionsbox = Revealer({
        transition: 'slide_up',
        child: EventBox({
            onHover: hover,
            child: Box({
                className: 'notification-actions',
                children: notification.actions.map((action) =>
                    Button({
                        onHover: hover,
                        css: `margin-bottom: 0.5rem; margin-top: 1rem; margin-left: 0.5rem; margin-right: 0.5rem`,
                        className: 'action-button',
                        onClicked: () => notification.invoke(action.id),
                        hexpand: true,
                        child: Label(action.label),
                    })
                ),
            }),
        }),
    }).bind('revealChild', hovered);

    const mainbox = EventBox({
        className: `notification ${notification.urgency}`,
        vexpand: false,
        onPrimaryClick: () => {
            hovered.value = false;
            notification.dismiss();
        },
        attribute: { hovered: hovered },
        onHover: hover,
        onHoverLost: hoverLost,
        child: Box({
            vertical: true,
            children: [content, notification.actions.length > 0 && actionsbox],
        }),
    });

    return mainbox;
};
