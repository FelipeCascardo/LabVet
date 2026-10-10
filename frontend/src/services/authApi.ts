type LoginResponse = { accessToken: string; expiraEm: number }

const API_URL = import.meta.env.VITE_API_URL ?? '/api/v1'

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const response = await fetch(`${API_URL}${path}`, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options,
  })
  if (!response.ok) {
    const payload = await response.json().catch(() => null)
    throw new Error(payload?.error?.message ?? payload?.message ?? 'Não foi possível concluir a operação.')
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
