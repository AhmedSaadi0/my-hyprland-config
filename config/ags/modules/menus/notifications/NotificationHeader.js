import strings from '../../strings.js';

const agsNotifications = await Service.import('notifications');

const notificationHeader = Widget.Box({
    className: 'notification-header-box',
    // homogeneous: true,
    children: [
        Widget.Button({
            className: 'notification-center-header-clear',
            label: strings.deleteAll,
            // label: "",
            // label: "",
            // label: "",
            // label: "",
            // label: "󰅖",
            onClicked: () => {
                agsNotifications.clear();
            },
        }),

        Widget.Button({
            className: 'notification-center-header-mute',
            label: '󰂚',
            onClicked: () => (agsNotifications.dnd = !agsNotifications.dnd),
            // label: "",
        }),

        Widget.Label({
            label: '',
            className: 'notification-header-label',
        }),
    ],
}).hook(agsNotifications, (self) => {
    if (agsNotifications.dnd) {
        self.children[1].label = '󰂛';
    } else {
        self.children[1].label = '󰂚';
    }

    self.children[2].label = `${agsNotifications.notifications.length} ${strings.notificationCountText}`;
});

export default notificationHeader;
