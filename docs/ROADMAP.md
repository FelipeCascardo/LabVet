# LabVet — Roadmap

Atualizado: 12/10/2026

## Fundação do ambiente

- [ ] Disponibilizar a base oficial Labvet V1 no PostgreSQL de desenvolvimento.
- [ ] Registrar como o ambiente seleciona essa base.
- [ ] Validar e aplicar as migrations de estrutura na ordem correta.
- [ ] Confirmar backup e restauração antes de cargas relevantes.

## Catálogo de exames

- [x] Modelar categorias, exames, analitos e associações.
- [x] Criar a estrutura de modelos de exame e seus analitos.
- [x] Versionar as renomeações `modeloslaudos → modeloexames` e
  `tiposanimais → animalgrupos`.
- [ ] Concluir o CRUD dos repositories individuais.
- [ ] Criar services individuais com validações de domínio.
- [ ] Criar controllers e rotas HTTP para cada entidade.
- [ ] Validar inativação e auditoria de alterações.

## Modelos de exame

- [ ] Implementar a leitura do agregado de detalhe do modelo.
- [ ] Gravar cabeçalho e analitos em uma transação única.
- [ ] Validar ordem de exibição, referências numéricas e referências textuais.
- [ ] Inativar itens removidos sem perder histórico.

## Interface e operação

- [ ] Integrar o cadastro de modelos de exame à API.
- [ ] Validar login, sessão e autorização nas novas rotas.
- [ ] Compilar o backend Delphi Win64 e testar a API localmente.
- [ ] Documentar o contrato HTTP conforme cada controller for entregue.

## Critério de passagem

Uma etapa de cadastro só é considerada concluída quando seu schema, repository,
service, controller e rota estão alinhados, compilados e validados contra a
base oficial Labvet V1.
