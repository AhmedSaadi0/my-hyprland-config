import { Button } from 'resource:///com/github/Aylur/ags/widget.js';
import { Notifications } from '../utils/imports.js';
import { TitleText } from '../utils/helpers.js';

// Notification muted  |  | 󰂛 |  | 
// Notification 󰂜 | 󰂚 |  | 
// Notification Broadcast 󰂞 | 󰂟 | 󰪒 | 
// Notification has data 
export const NotificationCenterButton = () =>
    Button({
        className: 'notification-center-button unset',
        // child: Label({ label: "" }),
        // label: '',
        child: TitleText({
            title: '',
            text: '',
            textClass: 'unset',
            vertical: false,
            titleXalign: 1,
            textXalign: 0,
            spacing: 4,
        }),

        onClicked: () => ToggleNotificationCenter(),
    }).hook(Notifications, (self) => {
        if (Notifications.dnd) {
            // self.label = '󰂛';
            self.child.children[0].label = '󰂛';
            self.child.children[1].label = '';
        } else if (Notifications.notifications.length === 0) {
            // self.label = '󰂚';
            self.child.children[0].label = '󰂚';
            self.child.children[1].label = '';
            // self.label = "󱇥";
        } else if (Notifications.notifications.length > 0) {
            self.child.children[0].label = '󱅫';
            self.child.children[1].label =
                Notifications.notifications.length + '';
            // self.label = `${Notifications.notifications.length} 󱅫`;
        }
    });
