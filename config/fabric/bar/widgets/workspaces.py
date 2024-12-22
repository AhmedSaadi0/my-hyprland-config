from fabric.hyprland.widgets import WorkspaceButton, Workspaces
from fabric.utils import FormattedString
from fabric.widgets.box import Box


class CustomWorkspaceButton(WorkspaceButton):

    def __init__(self, active_label: str, inactive_label: str, **kwargs):
        self._inactive_label: FormattedString = FormattedString(inactive_label)
        super().__init__(label=active_label, **kwargs)

    def do_bake_label(self):
        label = self._label if self.active else self._inactive_label
        self.set_label(label.format(button=self))


class WorkspaceBox(Box):

    def __init__(
        self,
        name: str = "workspaces",
        orientation: str = "h",
        spacing: int = 8,
    ):
        super().__init__(orientation=orientation)
        self.workspaces = self._create_workspaces(name, orientation, spacing)
        self.add(self.workspaces)

    @staticmethod
    def _create_workspaces(name: str, orientation: str, spacing: int) -> Workspaces:
        inactive_icons = ["", "󰿤", "󰂕", "󰉖", "󱙌", "󰆉", "󱍚", "󰺶", "󱋢", "󰤑"]
        active_icons = ["󰋜", "󰿣", "󰂔", "󰉋", "󱙋", "󰆈", "󱍙", "󰺵", "󱋡", "󰙨"]

        buttons = [
            CustomWorkspaceButton(
                id=index + 1,
                active_label=active_icons[index],
                inactive_label=inactive_icons[index],
            )
            for index in range(10)
        ]

        return Workspaces(
            name=name,
            orientation=orientation,
            spacing=spacing,
            invert_scroll=True,
            empty_scroll=True,
            buttons=buttons,
        )
