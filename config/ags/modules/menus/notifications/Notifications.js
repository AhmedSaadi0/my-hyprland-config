import Notification from '../../notifications/MenuNotification.js';

import strings from '../../strings.js';
import { Notifications } from '../../utils/imports.js';

const Scrollable = Widget.Scrollable;
const Label = Widget.Label;
const Box = Widget.Box;

function findAndRemoveChildByName(container, nameToFind) {
    const children = container.get_children();

    const childToRemove = children.find((child) => {
        return child && child.name === nameToFind;
    });

    if (childToRemove) {
        container.remove(childToRemove); // Remove the widget from the box
        childToRemove.destroy();
        return true; // Indicate success
    } else {
        return false; // Indicate failure
    }
}

const NoNotification = Box({
    vertical: true,
    className: 'notification-this-is-all',
    name: 'no-notification-box',
    children: [
        Label({
            className: 'no-notification-icon',
            // label: "󰂛"
            // label: "",
            label: '󱇥',
        }),
        Label({
            label: strings.noNotifications,
        }),
    ],
});

const NotificationsBox = () => {
    const box = Box({
        className: 'notification-menu-header',
        vertical: true,
        children: [],
        setup: (self) =>
            self
                .hook(
                    Notifications,
                    (self, id) => {
                        if (id !== undefined) {
                            if (self.get_children().length === 1) {
                                findAndRemoveChildByName(
                                    self,
                                    'no-notification-box'
                                );
                            }
                            const line = Box({
                                className: 'horizontal-line',
                                name: `notification-line-${id}`,
                            });
                            const notificationWidget = Notification(
                                Notifications.getNotification(id),
                                true
                            );
                            self.pack_end(line, false, false, 0);
                            self.pack_end(notificationWidget, false, false, 0);
                            self.show_all();
                        }
                    },
                    'notified'
                )
                .hook(
                    Notifications,
                    (box, id) => {
                        if (!id) return;

                        findAndRemoveChildByName(box, `notification-${id}`);
                        findAndRemoveChildByName(
                            box,
                            `notification-line-${id}`
                        );
                    },
                    'closed'
                ),
    });
    setTimeout(() => {
        initNotificationBox(box);
    }, 1000 * 2);
    return box;
};

function initNotificationBox(boxWidget) {
    const array = Notifications.notifications;

    if (array.length > 0) {
        boxWidget.children = [];
    }

    for (let index = 0; index < array.length; index++) {
        const element = array[index];
        let line = Box({
            className: 'horizontal-line',
            name: `notification-line-${element.id}`,
        });

        if (index === 0) {
            line = null;
        }
        boxWidget.pack_end(Notification(element, true), false, false, 0);
        if (line) {
            boxWidget.pack_end(line, false, false, 0);
        }
    }

    boxWidget.show_all();
}

const notificationContainer = Scrollable({
    hscroll: 'never',
    vscroll: 'automatic',
    className: 'notification-center-container',
    child: NotificationsBox(),
});

export default notificationContainer;
