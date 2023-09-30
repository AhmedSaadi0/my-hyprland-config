import Notification from '../notifications/Notification.js';
const { Notifications } = ags.Service;
const { Box, Revealer, Window, Label } = ags.Widget;
const { timeout } = ags.Utils;

const Popups = () => Box({
    className: "notification-popups",
    vertical: true,
    properties: [
        ['map', new Map()],
        ['dismiss', (box, id, force = false) => {
            if (!id || !box._map.has(id))
                return;

            if (box._map.get(id)._hovered.value && !force)
                return;

            if (box._map.size - 1 === 0)
                box.get_parent().reveal_child = false;

            timeout(200, () => {
                box._map.get(id)?.destroy();
                box._map.delete(id);
            });
        }],
        ['notify', (box, id) => {
            if (!id || Notifications.dnd)
                return;

            box._map.delete(id);
            box._map.set(id, Notification(Notifications.getNotification(id)));
            let children = [];
            const mapValues = Array.from(box._map.values());
            for (let i = mapValues.length - 1; i >= 0; i--) {
                children.push(mapValues[i]);
                if (mapValues.length>1) {
                    children.push(Label({}));
                }
            }
            box.children = children;
            timeout(10, () => {
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

const PopupList = ({ transition = 'slide_down' } = {}) => Box({
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
    name: `notifications${monitor}`,
    anchor: ['top', "left"],
    child: PopupList(),
});
