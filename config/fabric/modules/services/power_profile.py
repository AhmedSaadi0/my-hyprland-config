import subprocess
import threading
import time
from typing import Literal

from loguru import logger

from fabric.core.service import Property, Service, Signal


class PowerProfileError(Exception):
    def __init__(self, message: str, *args):
        super().__init__(message, *args)


PERFORMANCE = "performance"
BALANCED = "balanced"
POWER_SAVER = "power-saver"


class PowerProfile(Service):
    @Signal
    def changed(self) -> None:
        """Emitted when the power profile is changed."""
        ...

    @Property(list[str], "readable")
    def available_profiles(self) -> list[str]:
        """List of available power profiles."""
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
        """The currently active power profile."""
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
        """Set or get the current power profile."""
        return self.active_profile

    @profile.setter
    def profile(self, value: Literal["performance", "balanced", "power-saver"]):
        if value not in self.available_profiles:
            raise ValueError(f"Invalid power profile: {value}")
        try:
            subprocess.run(
                ["powerprofilesctl", "set", value],
                text=True,
                capture_output=True,
                check=True,
            )
            logger.info(f"Power profile changed to: {value}")
            self.changed()
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to set power profile: {e.stderr}")
            raise PowerProfileError(f"Unable to set power profile to {value}.") from e

    def switch_to_performance(self):
        """Switch to the performance power profile."""
        self.switch_profile(PERFORMANCE)

    def switch_to_balanced(self):
        """Switch to the balanced power profile."""
        self.switch_profile(BALANCED)

    def switch_to_power_saver(self):
        """Switch to the power-saver power profile."""
        self.switch_profile(POWER_SAVER)

    def switch_profile(self, profile_name: str):
        """Switch to a specific power profile."""
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
            self.changed()
        except subprocess.CalledProcessError as e:
            logger.error(
                f"Failed to switch power profile to {profile_name}: {e.stderr}"
            )
            raise PowerProfileError(
                f"Unable to switch to {profile_name} profile."
            ) from e

    def __init__(self, poll_interval: int = 1, **kwargs):  # Add poll_interval
        super().__init__(**kwargs)
        self._poll_interval = poll_interval
        self._stop_event = threading.Event()
        self._monitoring_thread = threading.Thread(
            target=self._monitor_profile, daemon=True
        )
        self._monitoring_thread.start()
        logger.info("PowerProfile service initialized.")

    def _monitor_profile(self):
        """Monitors the active power profile for changes."""
        last_profile = self.active_profile
        while not self._stop_event.is_set():
            try:
                current_profile = self.active_profile
                if current_profile != last_profile:
                    logger.info(
                        f"Power profile changed externally to: {current_profile}"
                    )
                    self.changed()
                    last_profile = current_profile
            except PowerProfileError as e:
                logger.error(f"Error monitoring power profile: {e}")
            time.sleep(self._poll_interval)

    def stop_monitoring(self):
        """Stops the background monitoring thread."""
        self._stop_event.set()
        self._monitoring_thread.join()

    def __del__(self):
        self.stop_monitoring()
