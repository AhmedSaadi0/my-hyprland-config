import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GObject, Gdk, cairo

class CircProg(Gtk.DrawingArea):
    def __init__(self):
        super().__init__()
        self.start_at = 0.0
        self.value = 0.0
        self.thickness = 1.0
        self.clockwise = True
        self.label_text = "Hello, World!"

    def do_draw(self, cr):
        def perc_to_rad(n):
            return (n / 100.0) * 2.0 * 3.14159265359

        value = self.value
        start_at = self.start_at
        thickness = self.thickness
        clockwise = self.clockwise

        styles = self.get_style_context()
        fg_color = styles.get_color(Gtk.StateFlags.NORMAL)
        bg_color = styles.get_background_color(Gtk.StateFlags.NORMAL)

        start_angle = 0.0
        end_angle = 0.0

        if clockwise:
            start_angle = 0.0
            end_angle = perc_to_rad(value)
        else:
            start_angle = perc_to_rad(100.0 - value)
            end_angle = 2.0 * 3.14159265359

        width = self.get_allocated_width()
        height = self.get_allocated_height()
        center = (width / 2.0, height / 2.0)

        circle_width = width
        circle_height = height
        outer_ring = min(circle_width, circle_height) / 2.0
        inner_ring = min(circle_width, circle_height) / 2.0 - thickness

        cr.save()

        cr.translate(center[0], center[1])
        cr.rotate(perc_to_rad(start_at))
        cr.translate(-center[0], -center[1])

        cr.move_to(center[0], center[1])
        cr.arc(center[0], center[1], outer_ring, 0.0, perc_to_rad(100.0))
        cr.set_source_rgba(bg_color.red, bg_color.green, bg_color.blue, bg_color.alpha)
        cr.move_to(center[0], center[1])
        cr.arc(center[0], center[1], inner_ring, 0.0, perc_to_rad(100.0))
        cr.set_fill_rule(cairo.FillRule.EVEN_ODD)
        cr.fill()

        cr.move_to(center[0], center[1])
        cr.arc(center[0], center[1], outer_ring, start_angle, end_angle)
        cr.set_source_rgba(fg_color.red, fg_color.green, fg_color.blue, fg_color.alpha)
        cr.move_to(center[0], center[1])
        cr.arc(center[0], center[1], inner_ring, start_angle, end_angle)
        cr.set_fill_rule(cairo.FillRule.EVEN_ODD)
        cr.fill()
        cr.restore()

        # Render text
        layout = cr.create_layout()
        layout.set_text(self.label_text)
        layout.set_alignment(0.5, 0.5)  # Center alignment
        layout.set_width(int(width))
        layout.set_height(int(height))

        cr.set_source_rgba(0, 0, 0, 1)  # Text color
        cr.move_to((width - layout.get_pixel_size()[0]) / 2.0, (height - layout.get_pixel_size()[1]) / 2.0)
        cr.show_layout(layout)

GObject.type_register(CircProg)

if __name__ == "__main__":
    win = Gtk.Window()
    win.connect("destroy", Gtk.main_quit)

    circ_prog = CircProg()
    circ_prog.set_size_request(200, 200)
    circ_prog.start_at = 0.0
    circ_prog.value = 75.0
    circ_prog.thickness = 20.0
    circ_prog.label_text = "Hello, World!"

    win.add(circ_prog)
    win.show_all()

    Gtk.main()
