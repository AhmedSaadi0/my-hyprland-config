from fabric.widgets.box import Box
from fabric.widgets.button import Button
from modules.services.power_profile import (
    BALANCED,
    PERFORMANCE,
    POWER_SAVER,
    PowerProfile,
)
from modules.utils.strings import get_string
from modules.widgets.titletext import TitleText


class PowerProfileWidget(Box):
    def change_css_class(self, emitter):
        active_profile = emitter.active_profile

        if active_profile == PERFORMANCE:
            self.buttons_row.children[0].set_property(
                "style_classes", "active-power-profiles"
            )
            self.buttons_row.children[1].set_property("style_classes", "theme-btn")
            self.buttons_row.children[2].set_property("style_classes", "theme-btn")
        elif active_profile == BALANCED:
            self.buttons_row.children[0].set_property("style_classes", "theme-btn")
            self.buttons_row.children[1].set_property(
                "style_classes", "active-power-profiles"
            )
            self.buttons_row.children[2].set_property("style_classes", "theme-btn")
        elif active_profile == POWER_SAVER:
            self.buttons_row.children[0].set_property("style_classes", "theme-btn")
            self.buttons_row.children[1].set_property("style_classes", "theme-btn")
            self.buttons_row.children[2].set_property(
                "style_classes", "active-power-profiles"
            )

    def __init__(self, **kwargs):
        super().__init__(
            style="margin-bottom: 1rem;",
            style_classes="power-profile-box",
            orientation="v",
            **kwargs,
        )

        # Create title and buttons row
        self.title = self.create_title()
        self.buttons_row = self.create_buttons_row()
        self.power_profiles_service = PowerProfile()

        # Add widgets to the box
        self.children = [self.title, self.buttons_row]

        self.power_profiles_service.connect("changed", self.change_css_class)
        self.change_css_class(self.power_profiles_service)

    @staticmethod
    def create_title():
        return TitleText(
            title="󰎓",
            text=get_string("power_profile"),
            text_class="themes-buttons-title",
            title_class="themes-buttons-icon",
            button_class="unset",
            vertical=False,
            title_y_align=0,
            text_y_align=0,
        )

    def create_buttons_row(self):
        high_performance = Button(
            style_classes="theme-btn",
            style="min-height: 1.5rem; border-radius: 1rem;",
            label=get_string("high_performance"),
            on_clicked=lambda _: self.power_profiles_service.switch_to_performance(),
        )

        normal_performance = Button(
            style_classes="theme-btn",
            style="min-height: 1.5rem; border-radius: 1rem;",
            label=get_string("balanced"),
            on_clicked=lambda _: self.power_profiles_service.switch_to_balanced(),
        )

        low_performance = Button(
            style_classes="theme-btn",
            style="min-height: 1.5rem; border-radius: 1rem;",
            label=get_string("power_saver"),
            on_clicked=lambda _: self.power_profiles_service.switch_to_power_saver(),
        )

        return Box(
            spacing=15,
            children=[high_performance, normal_performance, low_performance],
            h_align="center",
            v_align="center",
        )

    def update_button_classes(self, _):
        """
        Update the button classes based on the active power profile.
        """
        buttons = self.buttons_row.children
        for button in buttons:
            button.style_classes = "theme-btn"

        if self.power_profiles_service.active_profile == "performance":
            buttons[0].style_classes = (
                "power-profiles-box-btn power-profiles-box-btn-active"
            )
        elif self.power_profiles_service.active_profile == "balanced":
            buttons[1].style_classes = (
                "power-profiles-box-btn power-profiles-box-btn-active"
            )
        elif self.power_profiles_service.active_profile == "power-saver":
            buttons[2].style_classes = (
                "power-profiles-box-btn power-profiles-box-btn-active"
            )
