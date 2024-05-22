import subprocess


class GradienceCLI:
    def __init__(self, wallpaper_path, theme_name="mat-d", theme_type="dark", tone=10):
        self.wallpaper_path = wallpaper_path
        self.theme_name = theme_name
        self.theme_type = theme_type
        self.tone = tone

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

    def apply(self):
        command = ["gradience-cli", "apply", "-n", self.theme_name]
        try:
            result = subprocess.run(
                command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
            print("Apply command executed successfully.")
            print(result.stdout.decode())
        except subprocess.CalledProcessError as e:
            print("Error executing apply command:")
            print(e.stderr.decode())
