# Rotina de trabalho do LabVet

## Início de sessão

Antes de analisar, alterar ou executar qualquer artefato do projeto, leia
`docs/PROJECT_STATE.md`. Esse documento registra o ponto de parada, as
pendências, os riscos e as próximas atividades priorizadas.

Leia também o guia canônico de programação Delphi em
`C:\Projetos\Documentacoes\Padroes-Gerais\PADROES_PROGRAMACAO_DELPHI.md`.
Ele define a organização de units, formatação, uso de recursos, tratamento de
erros e responsabilidades das camadas.

Em caso de divergência entre esse status e o código ou o banco de dados,
confira a evidência disponível e atualize o status antes de prosseguir.

## Units Delphi

Toda nova unit Delphi criada para o backend deve ser registrada na mesma
alteração em ambos os arquivos de projeto:

- `backend/LabVet.dpr`, no bloco `uses`, com namespace e caminho da unit;
- `backend/LabVet.dproj`, como `DCCReference`.

Antes de concluir a entrega, confirme que as duas referências apontam para o
arquivo criado e que o namespace declarado na unit corresponde a elas.

## Evoluções e correções

Toda evolução ou correção deve atualizar os artefatos de documentação
impactados na mesma sessão. Conforme o tipo de alteração, revisar:

- `docs/PROJECT_STATE.md` para estado, pendências e validações;
- `docs/WORK_HISTORY.md` para o registro cronológico da entrega;
- `docs/ARCHITECTURE.md` para componentes, camadas ou decisões técnicas;
- `docs/PRODUCT.md` e `docs/ROADMAP.md` para escopo e planejamento;
- especificações, diagramas e padrões técnicos relacionados.

Não declarar uma atividade concluída sem registrar a documentação que ela
alterou e a validação realizada.
