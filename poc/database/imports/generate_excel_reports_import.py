"""Gera arquivos CSV de estágio para importar laudos Excel mapeados."""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

from map_excel_reports import is_copy_file, map_file


TYPE_CODES = {
    "HEMOGRAMA": "H", "BIOQUIMICA": "B", "URINALISE": "EAS", "IMUNO_4DX": "IMUNO4DX",
    "LEPTOSPIROSE": "LEPTO", "KNOTT": "KNOTT", "CORTISOL": "CORTISOL", "T4": "T4",
    "COMPATIBILIDADE": "COMPAT", "HEMOAGLUTINACAO": "HEMOAGL", "PESQUISA_HEMOPARASITA": "HEMOP",
    "PONTA_ORELHA": "HEMOP", "SALINA": "SALINA", "LIQUIDO_CAVITARIO": "LIQCAV",
    "LAVADO_BRONCOALVEOLAR": "LAVBRONQ",
}


def write_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> None:
    with path.open("w", newline="", encoding="utf-8") as output:
        writer = csv.DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main(source_directory: Path, output_directory: Path, existing_reports_json: Path | None = None) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    reports, results, notes, ignored = [], [], [], []
    existing_files: set[str] = set()
    if existing_reports_json and existing_reports_json.exists():
        existing_files = {item.get("arquivo", "") for item in json.loads(existing_reports_json.read_text(encoding="utf-8")).get("records", [])}
    for path in sorted(source_directory.glob("*.xlsx")):
        if is_copy_file(path):
            ignored.append({"source_file": path.name, "reason": "Arquivo com sufixo de cópia"})
            continue
        if path.name in existing_files:
            ignored.append({"source_file": path.name, "reason": "Laudo já existente na base"})
            continue
        mapped = map_file(path)
        report_type = TYPE_CODES.get(mapped["exam_type"])
        if mapped["review_required"] or not report_type or not mapped["source_record"] or not mapped["source_origin"]:
            ignored.append({"source_file": path.name, "reason": "Formato sem mapeador automático"})
            continue
        reports.append({
            "source_file_name": mapped["source_file"],
            "source_file_path": str(path.resolve()),
            "source_origin": mapped["source_origin"],
            "source_record_number": mapped["source_record"],
            "report_type_code": report_type,
            "raw_text": mapped["raw_text"],
            "comments": mapped["comments"],
        })
        for display_order, item in enumerate(mapped["results"], start=1):
            results.append({
                "source_file_name": mapped["source_file"],
                "analyte_code": item["analyte_code"],
                "analyte_name": item["analyte_name"],
                "default_unit": item["unit"] or "",
                "value_kind": "NUMERIC" if item["result_numeric"] is not None else "TEXT",
                "section_name": item["section"],
                "display_order": display_order,
                "result_numeric": item["result_numeric"] if item["result_numeric"] is not None else "",
                "result_text": item["result_text"] or "",
                "unit": item["unit"] or "",
                "reference_low": item["reference_low"] if item["reference_low"] is not None else "",
                "reference_high": item["reference_high"] if item["reference_high"] is not None else "",
                "reference_text": item["reference_text"] or "",
            })
        if mapped["comments"]:
            notes.append({"source_file_name": mapped["source_file"], "note_text": mapped["comments"]})

    write_csv(output_directory / "laudos.csv", list(reports[0]) if reports else ["source_file_name"], reports)
    write_csv(output_directory / "resultados.csv", list(results[0]) if results else ["source_file_name"], results)
    write_csv(output_directory / "comentarios.csv", list(notes[0]) if notes else ["source_file_name"], notes)
    write_csv(output_directory / "nao-importados.csv", ["source_file", "reason"], ignored)
    print(f"Laudos prontos para carga: {len(reports)}")
    print(f"Resultados estruturados: {len(results)}")
    print(f"Comentários integrais: {len(notes)}")
    print(f"Arquivos fora da carga automática: {len(ignored)}")


if __name__ == "__main__":
    existing = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    main(Path(sys.argv[1]), Path(sys.argv[2]), existing)
