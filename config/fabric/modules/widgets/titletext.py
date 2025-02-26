from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from fabric.widgets.revealer import Revealer


class TitleText(Button):
    def __init__(
        self,
        title,
        title_class="",
        text="",
        text_class="",
        box_class="",
        button_css="",
        button_class="",
        # transition_duration=300,
        homogeneous=False,
        title_truncate="none",
        text_truncate="none",
        vertical=True,
        spacing=0,
        on_hover=None,
        on_hover_lost=None,
        on_clicked=None,
        title_widget=None,
        text_widget=None,
        title_h_align="center",
        title_v_align="center",
        text_h_align="center",
        text_v_align="center",
        **kwarga,
    ):
        # Define title label
        _title = Label(
            label=title,
            style_classes=title_class,
            h_align=title_h_align,
            v_align=title_v_align,
            ellipsization=title_truncate,
        )

        # Define text label
        _text = Label(
            label=text,
            style_classes=text_class,
            h_align=text_h_align,
            v_align=text_v_align,
            ellipsization=text_truncate,
        )

        # Define the box
        box = Box(
            spacing=spacing,
            orientation="vertical" if vertical else "horizontal",
            children=[
                title_widget or _title,
                text_widget or _text,
            ],
            style_classes=box_class,
        )
        box.homogeneous = homogeneous

        super().__init__(
            child=box,
            style=button_css,
            style_classes=button_class,
            **kwarga,
        )

        # Connect events
        if on_hover:
            self.connect("enter-notify-event", lambda btn, _: on_hover(btn))

        if on_hover_lost:
            self.connect(
                "leave-notify-event", lambda btn, _: on_hover_lost(btn)
            )

        if on_clicked:
            self.connect("clicked", lambda btn: on_clicked(btn))


class TitleTextRevealer(Button):
    def __init__(
        self,
        title,
        title_class="",
        text="",
        text_class="",
        box_class="",
        button_css="",
        button_class="",
        revealer_class="",
        transition_duration=300,
        homogeneous=False,
        title_truncate="none",
        text_truncate="none",
        vertical=True,
        spacing=0,
        on_hover=None,
        on_hover_lost=None,
        on_clicked=None,
        title_widget=None,
        text_widget=None,
        title_h_align="center",
        title_v_align="center",
        text_h_align="center",
        text_v_align="center",
        **kwarga,
    ):
        # Define title label
        _title = Label(
            label=title,
            style_classes=title_class,
            h_align=title_h_align,
            v_align=title_v_align,
            ellipsization=title_truncate,
        )

        # Define text label
        _text = Label(
            label=text,
            style_classes=text_class,
            h_align=text_h_align,
            v_align=text_v_align,
            ellipsization=text_truncate,
        )

        # Define the revealer widget
        revealed_text = Revealer(
            child=text_widget if text_widget else _text,
            child_revealed=False,
            transition_type="slide-down" if vertical else "slide-left",
            transition_duration=transition_duration,
            style_classes=revealer_class,
        )

        # Define the box
        box = Box(
            spacing=spacing,
            orientation="vertical" if vertical else "horizontal",
            children=[
                title_widget if title_widget else _title,
                revealed_text,
            ],
            style_classes=box_class,
        )
        box.homogeneous = homogeneous

        super().__init__(
            child=box,
            style=button_css,
            style_classes=button_class,
            **kwarga,
        )

        # Connect events
        if on_hover:
            self.connect("enter-notify-event", lambda btn, _: on_hover(btn))

        if on_hover_lost:
            self.connect(
                "leave-notify-event", lambda btn, _: on_hover_lost(btn)
            )

        if on_clicked:
            self.connect("clicked", lambda btn: on_clicked(btn))
