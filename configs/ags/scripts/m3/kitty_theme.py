import os

class KittyThemeExporter:
    """Handles the generation and export of CSS files based on a color schema."""

    file_path = f'{os.path.expanduser("~")}/.config/ags/modules/theme/kitty/material-you.conf'

    TEMPLATE = """
    # File created by kitty_theme written by ahmedsaadi0
foreground            {primary}
background            {background}
selection_foreground  {surface}
selection_background  {tertiary}
background_opacity 0.8
shell fish

url_color {inversePrimary}

color0  {primary}
color8  {error}

color1  {secondary}
color9  {error}

color2  {tertiary}
color10 {tertiary}

color5  {inverseSurface}
color13 {secondary}

color4  {onPrimaryContainer}
color12 {inverseSurface}

color3  {onSecondaryContainer}
color11 {onPrimaryContainer}

color6  {onTertiaryContainer}
color14 {onSecondaryContainer}

color7  {onErrorContainer}
color15 {onTertiaryContainer}

cursor            {onBackground}
cursor_text_color background

# font Monospace
map shift+alt+page_up scroll_page_up
map shift+alt+page_down scroll_page_down
map shift+alt+\ scroll_home
map shift+alt+/ scroll_end

scrollbar yes
scrollback_lines 20000

# font_family JetBrainsMono Nerd Font
font_family FantasqueSansMono Nerd Font
font_size 13.0

""".strip()

    def __init__(self, color_schema):
        self.color_schema = color_schema

    def generate_kitty_theme(self):
        """Generates the needed CSS classes."""
        return self.TEMPLATE.format(**self.color_schema)

    def write_new_kitty_theme(self, output_file=None):
        """Writes the generated classes into the Kitty file."""

        self.file_path = output_file or self.file_path

        generated_css = self.generate_kitty_theme()

        with open(self.file_path, "w", encoding="utf-8") as file:
            file.write(generated_css)
