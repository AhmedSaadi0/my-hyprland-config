import gi

from fabric.widgets.label import Label
from fabric.widgets.widget import Widget

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk


class TableGrid(Gtk.Grid, Widget):

    def __init__(
        self,
        headers: list[str] | None = None,
        data: list[list[str]] | None = None,
        spacing: int = 6,
        name: str | None = None,
        visible: bool = True,
        all_visible: bool = False,
        style: str | None = None,
        style_classes: list[str] | str | None = None,
        tooltip_text: str | None = None,
        tooltip_markup: str | None = None,
        h_align: Gtk.Align | None = None,
        v_align: Gtk.Align | None = None,
        h_expand: bool = False,
        v_expand: bool = False,
        size: int | list[int] | None = None,
        header_attrs={},
        body_attrs={},
        **kwargs,
    ):
        Gtk.Grid.__init__(self)
        Widget.__init__(
            self,
            name,
            visible,
            all_visible,
            style,
            style_classes,
            tooltip_text,
            tooltip_markup,
            h_align,
            v_align,
            h_expand,
            v_expand,
            size,
            **kwargs,
        )
        self.set_row_spacing(spacing)
        self.set_column_spacing(spacing)
        # self.set_border_width(10)

        self._header_widgets: list[Gtk.Widget] = []
        self._data_cells: list[list[Gtk.Widget]] = []

        self._header_attrs = header_attrs
        self._body_attrs = body_attrs

        current_row = 0
        self._set_header(current_row, headers)

        # Create the initial data rows.
        if data is not None:
            self._create_data_rows(data, start_row=current_row)
        else:
            # If no data provided, create a default 5x2 table.
            default_data = [
                [f"Row {r+1}, Col {c+1}" for c in range(2)] for r in range(5)
            ]
            self._create_data_rows(default_data, start_row=current_row)

    def _set_header(self, current_row, headers: list[str] | None):
        if headers is not None:
            for col, header in enumerate(headers):
                header_label = Label(label=header, **self._header_attrs)
                self.attach(header_label, col, current_row, 1, 1)
                self._header_widgets.append(header_label)
            current_row += 1

    def _create_data_rows(self, data: list[list[str]], start_row: int) -> None:
        """Helper function to create data rows from a 2D list of strings."""
        current_row = start_row
        for row_data in data:
            row_widgets = []
            for col, cell_text in enumerate(row_data):
                cell_label = Label(label=cell_text, **self._body_attrs)
                self.attach(cell_label, col, current_row, 1, 1)
                row_widgets.append(cell_label)
            self._data_cells.append(row_widgets)
            current_row += 1

    def update_data(self, new_data: list[list[str]]) -> None:
        """
        Updates the table's data with new_data.
        This method removes the old data rows and creates new ones.
        """
        # Remove old data cells from the grid.
        for row in self._data_cells:
            for widget in row:
                self.remove(widget)
        self._data_cells = []

        # Determine the starting row index (after header if exists).
        start_row = 1 if self._header_widgets else 0
        self._create_data_rows(new_data, start_row=start_row)
        self.show_all()
