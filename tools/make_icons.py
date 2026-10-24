"""Draw the app icon: a brushed Ensō circle in vàng đồng on giấy dó cream (CLAUDE.md section 4).

No Buddha imagery is used for the icon (CLAUDE.md principle 1).

Usage (from the project root):
    python -I tools/make_icons.py
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

BACKGROUND = (247, 243, 234)  # #F7F3EA
INK = (176, 141, 62)  # #B08D3E
SCALE = 4  # supersampling for smooth edges


def draw_enso(size, padding_ratio=0.2, background=BACKGROUND):
    big = size * SCALE
    img = Image.new("RGBA", (big, big), background + (255,) if background else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = big / 2
    r = big * (0.5 - padding_ratio)
    max_w = big * 0.075
    # Brush stroke: starts thick at the top-left, thins out, leaves a small gap.
    start, sweep = math.radians(200), math.radians(320)
    steps = 900
    for i in range(steps):
        t = i / steps
        a = start + sweep * t
        w = max_w * (1.0 - 0.75 * t ** 1.6)
        # Slight wobble so it reads as a brush, not a vector ring.
        rr = r + big * 0.006 * math.sin(t * 9)
        x, y = c + rr * math.cos(a), c + rr * math.sin(a)
        d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=INK + (255,))
    return img.resize((size, size), Image.LANCZOS)


def main():
    root = Path(__file__).resolve().parent.parent
    res = root / "android/app/src/main/res"
    for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        draw_enso(px).convert("RGB").save(res / f"mipmap-{folder}/ic_launcher.png")
    web = root / "web"
    draw_enso(192).convert("RGB").save(web / "icons/Icon-192.png")
    draw_enso(512).convert("RGB").save(web / "icons/Icon-512.png")
    draw_enso(192, padding_ratio=0.28).convert("RGB").save(web / "icons/Icon-maskable-192.png")
    draw_enso(512, padding_ratio=0.28).convert("RGB").save(web / "icons/Icon-maskable-512.png")
    draw_enso(32, padding_ratio=0.12).convert("RGB").save(web / "favicon.png")
    print("icons written")


if __name__ == "__main__":
    main()
