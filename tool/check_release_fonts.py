#!/usr/bin/env python3
"""Fail if a release APK shipped a tree-shaken icon font or a variable CJK face."""

import struct
import sys
import zipfile

REQUIRED_MATERIAL = {
    0xE092: "arrow_back",
    0xE16A: "close",
    0xEF11: "calendar_today_outlined",
    0xF285: "pets_outlined",
    0xF44D: "today_outlined",
}


def read_u16(data, offset):
    return struct.unpack_from(">H", data, offset)[0]


def read_u32(data, offset):
    return struct.unpack_from(">I", data, offset)[0]


def tables(data):
    count = read_u16(data, 4)
    found = {}
    offset = 12
    for _ in range(count):
        tag = data[offset : offset + 4]
        found[tag] = read_u32(data, offset + 8)
        offset += 16
    return found


def cmap_chars(data):
    table = tables(data)[b"cmap"]
    chars = set()
    subtables = read_u16(data, table + 2)
    for index in range(subtables):
        _plat, _enc, start = struct.unpack_from(">HHI", data, table + 4 + index * 8)
        start += table
        fmt = read_u16(data, start)
        if fmt == 4:
            seg_count = read_u16(data, start + 6) // 2
            end_count = start + 14
            start_count = end_count + 2 * seg_count + 2
            id_delta = start_count + 2 * seg_count
            id_range = id_delta + 2 * seg_count
            for seg in range(seg_count):
                end = read_u16(data, end_count + 2 * seg)
                begin = read_u16(data, start_count + 2 * seg)
                delta = struct.unpack_from(">h", data, id_delta + 2 * seg)[0]
                range_off = read_u16(data, id_range + 2 * seg)
                if begin == 0xFFFF:
                    continue
                for code in range(begin, end + 1):
                    if range_off == 0:
                        glyph = (code + delta) & 0xFFFF
                    else:
                        pos = id_range + 2 * seg + range_off + 2 * (code - begin)
                        glyph = read_u16(data, pos)
                        if glyph:
                            glyph = (glyph + delta) & 0xFFFF
                    if glyph:
                        chars.add(code)
        elif fmt == 12:
            groups = read_u32(data, start + 12)
            base = start + 16
            for group in range(groups):
                begin, end, _glyph = struct.unpack_from(">III", data, base + group * 12)
                chars.update(range(begin, end + 1))
    return chars


def main():
    apk = sys.argv[1]
    with zipfile.ZipFile(apk) as bundle:
        names = bundle.namelist()
        manifest = bundle.read("assets/flutter_assets/FontManifest.json").decode()
        noto_reg = bundle.read(
            "assets/flutter_assets/assets/fonts/NotoSansSC-Regular.ttf"
        )
        noto_bold = bundle.read(
            "assets/flutter_assets/assets/fonts/NotoSansSC-Bold.ttf"
        )
        material = bundle.read(
            "assets/flutter_assets/fonts/MaterialIcons-Regular.otf"
        )
        cupertino_name = next(
            name
            for name in names
            if name.endswith("CupertinoIcons.ttf")
        )
        cupertino = bundle.read(cupertino_name)

    errors = []
    if b'"fvar"' in manifest:
        errors.append("FontManifest mentions a variable font")
    for label, blob in (("Regular", noto_reg), ("Bold", noto_bold)):
        faces = tables(blob)
        if b"fvar" in faces:
            errors.append(f"Noto Sans SC {label} is a variable font")
        if len(cmap_chars(blob)) < 20000:
            errors.append(f"Noto Sans SC {label} is missing Chinese glyphs")
    for weight in (100, 400, 500, 600, 700, 900):
        if f'"weight":{weight}' not in manifest.replace(" ", ""):
            errors.append(f"NotoSansSC weight {weight} is not registered")
    material_chars = cmap_chars(material)
    if len(material_chars) < 1000:
        errors.append(
            f"MaterialIcons was tree-shaken to {len(material_chars)} glyphs"
        )
    for code, name in REQUIRED_MATERIAL.items():
        if code not in material_chars:
            errors.append(f"MaterialIcons is missing {name} (U+{code:04X})")
    cupertino_chars = cmap_chars(cupertino)
    if len(cupertino_chars) < 200:
        errors.append(
            f"CupertinoIcons was tree-shaken to {len(cupertino_chars)} glyphs"
        )
    if errors:
        print("\n".join(errors))
        return 1
    print(
        f"fonts ok: noto={len(cmap_chars(noto_reg))} "
        f"material={len(material_chars)} cupertino={len(cupertino_chars)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
