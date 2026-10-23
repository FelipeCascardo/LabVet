export type AnimalGrupo = {
  id: number
  nome: string
  descricao: string
  idGrupoPai: number | null
  ativo: boolean
}

export type ModeloExame = {
  id: number
  codigo: string
  nome: string
  faixaIdade: string
  arquivoOrigem: string
  idExame: number | null
  idAnimalGrupo: number | null
  ativo: boolean
}

export type ModeloExameInput = Omit<ModeloExame, 'id' | 'ativo'>

export type ModeloExameAnalito = {
  id: number
  idModeloExame: number
  idExameAnalito: number
  secao: string
  ordem: number
  rotulo: string
  tecnica: string
  unidadeMedida: string
  referencia: string
  referenciaMinima: string | null
  referenciaMaxima: string | null
  referenciaPercentualMinima: number | null
  referenciaPercentualMaxima: number | null
  ativo: boolean
}

export type ModeloExameAnalitoInput = Omit<ModeloExameAnalito, 'id' | 'ativo'>

export type Exame = {
  id: number
  codigo: string
  nome: string
  quantidade: number
  valor: number | null
  ativo: boolean
}

export type ExameAnalito = {
  id: number
  idExame: number
  idAnalito: number
  ativo: boolean
}

export type Analito = {
  id: number
  nome: string
  tecnica: string
  unidadeMedida: string
  tipoValor: number
  percentual: boolean
  ativo: boolean
}

const apiUrl = import.meta.env.VITE_API_URL ?? '/api/v1'

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
      const payload = JSON.parse(content) as { error?: { message?: string } | string, message?: string }
      message = (typeof payload.error === 'string' ? payload.error : payload.error?.message) ?? payload.message ?? message
    } catch {
      // A API pode retornar uma mensagem de exceção em texto simples.
    }

    throw new Error(message || `Erro HTTP ${response.status}.`)
  }

  if (response.status === 204) return undefined as T
  return response.json() as Promise<T>
}

export const modeloExamesApi = {
  listarGrupos: (accessToken: string) => request<AnimalGrupo[]>('/animal-grupos', accessToken),
  listarModelos: (accessToken: string) => request<ModeloExame[]>('/modelos-exames', accessToken),
  obterModelo: (id: number, accessToken: string) => request<ModeloExame>(`/modelos-exames/${id}`, accessToken),
  criarModelo: (input: ModeloExameInput, accessToken: string) => request<ModeloExame>('/modelos-exames', accessToken, { method: 'POST', body: JSON.stringify(input) }),
  atualizarModelo: (id: number, input: ModeloExameInput, accessToken: string) => request<ModeloExame>(`/modelos-exames/${id}`, accessToken, { method: 'PUT', body: JSON.stringify(input) }),
  definirModeloAtivo: (id: number, ativo: boolean, accessToken: string) => request<void>(ativo ? `/modelos-exames/${id}/reativar` : `/modelos-exames/${id}`, accessToken, { method: ativo ? 'POST' : 'DELETE' }),
  listarExames: (accessToken: string) => request<Exame[]>('/exames', accessToken),
  listarExameAnalitos: (accessToken: string) => request<ExameAnalito[]>('/exame-analitos', accessToken),
  listarCatalogoAnalitos: (accessToken: string) => request<Analito[]>('/analitos', accessToken),
  listarAnalitos: (idModeloExame: number, accessToken: string) =>
    request<ModeloExameAnalito[]>(
      `/modelos-exames-analitos?idModeloExame=${idModeloExame}`,
      accessToken,
    ),
  criarAnalitoModelo: (input: ModeloExameAnalitoInput, accessToken: string) => request<ModeloExameAnalito>('/modelos-exames-analitos', accessToken, { method: 'POST', body: JSON.stringify(input) }),
  atualizarAnalitoModelo: (id: number, input: ModeloExameAnalitoInput, accessToken: string) => request<ModeloExameAnalito>(`/modelos-exames-analitos/${id}`, accessToken, { method: 'PUT', body: JSON.stringify(input) }),
  definirAnalitoModeloAtivo: (id: number, ativo: boolean, accessToken: string) => request<void>(ativo ? `/modelos-exames-analitos/${id}/reativar` : `/modelos-exames-analitos/${id}`, accessToken, { method: ativo ? 'POST' : 'DELETE' }),
}
