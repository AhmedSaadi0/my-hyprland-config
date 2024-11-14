from bar.bar import StatusBar
from fabric import Application
from fabric.utils import get_relative_path

if __name__ == "__main__":
    bar = StatusBar()
    app = Application("bar", bar)
    app.set_stylesheet_from_file(get_relative_path("bar.css"))

    app.run()
