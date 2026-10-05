from __future__ import annotations

import csv
import hashlib
import re
import sys
from datetime import datetime
from pathlib import Path

from pypdf import PdfReader


NAME = re.compile(r"^(?P<record>\d+)_(?P<year>\d{2})(?P<kind>B|H|IMUNO4DX|EAS)\.pdf$", re.I)
DATE = re.compile(r"\b(\d{2}/\d{2}/20\d{2})(?:\s+(\d{2}:\d{2}))?\b")


def main(source: Path, output: Path) -> None:
    rows = []
    for pdf_path in sorted(source.glob("*.pdf")):
        match = NAME.match(pdf_path.name)
        if not match:
            raise ValueError(f"Nome de arquivo fora do padrão: {pdf_path.name}")
        text = "\n".join(page.extract_text() or "" for page in PdfReader(pdf_path).pages)
        date_match = DATE.search(text)
        reported_at = ""
        if date_match:
            value = f"{date_match.group(1)} {date_match.group(2) or '00:00'}"
            reported_at = datetime.strptime(value, "%d/%m/%Y %H:%M").isoformat()
        rows.append({
            "source_file_name": pdf_path.name,
            "source_file_path": str(pdf_path),
            "source_record_number": match.group("record"),
            "report_year": int(f"20{match.group('year')}"),
            "report_type_code": match.group("kind").upper(),
            "reported_at": reported_at,
            "source_file_hash": hashlib.sha256(pdf_path.read_bytes()).hexdigest(),
            "raw_text": text,
        })
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
