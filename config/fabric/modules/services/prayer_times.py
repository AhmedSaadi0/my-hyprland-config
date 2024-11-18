import threading
from datetime import datetime

import requests

from fabric import Service
from fabric.core.service import Property, Signal


class PrayerTimesService(Service):
    @Signal
    def changed(self) -> None:
        """Emitted when prayer times or other properties change."""

    @Property(str, "readable")
    def next_prayer_name(self) -> str:
        return self._next_prayer_name

    @Property(str, "readable")
    def next_prayer_time(self) -> str:
        return self._next_prayer_time

    @Property(str, "readable")
    def prayer_now(self) -> str:
        return self._prayer_now

    @Property(str, "readable")
    def hijri_date(self) -> str:
        return self._hijri_date

    def __init__(self, city: str, country: str, interval: int = 3600, **kwargs):
        super().__init__(**kwargs)
        self.city = city
        self.country = country
        self.polling_interval = interval
        self._next_prayer_name = ""
        self._next_prayer_time = ""
        self._prayer_now = None
        self._hijri_date = ""
        self.state = {}
        self._polling_timer = None  # Timer for periodic updates
        self.start_polling()

    def start_polling(self):
        """Start periodic fetching of prayer times."""
        self.update_prayer_times()
        self._schedule_next_update(self.polling_interval)

    def _schedule_next_update(self, delay: int):
        """Schedule the next update using a timer."""
        if self._polling_timer:
            self._polling_timer.cancel()  # Cancel any existing timer
        self._polling_timer = threading.Timer(delay, self.update_prayer_times)
        self._polling_timer.start()

    def update_prayer_times(self):
        """Fetch prayer times from the API."""
        try:
            current_date = datetime.now().strftime("%d-%m-%Y")
            url = f"https://api.aladhan.com/v1/timingsByCity/{current_date}?city={self.city}&country={self.country}"
            response = requests.get(url)
            response.raise_for_status()
            self.state = response.json()
            self._process_prayer_times()
            self.emit("changed")
            print(self.state)
        except Exception as e:
            print(f"Error fetching prayer times: {e}")
            # Retry after 15 minutes on failure
            self._schedule_next_update(15 * 60)

    def _process_prayer_times(self):
        """Process fetched prayer times and calculate the next prayer."""
        timings = self.state.get("data", {}).get("timings", {})
        hijri_date = (
            self.state.get("data", {}).get("date", {}).get("hijri", {}).get("date", "")
        )

        self._hijri_date = hijri_date
        now = datetime.now()
        next_prayer = None

        for prayer, time in timings.items():
            prayer_time = self._parse_time(time)
            if now < prayer_time:
                next_prayer = (prayer, prayer_time)
                break

        if next_prayer:
            self._next_prayer_name = next_prayer[0]
            self._next_prayer_time = next_prayer[1].strftime("%H:%M")
            self._set_notification(now, next_prayer[1], next_prayer[0])

    def _set_notification(self, now: datetime, prayer_time: datetime, prayer_name: str):
        """Set a timer to notify when the next prayer starts."""
        time_until_prayer = (prayer_time - now).total_seconds()
        threading.Timer(
            time_until_prayer, lambda: self._notify_prayer(prayer_name)
        ).start()

    def _notify_prayer(self, prayer_name: str):
        """Send a notification for the current prayer."""
        self._prayer_now = prayer_name
        self.emit("changed")
        # Clear prayer after 20 minutes
        threading.Timer(20 * 60, self._clear_current_prayer).start()

    def _clear_current_prayer(self):
        """Clear the current prayer."""
        self._prayer_now = None
        self.emit("changed")

    def _parse_time(self, time_str: str) -> datetime:
        """Convert a time string (HH:MM) to a datetime object."""
        hours, minutes = map(int, time_str.split(":"))
        now = datetime.now()
        return now.replace(hour=hours, minute=minutes, second=0, microsecond=0)
