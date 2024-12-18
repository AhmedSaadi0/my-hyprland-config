import os
import random
import sys

from PIL import Image


def create_thumbnail(
    directory,
    output,
    thumb_width=2560,
    thumb_height=1440,
    cols=3,
    rows=3,
):
    # Find image files
    image_files = [
        os.path.join(directory, f)
        for f in os.listdir(directory)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ]

    # Select 6 random images
    if len(image_files) < cols * rows:
        print("Not enough images in the directory")
        return

    random_images = random.sample(image_files, cols * rows)

    # Open and resize images
    images = [
        Image.open(f).resize((thumb_width // cols, thumb_height // rows))
        for f in random_images
    ]

    # Create a new image with white background
    thumbnail = Image.new("RGB", (thumb_width, thumb_height), (255, 255, 255))

    # Paste images into the thumbnail
    for i, image in enumerate(images):
        x = (i % cols) * (thumb_width // cols)
        y = (i // cols) * (thumb_height // rows)
        thumbnail.paste(image, (x, y))

    # Save the thumbnail
    thumbnail.save(output)
    print(f"Thumbnail created at {output}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python create_thumbnail.py <directory>")
        sys.exit(1)

    directory = sys.argv[1]
    output = os.path.join(directory, "thumbnail.jpg")
    create_thumbnail(directory, output)
