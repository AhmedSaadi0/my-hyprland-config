from fabric.widgets.box import Box
from fabric.widgets.button import Button
from modules.utils.helper import TitleText
from modules.utils.strings import strings


class PowerProfileWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(
            style="margin-bottom: 1rem;",
            style_classes="left-menu-insider-box",
            vertical=True,
            **kwargs,
        )

        # Create title and buttons row
        self.title = self.create_title()
        self.buttons_row = self.create_buttons_row()

        # Add widgets to the box
        self.add_children([self.title, self.buttons_row])

    @staticmethod
    def create_title():
        """
        Create the title widget.
        """
        return TitleText(
            title="󰎓",
            title_class="themes-buttons-icon",
            text=strings.power_profile,
            text_class="themes-buttons-title",
            vertical=False,
            title_y_align=0,
            text_y_align=0,
        )

    def create_buttons_row(self):
        high_performance = Button(
            style_classes="theme-btn",
            style="min-height: 2rem; border-radius: 1rem;",
            label=strings.high_performance,
            on_clicked=lambda _: setattr(
                self.power_profiles_service, "active_profile", "performance"
            ),
        )

        normal_performance = Button(
            style_classes="theme-btn",
            style="min-height: 2rem; border-radius: 1rem;",
            label=strings.balanced,
            on_clicked=lambda _: setattr(
                self.power_profiles_service, "active_profile", "balanced"
            ),
        )

        low_performance = Button(
            style_classes="theme-btn",
            style="min-height: 2rem; border-radius: 1rem;",
            label=strings.power_saver,
            on_clicked=lambda _: setattr(
                self.power_profiles_service, "active_profile", "power-saver"
            ),
        )

        return Box(
            homogeneous=True,
            spacing=15,
            children=[high_performance, normal_performance, low_performance],
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
