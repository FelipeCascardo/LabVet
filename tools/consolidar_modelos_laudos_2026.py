from __future__ import annotations

import json
import re
import unicodedata
from collections import Counter
from pathlib import Path


SOURCE = Path(r"C:\Projetos\LabVet\tmp\analise_modelos_laudos_2026.json")
OUTPUT = Path(r"C:\Projetos\LabVet\tmp\consolidado_modelos_laudos_2026.json")


def normalizar(valor: str) -> str:
    valor = unicodedata.normalize("NFKD", valor)
    valor = "".join(caractere for caractere in valor if not unicodedata.combining(caractere))
    return re.sub(r"\s+", " ", valor).strip().casefold()


def valores_referencia(linha: list[str], posicao: int) -> list[str]:
    valores = []
    for valor in linha[posicao + 1 :]:
        valor = valor.strip()
        if not valor or valor.startswith("="):
            continue
        valores.append(valor)
    return valores


def parece_parametro(rotulo: str, referencias: list[str]) -> bool:
    texto = normalizar(rotulo)
    if not rotulo or not referencias or texto.startswith("="):
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
    referencia = " ".join(referencias)
    return bool(
        re.search(r"\d", referencia)
        or re.search(r"positivo|negativo|ausente|presente|normal|raro|nao observado", normalizar(referencia))
    )


def tipo_valor(referencias: list[str]) -> str:
    texto = " ".join(referencias)
    tem_numero = bool(re.search(r"\d", texto))
    tem_texto = bool(re.search(r"[A-Za-zÀ-ÿ]", texto))
    if tem_numero and tem_texto:
        return "misto"
    if tem_numero:
        return "numérico"
    return "texto" if tem_texto else "não identificado"


def tecnica_seguinte(linhas: list[list[str]], indice: int) -> str | None:
    if indice + 1 >= len(linhas):
        return None
    proxima = linhas[indice + 1]
    primeira = next((valor.strip() for valor in proxima if valor.strip()), "")
    texto = normalizar(primeira)
    marcadores = (
        "automat", "colorimet", "cinet", "fotometr", "microsc", "imuno", "manual",
        "refrat", "eletro", "espectro", "kit", "metodo",
    )
    return primeira if primeira and any(marcador in texto for marcador in marcadores) else None


def analitos_modelo(modelo: dict) -> list[dict]:
    encontrados: dict[tuple[str, tuple[str, ...]], dict] = {}
    for planilha in modelo["planilhas"]:
        linhas = planilha["linhas"]
        for indice, linha in enumerate(linhas):
            preenchidas = [(posicao, valor.strip()) for posicao, valor in enumerate(linha) if valor.strip()]
            if not preenchidas:
                continue
            posicao, rotulo = preenchidas[0]
            referencias = valores_referencia(linha, posicao)
            if not parece_parametro(rotulo, referencias):
                continue
            chave = (rotulo, tuple(referencias))
            encontrados[chave] = {
                "nome": rotulo,
                "referencias": referencias,
                "tipoValor": tipo_valor(referencias),
                "tecnica": tecnica_seguinte(linhas, indice),
                "planilha": planilha["nome"],
            }
    return list(encontrados.values())


def main() -> None:
    base = json.loads(SOURCE.read_text(encoding="utf-8"))
    modelos = []
    tipos = Counter()
    analitos = Counter()
    tecnicas = Counter()
    for modelo in base["modelos"]:
        itens = analitos_modelo(modelo)
        for item in itens:
            tipos[item["tipoValor"]] += 1
            analitos[item["nome"]] += 1
            if item["tecnica"]:
                tecnicas[item["tecnica"]] += 1
        modelos.append(
            {
                "arquivo": modelo["arquivo"],
                "grupoAnimal": modelo["grupoAnimal"],
                "idadeMencionada": modelo["idadeMencionada"],
                "analitos": itens,
                "cabecalhos": modelo["linhasCabecalho"],
            }
        )
    OUTPUT.write_text(
        json.dumps(
            {
                "gruposAnimal": base["gruposAnimal"],
                "modelos": modelos,
                "tiposValor": dict(tipos),
                "analitosFrequentes": analitos.most_common(),
                "tecnicasFrequentes": tecnicas.most_common(),
                "arquivosXlsNaoLidos": [
                    str(caminho.relative_to(SOURCE.parents[1] / "Importação" / "Laudos 2026"))
                    for caminho in sorted((SOURCE.parents[1] / "Importação" / "Laudos 2026").rglob("*.xls"))
                ],
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    print(OUTPUT)
    print(f"modelos={len(modelos)} analitosExtraidos={sum(len(m['analitos']) for m in modelos)}")


if __name__ == "__main__":
    main()
