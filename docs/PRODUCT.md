# LabVet — Produto

Atualizado: 21/10/2026

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
- manutenção administrativa de categorias, exames e analitos pela interface,
  incluindo a composição de analitos de cada exame;
- modelos de exame e a configuração de seus analitos;
- preparação do registro de realização de exames e laudos, separado do cadastro
  operacional de modelos.

## Princípios do domínio

- A base oficial é **Labvet V1**; ela contém o modelo de dados do produto.
- Cadastros são inativados; a exclusão física não é o comportamento padrão.
- Um modelo de exame pode ser associado a um exame e, opcionalmente, a um grupo
  de animais e a uma faixa de idade.
- Os itens de um modelo preservam a ordem de apresentação e suas referências.
- A realização de um exame deve preservar os valores e referências vigentes no
  momento da emissão, sem alterar a configuração reutilizável do modelo.

## Fora do escopo atual

- gestão de atendimento clínico;
- emissão final do laudo para cliente;
- faturamento e integração financeira;
- perfis e permissões além da autenticação administrativa já existente.

## Referências de domínio

- [Diagrama ER de exames](diagrama-er-exames.svg)
- [Diagrama ER de exames e modelos](diagrama-er-exames-modelos.svg)
- [Imagem PNG do diagrama ER de exames e modelos](diagrama-er-exames-modelos.png)
- [Especificação do backend de modelos de exames](spec-backend-modelosexames.md)
- [Especificação das páginas de cadastro de exames](spec-frontend-cadastros-exames.md)
- [Bases de dados](BASES_DE_DADOS.md)
- [Rascunho de laudos](../database/estrutura/014_laudos_e_laudoanalitos.sql)
