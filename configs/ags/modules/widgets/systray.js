const { Gravity } = imports.gi.Gdk;
import { SystemTray, Widget } from '../utils/imports.js';

const PanelButton = ({ className, content, ...rest }) =>
  Widget.Button({
    className: `panel-button ${className} unset`,
    child: Widget.Box({ children: [content] }),
    ...rest,
  });

const SysTrayItem = (item) =>
  PanelButton({
    className: 'tray-btn unset',
    content: Widget.Icon().bind('icon', item, 'icon'),
    setup: (btn) => {
      const id = item.menu.connect('popped-up', (menu) => {
        btn.toggleClassName('active');
        menu.connect('notify::visible', (menu) => {
          btn.toggleClassName('active', menu.visible);
        });
        menu.disconnect(id);
      });
    },
    onPrimaryClick: (_, event) => {
      item.activate(event).catch(print);
    },
    onSecondaryClick: (btn) =>
      item.menu.popup_at_widget(btn, Gravity.SOUTH, Gravity.NORTH, null),
  });

export const SysTrayBox = () =>
  Widget.Box({
    className: 'systray unset',
    attribute: {
      items: new Map(),
      onAdded: (box, id) => {
        const item = SystemTray.getItem(id);
        if (box.attribute.items.has(id) || !item) return;

        const widget = SysTrayItem(item);
        box.attribute.items.set(id, widget);
        box.add(widget);
        box.show_all();
      },
      onRemoved: (box, id) => {
        if (!box.attribute.items.has(id)) return;

        box.attribute.items.get(id).destroy();
        box.attribute.items.delete(id);
      },
    },
  })
    .hook(SystemTray, (box, id) => box.attribute.onAdded(box, id), 'added')
    .hook(SystemTray, (box, id) => box.attribute.onRemoved(box, id), 'removed');
