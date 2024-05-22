import argparse

from gtk_theme import GradienceCLI
from plasma_color import ColorExporter

if __name__ == "__main__":
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

    args = parser.parse_args()
    selected_color_mode = "dark" if args.mode == "dark" else "light"

    # Apply plasma theme
    ColorExporter(args.image_path, None, selected_color_mode)

    # Apply GTK theme
    gradience_cli = GradienceCLI(
        wallpaper_path=args.image_path,
        theme_name=f"ahmed-config-{selected_color_mode}",
        theme_type=selected_color_mode,
        tone="10",
    )
    gradience_cli.monet()
    gradience_cli.apply()
