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
      const payload = JSON.parse(content) as { error?: { message?: string }; message?: string }
      message = payload.error?.message ?? payload.message ?? message
    } catch {
      // A API pode retornar erros em texto simples.
    }

    throw new Error(message || `Erro HTTP ${response.status}.`)
  }

  if (response.status === 204) return undefined as T
  return response.json() as Promise<T>
}

export const examesApi = {
  listarAnalitos: (accessToken: string) => request<Analito[]>('/analitos', accessToken),
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
