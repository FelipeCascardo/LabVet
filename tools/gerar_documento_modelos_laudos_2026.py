from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path


SOURCE = Path(r"C:\Projetos\LabVet\tmp\consolidado_modelos_laudos_2026.json")
OUTPUT = Path(r"C:\Projetos\LabVet\docs\analise-modelos-laudos-2026.md")


def md(valor: str) -> str:
    return valor.replace("|", "\\|").replace("\n", " ")


def analito_linha(analito: dict) -> str:
    referencia = " ".join(analito["referencias"]).strip() or "não identificada"
    tecnica = f"; técnica: {analito['tecnica']}" if analito["tecnica"] else ""
    return f"{analito['nome']} — referência: {referencia}; tipo: {analito['tipoValor']}{tecnica}"


def main() -> None:
    base = json.loads(SOURCE.read_text(encoding="utf-8"))
    por_grupo: dict[str, list[dict]] = defaultdict(list)
    for modelo in base["modelos"]:
        por_grupo[modelo["grupoAnimal"] or "Sem agrupamento"] .append(modelo)

    total_analitos = sum(len(modelo["analitos"]) for modelo in base["modelos"])
    modelos_idade = [modelo for modelo in base["modelos"] if modelo["idadeMencionada"]]
    linhas = [
        "# Análise dos modelos de laudos de 2026",
        "",
        "## Escopo e método",
        "",
        "Foram lidos 161 modelos `.xlsx` na pasta `Importação/Laudos 2026`. "
        "A classificação de animal abaixo reproduz a organização operacional do laboratório, "
        "sem convertê-la para taxonomia científica. A extração considera títulos, parâmetros, "
        "valores de referência e técnicas presentes nas planilhas.",
        "",
        f"Foram identificadas **{total_analitos} ocorrências de analitos** nos modelos. "
        "Uma ocorrência representa a presença de um parâmetro em um modelo; o mesmo analito pode aparecer em vários modelos.",
        "",
        "Quatro arquivos `.xls` não foram lidos estruturalmente pelo leitor disponível e estão listados como pendência de revisão manual no fim deste documento.",
        "",
        "## Cobertura por tipo de animal do laboratório",
        "",
        "| Tipo de animal / agrupamento operacional | Modelos |",
        "| --- | ---: |",
    ]
    for grupo, quantidade in sorted(base["gruposAnimal"].items()):
        linhas.append(f"| {md(grupo or 'Sem agrupamento')} | {quantidade} |")

    linhas += [
        "",
        "## Estrutura observada nos laudos",
        "",
        "Os modelos geralmente apresentam o bloco **Parâmetros avaliados**, uma área de resultado, "
        "uma ou mais colunas de **Valores de Referência** e, em muitos casos, uma linha seguinte com a técnica de medição. "
        "Foram encontradas referências numéricas, textuais e mistas.",
        "",
        "| Forma de referência identificada | Ocorrências de analitos |",
        "| --- | ---: |",
    ]
    for tipo, quantidade in sorted(base["tiposValor"].items()):
        linhas.append(f"| {md(tipo)} | {quantidade} |")

    linhas += [
        "",
        "As técnicas mais frequentes identificadas foram:",
        "",
        "| Técnica | Ocorrências |",
        "| --- | ---: |",
    ]
    for tecnica, quantidade in base["tecnicasFrequentes"][:15]:
        linhas.append(f"| {md(tecnica)} | {quantidade} |")

    linhas += [
        "",
        f"Há **{len(modelos_idade)} modelos** com indicação textual de faixa ou condição de idade, como `adulto`, `filhote` ou referências em meses. "
        "Essas indicações vêm do nome do modelo e/ou do conteúdo da planilha.",
        "",
        "## Comparação com o modelo atual",
        "",
        "| Tabela | Situação atual | Evidência dos modelos | Ajuste necessário |",
        "| --- | --- | --- | --- |",
        "| `exames` | Representa o catálogo comercial. | Um mesmo exame possui vários modelos por tipo de animal e faixa de idade. | Criar entidade de modelo de laudo vinculada ao exame. |",
        "| `analitos` | Possui nome, código, técnica, unidade e `tpvalor`. | Técnicas podem mudar conforme o modelo e alguns parâmetros têm resposta textual ou mista. | Manter a técnica padrão no analito, mas permitir técnica e rótulo de exibição no vínculo com o modelo. |",
        "| `exameanalitos` | Liga exame e analito; referências mínima e máxima são `NUMERIC`. | Há 85 ocorrências textuais e 111 mistas; valores de referência variam por agrupamento operacional de animal e idade. | Não usar apenas limites numéricos. Mover as referências para uma estrutura própria, com texto livre e contexto de modelo, animal e idade. |",
        "",
        "## Modelo recomendado para a próxima revisão",
        "",
        "1. Manter `exameanalitos` como a associação base entre um exame e um analito.",
        "2. Criar `tipoanimais` para os agrupamentos internos do laboratório, por exemplo `Cão`, `Bovino` e `Silvestres > Aves`. Esse cadastro não é uma tabela taxonômica.",
        "3. Criar `modeloslaudos`, ligado a `exames` e `tipoanimais`, com nome do modelo e a faixa etária descritiva original.",
        "4. Criar `modeloexameanalitos` para os parâmetros que aparecem em cada modelo. A tabela deve registrar `dssecao`, `nrexibicao`, `dsrotulo`, `dstecnica`, `dsreferencia`, `vrrefminimo` e `vrrefmaximo`.",
        "5. Preservar `dsreferencia` como `TEXT`, mesmo quando houver limites numéricos. Os limites numéricos continuam úteis para cálculo, mas não conseguem representar referências como `negativo`, `ausente`, observações e faixas condicionais.",
        "6. Para idade, registrar primeiro `dsfaixaidade` conforme o modelo original. A normalização em mínimo, máximo e unidade deve ser feita após validação do laboratório.",
        "",
        "A regra de unicidade atual de `exameanalitos (idexame, idanalito)` deve permanecer para o vínculo base. As várias faixas de referência devem existir em `modeloexameanalitos`, e não como linhas duplicadas sem contexto em `exameanalitos`.",
        "",
        "## Inventário dos modelos `.xlsx`",
        "",
        "Cada item abaixo é um modelo de laudo. `Análitos` reproduz os parâmetros identificados automaticamente, incluindo referência e técnica quando presentes.",
    ]

    for grupo, modelos in sorted(por_grupo.items()):
        linhas += ["", f"### {grupo or 'Sem agrupamento'}", ""]
        for modelo in sorted(modelos, key=lambda item: item["arquivo"]):
            idade = ", ".join(modelo["idadeMencionada"]) if modelo["idadeMencionada"] else "Não indicada"
            linhas += [
                f"#### {Path(modelo['arquivo']).stem}",
                "",
                f"- Arquivo: `{modelo['arquivo']}`",
                f"- Tipo de animal: {grupo or 'Sem agrupamento'}",
                f"- Idade: {idade}",
                f"- Analitos identificados: {len(modelo['analitos'])}",
            ]
            if modelo["analitos"]:
                linhas.append("- Estrutura de analitos:")
                for analito in modelo["analitos"]:
                    linhas.append(f"  - {analito_linha(analito)}")
            else:
                linhas.append("- Estrutura de analitos: não identificada automaticamente; requer revisão manual.")

    linhas += ["", "## Arquivos `.xls` pendentes de leitura estrutural", ""]
    for arquivo in base["arquivosXlsNaoLidos"]:
        linhas.append(f"- `{arquivo}`")
    linhas += [
        "",
        "## Próxima etapa recomendada",
        "",
        "Validar com o laboratório a nomenclatura dos agrupamentos de animal, as faixas etárias e a composição dos pacotes. Depois disso, aprovar a migração das referências para a estrutura por modelo de laudo antes de cadastrar os analitos definitivos.",
        "",
    ]
    OUTPUT.write_text("\n".join(linhas), encoding="utf-8")
    print(OUTPUT)
    print(f"modelos={len(base['modelos'])} analitos={total_analitos} idade={len(modelos_idade)}")


if __name__ == "__main__":
    main()
