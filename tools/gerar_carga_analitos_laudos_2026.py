"""Gera a carga de analitos e parâmetros dos modelos de laudos de 2026."""

from __future__ import annotations

import json
import re
import unicodedata
from collections import defaultdict
from pathlib import Path


RAIZ = Path(r"C:\Projetos\LabVet")
FONTE = RAIZ / "tmp" / "analise_modelos_laudos_2026.json"
DESTINO = RAIZ / "database" / "estrutura" / "008_cargaanalitoslaudos2026.sql"


def normalizar(valor: object) -> str:
    texto = "" if valor is None else str(valor)
    texto = unicodedata.normalize("NFKD", texto)
    texto = "".join(caractere for caractere in texto if not unicodedata.combining(caractere))
    return re.sub(r"\s+", " ", texto).strip().casefold()


def sql(valor: object | None) -> str:
    if valor is None:
        return "NULL"
    return "'" + str(valor).replace("'", "''") + "'"


def codigo(texto: str) -> str:
    texto = unicodedata.normalize("NFKD", texto)
    texto = "".join(caractere for caractere in texto if not unicodedata.combining(caractere))
    texto = re.sub(r"[^A-Za-z0-9]+", "-", texto.upper()).strip("-")
    return ("ANA-" + texto)[:100]


def valores_referencia(linha: list[str], posicao: int) -> list[str]:
    retorno = []
    for valor in linha[posicao + 1:]:
        valor = valor.strip()
        if not valor or valor.startswith("=") or valor in {"#REF!", "#VALUE!", "#N/A"}:
            continue
        retorno.append(valor)
    return retorno


def parece_parametro(rotulo: str, referencias: list[str]) -> bool:
    texto = normalizar(rotulo)
    if not rotulo or not referencias or texto.startswith("="):
        return False
    # Algumas planilhas têm faixas de referência em células deslocadas. Nelas,
    # o primeiro valor da faixa pode parecer o rótulo da linha; isso não é analito.
    if not re.search(r"[A-Za-zÀ-ÿ]", rotulo) or re.match(r"^\s*(?:[<>]=?|[-+]?\d|[-–—])", rotulo):
        return False
    ignorar = (
        "paciente", "idade", "proprietario", "numero", "raca", "veterinario",
        "registro", "sexo", "especie", "metodo", "parametros avaliados", "resultado",
        "valores de referencia", "bioquimica", "hematologia", "hemograma", "urin",
        "eritrograma", "leucograma", "plaquetas", "observacao", "conclusao", "laudo",
        "laboratorio", "responsavel", "data", "amostra", "material", "referencia",
    )
    if any(item in texto for item in ignorar):
        return False
    if texto in {
        "doador", "doador 1", "doador 2", "receptor", "fonte",
        "demais observacoes", "valor absoluto", "valor absoluto agregados",
        "valor absoluto pontilhados",
    }:
        return False
    referencia = " ".join(referencias)
    return bool(
        re.search(r"\d", referencia)
        or re.search(r"positivo|negativo|ausente|presente|normal|raro|nao observado", normalizar(referencia))
    )


def tecnica_seguinte(linhas: list[list[str]], indice: int) -> str | None:
    if indice + 1 >= len(linhas):
        return None
    primeira = next((valor.strip() for valor in linhas[indice + 1] if valor.strip()), "")
    marcadores = (
        "automat", "colorimet", "cinet", "fotometr", "microsc", "imuno", "manual",
        "refrat", "eletro", "espectro", "kit", "metodo",
    )
    return primeira if primeira and any(marcador in normalizar(primeira) for marcador in marcadores) else None


def secao(linha: list[str]) -> str | None:
    primeira = next((valor.strip() for valor in linha if valor.strip()), "")
    texto = normalizar(primeira)
    secoes = {
        "bioquimica": "Bioquímica",
        "hematologia": "Hematologia",
        "hemograma": "Hemograma",
        "eritrograma": "Eritrograma",
        "leucograma": "Leucograma",
        "plaquetas": "Plaquetas",
        "exame fisico": "Exame físico",
        "exame quimico": "Exame químico",
        "sedimentoscopia": "Sedimentoscopia",
        "coagulograma": "Coagulograma",
        "citologia": "Citologia",
        "parasitologico": "Parasitológico",
        "imunologico": "Imunológico",
    }
    if len([valor for valor in linha if valor.strip()]) <= 2:
        for chave, valor in secoes.items():
            if texto == chave or texto.startswith(chave + " "):
                return valor
    return None


def separar_unidade(rotulo: str) -> tuple[str, str | None]:
    encontrado = re.match(r"^(.*?)\s*\(([^()]*)\)\s*$", rotulo.strip())
    if not encontrado:
        return rotulo.strip(), None
    nome, unidade = encontrado.groups()
    return nome.strip(), unidade.strip() or None


def decimal(valor: str) -> str | None:
    valor = valor.strip().replace(",", ".")
    return valor if re.fullmatch(r"[-+]?\d+(?:\.\d+)?", valor) else None


def tipo_valor(referencias: list[str]) -> int:
    texto = " ".join(referencias)
    tem_numero = bool(re.search(r"\d", texto))
    tem_texto = bool(re.search(r"[A-Za-zÀ-ÿ]", texto))
    if tem_numero and tem_texto:
        return 4
    if tem_texto:
        return 3
    if any("." in valor or "," in valor for valor in referencias):
        return 2
    return 1


def extrair_ocorrencias(modelo: dict) -> list[dict]:
    ocorrencias = []
    encontrados: set[tuple[str, tuple[str, ...], str | None]] = set()
    for planilha in modelo["planilhas"]:
        secao_atual = None
        for indice, linha in enumerate(planilha["linhas"]):
            secao_identificada = secao(linha)
            if secao_identificada:
                secao_atual = secao_identificada
            preenchidas = [(posicao, valor.strip()) for posicao, valor in enumerate(linha) if valor.strip()]
            if not preenchidas:
                continue
            posicao, rotulo = preenchidas[0]
            referencias = valores_referencia(linha, posicao)
            if not parece_parametro(rotulo, referencias):
                continue
            chave = (rotulo, tuple(referencias), secao_atual)
            if chave in encontrados:
                continue
            encontrados.add(chave)
            nome, unidade = separar_unidade(rotulo)
            minimo = maximo = None
            if len(referencias) == 3 and referencias[1] == "-":
                minimo, maximo = decimal(referencias[0]), decimal(referencias[2])
            ocorrencias.append(
                {
                    "cdanalito": codigo(nome),
                    "nmanalito": nome,
                    "dsunidade": unidade,
                    "tpvalor": tipo_valor(referencias),
                    "dssecao": secao_atual,
                    "dsrotulo": rotulo,
                    "dstecnica": tecnica_seguinte(planilha["linhas"], indice),
                    "dsreferencia": " ".join(referencias),
                    "vrrefminimo": minimo,
                    "vrrefmaximo": maximo,
                }
            )
    return ocorrencias


def main() -> None:
    base = json.loads(FONTE.read_text(encoding="utf-8"))
    por_modelo = {}
    analitos: dict[str, dict] = {}
    unidades: dict[str, set[str]] = defaultdict(set)
    for ordem, modelo in enumerate(base["modelos"], start=1):
        if modelo["arquivo"] in {
            "Cão 2026\\IMUNO_ WOO_CÃO - Labvet 2026.xlsx",
            "Cão 2026\\IMUNO_LEPTO CAO - Labvet 2026.xlsx",
            "Gato 2026\\B_POP_FEL - Labvet.xlsx",
            "Gato 2026\\IMUNO_LIPASE- FEL- Labvet.xlsx",
        }:
            continue
        ocorrencias = extrair_ocorrencias(modelo)
        por_modelo[f"ML2026-{ordem:03d}"] = ocorrencias
        for ocorrencia in ocorrencias:
            item = analitos.setdefault(
                ocorrencia["cdanalito"],
                {"cdanalito": ocorrencia["cdanalito"], "nmanalito": ocorrencia["nmanalito"], "tpvalor": ocorrencia["tpvalor"]},
            )
            item["tpvalor"] = max(item["tpvalor"], ocorrencia["tpvalor"])
            if ocorrencia["dsunidade"]:
                unidades[ocorrencia["cdanalito"]].add(ocorrencia["dsunidade"])

    for cdanalito, item in analitos.items():
        unitario = unidades[cdanalito]
        item["dsunidade"] = next(iter(unitario)) if len(unitario) == 1 else None

    fontes_analitos = [
        "  (" + ", ".join(sql(item[campo]) for campo in ("cdanalito", "nmanalito", "dsunidade", "tpvalor")) + ")"
        for item in sorted(analitos.values(), key=lambda item: item["cdanalito"])
    ]
    fontes_ocorrencias = []
    for cdmodelo, ocorrencias in por_modelo.items():
        for ordem, ocorrencia in enumerate(ocorrencias, start=1):
            fontes_ocorrencias.append(
                "  (" + ", ".join(
                    sql(valor)
                    for valor in (
                        cdmodelo, ocorrencia["cdanalito"], ocorrencia["dssecao"], ordem,
                        ocorrencia["dsrotulo"], ocorrencia["dstecnica"], ocorrencia["dsunidade"],
                        ocorrencia["dsreferencia"], ocorrencia["vrrefminimo"], ocorrencia["vrrefmaximo"],
                    )
                ) + ")"
            )

    conteudo = """-- Labvet V1 — carga de analitos e parâmetros extraídos dos laudos de 2026.
-- Fonte: 157 modelos com exame comercial mapeado. Quatro modelos pendentes de catálogo não possuem parâmetros carregáveis.
-- As referências são preservadas em texto; os limites numéricos são preenchidos somente quando a origem contém uma faixa simples e inequívoca.

BEGIN;

SET search_path TO labvet, public;

WITH fonte (cdanalito, nmanalito, dsunidademedida, tpvalor) AS (
VALUES
""" + ",\n".join(fontes_analitos) + """
)
INSERT INTO analitos (cdanalito, nmanalito, dsunidademedida, tpvalor, stativo)
SELECT cdanalito, nmanalito, dsunidademedida, tpvalor::SMALLINT, true
FROM fonte
ON CONFLICT (cdanalito) DO UPDATE
SET
  nmanalito = EXCLUDED.nmanalito,
  dsunidademedida = EXCLUDED.dsunidademedida,
  tpvalor = EXCLUDED.tpvalor,
  stativo = EXCLUDED.stativo,
  dhalteracao = CURRENT_TIMESTAMP;

WITH fonte (
  cdmodelolaudo, cdanalito, dssecao, nrexibicao, dsrotulo,
  dstecnica, dsunidademedida, dsreferencia, vrrefminimo, vrrefmaximo
) AS (
VALUES
""" + ",\n".join(fontes_ocorrencias) + """
), vinculos AS (
  SELECT DISTINCT modelo.idexame, analito.idanalito
  FROM fonte
  JOIN modeloslaudos modelo ON modelo.cdmodelolaudo = fonte.cdmodelolaudo
  JOIN analitos analito ON analito.cdanalito = fonte.cdanalito
  WHERE modelo.idexame IS NOT NULL
)
INSERT INTO exameanalitos (idexame, idanalito, stativo)
SELECT idexame, idanalito, true
FROM vinculos
ON CONFLICT (idexame, idanalito) DO UPDATE
SET stativo = EXCLUDED.stativo, dhalteracao = CURRENT_TIMESTAMP;

WITH fonte (
  cdmodelolaudo, cdanalito, dssecao, nrexibicao, dsrotulo,
  dstecnica, dsunidademedida, dsreferencia, vrrefminimo, vrrefmaximo
) AS (
VALUES
""" + ",\n".join(fontes_ocorrencias) + """
)
INSERT INTO modeloexameanalitos (
  idmodelolaudo, idexameanalito, dssecao, nrexibicao, dsrotulo,
  dstecnica, dsunidademedida, dsreferencia, vrrefminimo, vrrefmaximo, stativo
)
SELECT
  modelo.idmodelolaudo, exameanalito.idexameanalito, fonte.dssecao, fonte.nrexibicao::INTEGER,
  fonte.dsrotulo, fonte.dstecnica, fonte.dsunidademedida, fonte.dsreferencia,
  fonte.vrrefminimo::NUMERIC(18,6), fonte.vrrefmaximo::NUMERIC(18,6), true
FROM fonte
JOIN modeloslaudos modelo ON modelo.cdmodelolaudo = fonte.cdmodelolaudo
JOIN analitos analito ON analito.cdanalito = fonte.cdanalito
JOIN exameanalitos exameanalito
  ON exameanalito.idexame = modelo.idexame
 AND exameanalito.idanalito = analito.idanalito
ON CONFLICT (idmodelolaudo, nrexibicao) DO UPDATE
SET
  idexameanalito = EXCLUDED.idexameanalito,
  dssecao = EXCLUDED.dssecao,
  dsrotulo = EXCLUDED.dsrotulo,
  dstecnica = EXCLUDED.dstecnica,
  dsunidademedida = EXCLUDED.dsunidademedida,
  dsreferencia = EXCLUDED.dsreferencia,
  vrrefminimo = EXCLUDED.vrrefminimo,
  vrrefmaximo = EXCLUDED.vrrefmaximo,
  stativo = EXCLUDED.stativo,
  dhalteracao = CURRENT_TIMESTAMP;

DO $$
DECLARE
  quantidadeanalitos INTEGER;
  quantidadeparametros INTEGER;
BEGIN
  SELECT COUNT(*) INTO quantidadeanalitos FROM analitos;
  IF quantidadeanalitos < """ + str(len(analitos)) + """ THEN
    RAISE EXCEPTION 'Carga de analitos incompleta: esperados ao menos """ + str(len(analitos)) + """, encontrados %.', quantidadeanalitos;
  END IF;

  SELECT COUNT(*) INTO quantidadeparametros
  FROM modeloexameanalitos parametro
  JOIN modeloslaudos modelo ON modelo.idmodelolaudo = parametro.idmodelolaudo
  WHERE modelo.cdmodelolaudo LIKE 'ML2026-%';
  IF quantidadeparametros <> """ + str(len(fontes_ocorrencias)) + """ THEN
    RAISE EXCEPTION 'Carga de parâmetros incompleta: esperados """ + str(len(fontes_ocorrencias)) + """, encontrados %.', quantidadeparametros;
  END IF;
END;
$$;

COMMIT;
"""
    DESTINO.write_text(conteudo, encoding="utf-8")
    print(f"Gerado: {DESTINO}")
    print(f"Analitos únicos: {len(analitos)}")
    print(f"Parâmetros em modelos mapeados: {len(fontes_ocorrencias)}")


if __name__ == "__main__":
    main()
