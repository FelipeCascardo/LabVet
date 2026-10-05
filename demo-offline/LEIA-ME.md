# LabVet — demonstração offline

Esta pasta é uma demonstração **somente leitura**. Ela consulta os dados já
exportados em `dados/`, sem PostgreSQL, API, autenticação ou acesso à rede.

## Como abrir

1. Mantenha todos os arquivos desta pasta juntos.
2. Dê dois cliques em `Abrir demonstracao.bat`.
3. O navegador abrirá em `http://127.0.0.1:4174`. A janela preta deve permanecer
   aberta enquanto a demonstração estiver em uso; ela só atende o próprio
   computador.

Não é necessário instalar PostgreSQL, Node.js ou qualquer aplicativo adicional
na máquina que receber a demonstração.

## Conteúdo

- `index.html`, `app.js` e `estilos.css`: páginas e comportamento da consulta.
- `dados/atendimentos.json`: atendimentos, pacientes, responsáveis e exames
  solicitados.
- `dados/laudos.json`: metadados e texto extraído dos laudos vinculados.
- `ferramentas/exportar-dados.ps1`: atualização técnica dos JSONs a partir do
  PostgreSQL local do LabVet. Não é usado para apresentar a demonstração.

## Segurança dos dados

Os JSONs incluem informações reais de pacientes e proprietários. Distribua a
pasta somente a pessoas autorizadas. A demonstração não possui autenticação nem
criptografia do conteúdo; quem receber a pasta poderá ler os arquivos JSON.

## Atualização dos dados

Na máquina de desenvolvimento, com o PostgreSQL do LabVet em execução, execute:

```powershell
./ferramentas/exportar-dados.ps1
```

O script é somente leitura e sobrescreve exclusivamente os dois JSONs da pasta
`dados/`. Revise o resultado antes de distribuir uma nova cópia da demonstração.
