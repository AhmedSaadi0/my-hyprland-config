import argparse
import subprocess


class GradienceCLI:
    def __init__(
        self,
        wallpaper_path,
        theme_name="mat-d",
        theme_type="dark",
        tone="20",
        gtk="both",
    ):
        self.wallpaper_path = wallpaper_path
        self.theme_name = theme_name
        self.theme_type = theme_type
        self.tone = tone
        self.gtk = gtk

    def monet(self):
        command = [
            "gradience-cli",
            "monet",
            "-p",
            self.wallpaper_path,
            "-n",
            self.theme_name,
            "--theme",
            self.theme_type,
            "--tone",
            self.tone,
        ]
        try:
            result = subprocess.run(
                command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
            print("Monet command executed successfully.")
            print(result.stdout.decode())
        except subprocess.CalledProcessError as e:
            print("Error executing monet command:")
            print(e.stderr.decode())
        except FileNotFoundError as err:
            print("Make sure to install gradience on your device")
            print("Full error : ", err)

    def apply(self):
        command = [
            "gradience-cli",
            "apply",
            "-n",
            self.theme_name,
            "--gtk",
            self.gtk,
        ]
        try:
            result = subprocess.run(
                command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
            print("Apply command executed successfully.")
            print(result.stdout.decode())
        except subprocess.CalledProcessError as e:
            print("Error executing apply command:")
            print(e.stderr.decode())
        except FileNotFoundError as err:
            print("Make sure to install gradience on your device")
            print("Full error : ", err)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate material you  theme for gtk")
    parser.add_argument("-p", type=str, help="Path of the image")
    parser.add_argument(
        "-m", type=str, help="Color mode (dark or light)", default="dark"
    )
    parser.add_argument("-t", type=str, help="Tone", default="20")
    parser.add_argument("-n", type=str, help="Theme name", default="gtk-m3")

    args = parser.parse_args()

    gradience_cli = GradienceCLI(
        wallpaper_path=args.p,
        theme_name=args.n,
        theme_type=args.m,
        tone=args.t,
    )

    gradience_cli.monet()
    gradience_cli.apply()
