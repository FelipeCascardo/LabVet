# Bases de Dados do LabVet

## Base oficial do produto

A base oficial do LabVet é **Labvet V1**. Ela é a fonte de dados do
aplicativo e deve receber as estruturas e migrations mantidas em
`database/estrutura`.

As entidades do domínio de exames pertencem a essa base, incluindo:

- `examecategorias`;
- `exames`;
- `analitos`;
- `animalgrupos`;
- `exameanalitos`;
- `modeloexames`;
- `modeloexameanalitos`.

## Regra operacional

Antes de executar qualquer migration, confirmar o banco de destino com:

```sql
select current_database(), current_user;
```

As migrations do produto devem ser executadas somente quando a conexão estiver
na base **Labvet V1**. Caso o resultado seja diferente, a execução deve ser
interrompida e a configuração do ambiente deve ser corrigida antes de qualquer
alteração.

