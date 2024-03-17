import argparse

from plasma_color import ColorExporter

if __name__ == "__main__":
    # main()
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
    selected_color_mode = "dark" if args.mode == "dark" else "light"
    ColorExporter(args.image_path, None, selected_color_mode)
