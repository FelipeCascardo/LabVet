from __future__ import annotations

import csv
from decimal import Decimal, InvalidOperation
import math
import sys
import unicodedata
from pathlib import Path

import pandas as pd


def clean(value: object) -> str:
    if value is None or (isinstance(value, float) and math.isnan(value)):
        return ""
    if isinstance(value, float) and value.is_integer():
        return str(int(value))
    return str(value).strip()


def key(value: object) -> str:
    text = unicodedata.normalize("NFKD", clean(value)).encode("ascii", "ignore").decode()
    return "".join(ch for ch in text.casefold() if ch.isalnum())


def normalize_species(value: object) -> str:
    aliases = {"can": "Can", "canino": "Can", "fel": "Fel", "felinos": "Fel"}
    text = clean(value)
    return aliases.get(key(text), text)


def normalize_sex(value: object) -> str:
    aliases = {
        "f": "F",
        "femea": "F",
        "m": "M",
        "macho": "M",
        "indf": "INDEFINIDO",
        "indef": "INDEFINIDO",
        "indefinido": "INDEFINIDO",
    }
    return aliases.get(key(value), "NAO_INFORMADO")


def normalize_sector(value: object) -> tuple[str, str]:
    raw = clean(value)
    compact = key(raw).replace("hpva", "hvpa")
    aliases = {
        "hvpaclinica": "HVPA/Clínica",
        "hvpaclinicos": "HVPA/Clínica",
        "hvpacinica": "HVPA/Clínica",
        "hvpaclinica": "HVPA/Clínica",
        "hvpaoncologia": "HVPA/Oncologia",
        "hvpafelinos": "HVPA/Felinos",
        "hvpacirurgia": "HVPA/Cirurgia",
        "hvpacardiologia": "HVPA/Cardiologia",
        "hvpadermatologia": "HVPA/Dermatologia",
        "hvpasilvestres": "HVPA/Silvestres",
        "hvpaselvagens": "HVPA/Silvestres",
        "hvpaoftalmo": "HVPA/Oftalmo",
        "hvpanestesia": "HVPA/Anestesiologia",
        "hvpaanestesio": "HVPA/Anestesiologia",
        "hvpaanestesiologia": "HVPA/Anestesiologia",
        "hvga": "HVGA",
        "hvgaselvagens": "HVGA/Silvestres",
    }
    name = aliases.get(compact, raw)
    return name, key(name)


def normalize_origin(value: str) -> str:
    origin = clean(value).upper()
    if origin not in {"HV", "AMA"}:
        raise ValueError("A origem deve ser HV ou AMA.")
    return origin


def exam_sort_key(exam_code: str) -> tuple[int, Decimal | str]:
    try:
        return (0, Decimal(exam_code))
    except InvalidOperation:
        return (1, exam_code.casefold())


def normalize_exams(value: object) -> str:
    """Ordena os códigos recebidos por vírgula e os exibe separados por ' | '."""
    codes = [clean(code) for code in clean(value).split(",")]
    return " | ".join(sorted((code for code in codes if code), key=exam_sort_key))


def main(source_path: Path, source_origin: str, output_path: Path, rejected_path: Path) -> None:
    source_origin = normalize_origin(source_origin)
    source = pd.read_excel(source_path)
    source = source.dropna(axis=1, how="all")
    source.columns = [clean(column) for column in source.columns]
    expected = {
        "Registro", "Data", "Código", "Animal", "Proprietário", "Especie", "Idade",
        "Sexo", "Raça", "Setor", "Histórico", "Exames", "Total de exames",
    }
    missing = expected - set(source.columns)
    if missing:
        raise ValueError(f"Colunas ausentes: {sorted(missing)}")

    fields = [
        "source_origin", "source_record_number", "attended_on", "owner_name", "owner_key", "animal_name",
        "animal_key", "external_code", "species", "breed", "sex", "sector_name", "sector_key",
        "age_text", "clinical_history", "reported_exam_total", "charged_amount", "exams_pipe",
    ]
    output_path.parent.mkdir(parents=True, exist_ok=True)
    rejected_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", newline="", encoding="utf-8") as accepted, rejected_path.open("w", newline="", encoding="utf-8") as rejected:
        accepted_writer = csv.DictWriter(accepted, fieldnames=fields)
        rejected_writer = csv.DictWriter(rejected, fieldnames=["source_record_number", "attended_on", "reason"])
        accepted_writer.writeheader()
        rejected_writer.writeheader()
        for _, row in source.iterrows():
            animal_name = clean(row["Animal"])
            owner_name = clean(row["Proprietário"])
            external_code = clean(row["Código"])
            history = clean(row["Histórico"])
            exams = normalize_exams(row["Exames"])
            sector_raw = clean(row["Setor"])
            source_number = clean(row["Registro"])
            attended_on = pd.Timestamp(row["Data"]).date().isoformat()
            has_clinical_data = any([animal_name, owner_name, external_code, history, exams, sector_raw])
            if not has_clinical_data:
                rejected_writer.writerow({
                    "source_record_number": source_number,
                    "attended_on": attended_on,
                    "reason": "Linha sem dados clínicos",
                })
                continue
            sector_name, sector_key = normalize_sector(sector_raw)
            owner_key = key(owner_name)
            animal_key = "|".join((key(external_code), key(animal_name), owner_key))
            accepted_writer.writerow({
                "source_origin": source_origin,
                "source_record_number": source_number,
                "attended_on": attended_on,
                "owner_name": owner_name,
                "owner_key": owner_key,
                "animal_name": animal_name,
                "animal_key": animal_key,
                "external_code": external_code,
                "species": normalize_species(row["Especie"]),
                "breed": clean(row["Raça"]),
                "sex": normalize_sex(row["Sexo"]),
                "sector_name": sector_name,
                "sector_key": sector_key,
                "age_text": clean(row["Idade"]),
                "clinical_history": history,
                "reported_exam_total": clean(row["Total de exames"]),
                "charged_amount": clean(row["Valor"]) if "Valor" in source.columns else "",
                "exams_pipe": exams,
            })


if __name__ == "__main__":
    if len(sys.argv) != 5:
        raise SystemExit("Uso: generate_setembro_2026_import.py HV|AMA origem.xlsx aceitos.csv rejeitados.csv")
    main(Path(sys.argv[2]), sys.argv[1], Path(sys.argv[3]), Path(sys.argv[4]))
