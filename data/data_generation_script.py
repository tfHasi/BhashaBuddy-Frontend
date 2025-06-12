import os
import random
from PIL import Image, ImageDraw, ImageFont

# Configuration
IMG_SIZE = (28, 28)                     # Output image size
CHARS = [chr(i) for i in range(65, 91)] # A-Z uppercase
FONTS_DIR = './fonts/'                 # Directory with .ttf or .otf fonts
OUTPUT_DIR = './char_dataset/'         # Output dataset directory
SAMPLES_PER_CHAR = 300                 # Number of images per character

# Create output directories for each character
for char in CHARS:
    os.makedirs(os.path.join(OUTPUT_DIR, char), exist_ok=True)

# Load all font paths
font_files = [os.path.join(FONTS_DIR, f) for f in os.listdir(FONTS_DIR) if f.endswith(('.ttf', '.otf'))]

# Generate synthetic images
for char in CHARS:
    print(f"Generating samples for character: {char}")
    for i in range(SAMPLES_PER_CHAR):
        # Create blank white canvas
        img = Image.new('L', IMG_SIZE, color=255)  # 'L' = grayscale
        draw = ImageDraw.Draw(img)

        # Random font and size
        font_path = random.choice(font_files)
        font_size = random.randint(18, 24)
        try:
            font = ImageFont.truetype(font_path, font_size)
        except Exception as e:
            print(f"Failed to load font: {font_path}, skipping...")
            continue

        # Random position
        x_offset = random.randint(0, 4)
        y_offset = random.randint(0, 4)

        # Draw the character
        draw.text((x_offset, y_offset), char, fill=0, font=font)

        # Random slight rotation
        angle = random.uniform(-15, 15)
        img = img.rotate(angle, fillcolor=255)

        # Save image
        filename = f"{char}_{i:04d}.png"
        img.save(os.path.join(OUTPUT_DIR, char, filename))