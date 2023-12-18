import MyNotification from '../notifications/Notification.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { Box, Revealer, Window, Label } from 'resource:///com/github/Aylur/ags/widget.js';
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';
import { local } from '../utils/helpers.js';

const Popups = () => Box({
    className: "notification-popups",
    vertical: true,
    properties: [
        ['map', new Map()],
        ['dismiss', (box, id, force = false) => {

            if (!id || !box._map.has(id)) {
                // box.get_parent().revealChild = false;
                return;
            }

            if (box._map.get(id)._hovered.value && !force)
                return;

            if (box._map.size - 1 === 0)
                box.get_parent().revealChild = false;

            timeout(400, () => {
                box._map.get(id)?.destroy();
                box._map.delete(id);
                box.get_parent().revealChild = false;
            });
        }],
        ['notify', (box, id) => {

            if (!id || Notifications.dnd) {
                box.get_parent().revealChild = false;
                return;
            }

            box._map.delete(id);
            box._map.set(id, MyNotification(Notifications.getNotification(id)));
            let children = [];
            const mapValues = Array.from(box._map.values());
            for (let i = mapValues.length - 1; i >= 0; i--) {
                children.push(mapValues[i]);
                if (mapValues.length > 1) {
                    children.push(Label({}));
                }
            }
            box.children = children;
            timeout(20, () => {
                box.get_parent().revealChild = true;
            });
        }],
    ],
    connections: [
        [Notifications, (box, id) => box._notify(box, id), 'notified'],
        [Notifications, (box, id) => box._dismiss(box, id), 'dismissed'],
        [Notifications, (box, id) => box._dismiss(box, id, true), 'closed'],
    ],
});

const PopupList = ({ transition = 'slide_up' } = {}) => Box({
    className: 'notifications-popup-list',
    children: [
        Revealer({
            transition,
            child: Popups(),
        }),
    ],
});

export default monitor => Window({
    monitor,
    layer: 'overlay',
    name: `notifications${monitor}`,
    margins: [30, 30],
    anchor: ['bottom', local === "RTL" ? "left" : "right"],
    child: PopupList(),
});
