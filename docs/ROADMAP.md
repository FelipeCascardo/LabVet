# LabVet — Roadmap

Atualizado: 15/10/2026

## Fundação do ambiente

- [x] Disponibilizar a base oficial Labvet V1 no PostgreSQL de desenvolvimento.
- [x] Registrar como o ambiente seleciona essa base.
- [x] Validar e aplicar as migrations de estrutura na ordem correta até a 013.
- [x] Confirmar backup antes de evolução estrutural relevante.

## Catálogo de exames

- [x] Modelar categorias, exames, analitos e associações.
- [x] Criar a estrutura de modelos de exame e seus analitos.
- [x] Versionar as renomeações `modeloslaudos → modeloexames` e
  `tiposanimais → animalgrupos`.
- [ ] Concluir o CRUD dos repositories individuais.
- [ ] Criar services individuais com validações de domínio.
- [x] Criar controllers e rotas HTTP para cada entidade.
- [ ] Validar inativação e auditoria de alterações.

## Modelos de exame

- [ ] Implementar a leitura do agregado de detalhe do modelo.
- [ ] Gravar cabeçalho e analitos em uma transação única.
- [ ] Validar ordem de exibição, referências numéricas e referências textuais.
- [ ] Inativar itens removidos sem perder histórico.

## Realização de exames e laudos

- [x] Criar o rascunho estrutural de `laudos` e `laudoanalitos`.
- [ ] Criar e revisar as tabelas `atendimentos`, `laudos`, `laudoanalitos` e
  `laudonotas`.
- [ ] Definir vínculos com paciente, atendimento, coleta e responsáveis.
- [ ] Implementar o processo de importação com mapeamento para os modelos de
  exame e seus analitos.
- [ ] Implementar consultas de atendimentos e laudos.
- [ ] Definir a persistência dos valores realizados e o ciclo de emissão.
- [ ] Revisar e aplicar a migration de laudos após aprovação funcional.

## Interface e operação

- [x] Integrar a consulta de modelos de exame à API.
- [x] Preparar o frontend de produção local em Nginx/Docker, isolado em
  `127.0.0.1:8081`.
- [x] Publicar e validar o Cloudflare Tunnel para `app.labvet.app`.
- [ ] Configurar Cloudflare Access para proteger `app.labvet.app`.
- [ ] Validar login, sessão e autorização nas novas rotas.
- [x] Compilar o backend Delphi Win64 e testar a API localmente.
- [ ] Documentar o contrato HTTP conforme cada controller for entregue.

## Critério de passagem

Uma etapa de cadastro só é considerada concluída quando seu schema, repository,
service, controller e rota estão alinhados, compilados e validados contra a
base oficial Labvet V1.
