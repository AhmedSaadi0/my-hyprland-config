import argparse
import sys

from plasma_color import ColorExporter

# from gtk_theme import GradienceCLI (Uncomment if needed)


def main():
    parser = argparse.ArgumentParser(
        description="Generate KDE Plasma theme colors based on a wallpaper image using Material You algorithm."
    )

    # 1. المسار إجباري (Positional)
    parser.add_argument(
        "image_path",
        type=str,
        help="Absolute path to the input wallpaper image.",
    )

    # 2. الوضع (اختياري)
    parser.add_argument(
        "-m",
        "--mode",
        type=str,
        choices=["dark", "light"],
        default="dark",
        help="Theme mode: 'dark' or 'light' (default: dark).",
    )

    parser.add_argument(
        "-s",
        "--scheme",
        dest="scheme_variant",
        type=int,
        default=2,
        choices=range(9),
        help="Scheme Variant ID (0=Content, 1=Expressive, 2=Fidelity, ... 8=FruitSalad).",
    )

    parser.add_argument(
        "-c",
        "--chroma",
        dest="chroma_mult",
        type=float,
        default=2.5,
        help="Chroma Multiplier (Saturation booster). Default: 2.5",
    )

    parser.add_argument(
        "-t",
        "--tone",
        dest="tone_mult",
        type=float,
        default=1.0,
        help="Tone Multiplier (Contrast spread). Default: 1.0",
    )

    args = parser.parse_args()

    print(f"[*] Processing: {args.image_path}")
    print(
        f"[*] Params: Scheme={args.scheme_variant}, Chroma={args.chroma_mult}, Tone={args.tone_mult}, Mode={args.mode}"
    )

    try:
        # استدعاء الكلاس الخاص بك
        ColorExporter(
            wallpaper_data=args.image_path,
            ncolor=None,
            theme_mode=args.mode,
            scheme_variant=args.scheme_variant,
            chroma_mult=args.chroma_mult,
            tone_mult=args.tone_mult,
        )
        print("[+] Plasma colors applied successfully.")

    except Exception as e:
        print(f"[!] Error applying colors: {e}", file=sys.stderr)
        sys.exit(1)

    # --- GTK Theme Section (Future Use) ---
    # if args.apply_gtk:
    #     gradience_cli = GradienceCLI(
    #         wallpaper_path=args.image_path,
    #         theme_name=f"ahmed-config-{args.mode}",
    #         theme_type=args.mode,
    #         tone="10",
    #     )
    #     gradience_cli.monet()
    #     gradience_cli.apply()


if __name__ == "__main__":
    main()
