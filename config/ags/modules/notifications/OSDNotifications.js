import MyNotification from '../notifications/Notification.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import {
    Box,
    Revealer,
    Window,
    Label,
} from 'resource:///com/github/Aylur/ags/widget.js';
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';
import { local } from '../utils/helpers.js';

const Popups = () =>
    Box({
        className: 'notification-popups',
        vertical: true,
        attribute: {
            map: new Map(),
            dismiss: (box, id, force = false) => {
                if (!id || !box.attribute.map.has(id)) {
                    // box.get_parent().revealChild = false;
                    return;
                }

                if (box.attribute.map.get(id).attribute.hovered.value && !force)
                    return;

                if (box.attribute.map.size - 1 === 0)
                    box.get_parent().revealChild = false;

                timeout(400, () => {
                    box.attribute.map.get(id)?.destroy();
                    box.attribute.map.delete(id);
                });
            },
            notify: (box, id) => {
                if (!id || Notifications.dnd) {
                    box.get_parent().revealChild = false;
                    return;
                }

                // box.attribute.map.delete(id);
                box.attribute.map.set(
                    id,
                    MyNotification(Notifications.getNotification(id))
                );

                box.children = Array.from(box.attribute.map.values());

                box.get_parent().revealChild = true;
            },
        },
    })
        .hook(
            Notifications,
            (box, id) => box.attribute.notify(box, id),
            'notified'
        )
        .hook(
            Notifications,
            (box, id) => box.attribute.dismiss(box, id),
            'dismissed'
        )
        .hook(
            Notifications,
            (box, id) => box.attribute.dismiss(box, id, true),
            'closed'
        );

const OSDNotification = () =>
    Box({
        className: 'notification-popups',
        vertical: true,
        children: [],
    })
        .hook(
            Notifications,
            (box, id) => {
                if (Notifications.dnd) {
                    return;
                }

                box.children = [
                    MyNotification(Notifications.getNotification(id)),
                    ...box.children,
                ];

                box.get_parent().revealChild = true;
            },
            'notified'
        )
        .hook(
            Notifications,
            (box, id) => {
                if (Notifications.popups.length == 0) {
                    box.get_parent().revealChild = false;
                    box.children = [];
                }
            },
            'dismissed'
        )
        .hook(
            Notifications,
            (box, id) => {
                if (Notifications.popups.length == 0) {
                    box.get_parent().revealChild = false;
                    box.children = [];
                }
            },
            'closed'
        );

const PopupList = ({ transition = 'slide_up' } = {}) =>
    Box({
        className: 'notifications-popup-list',
        css: `
        min-height: 1.2px;
        min-width: 1.2px;
    `,
        children: [
            Revealer({
                transition,
                child: Popups(),
            }),
        ],
    });

export default (monitor) =>
    Window({
        monitor,
        layer: 'overlay',
        name: `notifications${monitor}`,
        visible: true,
        margins: [30, 30],
        anchor: ['bottom', local === 'RTL' ? 'left' : 'right'],
        child: PopupList(),
    });
