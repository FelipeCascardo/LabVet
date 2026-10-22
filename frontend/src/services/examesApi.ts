const apiUrl = import.meta.env.VITE_API_URL ?? '/api/v1'

export type Analito = {
  id: number
  codigo: string
  nome: string
  tecnica: string
  unidadeMedida: string
  tipoValor: 1 | 2 | 3
  percentual: boolean
  ativo: boolean
}

export type AnalitoInput = Omit<Analito, 'id' | 'ativo'>

export type ExameCategoria = {
  id: number
  nome: string
  ativo: boolean
}

export type ExameCategoriaInput = Pick<ExameCategoria, 'nome'>

export type AnimalGrupo = {
  id: number
  nome: string
  descricao: string
  idGrupoPai: number | null
  ativo: boolean
}

export type AnimalGrupoInput = Pick<AnimalGrupo, 'nome' | 'descricao' | 'idGrupoPai'>

export type Exame = {
  id: number
  idCategoria: number
  codigo: string
  nome: string
  quantidade: number
  valor: number | null
  primario: boolean
  idExamePai: number | null
  ativo: boolean
}

export type ExameInput = Omit<Exame, 'id' | 'ativo'>

export type ExameAnalito = {
  id: number
  idExame: number
  idAnalito: number
  ativo: boolean
}

export type ExameAnalitoInput = Pick<ExameAnalito, 'idExame' | 'idAnalito'>

async function request<T>(
  path: string,
  accessToken: string,
  init?: RequestInit,
): Promise<T> {
  let response: Response

  try {
    response = await fetch(`${apiUrl}${path}`, {
      ...init,
      headers: {
        Authorization: `Bearer ${accessToken}`,
        ...(init?.body ? { 'Content-Type': 'application/json' } : {}),
        ...init?.headers,
      },
    })
  } catch {
    throw new Error('Não foi possível conectar à API do LabVet.')
  }

  if (!response.ok) {
    const content = await response.text()
    let message = content.trim()

    try {
      const payload = JSON.parse(content) as { error?: { message?: string } | string; message?: string }
      const detalheErro = typeof payload.error === 'string' ? payload.error : payload.error?.message
      message = detalheErro ?? payload.message ?? message
    } catch {
      // A API pode retornar erros em texto simples.
    }

    throw new Error(message || `Erro HTTP ${response.status}.`)
  }

  if (response.status === 204) return undefined as T
  return response.json() as Promise<T>
}

export const examesApi = {
  listarGruposAnimais: (accessToken: string, incluirInativos = false) => request<AnimalGrupo[]>(
    incluirInativos ? '/animal-grupos?incluirInativos=true' : '/animal-grupos',
    accessToken,
  ),
  obterGrupoAnimal: (id: number, accessToken: string) => request<AnimalGrupo>(`/animal-grupos/${id}`, accessToken),
  criarGrupoAnimal: (input: AnimalGrupoInput, accessToken: string) => request<AnimalGrupo>('/animal-grupos', accessToken, {
    method: 'POST',
    body: JSON.stringify(input),
  }),
  atualizarGrupoAnimal: (id: number, input: AnimalGrupoInput, accessToken: string) => request<AnimalGrupo>(`/animal-grupos/${id}`, accessToken, {
    method: 'PUT',
    body: JSON.stringify(input),
  }),
  definirGrupoAnimalAtivo: (id: number, ativo: boolean, accessToken: string) => request<void>(
    ativo ? `/animal-grupos/${id}/reativar` : `/animal-grupos/${id}`,
    accessToken,
    { method: ativo ? 'POST' : 'DELETE' },
  ),
  listarCategorias: (accessToken: string, incluirInativos = false) => request<ExameCategoria[]>(
    incluirInativos ? '/exame-categorias?incluirInativos=true' : '/exame-categorias',
    accessToken,
  ),
  obterCategoria: (id: number, accessToken: string) => request<ExameCategoria>(`/exame-categorias/${id}`, accessToken),
  criarCategoria: (input: ExameCategoriaInput, accessToken: string) => request<ExameCategoria>('/exame-categorias', accessToken, {
    method: 'POST',
    body: JSON.stringify(input),
  }),
  atualizarCategoria: (id: number, input: ExameCategoriaInput, accessToken: string) => request<ExameCategoria>(`/exame-categorias/${id}`, accessToken, {
    method: 'PUT',
    body: JSON.stringify(input),
  }),
  definirCategoriaAtiva: (id: number, ativo: boolean, accessToken: string) => request<void>(
    ativo ? `/exame-categorias/${id}/reativar` : `/exame-categorias/${id}`,
    accessToken,
    { method: ativo ? 'POST' : 'DELETE' },
  ),
  listarExames: (accessToken: string, incluirInativos = false) => request<Exame[]>(
    incluirInativos ? '/exames?incluirInativos=true' : '/exames',
    accessToken,
  ),
  obterExame: (id: number, accessToken: string) => request<Exame>(`/exames/${id}`, accessToken),
  criarExame: (input: ExameInput, accessToken: string) => request<Exame>('/exames', accessToken, {
    method: 'POST',
    body: JSON.stringify(input),
  }),
  atualizarExame: (id: number, input: ExameInput, accessToken: string) => request<Exame>(`/exames/${id}`, accessToken, {
    method: 'PUT',
    body: JSON.stringify(input),
  }),
  definirExameAtivo: (id: number, ativo: boolean, accessToken: string) => request<void>(
    ativo ? `/exames/${id}/reativar` : `/exames/${id}`,
    accessToken,
    { method: ativo ? 'POST' : 'DELETE' },
  ),
  listarExameAnalitos: (accessToken: string, incluirInativos = false) => request<ExameAnalito[]>(
    incluirInativos ? '/exame-analitos?incluirInativos=true' : '/exame-analitos',
    accessToken,
  ),
  criarExameAnalito: (input: ExameAnalitoInput, accessToken: string) => request<ExameAnalito>('/exame-analitos', accessToken, {
    method: 'POST',
    body: JSON.stringify(input),
  }),
  definirExameAnalitoAtivo: (id: number, ativo: boolean, accessToken: string) => request<void>(
    ativo ? `/exame-analitos/${id}/reativar` : `/exame-analitos/${id}`,
    accessToken,
    { method: ativo ? 'POST' : 'DELETE' },
  ),
  listarAnalitos: (accessToken: string, incluirInativos = false) => request<Analito[]>(
    incluirInativos ? '/analitos?incluirInativos=true' : '/analitos',
    accessToken,
  ),
  obterAnalito: (id: number, accessToken: string) => request<Analito>(`/analitos/${id}`, accessToken),
  criarAnalito: (input: AnalitoInput, accessToken: string) => request<Analito>('/analitos', accessToken, {
    method: 'POST',
    body: JSON.stringify(input),
  }),
  atualizarAnalito: (id: number, input: AnalitoInput, accessToken: string) => request<Analito>(`/analitos/${id}`, accessToken, {
    method: 'PUT',
    body: JSON.stringify(input),
  }),
  definirAnalitoAtivo: (id: number, ativo: boolean, accessToken: string) => request<void>(
    ativo ? `/analitos/${id}/reativar` : `/analitos/${id}`,
    accessToken,
    { method: ativo ? 'POST' : 'DELETE' },
  ),
}
