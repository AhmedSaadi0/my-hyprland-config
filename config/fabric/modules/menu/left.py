"""side panel example, contains info about the system"""

import os

from loguru import logger

from fabric.widgets.box import Box
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from fabric.widgets.stack import Stack
from fabric.widgets.wayland import WaylandWindow as Window
from modules.helper import TitleTextRevealer


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
    """Represents a left menu with profile and navigation tabs."""

    SHARED_TAB_ATTRS = {
        "spacing": 2,
        "vertical": False,
        "button_class": "topbar-button",
        "on_hover": None,
        "on_hover_lost": None,
        "title_class": "topbar-button-icon",
        "text_class": "topbar-button-text",
    }

    PROFILE_IMAGE = "/home/ahmed/wallpapers/profile.png"
    BACKGROUND_IMAGE = "/home/ahmed/wallpapers/dark/win20.png"

    def __init__(self, **kwargs):
        super().__init__(
            layer="overlay",
            title="left-menu",
            anchor="top left",
            margin="0px 7px 7px",
            style_classes="left-menu",
            **kwargs,
        )
        self.selected_tab = None
        self.tab_stack_map = {}  # Mapping of tabs to stack page names
        self.stack = None
        self.build_ui()

    def build_ui(self):
        """Builds the complete UI for the LeftMenu."""
        # Initialize the stack
        self.stack = Stack(transition_type="slide-left-right", transition_duration=300)

        # Define tabs and corresponding stack pages
        tab_definitions = [
            {
                "title": "󰨝",
                "text": "التحكم",
                "stack_name": "control",
                "stack": Label(label=f"Content for 1"),
            },
            {
                "title": "󰂞",
                "text": "اشعارات",
                "stack_name": "notifications",
                "stack": Label(label=f"Content for 2"),
            },
            {
                "title": "󰖐",
                "text": "الطقس",
                "stack_name": "weather",
                "stack": Label(label=f"Content for 3"),
            },
            {
                "title": "",
                "text": "مؤشرات",
                "stack_name": "monitors",
                "stack": Label(label=f"Content for 4"),
            },
            {
                "title": "",
                "text": "الشبكة",
                "stack_name": "network",
                "stack": Label(label=f"Content for 5"),
            },
        ]

        tabs = []
        for tab_def in tab_definitions:
            # Create tab button
            tab = self.create_topbar_icon(
                tab_def["title"], tab_def["text"], self.reveal_tab
            )
            tabs.append(tab)

            # Create corresponding stack page
            stack_page = tab_def["stack"]
            self.stack.add_named(stack_page, tab_def["stack_name"])

            # Map tab to stack page name
            self.tab_stack_map[tab] = tab_def["stack_name"]

        # Add everything to the UI
        self.add(
            Box(
                name="window-inner",
                orientation="v",
                children=[
                    self.create_header_background(),
                    self.create_header_profile(),
                    self.create_topbar(children=tabs),
                    self.stack,
                ],
            ),
        )

        # Show the first tab by default
        self.reveal_tab(tabs[0])
        self.show_all()

    @staticmethod
    def create_header_background():
        """Creates the header background box."""
        return Box(
            style=f'background-image: url("{LeftMenu.BACKGROUND_IMAGE}");',
            style_classes="left-menu-header-background",
            orientation="v",
        )

    @staticmethod
    def create_header_profile():
        """Creates the profile section in the header."""
        return Box(
            style_classes="left-menu-header-profile",
            orientation="v",
            size=70,
            spacing=0,
            children=[
                Image(
                    image_file=LeftMenu.PROFILE_IMAGE,
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

    @staticmethod
    def create_topbar_icon(title, text, on_clicked):
        """Creates an individual topbar icon."""
        return TitleTextRevealer(
            title=title,
            text=text,
            on_clicked=on_clicked,
            **LeftMenu.SHARED_TAB_ATTRS,
        )

    @staticmethod
    def create_topbar(children):
        """Creates the topbar containing navigation icons."""
        return Box(
            style_classes="topbar-icons-box",
            children=children,
        )

    def reveal_tab(self, selected_tab):
        """Reveals the selected tab and switches to its associated stack page."""
        if selected_tab == self.selected_tab:
            return

        # Highlight the new tab
        selected_tab.children[0].children[1].reveal()
        selected_tab.style_classes = "topbar-button-selected small-shadow"

        # Switch the stack page
        stack_name = self.tab_stack_map.get(selected_tab)
        if stack_name:
            self.stack.set_visible_child_name(stack_name)

        # Unhighlight the previous tab
        if self.selected_tab:
            self.selected_tab.children[0].children[1].unreveal()
            self.selected_tab.style_classes = "topbar-button"

        self.selected_tab = selected_tab
