import os

import sass

from fabric import Application
from fabric.utils import get_relative_path
from modules.bar.bar import StatusBar
from modules.services.prayer_times import PrayerTimesService

prayer_service = PrayerTimesService(city="Sanaa", country="Yemen")


def compile_scss_to_css(scss_file: str, css_file: str):
    try:
        with open(scss_file, "r") as scss:
            compiled_css = sass.compile(string=scss.read())
        with open(css_file, "w") as css:
            css.write(compiled_css)
        print(f"Compiled {scss_file} to {css_file}")
    except FileNotFoundError:
        print(f"Error: {scss_file} not found.")
        exit(1)
    except sass.CompileError as e:
        print(f"Error compiling SCSS: {e}")
        exit(1)


if __name__ == "__main__":
    bar = StatusBar()
    app = Application("bar", bar)

    scss_path = get_relative_path("scss/main.scss")
    css_path = get_relative_path("main.css")

    if os.path.exists(scss_path):
        compile_scss_to_css(scss_path, css_path)
    else:
        print(f"Error: {scss_path} not found.")
        exit(1)

    app.set_stylesheet_from_file(css_path)

    app.run()


def on_prayer_changed():
    print(
        f"Next prayer: {prayer_service.next_prayer_name} at {prayer_service.next_prayer_time}"
    )
    if prayer_service.prayer_now:
        print(f"Prayer now: {prayer_service.prayer_now}")


prayer_service.connect("changed", on_prayer_changed)
