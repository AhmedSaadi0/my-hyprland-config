import subprocess
from typing import Literal

import dbus
import dbus.mainloop.glib
from cachetools import TTLCache, cached
from loguru import logger

from fabric.core.service import Property, Service, Signal


class PowerProfileError(Exception):
    """Exception raised for errors in power profile operations."""


PERFORMANCE = "performance"
BALANCED = "balanced"
POWER_SAVER = "power-saver"

_available_profiles_cache = TTLCache(maxsize=10, ttl=60)


class PowerProfile(Service):
    @Signal
    def changed(self) -> None:
        pass

    @Property(list[str], "readable")
    def available_profiles(self) -> list[str]:
        return self._get_available_profiles()

    @cached(cache=_available_profiles_cache)
    def _get_available_profiles(self) -> list[str]:
        try:
            result = subprocess.run(
                ["powerprofilesctl", "list"],
                text=True,
                capture_output=True,
                check=True,
            )
            profiles = [
                line.split(":")[0].strip().strip("*")
                for line in result.stdout.splitlines()
                if line
            ]
            return profiles
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to retrieve power profiles: {e.stderr}")
            raise PowerProfileError("Unable to list power profiles.") from e

    @Property(str, "readable")
    def active_profile(self) -> str:
        try:
            result = subprocess.run(
                ["powerprofilesctl", "get"],
                text=True,
                capture_output=True,
                check=True,
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to get active power profile: {e.stderr}")
            raise PowerProfileError("Unable to get active power profile.") from e

    @Property(str, "read-write")
    def profile(self) -> str:
        return self.active_profile

    @profile.setter
    def profile(self, value: Literal["performance", "balanced", "power-saver"]):
        self.switch_profile(value)

    def switch_profile(self, profile_name: str):
        if profile_name not in self.available_profiles:
            raise PowerProfileError(f"Profile '{profile_name}' is not available.")
        try:
            subprocess.run(
                ["powerprofilesctl", "set", profile_name],
                text=True,
                capture_output=True,
                check=True,
            )
            logger.info(f"Switched to {profile_name} profile.")
            _available_profiles_cache.clear()
            self.changed()
        except subprocess.CalledProcessError as e:
            logger.error(
                f"Failed to switch power profile to {profile_name}: {e.stderr}"
            )
            raise PowerProfileError(
                f"Unable to switch to {profile_name} profile."
            ) from e

    def switch_to_performance(self):
        self.switch_profile(PERFORMANCE)

    def switch_to_balanced(self):
        self.switch_profile(BALANCED)

    def switch_to_power_saver(self):
        self.switch_profile(POWER_SAVER)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._monitor_dbus()
        logger.info("PowerProfile service initialized.")

    def _monitor_dbus(self):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        bus = dbus.SystemBus()
        bus.add_signal_receiver(
            self._on_profile_changed,
            dbus_interface="org.freedesktop.DBus.Properties",
            signal_name="PropertiesChanged",
            path="/net/hadess/PowerProfiles",
        )
        # GLib.timeout_add(
        #     1000 * 60 * 60, self._check_active_profile
        # )  # فحص دوري كل ثانية

    def _check_active_profile(self):
        try:
            current_profile = self.active_profile
            logger.info(f"Current power profile: {current_profile}")
        except PowerProfileError:
            pass
        return True  # يسمح للحلقة بالاستمرار

    def _on_profile_changed(
        self, interface, changed_properties, invalidated_properties
    ):
        if "ActiveProfile" in changed_properties:
            new_profile = changed_properties["ActiveProfile"]
            logger.info(f"Power profile changed externally to: {new_profile}")
            self.changed()

    # def _run_glib_loop(self):
    #     loop = GLib.MainLoop()
    #     loop.run()
