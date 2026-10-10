import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from './useAuth'

export function ProtectedRoute() {
  const { accessToken } = useAuth()
  const location = useLocation()
  return accessToken ? <Outlet /> : <Navigate to="/login" replace state={{ from: location }} />
}
