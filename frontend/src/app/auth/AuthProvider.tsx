import { useMemo, useState, type PropsWithChildren } from 'react'
import { authApi } from '../../services/authApi'
import { AuthContext, type AuthContextValue } from './AuthContext'

const TOKEN_KEY = 'labvet.access-token'

export function AuthProvider({ children }: PropsWithChildren) {
  const [accessToken, setAccessToken] = useState(() => localStorage.getItem(TOKEN_KEY))
  const value = useMemo<AuthContextValue>(() => ({
    accessToken,
    async login(email, password) {
      const response = await authApi.login(email, password)
      localStorage.setItem(TOKEN_KEY, response.accessToken)
      setAccessToken(response.accessToken)
    },
    async logout() {
      try {
        await authApi.logout()
      } finally {
        localStorage.removeItem(TOKEN_KEY)
        setAccessToken(null)
      }
    },
  }), [accessToken])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
