from fabric.widgets.box import Box
from fabric.widgets.label import Label

from ...services.prayer_times import PrayerTimesService


class PrayerTimeDisplay:
    def __init__(self, city: str, country: str):
        self.prayer_time_label = Label(label="")
        self.container = Box(orientation="h", children=[self.prayer_time_label])
        self.prayer_service = PrayerTimesService(city=city, country=country)
        self.update_ui()
        self.prayer_service.connect("changed", self.update_ui)

    def update_ui(self, *_args):
        """Update the label with current and next prayer times."""
        self.prayer_time_label.set_property(
            "label",
            self.prayer_service.next_prayer_name,
        )

    def get_widget(self):
        """Expose the container for embedding into a larger UI."""
        return self.container
