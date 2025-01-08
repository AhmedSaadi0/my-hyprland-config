"""side panel example, contains info about the system"""

import os

from loguru import logger

from fabric.widgets.box import Box
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from fabric.widgets.wayland import WaylandWindow as Window


def get_profile_picture_path() -> str | None:
    path = os.path.expanduser("~/Pictures/Other/face.jpg")
    if not os.path.exists(path):
        path = os.path.expanduser("~/.face")
    if not os.path.exists(path):
        logger.warning(
            "can't fetch a user profile picture, add a profile picture image at ~/.face or at ~/Pictures/Other/profile.jpg"
        )
        path = None
    return path


class LeftMenu(Window):

    @staticmethod
    def create_header_background():
        return Box(
            style='background-image: url("/home/ahmed/wallpapers/dark/win20.png");',
            style_classes="left-menu-header-background",
            orientation="v",
            size=130,
        )

    @staticmethod
    def create_header_profile():
        return Box(
            style_classes="left-menu-header-profile",
            orientation="v",
            size=70,
            spacing=0,
            children=[
                Image(
                    image_file="/home/ahmed/wallpapers/profile.png",
                    style="margin-top: -6rem; border-radius: 5rem;",
                    size=80,
                ),
                Label(
                    style="margin-top: -2.5rem; font-family: 'VIP Rawy Regular'; font-size: xx-large;",
                    label="Ahmed Alsaadi",
                ),
                Label(
                    style="margin-top: -0.3rem; font-family: 'VIP Rawy Regular'; font-size: large;",
                    label="Software Engineer",
                ),
            ],
        )

    def __init__(self, **kwargs):
        super().__init__(
            layer="overlay",
            title="left-menu",
            anchor="top left",
            margin="0px 7px 7px 7px",
            # exclusivity="none",
            style_classes="left-menu",
            **kwargs,
        )

        self.add(
            Box(
                name="window-inner",
                orientation="v",
                spacing=24,
                children=[
                    self.create_header_background(),
                    self.create_header_profile(),
                    Label(size=100, label="HIIII"),
                ],
            ),
        )
        self.show_all()
