import json
import re
import subprocess

# --- Audio and other functions remain the same ---
# (I will omit them for brevity but they are included in the final script block)


def get_display_devices_hyprland():
    """
    Fetches connected display monitors with rich details using 'hyprctl'.
    This is the preferred method for a Hyprland environment.
    """
    display_devices = []
    try:
        # Execute the hyprctl command
        result = subprocess.run(
            ["hyprctl", "monitors"], capture_output=True, text=True, check=True
        )
        output = result.stdout.strip()

        # Each monitor's info is separated by a blank line
        monitor_blocks = output.split("\n\n")

        for block in monitor_blocks:
            lines = block.strip().splitlines()
            if not lines:
                continue

            device_info = {}

            # First line: Monitor name
            first_line_match = re.search(r"Monitor (.*?) \(ID", lines[0])
            if first_line_match:
                device_info["name"] = first_line_match.group(1).strip()

            # Second line: Resolution and Refresh Rate
            second_line_match = re.search(r"(\d+x\d+)@([\d.]+)", lines[1])
            if second_line_match:
                device_info["resolution"] = second_line_match.group(1)
                # Round the refresh rate for cleaner display
                device_info["refresh_rate_hz"] = round(
                    float(second_line_match.group(2))
                )

            # Parse the rest of the key-value pairs
            for line in lines[2:]:
                if ":" in line:
                    key, value = line.split(":", 1)
                    # Clean up key and value
                    clean_key = key.strip().replace(" ", "_")
                    device_info[clean_key] = value.strip()

            # Add our custom device_type classification
            if device_info.get("name", "").startswith("eDP"):
                device_info["device_type"] = "internal_laptop_screen"
            else:
                device_info["device_type"] = "external_monitor"

            display_devices.append(device_info)

    except FileNotFoundError:
        return {
            "error": "'hyprctl' command not found. This script must be run in a Hyprland session."
        }
    except (subprocess.CalledProcessError, IndexError) as e:
        return {
            "error": f"Failed to parse 'hyprctl monitors' output. Error: {e}"
        }

    return display_devices


# --- Main script combining all functions ---


# (Copying the unchanged audio/usb/capture functions here for a complete script)
def get_audio_device_group_key(device_name):
    name_lower = device_name.lower()
    if (
        "hda nvidia" in name_lower
        or "hda amd" in name_lower
        or "hdmi" in name_lower
    ):
        return "display_audio_group"
    if (
        "hda intel" in name_lower
        or "analog" in name_lower
        or "internal" in name_lower
    ):
        return "internal_audio_group"
    return device_name.split(":")[0].strip()


def get_audio_devices():
    grouped_devices = {}
    VIRTUAL_DEVICE_KEYWORDS = [
        "sysdefault",
        "default",
        "dmix",
        "pipewire",
        "surround",
        "front",
    ]
    try:
        import sounddevice as sd

        raw_devices = sd.query_devices()
        for device in raw_devices:
            name = device["name"]
            if any(k in name.lower() for k in VIRTUAL_DEVICE_KEYWORDS) or (
                device["max_input_channels"] == 0
                and device["max_output_channels"] == 0
            ):
                continue
            key = get_audio_device_group_key(name)
            if key not in grouped_devices:
                device_type, _ = classify_audio_device(device)
                friendly_name = name.split(":")[0].strip()
                if key == "display_audio_group":
                    friendly_name = "Monitor/Display Audio (HDMI/DP)"
                if key == "internal_audio_group":
                    friendly_name = "Internal Speakers & Microphone"
                grouped_devices[key] = {
                    "name": friendly_name,
                    "device_type": device_type,
                    "io_type": "unknown",
                    "max_input_channels": 0,
                    "max_output_channels": 0,
                    "default_samplerate": device["default_samplerate"],
                    "indices": [],
                }
            group = grouped_devices[key]
            group["indices"].append(device["index"])
            group["max_input_channels"] = max(
                group["max_input_channels"], device["max_input_channels"]
            )
            group["max_output_channels"] = max(
                group["max_output_channels"], device["max_output_channels"]
            )
        for group in grouped_devices.values():
            max_in, max_out = (
                group["max_input_channels"],
                group["max_output_channels"],
            )
            if max_in > 0 and max_out > 0:
                group["io_type"] = "input/output"
            elif max_in > 0:
                group["io_type"] = "input"
            elif max_out > 0:
                group["io_type"] = "output"
        return list(grouped_devices.values())
    except Exception as e:
        return {
            "error": f"An error occurred while fetching audio devices: {e}"
        }


def get_audio_devices_control():
    """
    Fetches audio devices using 'pactl' specifically for control purposes.
    Returns distinct lists for sinks (outputs) and sources (inputs).
    """
    devices = {"outputs": [], "inputs": []}

    def fetch_pactl_json(device_type):
        # device_type is either 'sinks' (outputs) or 'sources' (inputs)
        try:
            result = subprocess.run(
                ["pactl", "--format=json", "list", device_type],
                capture_output=True,
                text=True,
                check=True,
            )
            return json.loads(result.stdout)
        except (
            subprocess.CalledProcessError,
            FileNotFoundError,
            json.JSONDecodeError,
        ):
            return []

    # --- Process Outputs (Sinks) ---
    for sink in fetch_pactl_json("sinks"):
        # Determine a user-friendly name
        description = sink.get("description", sink.get("name"))

        device_info = {
            "control_name": sink.get(
                "name"
            ),  # THIS is what you need to change settings
            "friendly_name": description,
            "index": sink.get("index"),
            "state": sink.get("state"),
            "type": "output",
        }
        # Attempt to classify for icons/grouping
        dev_type = "unknown"
        if "hdmi" in sink.get("name", "").lower():
            dev_type = "display_audio"
        elif "usb" in sink.get("name", "").lower():
            dev_type = "external_usb"
        elif "pci" in sink.get("name", "").lower():
            dev_type = "internal_speaker"
        device_info["device_type"] = dev_type

        devices["outputs"].append(device_info)

    # --- Process Inputs (Sources) ---
    for source in fetch_pactl_json("sources"):
        # Filter out "monitor" sources which are just echoes of outputs
        if "monitor" in source.get("name", ""):
            continue

        description = source.get("description", source.get("name"))
        device_info = {
            "control_name": source.get(
                "name"
            ),  # THIS is what you need for control
            "friendly_name": description,
            "index": source.get("index"),
            "state": source.get("state"),
            "type": "input",
        }
        # Attempt to classify
        dev_type = "unknown"
        if "usb" in source.get("name", "").lower():
            dev_type = "external_mic"
        elif "pci" in source.get("name", "").lower():
            dev_type = "internal_mic"
        device_info["device_type"] = dev_type

        devices["inputs"].append(device_info)

    return devices


def classify_audio_device(device):
    name = device.get("name", "").lower()
    if "usb" in name:
        return "external_usb", None
    if "hdmi" in name or "dp" in name or "nvidia" in name or "amd" in name:
        return "display_audio", None
    if "analog" in name or "pch" in name or "internal" in name:
        return "internal_speakers_mic", None
    if "bluetooth" in name or "bluez" in name:
        return "bluetooth_device", None
    return "unknown", None


def get_capture_devices():
    capture_devices = []
    try:
        result = subprocess.run(
            ["v4l2-ctl", "--list-devices"],
            capture_output=True,
            text=True,
            check=True,
        )
        output = result.stdout.strip()
        devices = output.split("\n\n")
        for device_info in devices:
            if not device_info:
                continue
            lines = device_info.strip().split("\n")
            name, path = lines[0].strip(), lines[1].strip()
            device_type = (
                "internal_webcam"
                if "integrated" in name.lower()
                else "external_webcam"
            )
            capture_devices.append(
                {"name": name, "path": path, "device_type": device_type}
            )
    except Exception:
        pass
    return capture_devices


def get_usb_peripherals():
    usb_peripherals = []
    INTERNAL_USB_KEYWORDS = [
        "root hub",
        "linux foundation",
        "bluetooth",
        "integrated camera",
    ]
    try:
        device_re = re.compile(
            r"Bus\s+(?P<bus>\d+)\s+Device\s+(?P<device>\d+):\s+ID\s+(?P<id>\w+:\w+)\s+(?P<tag>.+)",
            re.I,
        )
        df = subprocess.check_output("lsusb", text=True)
        for i in df.strip().split("\n"):
            if not i:
                continue
            info = device_re.match(i)
            if not info:
                continue
            dinfo = info.groupdict()
            tag_lower = dinfo["tag"].lower()
            if any(keyword in tag_lower for keyword in INTERNAL_USB_KEYWORDS):
                continue
            device_type = "generic_usb"
            if "mouse" in tag_lower:
                device_type = "mouse"
            elif "keyboard" in tag_lower:
                device_type = "keyboard"
            elif "audio" in tag_lower or "headset" in tag_lower:
                device_type = "audio_device"
            dinfo["device_type"] = device_type
            usb_peripherals.append(dinfo)
    except Exception as e:
        return {"error": f"An error occurred while fetching USB devices: {e}"}
    return usb_peripherals


def main():
    """
    Main function to fetch all device information for a Hyprland environment.
    """
    all_devices = {
        "audio_devices": get_audio_devices_control(),
        "display_devices": get_display_devices_hyprland(),  # Using the new hyprctl function
        "capture_devices": get_capture_devices(),
        "usb_peripherals": get_usb_peripherals(),
    }
    print(json.dumps(all_devices, indent=4, ensure_ascii=False))


if __name__ == "__main__":
    main()
