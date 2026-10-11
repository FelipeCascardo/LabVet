import { useMemo, useState, type PropsWithChildren } from 'react'
import { authApi } from '../../services/authApi'
import { AuthContext, type AuthContextValue } from './AuthContext'

export function AuthProvider({ children }: PropsWithChildren) {
  // A sessão permanece somente enquanto a aplicação está aberta.
  const [accessToken, setAccessToken] = useState<string | null>(null)
  const value = useMemo<AuthContextValue>(() => ({
    accessToken,
    async login(email, password) {
      const response = await authApi.login(email, password)
      setAccessToken(response.accessToken)
    },
    async logout() {
      try {
        await authApi.logout()
      } finally {
        setAccessToken(null)
      }
    },
  }), [accessToken])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
