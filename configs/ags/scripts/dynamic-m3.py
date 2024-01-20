import argparse
# yay -S python-material-color-utilities
from material_color_utilities_python import *
import json


def convert_decimal_colors_to_rgba(colors_json, alpha=1.0):
    colors = json.loads(colors_json)
    rgba_colors = {}

    for color_name, decimal_value in colors.items():
        hex_value = "#{:08X}".format(decimal_value)
        rgba_value = "rgba(#{}, {})".format(hex_value[1:-2], alpha)  # Extract RGB part and add alpha
        rgba_colors[color_name] = rgba_value

    return json.dumps(rgba_colors, ensure_ascii=False, indent=2)


def convert_decimal_colors_to_hex(colors_json):
    colors = json.loads(colors_json)
    hex_colors = {}

    for color_name, decimal_value in colors.items():
        hex_value = "#{:08X}".format(decimal_value)
        hex_colors[color_name] = hexFromArgb(decimal_value)

    return json.dumps(hex_colors)


def main():
    # Define command-line arguments
    parser = argparse.ArgumentParser(
        description="Generate theme colors based on an image."
    )
    parser.add_argument("image_path", type=str, help="Path to the image file")
    parser.add_argument(
        "-m",
        "--mode",
        type=str,
        choices=["dark", "light"],
        default="dark",
        help="Color mode (dark or light)",
    )

    # Parse the command-line arguments
    args = parser.parse_args()

    # Open and resize the image
    image = Image.open(args.image_path)
    target_width = 140
    width_percent = target_width / float(image.size[0])
    target_height = int((float(image.size[1]) * float(width_percent)))
    image_resized = image.resize(
        (target_width, target_height), Image.Resampling.LANCZOS
    )

    # Generate theme from the resized image
    theme = themeFromImage(image_resized)


    # Convert theme colors to hex based on the selected mode
    selected_color_mode = "dark" if args.mode == "dark" else "light"
    theme_colors_hex = convert_decimal_colors_to_hex(
        theme["schemes"][selected_color_mode].toJSON()
    )
    print(theme_colors_hex)


if __name__ == "__main__":
    main()
