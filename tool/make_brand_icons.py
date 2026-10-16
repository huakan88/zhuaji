"""Scale the brand paw into launcher, splash, and in-app assets.

The source image is used as-is. Densities are LANCZOS resizes of that
square, including the dark green field. Nothing is redrawn or cropped.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path("/opt/cursor/artifacts/assets/logo-paw.jpg")
BRAND = ROOT / "assets/brand/logo-paw.png"

ANDROID_LAUNCHER = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
ANDROID_SPLASH = {
    "drawable-mdpi": 192,
    "drawable-hdpi": 288,
    "drawable-xhdpi": 384,
    "drawable-xxhdpi": 576,
    "drawable-xxxhdpi": 768,
}
IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
IOS_LAUNCH = {
    "LaunchImage.png": 200,
    "LaunchImage@2x.png": 400,
    "LaunchImage@3x.png": 600,
}


def sample_ground(image: Image.Image) -> tuple[int, int, int]:
    pixels = [
        image.getpixel((x, y))
        for x in range(0, 12)
        for y in range(0, 12)
    ]
    pixels.sort()
    return pixels[len(pixels) // 2]


def save_square(image: Image.Image, size: int, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(path, "PNG")


def patch_launch_color(path: Path, hex_color: str) -> None:
    text = path.read_text(encoding="utf-8")
    old = 'name="launch_background">'
    start = text.index(old) + len(old)
    end = text.index("</color>", start)
    path.write_text(text[:start] + hex_color + text[end:], encoding="utf-8")


def patch_storyboard(red: float, green: float, blue: float) -> None:
    path = ROOT / "ios/Runner/Base.lproj/LaunchScreen.storyboard"
    text = path.read_text(encoding="utf-8")
    needle = '<color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>'
    replacement = (
        '<color key="backgroundColor" '
        f'red="{red:.6f}" green="{green:.6f}" blue="{blue:.6f}" '
        'alpha="1" colorSpace="custom" customColorSpace="sRGB"/>'
    )
    if needle not in text:
        raise SystemExit("launch storyboard background color was not the expected white")
    path.write_text(text.replace(needle, replacement, 1), encoding="utf-8")


def main() -> None:
    if not SOURCE.is_file():
        raise SystemExit(f"missing brand source {SOURCE}")
    source = Image.open(SOURCE).convert("RGB")
    if source.size[0] != source.size[1]:
        raise SystemExit(f"brand source must be square, got {source.size}")
    BRAND.parent.mkdir(parents=True, exist_ok=True)
    source.save(BRAND, "PNG")
    ground = sample_ground(source)
    hex_color = "#{:02X}{:02X}{:02X}".format(*ground)
    print("ground", hex_color, "source", source.size)

    res = ROOT / "android/app/src/main/res"
    for folder, size in ANDROID_LAUNCHER.items():
        save_square(source, size, res / folder / "ic_launcher.png")
    for folder, size in ANDROID_SPLASH.items():
        save_square(source, size, res / folder / "launch_image.png")
    for name in ("values/colors.xml", "values-night/colors.xml"):
        patch_launch_color(res / name, hex_color)

    icon_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    listed = json.loads((icon_dir / "Contents.json").read_text(encoding="utf-8"))
    names = {item["filename"] for item in listed["images"]}
    if names != set(IOS_ICONS):
        raise SystemExit(f"iOS icon set changed: {sorted(names ^ set(IOS_ICONS))}")
    for name, size in IOS_ICONS.items():
        save_square(source, size, icon_dir / name)
    launch_dir = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for name, size in IOS_LAUNCH.items():
        save_square(source, size, launch_dir / name)
    patch_storyboard(*(channel / 255 for channel in ground))
    print("wrote", BRAND)


if __name__ == "__main__":
    main()
