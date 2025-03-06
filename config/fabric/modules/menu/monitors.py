import time

import gi
import psutil

gi.require_version("Gtk", "3.0")

from fabric import Fabricator
from fabric.widgets.box import Box
from modules.bar.widgets.monitors import (
    BatteryMonitor,
    CPUMonitor,
    RAMMonitor,
    TemperatureMonitor,
)
from modules.utils.strings import get_string
from modules.widgets.circularprogressbar import MyCircularProgressBar
from modules.widgets.table import TableGrid
from modules.widgets.titletext import TitleText


class MonitorsHeaderBox(Box):
    def __init__(self, **kwargs):
        super().__init__(
            # style="margin-bottom: 1rem;",
            style_classes="menu-monitors-box",
            orientation="h",
            spacing=17,
            **kwargs,
        )

        self.cpu_progress = self.create_cpu_progress()
        self.ram_progress = self.create_ram_progress()
        self.battery_progress = self.create_battery_progress()
        self.temp_progress = self.create_temp_progress()
        # self.storage_progresses = self.create_storage_progresses()

        self.children = [
            self.cpu_progress,
            self.ram_progress,
            self.battery_progress,
            self.temp_progress,
            # *self.storage_progresses,
        ]

    def create_cpu_progress(self):
        return TitleText(
            title=get_string("cpu"),
            text_widget=CPUMonitor(
                size=60, style_classes=["menu-cpu"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_ram_progress(self):
        return TitleText(
            title=get_string("ram"),
            text_widget=RAMMonitor(
                size=65, style_classes=["menu-ram"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_battery_progress(self):
        return TitleText(
            title=get_string("battery"),
            text_widget=BatteryMonitor(
                size=65, style_classes=["menu-battery"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_temp_progress(self):
        return TitleText(
            title=get_string("temp"),
            text_widget=TemperatureMonitor(
                size=65, style_classes=["menu-temp"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_storage_progresses(self):
        storage_widgets = []
        partitions = psutil.disk_partitions()
        for partition in partitions:
            try:
                # Create a StorageMonitor for each partition
                storage_monitor = StorageMonitor(
                    mount_point=partition.mountpoint,
                    size=65,
                    style_classes=["menu-storage"],
                )
                # Use the device name as the title (you can adjust this as needed)
                title = partition.device
                storage_widget = TitleText(
                    title=title,
                    text_widget=storage_monitor.get_widget(),
                    button_class="unset",
                    spacing=10,
                )
                storage_widgets.append(storage_widget)
            except Exception as e:
                # Handle potential issues accessing a partition (e.g., permission errors)
                print(f"Error accessing {partition.device}: {e}")
        return storage_widgets


class StorageMonitor:
    def __init__(self, mount_point, size=65, style_classes=None):
        self.mount_point = mount_point
        self.size = size
        self.style_classes = style_classes or []

    def get_usage(self):
        # Returns disk usage info (e.g., percent used)
        return psutil.disk_usage(self.mount_point)

    def get_widget(self):
        usage = self.get_usage()
        return MyCircularProgressBar(
            size=65,
            line_width=1,
            name=self.mount_point,
            value=usage.percent,
            min_value=0,
            max_value=100,
            style_classes=["menu-battery"],
        )


class MonitorsTables(Box):
    def __init__(self, poll_interval=5000, **kwargs):
        super().__init__(
            style="margin-bottom: 1rem;",
            style_classes="menu-monitors-box",
            orientation="h",
            spacing=17,
            **kwargs,
        )

        self.cpu_table = self.create_cpu_table()
        self.ram_table = self.create_ram_table()
        self.children = [self.cpu_table, self.ram_table]

        self.fabricator = Fabricator(
            poll_from=self.get_process_data,
            interval=poll_interval,
        )
        self.fabricator.connect("changed", self.update_widget)

    def create_cpu_table(self):
        table = TableGrid(
            headers=[get_string("cpu"), "%"],
            data=[],
            header_style_classes="table-header",
            row_style_classes="table-row",
            spacing=7,
            body_attrs={
                # "chars_width": 7,
                "max_chars_width": 9,
                "line_wrap": "word-char",
                "ellipsization": "end",
                "justification": "center",
            },
        )
        return table

    def create_ram_table(self):
        table = TableGrid(
            headers=[get_string("ram"), "%"],
            data=[],
            header_style_classes="table-header",
            row_style_classes="table-row",
            spacing=7,
            body_attrs={
                # "chars_width": 7,
                "max_chars_width": 9,
                "line_wrap": "word-char",
                "ellipsization": "end",
                "justification": "center",
            },
        )
        return table

    def get_top_cpu_processes(self, limit=7):
        processes = []
        for p in psutil.process_iter(["name"]):
            try:
                p.cpu_percent(interval=None)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        time.sleep(0.1)
        for p in psutil.process_iter(["name"]):
            try:
                cpu = p.cpu_percent(interval=None)
                processes.append((p.info["name"] or "Unknown", cpu))
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        processes.sort(key=lambda x: x[1], reverse=True)
        return processes[:limit]

    def get_top_ram_processes(self, limit=7):
        processes = []
        for p in psutil.process_iter(["name"]):
            try:
                mem = p.memory_percent()
                processes.append((p.info["name"] or "Unknown", mem))
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        processes.sort(key=lambda x: x[1], reverse=True)
        return processes[:limit]

    def get_process_data(self, *args):
        cpu_data = self.get_top_cpu_processes()
        ram_data = self.get_top_ram_processes()
        return (cpu_data, ram_data)

    def update_widget(self, fabricator, value):
        if value:
            cpu_data, ram_data = value
            cpu_table_data = [[name, f"{cpu:.1f}%"] for name, cpu in cpu_data]
            ram_table_data = [[name, f"{ram:.1f}%"] for name, ram in ram_data]

            self.cpu_table.update_data(cpu_table_data)
            self.ram_table.update_data(ram_table_data)
