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
  unidadeMedida: string
  tipoValor: number
  percentual: boolean
  ativo: boolean
}

const apiUrl = import.meta.env.VITE_API_URL ?? '/api/v1'

async function request<T>(
  path: string,
  accessToken: string,
): Promise<T> {
  let response: Response

  try {
    response = await fetch(`${apiUrl}${path}`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    })
  } catch {
    throw new Error('Não foi possível conectar à API do LabVet.')
  }

  if (!response.ok) {
    const content = await response.text()
    let message = content.trim()

    try {
      const payload = JSON.parse(content) as { error?: { message?: string }, message?: string }
      message = payload.error?.message ?? payload.message ?? message
    } catch {
      // A API pode retornar uma mensagem de exceção em texto simples.
    }

    throw new Error(message || `Erro HTTP ${response.status}.`)
  }

  return response.json() as Promise<T>
}

export const modeloExamesApi = {
  listarGrupos: (accessToken: string) => request<AnimalGrupo[]>('/animal-grupos', accessToken),
  listarModelos: (accessToken: string) => request<ModeloExame[]>('/modelos-exames', accessToken),
  listarExames: (accessToken: string) => request<Exame[]>('/exames', accessToken),
  listarExameAnalitos: (accessToken: string) => request<ExameAnalito[]>('/exame-analitos', accessToken),
  listarCatalogoAnalitos: (accessToken: string) => request<Analito[]>('/analitos', accessToken),
  listarAnalitos: (idModeloExame: number, accessToken: string) =>
    request<ModeloExameAnalito[]>(
      `/modelos-exames-analitos?idModeloExame=${idModeloExame}`,
      accessToken,
    ),
}
