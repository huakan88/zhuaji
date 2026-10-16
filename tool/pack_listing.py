"""Build the store feature graphic, 软著 source excerpt, and user-manual docx."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Cm, Pt

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
OUT_RUAN = ROOT / "docs" / "ruanzhu"
OUT_STORE = ROOT / "docs" / "store-listing"
SKIP_NAMES = {"pinyin_table.dart"}
LINES_PER_PAGE = 50
PAGES_EACH_END = 30


def source_files() -> list[Path]:
    files = []
    for path in sorted(LIB.rglob("*.dart")):
        if path.name in SKIP_NAMES or path.name.endswith(".g.dart"):
            continue
        files.append(path)
    return files


def source_lines() -> list[str]:
    lines: list[str] = []
    for path in source_files():
        rel = path.relative_to(ROOT).as_posix()
        lines.append(f"// {rel}")
        text = path.read_text(encoding="utf-8")
        lines.extend(text.splitlines())
        lines.append("")
    return lines


def paginate(lines: list[str]) -> str:
    per = LINES_PER_PAGE
    need = per * PAGES_EACH_END
    if len(lines) <= need * 2:
        chosen = lines
    else:
        chosen = lines[:need] + lines[-need:]
    pages = [chosen[i : i + per] for i in range(0, len(chosen), per)]
    blocks = []
    for index, page in enumerate(pages, start=1):
        header = f"肉垫本软件 V2.17.0{' ' * 24}第 {index} 页"
        body = list(page)
        while len(body) < per:
            body.append("")
        blocks.append(header + "\n" + "\n".join(body[:per]))
    return "\n\f\n".join(blocks) + "\n"


def feature_graphic() -> None:
    width, height = 1024, 500
    image = Image.new("RGB", (width, height), "#F4F7F3")
    draw = ImageDraw.Draw(image)
    icon_path = ROOT / "assets/cats/cat-icon.jpg"
    icon = Image.open(icon_path).convert("RGBA").resize((300, 300))
    image.paste(icon, (64, 100), icon)
    regular = ImageFont.truetype(
        str(ROOT / "assets/fonts/NotoSansSC-Regular.ttf"),
        42,
    )
    bold = ImageFont.truetype(
        str(ROOT / "assets/fonts/NotoSansSC-Bold.ttf"),
        92,
    )
    draw.text((420, 140), "肉垫本", font=bold, fill="#1A2A22")
    draw.text((420, 270), "给猫记粮、疫苗和体重", font=regular, fill="#1B5C3C")
    draw.text((420, 340), "记录留在这台手机上", font=regular, fill="#3E5348")
    out = OUT_STORE / "feature-1024x500.png"
    image.save(out, "PNG")


def add_heading(doc: Document, text: str) -> None:
    paragraph = doc.add_heading(text, level=1)
    paragraph.alignment = WD_ALIGN_PARAGRAPH.LEFT


def manual() -> None:
    doc = Document()
    style = doc.styles["Normal"]
    style.font.name = "Noto Sans SC"
    style.font.size = Pt(12)
    title = doc.add_heading("肉垫本软件用户手册（草案）", level=0)
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph("软件版本：V2.17.0    文档日期：2026 年 10 月")
    doc.add_paragraph(
        "本手册说明肉垫本（PawPad）在 Android 手机上的日常用法。"
        "界面以简体中文显示。包名为 com.maokangji.maokangji。"
    )

    add_heading(doc, "1. 运行环境")
    doc.add_paragraph("Android 8.0 及以上，arm64 手机。需要相机时才使用摄像头。不需要账号。")

    add_heading(doc, "2. 安装")
    doc.add_paragraph(
        "从应用商店安装，或安装已签名的 release APK。覆盖安装不会清除已经记下的猫咪和粮仓。"
        "第一次打开会停在协议页，点选之前不会申请相机、相册或通知。"
    )

    add_heading(doc, "3. 首次打开")
    doc.add_paragraph(
        "阅读隐私政策和用户协议。点「同意并继续」使用提醒和条码联网查询。"
        "点「不同意，仅用基本功能」则只在本机记录，不联网、不发提醒。"
        "点「退出应用」离开。之后可在「猫咪」页撤回同意或删除本机数据。"
    )
    _picture(doc, "00-consent.png")

    add_heading(doc, "4. 今天")
    doc.add_paragraph(
        "底部四个入口是今天、健康、粮仓、猫咪。今天页可以搜索，也可以切换猫咪。"
        "卡片上是当前这只猫和接下来要办的事。右上角相机进入扫码。"
    )
    _picture(doc, "01-today.png")

    add_heading(doc, "5. 健康")
    doc.add_paragraph(
        "记体重、记疫苗、记驱虫在第一屏。下面是最近的记录。化验单、就医和蓝牙秤从本页进入。"
        "蓝牙只在打开蓝牙秤时申请。拍化验单或从相册选择时才使用相机或相册。"
    )
    _picture(doc, "02-health.png")

    add_heading(doc, "6. 粮仓")
    doc.add_paragraph(
        "每袋粮用一句话说明还能吃几天，或还没开封。扫码、拍贴纸、自定义猫粮、自制鲜食和图鉴都在这一页。"
        "扫到手机里已有的条码会打开那一袋。校验通过但表里没有的条码，可以补充品牌和名称。"
    )
    _picture(doc, "03-pantry.png")

    add_heading(doc, "7. 猫咪、协议和数据")
    doc.add_paragraph(
        "猫咪页可以改外观、看品种和年龄、复制健康卡。"
        "最下面是隐私政策、用户协议、权限说明、撤回同意和删除本机数据。"
        "撤回后变成基本功能。删除会抹掉这台手机上的猫咪和记录，并重新询问是否同意。"
    )
    _picture(doc, "04-cats.png")

    add_heading(doc, "8. 权限")
    doc.add_paragraph(
        "相机用于扫码和拍照。相册用于选图。通知和精确闹钟只在同意完整功能后申请。"
        "蓝牙用于体重秤。Android 11 及更早扫描蓝牙时，系统会附带位置权限，应用不保存位置。"
    )
    out = OUT_RUAN / "用户手册草案.docx"
    doc.save(out)


def _picture(doc: Document, name: str) -> None:
    path = OUT_STORE / "screenshots" / name
    doc.add_picture(str(path), width=Cm(8.2))
    caption = doc.add_paragraph(name)
    caption.alignment = WD_ALIGN_PARAGRAPH.CENTER


def main() -> None:
    OUT_RUAN.mkdir(parents=True, exist_ok=True)
    OUT_STORE.mkdir(parents=True, exist_ok=True)
    lines = source_lines()
    text = paginate(lines)
    excerpt = OUT_RUAN / "source-excerpt.txt"
    excerpt.write_text(text, encoding="utf-8")
    feature_graphic()
    manual()
    print(f"source lines {len(lines)}")
    print(f"excerpt bytes {excerpt.stat().st_size}")


if __name__ == "__main__":
    main()
