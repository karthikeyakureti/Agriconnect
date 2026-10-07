import os
from PIL import Image, ImageDraw

src_path = r"C:\Users\beliv\.gemini\antigravity-ide\brain\876ff3b0-fca4-441a-8dea-447f53e31598\agriconnect_app_logo_1791218897464.jpg"
project_root = r"d:\fpt\agriconnect"

# Load source
img = Image.open(src_path).convert("RGBA")

# Ensure assets directory
assets_dir = os.path.join(project_root, "assets", "images")
os.makedirs(assets_dir, exist_ok=True)
img.save(os.path.join(assets_dir, "app_logo.png"), "PNG")
print("Saved assets/images/app_logo.png")

# Android mipmap directories and sizes
android_res = os.path.join(project_root, "android", "app", "src", "main", "res")
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

for folder, size in sizes.items():
    folder_path = os.path.join(android_res, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    # 1. Standard ic_launcher
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(os.path.join(folder_path, "ic_launcher.png"), "PNG")
    
    # 2. Round ic_launcher_round
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    
    round_img = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    round_img.paste(resized, (0, 0), mask)
    round_img.save(os.path.join(folder_path, "ic_launcher_round.png"), "PNG")
    print(f"Generated {folder}: {size}x{size}")

# Web icons
web_icons_dir = os.path.join(project_root, "web", "icons")
if os.path.exists(web_icons_dir):
    img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-192.png"), "PNG")
    img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-512.png"), "PNG")
    img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-maskable-192.png"), "PNG")
    img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-maskable-512.png"), "PNG")
    print("Updated web icons")

web_favicon = os.path.join(project_root, "web", "favicon.png")
if os.path.exists(os.path.dirname(web_favicon)):
    img.resize((48, 48), Image.Resampling.LANCZOS).save(web_favicon, "PNG")
    print("Updated web favicon")

print("All icons successfully generated!")
