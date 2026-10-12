"""Gera a carga reprodutível dos 161 modelos .xlsx de laudos de 2026."""

from __future__ import annotations

import json
import unicodedata
from pathlib import Path


RAIZ = Path(r"C:\Projetos\LabVet")
FONTE = RAIZ / "tmp" / "consolidado_modelos_laudos_2026.json"
DESTINO = RAIZ / "database" / "estrutura" / "007_cargamodeloslaudos2026.sql"


def sql(valor: str | None) -> str:
    if valor is None:
        return "NULL"
    return "'" + valor.replace("'", "''") + "'"


def normalizar(valor: str) -> str:
    return "".join(
        caractere
        for caractere in unicodedata.normalize("NFKD", valor).upper()
        if not unicodedata.combining(caractere)
    )


def codigo_exame(modelo: dict) -> str | None:
    """Mapeia somente associações que são evidentes pelo nome do modelo."""
    arquivo = normalizar(modelo["arquivo"])
    grupo = normalizar(modelo["grupoAnimal"] or "")

    associacoes_explicitas = {
        "B_CAO_BT_BD": "19",
        "B_UREIA+CREAT": "10",
        "B_LIQ_CAV": "46",
        "IMUNO_FEL-": "36",
        "ANTA_B": "11",
        "ANTA_H": "5",
        "LABIDOCHROMIS CAERULEUS": "5",
    }
    for trecho, codigo in associacoes_explicitas.items():
        if trecho in arquivo:
            return codigo

    if "COMPATIBIL" in arquivo:
        return "44/45"
    if "HEMOAGLUTIN" in arquivo:
        return "43"
    if "COAGU" in arquivo:
        return "51"
    if "CITOLOGIA" in arquivo:
        return "47"
    if "CORTISOL" in arquivo:
        return "48"
    if "TSH" in arquivo:
        return "49"
    if "T4_" in arquivo or "T4 " in arquivo:
        return "50"
    if "KNOTT" in arquivo:
        return "41"
    if "PONTA" in arquivo or "ESFREG" in arquivo:
        return "42"
    if "4DX" in arquivo:
        return "37"
    if "PARVO" in arquivo or "CORONA" in arquivo:
        return "38"
    if "FIV" in arquivo or "FELV" in arquivo:
        return "36"
    if "LIQUIDO" in arquivo or "LAVADO" in arquivo:
        return "46"
    if "U_EAS" in arquivo or "EAS_" in arquivo or "URI+REL" in arquivo:
        return "35" if any(trecho in arquivo for trecho in ("REL", "+CR", "RPC")) else "34"
    if "HEM" in arquivo or "HEMOGRAMA" in arquivo:
        if "RETIC" in arquivo:
            return "3"
        if "FIB" in arquivo:
            return "4"
        if "SILVESTRES" in arquivo:
            return "5"
        return "4" if grupo in {"BOVINO", "BUBALINO", "CAPRINO", "EQUINOS", "OVINO", "SUINO"} else "1"
    if "RENAL" in arquivo:
        return "10"
    if "HEP_" in arquivo:
        return "8"
    if "CHECK" in arquivo:
        return "11" if grupo in {"BOVINO", "CAPRINO", "EQUINOS", "OVINO", "SUINO"} else "7"
    if "BIOQ" in arquivo or "BIOQUIMICA" in arquivo or "AVESSO" in arquivo or arquivo.endswith("3593_26B.XLSX"):
        grandes_ou_silvestres = {
            "BOVINO", "CAPRINO", "EQUINOS", "OVINO", "SUINO",
            "SILVESTRES > AVES", "SILVESTRES > MAMIFEROS",
            "SILVESTRES > PEIXES", "SILVESTRES > REPTEIS",
        }
        return "11" if grupo in grandes_ou_silvestres else "7"
    return None


def grupo(modelo: dict) -> tuple[str | None, str | None]:
    valor = modelo["grupoAnimal"]
    if not valor:
        return None, None
    partes = [parte.strip() for parte in valor.split(">")]
    return (partes[-1], partes[-2] if len(partes) > 1 else None)


def main() -> None:
    modelos = json.loads(FONTE.read_text(encoding="utf-8"))["modelos"]
    if len(modelos) != 161:
        raise ValueError(f"Esperados 161 modelos .xlsx; encontrados {len(modelos)}.")

    valores = []
    for ordem, modelo in enumerate(modelos, start=1):
        nome, pai = grupo(modelo)
        idade = "; ".join(dict.fromkeys(modelo["idadeMencionada"])) or None
        valores.append(
            "  ("
            + ", ".join(
                [
                    sql(f"ML2026-{ordem:03d}"), sql(codigo_exame(modelo)), sql(nome), sql(pai),
                    sql(Path(modelo["arquivo"]).stem), sql(idade), sql(modelo["arquivo"]),
                ]
            )
            + ")"
        )

    conteudo = """-- Labvet V1 — carga dos 161 modelos .xlsx de laudos de 2026.
-- Fonte: Importação/Laudos 2026 e análise consolidada dos modelos.
-- Os quatro arquivos .xls permanecem fora desta carga, pois não foram lidos estruturalmente.
-- A relação com exame é nula somente nos quatro modelos cujo serviço não existe no catálogo atual:
-- IMUNO_WOO_CÃO, IMUNO_LEPTO_CÃO, B_POP_FEL e IMUNO_LIPASE_FEL.

BEGIN;

SET search_path TO labvet, public;

-- Modelos históricos podem aguardar o vínculo ao catálogo comercial.
ALTER TABLE modeloslaudos
  ALTER COLUMN idexame DROP NOT NULL;

COMMENT ON COLUMN modeloslaudos.idexame IS
  'Exame comercial associado ao modelo. Pode ficar nulo temporariamente em carga histórica quando o serviço ainda não existir no catálogo.';

INSERT INTO tiposanimais (nmtipoanimal, dsdescricao, stativo)
VALUES
  ('Bovino', 'Agrupamento operacional do laboratório.', true),
  ('Bubalino', 'Agrupamento operacional do laboratório.', true),
  ('Caprino', 'Agrupamento operacional do laboratório.', true),
  ('Cão', 'Agrupamento operacional do laboratório.', true),
  ('Equinos', 'Agrupamento operacional do laboratório.', true),
  ('Gato', 'Agrupamento operacional do laboratório.', true),
  ('Ovino', 'Agrupamento operacional do laboratório.', true),
  ('Silvestres', 'Agrupamento operacional do laboratório.', true),
  ('Suino', 'Agrupamento operacional do laboratório.', true)
ON CONFLICT DO NOTHING;

INSERT INTO tiposanimais (idtipoanimalpai, nmtipoanimal, dsdescricao, stativo)
SELECT pai.idtipoanimal, filho.nmtipoanimal, filho.dsdescricao, true
FROM (
  VALUES
    ('Aves', 'Agrupamento operacional do laboratório.'),
    ('Mamíferos', 'Agrupamento operacional do laboratório.'),
    ('Peixes', 'Agrupamento operacional do laboratório.'),
    ('Répteis', 'Agrupamento operacional do laboratório.')
) AS filho(nmtipoanimal, dsdescricao)
JOIN tiposanimais pai ON pai.nmtipoanimal = 'Silvestres' AND pai.idtipoanimalpai IS NULL
ON CONFLICT DO NOTHING;

WITH fonte (
  cdmodelolaudo, cdexame, nmtipoanimal, nmtipoanimalpai,
  nmmodelolaudo, dsfaixaidade, nmarquivoorigem
) AS (
VALUES
""" + ",\n".join(valores) + """
), resolvido AS (
  SELECT
    fonte.*,
    exame.idexame,
    tipo.idtipoanimal
  FROM fonte
  LEFT JOIN exames exame ON exame.cdexame = fonte.cdexame
  LEFT JOIN tiposanimais tipo
    ON tipo.nmtipoanimal = fonte.nmtipoanimal
   AND (
     (fonte.nmtipoanimalpai IS NULL AND tipo.idtipoanimalpai IS NULL)
     OR tipo.idtipoanimalpai = (
       SELECT pai.idtipoanimal
       FROM tiposanimais pai
       WHERE pai.nmtipoanimal = fonte.nmtipoanimalpai
         AND pai.idtipoanimalpai IS NULL
     )
   )
)
INSERT INTO modeloslaudos (
  idexame, idtipoanimal, cdmodelolaudo, nmmodelolaudo,
  dsfaixaidade, nmarquivoorigem, stativo
)
SELECT
  idexame, idtipoanimal, cdmodelolaudo, nmmodelolaudo,
  dsfaixaidade, nmarquivoorigem, true
FROM resolvido
ON CONFLICT (cdmodelolaudo) DO UPDATE
SET
  idexame = EXCLUDED.idexame,
  idtipoanimal = EXCLUDED.idtipoanimal,
  nmmodelolaudo = EXCLUDED.nmmodelolaudo,
  dsfaixaidade = EXCLUDED.dsfaixaidade,
  nmarquivoorigem = EXCLUDED.nmarquivoorigem,
  stativo = EXCLUDED.stativo,
  dhalteracao = CURRENT_TIMESTAMP;

DO $$
DECLARE
  quantidade INTEGER;
  semexame INTEGER;
BEGIN
  SELECT COUNT(*) INTO quantidade
  FROM modeloslaudos
  WHERE cdmodelolaudo LIKE 'ML2026-%';

  IF quantidade <> 161 THEN
    RAISE EXCEPTION 'Carga incompleta: esperados 161 modelos, encontrados %.', quantidade;
  END IF;

  SELECT COUNT(*) INTO semexame
  FROM modeloslaudos
  WHERE cdmodelolaudo LIKE 'ML2026-%'
    AND idexame IS NULL;

  IF semexame <> 4 THEN
    RAISE EXCEPTION 'Mapeamento de exames inconsistente: esperados 4 modelos pendentes, encontrados %.', semexame;
  END IF;
END;
$$;

COMMIT;
"""
    DESTINO.write_text(conteudo, encoding="utf-8")
    print(f"Gerado: {DESTINO}")
    print("Modelos: 161")
    print(f"Modelos sem exame comercial mapeado: {sum(codigo_exame(m) is None for m in modelos)}")


if __name__ == "__main__":
    main()
