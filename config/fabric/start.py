import psutil

from fabric import Application
from modules.bar.topbar import TopBar
from modules.menu.main import MainMenu
from modules.services.prayer_times import PrayerTimesService
from modules.services.theme import ThemeService

prayer_service = PrayerTimesService(city="Sanaa", country="Yemen")


battery = psutil.sensors_battery()
if battery:
    print(f"Battery percentage: {battery.percent}%")
    print(f"Charging: {'Yes' if battery.power_plugged else 'No'}")
else:
    print("Battery information not available.")


if __name__ == "__main__":
    app = Application()
    theme_service = ThemeService(app)
    menu = MainMenu()
    topbar = TopBar(theme_service=theme_service, menu=menu)

    app.add_window(topbar)
    app.add_window(menu)

    app.run()
