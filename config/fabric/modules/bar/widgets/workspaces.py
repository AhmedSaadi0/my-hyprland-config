import json

from fabric.hyprland.service import HyprlandEvent
from fabric.hyprland.widgets import WorkspaceButton, Workspaces
from fabric.utils import FormattedString
from fabric.widgets.box import Box


class CustomWorkspaceButton(WorkspaceButton):

    def __init__(self, active_label: str, inactive_label: str, **kwargs):
        self._inactive_label: FormattedString = FormattedString(inactive_label)
        super().__init__(label=active_label, **kwargs)

    def do_bake_label(self):
        label = self._label if self.active else self._inactive_label
        self.style_classes = ""
        if not self.empty:
            self.style_classes = "has-windows"
        self.set_label(label.format(button=self))


class CustomWorkspaces(Workspaces):
    def on_workspace(self, _, event: HyprlandEvent):
        if len(event.data) < 1:
            return

        active_workspace = int(event.data[0])
        if active_workspace == self._active_workspace:
            return

        if self._active_workspace is not None and (
            old_btn := self._buttons.get(self._active_workspace)
        ):
            old_btn.active = False

        self._active_workspace = active_workspace
        if not (btn := self.lookup_or_bake_button(active_workspace)):
            return

        btn.urgent = False
        btn.active = True

        return

    def on_ready(self, _):
        open_workspaces: tuple[int, ...] = tuple(
            workspace["id"]
            for workspace in json.loads(
                str(
                    self.connection.send_command("j/workspaces").reply.decode()
                )
            )
        )
        self._active_workspace = json.loads(
            str(
                self.connection.send_command(
                    "j/activeworkspace"
                ).reply.decode()
            )
        )["id"]

        for btn in self._buttons_preset:
            self.insert_button(btn)

        for id in open_workspaces:
            if id > 10:
                return
            if not (btn := self.lookup_or_bake_button(id)):
                continue

            btn.empty = False
            if id == self._active_workspace:
                btn.active = True

            if btn in self._buttons_preset:
                continue

            self.insert_button(btn)
        return

    def on_createworkspace(self, _, event: HyprlandEvent):
        button = self._buttons.get(int(event.data[0]))

        if button:
            button.style_classes = "has-windows"

    def on_destroyworkspace(self, _, event: HyprlandEvent):
        button = self._buttons.get(int(event.data[0]))
        if button:
            button.style_classes = ""


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
    def _create_workspaces(
        name: str, orientation: str, spacing: int
    ) -> Workspaces:
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

        # print(buttons.sort)

        workspaces = CustomWorkspaces(
            name=name,
            orientation=orientation,
            spacing=spacing,
            # invert_scroll=True,
            # empty_scroll=True,
            buttons=buttons,
            style_classes=["icon-font", "workspaces"],
        )
        return workspaces
