from pathlib import Path

from PIL import Image


icon_path = Path(__file__).resolve().parent.parent / "assets" / "images" / "icon.png"
with Image.open(icon_path) as image:
    optimized = image.convert("RGB").resize((1024, 1024), Image.Resampling.LANCZOS)
    optimized.save(icon_path, format="PNG", optimize=True, compress_level=9)

print(icon_path)
