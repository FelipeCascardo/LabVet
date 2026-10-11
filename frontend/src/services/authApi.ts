type LoginResponse = { accessToken: string; expiraEm: number }

const API_URL = import.meta.env.VITE_API_URL ?? '/api/v1'

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  let response: Response
  try {
    response = await fetch(`${API_URL}${path}`, {
      credentials: 'include',
      headers: { 'Content-Type': 'application/json', ...options.headers },
      ...options,
    })
  } catch {
    throw new Error('Não foi possível conectar à API do LabVet. Inicie o backend e tente novamente.')
  }
  if (!response.ok) {
    const content = await response.text()
    let message = content.trim()
    try {
      const payload = JSON.parse(content)
      message = payload?.error?.message ?? payload?.message ?? message
    } catch {
      // A API pode retornar uma mensagem de exceção em texto simples.
    }
    throw new Error(message || `Erro HTTP ${response.status}.`)
  }
  return response.status === 204 ? (undefined as T) : response.json() as Promise<T>
}

export const authApi = {
  login: (email: string, password: string) => request<LoginResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, senha: password }),
  }),
  logout: () => request<void>('/auth/logout', { method: 'POST' }),
}
