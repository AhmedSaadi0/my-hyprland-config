const { USER } = ags.Utils;

const { Label, Box, Icon, Window, Button, Revealer } = ags.Widget;


const NotificationItem = () => {

    let title = Label({
        label: "العنوان",
        justification: "right",
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
        wrap: false,
    })

    let message = Label({
        label: "نص الرسالة",
        justification: "right",
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
        wrap: false,
    })

    let time = Label({
        label: "04:57 AM 10/10/2023",
        justification: "right",
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
        wrap: false,
    })

    return Box({
        className:"notification-item",
        spacing: 8,
        vertical: true,
        children: [
            title,
            message,
            time
        ]
    })
}

const MenuBox = () => {
    return Box({
        className: "notification-menu-header",
        vertical: true,
        children: [
            NotificationItem(),
            NotificationItem(),
            NotificationItem(),
        ],
    })
}

const menuRevealer = Revealer({
    transition: "slide_down",
    child: Box({
        className: "left-menu-box",
        vertical: true,
        children: [
            MenuBox(),
        ]
    }),
})

export const NotificationCenter = () => Window({
    name: `notification_center`,
    margin: [12, 0, 0, 12],
    // layer: 'overlay',
    anchor: ['top', "left"],
    child: Box({
        style: `
            min-height: 0.0001rem;
        `,
        children: [
            menuRevealer,
        ],
    })
})

globalThis.showNotificationCenter = () => menuRevealer.revealChild = !menuRevealer.revealChild;

// مسجد 
// Notification muted  |  | 󰂛 |  
// Notification 󰂜 | 󰂚 |  | 
// Notification Broadcast 󰂞 | 󰂟 | 󰪒 | 
// Notification has data 
export const NotificationCenterButton = () => Button({
    className: "menu-button",
    child: Label({ label: "" }),
    onClicked: () => showNotificationCenter()
});