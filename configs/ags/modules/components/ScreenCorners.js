import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Gtk from 'gi://Gtk';

/**
 * @param {string} place
 */
export const RoundedCorner = (place, props) =>
  Widget.DrawingArea({
    ...props,
    hpack: place.includes('left') ? 'start' : 'end',
    vpack: place.includes('top') ? 'start' : 'end',
    setup: (widget) => {
      const r = 25; //widget.get_style_context().get_property('border-radius', Gtk.StateFlags.NORMAL);
      widget.set_size_request(r, r);
      widget.on('draw', (widget, cr) => {
        const c = widget
          .get_style_context()
          .get_property('background-color', Gtk.StateFlags.NORMAL);
        const r = widget
          .get_style_context()
          .get_property('border-radius', Gtk.StateFlags.NORMAL);
        widget.set_size_request(r, r);

        switch (place) {
          case 'topleft':
            cr.arc(r, r, r, Math.PI, (3 * Math.PI) / 2);
            cr.lineTo(0, 0);
            break;
          case 'topright':
            cr.arc(0, r, r, (3 * Math.PI) / 2, 2 * Math.PI);
            cr.lineTo(r, 0);
            break;
          case 'bottomleft':
            cr.arc(r, 0, r, Math.PI / 2, Math.PI);
            cr.lineTo(0, r);
            break;
          case 'bottomright':
            cr.arc(0, 0, r, 0, Math.PI / 2);
            cr.lineTo(r, r);
            break;
        }

        cr.closePath();
        cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha);
        cr.fill();
      });
    },
  });

/**
 * @param {string} place
 */
export const RoundedAngleEnd = (place, props) =>
  Widget.DrawingArea({
    ...props,
    setup: (widget) => {
      const ratio = 1.5;
      const r = widget.get_allocated_height();
      widget.set_size_request(ratio * r, r);
      widget.on('draw', (widget, cr) => {
        const context = widget.get_style_context();
        const c = context.get_property(
          'background-color',
          Gtk.StateFlags.NORMAL
        );
        const border_color = context.get_property(
          'color',
          Gtk.StateFlags.NORMAL
        );
        const border_width = context.get_border(Gtk.StateFlags.NORMAL).bottom;
        const r = widget.get_allocated_height();
        widget.set_size_request(ratio * r, r);
        switch (place) {
          case 'topleft':
            cr.moveTo(0, 0);
            cr.curveTo((ratio * r) / 2, 0, (ratio * r) / 2, r, ratio * r, r);
            cr.lineTo(ratio * r, 0);

            cr.moveTo(0, 0);
            cr.curveTo((ratio * r) / 2, 0, (ratio * r) / 2, r, ratio * r, r);
            cr.lineTo(ratio * r, 0);
            cr.closePath();
            cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha);
            cr.fillPreserve();
            cr.clip();
            cr.moveTo(0, 0);
            cr.curveTo((ratio * r) / 2, 0, (ratio * r) / 2, r, ratio * r, r);
            cr.setLineWidth(border_width * 2);
            cr.setSourceRGBA(
              border_color.red,
              border_color.green,
              border_color.blue,
              border_color.alpha
            );
            cr.stroke();
            break;

          case 'topright':
            cr.moveTo(ratio * r, 0);
            cr.curveTo((ratio * r) / 2, 0, (ratio * r) / 2, r, 0, r);
            cr.lineTo(0, 0);
            cr.closePath();
            cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha);
            cr.fillPreserve();
            cr.clip();
            cr.moveTo(ratio * r, 0);
            cr.curveTo((ratio * r) / 2, 0, (ratio * r) / 2, r, 0, r);
            cr.setLineWidth(border_width * 2);
            cr.setSourceRGBA(
              border_color.red,
              border_color.green,
              border_color.blue,
              border_color.alpha
            );
            cr.stroke();
            break;
        }

        // cr.setLineWidth(border_width);
        // cr.setSourceRGBA(border_color.red, border_color.green, border_color.blue, border_color.alpha);
      });
    },
  });

export const CornerTopleft = () =>
  Widget.Window({
    name: 'cornertl',
    layer: 'top',
    anchor: ['top', 'left'],
    exclusivity: 'normal',
    visible: true,
    child: RoundedCorner('topleft', { className: 'corner' }),
  });
export const CornerTopright = () =>
  Widget.Window({
    name: 'cornertr',
    layer: 'top',
    anchor: ['top', 'right'],
    exclusivity: 'normal',
    visible: true,
    child: RoundedCorner('topright', { className: 'corner' }),
  });
export const CornerBottomleft = () =>
  Widget.Window({
    name: 'cornerbl',
    layer: 'top',
    anchor: ['bottom', 'left'],
    exclusivity: 'normal',
    visible: true,
    child: RoundedCorner('bottomleft', { className: 'corner' }),
  });
export const CornerBottomright = () =>
  Widget.Window({
    name: 'cornerbr',
    layer: 'top',
    anchor: ['bottom', 'right'],
    exclusivity: 'normal',
    visible: true,
    child: RoundedCorner('bottomright', { className: 'corner' }),
  });

export default RoundedCorner;
