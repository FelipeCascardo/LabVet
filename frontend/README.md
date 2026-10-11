# Frontend LabVet

Aplicação React + TypeScript que substitui a POC offline como interface definitiva do LabVet.

## Executar localmente

1. Compile a API Delphi e execute `Iniciar Backend.bat`; ela deve ficar aberta na porta `9010`.
2. Na raiz do repositório, execute `Iniciar Frontend.bat`.
3. Acesse `http://127.0.0.1:5173`.

O servidor Vite encaminha chamadas iniciadas por `/api` para a API local. Assim, o login usa `POST /api/v1/auth/login` sem depender de CORS durante o desenvolvimento.

## Estrutura

- `src/app`: rotas, guarda de autenticação e navegação;
- `src/features`: páginas de login e módulos funcionais;
- `src/layouts`: casca autenticada e menu lateral;
- `src/services`: comunicação com a API;
- `src/index.css`: tema global e comportamento responsivo.

## Situação atual

- Login conectado à API;
- sidebar com os módulos de dashboard, cadastros, laboratório e utilitários;
- páginas-base prontas para receber listagens e formulários;
- dashboard ainda sem indicadores reais: o próximo corte conectará os contratos de dados da API.
