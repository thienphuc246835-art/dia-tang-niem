"""Convert source/kinh_dia_tang.pdf into the JSON schema described in CLAUDE.md (section 5).

Usage (from the project root):
    python -I tools/sutra_import/import_pdf.py source/kinh_dia_tang.pdf assets/sutra/dia_tang

The output is a first pass only. It must be proofread by hand against the printed book
before release (CLAUDE.md, principle 4). The text is never "modernised": only whitespace,
page headers and layout artefacts are removed.

Layout heuristics used (specific to this PDF):
- Page 0-5 are the cover / table of contents; the last page is the back cover.
- The first line of every body page is a running header ("PHẨM 1  5", "46  KINH ĐỊA TẠNG - ...").
- Prose is justified, so a prose line that continues has double spaces; the last line of a
  paragraph (and every verse line) has single spaces.
- Lines written fully in capitals are headings.
"""

import json
import re
import sys
import unicodedata
from pathlib import Path

from pypdf import PdfReader

FIRST_BODY_PAGE = 6
CHAPTER_ORDINALS = [
    "MƯỜI MỘT", "MƯỜI HAI", "MƯỜI BA", "MƯỜI",
    "NHẤT", "HAI", "BA", "TƯ", "NĂM", "SÁU", "BẢY", "TÁM", "CHÍN",
]
VOLUMES = [("q1", "Quyển Thượng", "THƯỢNG"), ("q2", "Quyển Trung", "TRUNG"), ("q3", "Quyển Hạ", "HẠ")]
REPEAT_RE = re.compile(r"\s*\((\d+)\s+(lần|lạy)\)\s*$")
SECTION_RE = re.compile(r"^(\d+)\)\s+")
LIST_ITEM_RE = re.compile(r"^\d+\.\s")


def nfc(s):
    return unicodedata.normalize("NFC", s)


def is_caps(line):
    letters = [c for c in line if c.isalpha()]
    return len(letters) >= 2 and not any(c.islower() for c in letters)


def body_lines(pdf_path):
    reader = PdfReader(pdf_path)
    pages = reader.pages[FIRST_BODY_PAGE:len(reader.pages) - 1]
    out = []
    for page in pages:
        lines = [nfc(l).strip() for l in (page.extract_text() or "").split("\n")]
        lines = [l for l in lines if l and l != "❖"]
        out.extend(lines[1:])  # drop running header
    # Re-join markers split over two lines: "... Bồ Tát.  (1" + "lạy)".
    # Likewise an invocation wrapped onto a second line without justification:
    # "Nam mô Thanh Tịnh Đại Hải Chúng Bồ" + "Tát.  (3 lần)".
    joined = []
    for line in out:
        if joined and re.search(r"\(\d+$", joined[-1]):
            joined[-1] += " " + line
        elif (joined and joined[-1].startswith("Nam mô") and not re.search(r"[.,:;!?”)…]$", joined[-1])
              and REPEAT_RE.search(line)):
            joined[-1] += " " + line
        else:
            joined.append(line)
    return [l.replace("❖", "").strip() for l in joined if l.replace("❖", "").strip()]


def collapse(s):
    return re.sub(r"\s+", " ", s).strip()


def to_paragraphs(lines):
    """Group raw lines into ('heading'|'para'|'list'|'line', text, repeat, unit) items."""
    items = []
    buf = []

    def flush(kind):
        if buf:
            items.append([kind, collapse(" ".join(buf))])
            buf.clear()

    in_list = False
    for line in lines:
        if is_caps(line) and not SECTION_RE.match(line):
            flush("list" if in_list else "para")
            in_list = False
            items.append(["heading", collapse(line)])
            continue
        if re.fullmatch(r"\(\d+\s+(lần|lạy)\)", collapse(line)):
            # A marker alone on its line belongs to the previous paragraph.
            flush("list" if in_list else "para")
            if items:
                items[-1][1] += " " + collapse(line)
            continue
        if LIST_ITEM_RE.match(line):
            flush("list" if in_list else "para")
            in_list = True
            buf.append(line)
            continue
        stripped = REPEAT_RE.sub("", line)
        justified = "  " in stripped
        if in_list and not justified and not SECTION_RE.match(line):
            buf.append(line)
            continue
        if in_list:
            flush("list")
            in_list = False
        buf.append(line)
        if not justified:
            flush("para" if len(buf) > 1 else "line")
    flush("list" if in_list else "para")
    return items


def make_block(kind, text, block_type=None):
    block = {"type": block_type or kind}
    m = REPEAT_RE.search(text)
    if m:
        text = text[:m.start()].rstrip()
        if m.group(2) == "lần":
            block["repeat"] = int(m.group(1))
        else:
            block["prostrations"] = int(m.group(1))
        if not block_type:
            block["type"] = "invocation"
    block["text"] = text
    return block


def group_lines(items):
    """Merge consecutive single 'line' items into one verse block."""
    out = []
    for kind, text in items:
        if (kind == "line" and out and out[-1][0] == "verse"
                and not REPEAT_RE.search(out[-1][1]) and not REPEAT_RE.search(text)):
            out[-1][1] += "\n" + text
        elif kind == "line":
            out.append(["verse", text])
        else:
            out.append([kind, text])
    return out


def split_section_title(text):
    """'5) BÀ LA MÔN NỮ CỨU MẸ. Lại thuở...' -> (5, 'BÀ LA MÔN NỮ CỨU MẸ', 'Lại thuở...')."""
    m = SECTION_RE.match(text)
    rest = text[m.end():]
    for i, ch in enumerate(rest):
        if ch == "." and (i + 1 == len(rest) or rest[i + 1] == " "):
            title = rest[:i]
            if not any(c.islower() for c in title):
                return int(m.group(1)), title.strip(), rest[i + 1:].strip()
            break
    return int(m.group(1)), None, rest


def assign_ids(blocks, prefix):
    for i, b in enumerate(blocks, 1):
        rest = dict(b)
        b.clear()
        b["id"] = f"{prefix}.b{i}"  # id first, for readable JSON
        b.update(rest)
    return blocks


def build(items):
    khai = {"id": "kk", "title": "Khai Kinh", "sections": []}
    ket = {"id": "kt", "title": "Kết Kinh", "sections": []}
    volumes = []
    state = "khai"
    current_section = None
    current_chapter = None
    current_volume = None
    pending_heading = []

    def new_section(container, title, number=None):
        sec = {"number": number, "title": title, "blocks": []}
        container["sections"].append(sec)
        return sec

    i = 0
    while i < len(items):
        kind, text = items[i]
        if kind == "heading":
            # Join consecutive heading lines (except labels ending with ':').
            heading = [text]

            def joins(prev, nxt):
                if prev.endswith(":") or nxt.endswith(":"):
                    return False
                if nxt.startswith(("PHẨM THỨ", "KINH ĐỊA TẠNG")):
                    return False
                if prev == "HẾT" or (re.fullmatch(r"QUYỂN (THƯỢNG|TRUNG|HẠ)", prev) and nxt != "HẾT"):
                    return False
                return True

            while (i + 1 < len(items) and items[i + 1][0] == "heading"
                   and joins(heading[-1], items[i + 1][1])):
                i += 1
                heading.append(items[i][1])
            h = " ".join(heading)
            i += 1
            vol_match = re.fullmatch(r"KINH ĐỊA TẠNG BỒ TÁT BỔN NGUYỆN QUYỂN (THƯỢNG|TRUNG|HẠ)( HẾT)?", h)
            if vol_match:
                if vol_match.group(2):
                    state = "closing"
                    current_volume["closing"] = []
                else:
                    vid, vtitle, _ = next(v for v in VOLUMES if v[2] == vol_match.group(1))
                    current_volume = {"id": vid, "title": vtitle, "chapters": [], "closing": []}
                    volumes.append(current_volume)
                    state = "volume"
                continue
            if h.startswith("PHẨM THỨ "):
                rest = h[len("PHẨM THỨ "):]
                ordinal = next(o for o in CHAPTER_ORDINALS if rest.startswith(o + " "))
                number = sum(len(v["chapters"]) for v in volumes) + 1
                current_chapter = {"number": number, "title": rest[len(ordinal):].strip(), "sections": []}
                current_volume["chapters"].append(current_chapter)
                current_section = new_section(current_chapter, None, 0)
                continue
            if h.endswith(":"):
                current_section["blocks"].append({"type": "heading", "text": h})
                continue
            if state == "khai":
                current_section = new_section(khai, h)
                continue
            if state in ("ket", "closing"):
                state = "ket"
                current_section = new_section(ket, h)
                continue
            current_section["blocks"].append({"type": "heading", "text": h})
            continue

        i += 1
        if state == "closing":
            block = make_block(kind, text)
            current_volume["closing"].append(block)
            invocations = [b for b in current_volume["closing"] if "repeat" in b]
            if current_volume["id"] == "q3" and len(invocations) >= 2:
                state = "ket"
                current_section = new_section(ket, None)
            continue
        if state == "khai" and current_section is None:
            current_section = new_section(khai, None)
        if kind == "para" and SECTION_RE.match(text) and state == "volume":
            number, title, body = split_section_title(text)
            current_section = new_section(current_chapter, title, number)
            if body:
                current_section["blocks"].append(make_block("prose", body))
            continue
        block_type = {"para": "prose", "list": "list_item", "verse": "verse"}[kind]
        current_section["blocks"].append(make_block(block_type, text))

    # Drop empty intro sections (chapters that start directly with "1) ...").
    for v in volumes:
        for c in v["chapters"]:
            c["sections"] = [s for s in c["sections"] if s["blocks"]]

    # Mantra sections keep their line structure as mantra blocks.
    for s in ket["sections"]:
        if s["title"] and "CHƠN NGÔN" in s["title"]:
            for b in s["blocks"]:
                b["type"] = "mantra"

    # Stable ids.
    for n, s in enumerate(khai["sections"], 1):
        s["id"] = f"kk.s{n}"
        assign_ids(s["blocks"], s["id"])
    for n, s in enumerate(ket["sections"], 1):
        s["id"] = f"kt.s{n}"
        assign_ids(s["blocks"], s["id"])
    for v in volumes:
        for c in v["chapters"]:
            c["id"] = f"{v['id']}.p{c['number']}"
            for s in c["sections"]:
                s["id"] = f"{c['id']}.s{s['number']}"
                assign_ids(s["blocks"], s["id"])
        assign_ids(v["closing"], f"{v['id']}.c")
    return khai, volumes, ket


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    pdf, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    items = group_lines(to_paragraphs(body_lines(pdf)))
    khai, volumes, ket = build(items)

    def dump(name, data):
        (out_dir / name).write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")

    dump("khai_kinh.json", khai)
    for v, name in zip(volumes, ["quyen_thuong.json", "quyen_trung.json", "quyen_ha.json"]):
        dump(name, v)
    dump("ket_kinh.json", ket)

    chapters = [c for v in volumes for c in v["chapters"]]
    print(f"volumes={len(volumes)} chapters={len(chapters)} "
          f"sections={sum(len(c['sections']) for c in chapters)} "
          f"khai={[s['title'] for s in khai['sections']]} ket={[s['title'] for s in ket['sections']]}")
    for c in chapters:
        print(c["number"], c["title"], [s["number"] for s in c["sections"]])


if __name__ == "__main__":
    main()
