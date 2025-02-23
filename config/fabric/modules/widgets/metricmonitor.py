from fabric import Fabricator
from modules.widgets.circularprogressbar import MyCircularProgressBar

WIDGET_SIZE = 22


# TODO: -> Make it a widget
class MetricMonitor:
    def __init__(
        self,
        name: str,
        poll_from,
        interval: int = 1000,
        stream=False,
        style_classes=None,
        initial_value=0.1,
        tooltip_text=None,
        child=None,
        size=WIDGET_SIZE,
    ):
        self.name = name
        self.tooltip_text = tooltip_text
        self.widget = MyCircularProgressBar(
            # pie=True,
            size=size,
            line_width=1,
            name=name,
            style_classes=style_classes,
            value=initial_value / 100,
            line_style="round",
            tooltip_text=f"{tooltip_text} ({initial_value:.2f})",
            child=child,
            start_at=0.4,
            end_at=0.1,
            inverted=True,
        )
        self.widget.START_ANGLE = 0.5
        self.fabricator = Fabricator(
            poll_from=poll_from,
            interval=interval,
            stream=stream,
        )
        self.fabricator.connect("changed", self.update_widget)

    def update_widget(self, fabricator, value):
        if value:
            self.widget.value = value / 100
        else:
            self.widget.value = 0

        self.widget.set_property(
            "tooltip_text",
            f"{self.tooltip_text} ({value:.2f})",
        )

    def get_widget(self):
        return self.widget
