# LabVet — Produto

Atualizado: 12/10/2026

## Visão

LabVet é o sistema de apoio ao laboratório veterinário. O produto organiza o
catálogo de exames, os grupos de animais, os analitos e os modelos de exame
usados na emissão e manutenção de laudos.

## Problema e objetivo

Os modelos de exames e os dados extraídos de laudos precisam deixar de ser
arquivos isolados para se tornarem cadastros consistentes, pesquisáveis e
auditáveis. O primeiro objetivo é disponibilizar uma API que permita manter
essas estruturas e que sirva de base para as telas administrativas do LabVet.

## Escopo atual

- autenticação, sessão e auditoria administrativa;
- categorias e catálogo de exames;
- grupos de animais com hierarquia opcional;
- analitos e associação entre exame e analito;
- modelos de exame e a configuração de seus analitos;
- preparação de dados de laudos para uso futuro, separada do cadastro operacional.

## Princípios do domínio

- A base oficial é **Labvet V1**; ela contém o modelo de dados do produto.
- Cadastros são inativados; a exclusão física não é o comportamento padrão.
- Um modelo de exame pode ser associado a um exame e, opcionalmente, a um grupo
  de animais e a uma faixa de idade.
- Os itens de um modelo preservam a ordem de apresentação e suas referências.

## Fora do escopo atual

- gestão de atendimento clínico;
- emissão final do laudo para cliente;
- faturamento e integração financeira;
- perfis e permissões além da autenticação administrativa já existente.

## Referências de domínio

- [Diagrama ER de exames](diagrama-er-exames.svg)
- [Especificação do backend de modelos de exames](spec-backend-modelosexames.md)
- [Bases de dados](BASES_DE_DADOS.md)
