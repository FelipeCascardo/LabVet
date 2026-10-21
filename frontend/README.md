# Frontend LabVet

Aplicação React + TypeScript que compõe a interface do LabVet.

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
- a sessão é mantida apenas enquanto a página está aberta: ao recarregar ou abrir novamente o LabVet, o login é solicitado;
- identidade visual do LabVet aplicada no login e no menu lateral;
- sidebar com os módulos de dashboard, cadastros, laboratório e utilitários;
- grupo Exames com rotas de catálogo; Analitos é o primeiro cadastro conectado
  à API, com pesquisa, seleção, ordenação, paginação local e edição;
- componentes reutilizáveis de pesquisa/seleção e edição para os demais
  cadastros de Exames;
- dashboard ainda sem indicadores reais: o próximo corte conectará os contratos de dados da API.
