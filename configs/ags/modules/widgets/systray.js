const { SystemTray } = ags.Service
const { Box, Icon, Button } = ags.Widget
const { Gravity } = imports.gi.Gdk;

const PanelButton = ({ className, content, ...rest }) => Button({
    className: `panel-button ${className} `,
    child: Box({ children: [content] }),
    ...rest,
});

const SysTrayItem = item => PanelButton({
    className: "tray-btn",
    content: Icon({
        binds: [[
            'icon',
            item,
            'icon'
        ]],
    }),
    binds: [[
        'tooltipMarkup',
        item,
        'tooltipMarkup'
    ]],
    setup: btn => {
        const id = item.menu.connect(
            'popped-up',
            menu => {
                btn.toggleClassName('active');
                menu.connect('notify::visible', menu => {
                    btn.toggleClassName('active', menu.visible);
                });
                menu.disconnect(id);
            });
    },
    onPrimaryClick: (_, event) => item.activate(event),
    onSecondaryClick: btn => item.menu.popup_at_widget(
        btn,
        Gravity.SOUTH,
        Gravity.NORTH,
        null
    ),
});

export const SysTrayBox = () => Box({
    className: 'systray',
    properties: [
        [
            'items',
            new Map()
        ],
        [
            'onAdded',
            (box, id) => {
                const item = SystemTray.getItem(id);
                if (box._items.has(id) || !item)
                    return;

                const widget = SysTrayItem(item);
                box._items.set(id, widget);
                box.add(widget);
                box.show_all();
            }
        ],
        [
            'onRemoved',
            (box, id) => {
                if (!box._items.has(id))
                    return;

                box._items.get(id).destroy();
                box._items.delete(id);
            }
        ],
    ],
    connections: [
        [SystemTray, (box, id) => box._onAdded(box, id), 'added'],
        [SystemTray, (box, id) => box._onRemoved(box, id), 'removed'],
    ],
});
