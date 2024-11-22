import socket
import subprocess

import psutil

from fabric import Fabricator
from fabric.widgets.box import Box
from fabric.widgets.eventbox import EventBox
from fabric.widgets.label import Label


class NetworkBarWidget:
    _old_value = None

    def __init__(self, interval=1000):
        self.name = "network-widget"
        self.interval = interval
        self.interface = self.get_active_interface()
        self.current_ssid = self.get_network_ssid()

        self.ssid_label = Label(label=self.current_ssid, style="font-weight: bold;")
        self.meter = self.create_speed_meter()
        self.widget = EventBox(child=Box(children=[self.ssid_label, self.meter]))
        self.widget.connect("button-press-event", self.on_click)

        self.fabricator = Fabricator(self.get_network_speed, interval=interval)
        self.fabricator.connect("changed", self.update_widget)

    def on_click(self, *_):
        print("Test message: Network widget clicked!")

    def get_network_ssid(self):
        if not self.interface:
            return "No Network"
        try:
            return (
                subprocess.check_output(["iwgetid", "-r"], encoding="utf-8").strip()
                or "No Network"
            )
        except (FileNotFoundError, subprocess.SubprocessError):
            pass
        try:
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"], encoding="utf-8"
            ).strip()
            for line in output.split("\n"):
                if line.startswith("yes:"):
                    return line.split(":")[1]
        except (FileNotFoundError, subprocess.SubprocessError):
            pass
        return "No Network"

    def create_speed_meter(self):
        return Box(
            children=[
                Label(label="↓", style="color: green;", justification="left"),
                Label(
                    justification="right", style="min-width: 60px;margin-left:0.3rem"
                ),
                Label(label="↑", style="color: red;", justification="left"),
                Label(justification="right", style="min-width: 60px"),
            ]
        )

    def get_active_interface(self):
        for interface, addrs in psutil.net_if_addrs().items():
            for addr in addrs:
                if addr.family == socket.AF_INET and not addr.address.startswith(
                    "127."
                ):
                    return interface
        return None

    def get_network_speed(self):
        return psutil.net_io_counters(pernic=True).get(self.interface)

    def update_widget(self, _, value):
        if not value or not self.interface:
            self.update_labels(0, 0, "No Network")
            return

        download_speed = (
            value.bytes_recv - (self._old_value.bytes_recv if self._old_value else 0)
        ) / self.interval
        upload_speed = (
            value.bytes_sent - (self._old_value.bytes_sent if self._old_value else 0)
        ) / self.interval
        self._old_value = value

        self.update_labels(download_speed, upload_speed, self.current_ssid)

        if not self.current_ssid:
            self.current_ssid = self.get_network_ssid()
            self.ssid_label.set_property("label", f"SSID: {self.current_ssid}")

    def update_labels(self, download_speed, upload_speed, ssid):
        dn, up = self.meter.children[1], self.meter.children[3]
        dn.set_property("label", f"{download_speed / 1024:.3f} MB/s")
        up.set_property("label", f"{upload_speed / 1024:.3f} MB/s")
        self.ssid_label.set_property("label", ssid)

    def get_widget(self):
        return self.widget
