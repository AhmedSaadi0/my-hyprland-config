import notificationHeader from './NotificationHeader.js';
import notificationContainer from './Notifications.js';

const notificationTabMenu = Widget.Box({
    vertical: true,
    children: [notificationHeader, notificationContainer],
});

export default notificationTabMenu;
