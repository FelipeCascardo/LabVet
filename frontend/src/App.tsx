import { Navigate, Route, Routes } from 'react-router-dom'
import { ProtectedRoute } from './app/auth/ProtectedRoute'
import { navigationItems } from './app/navigation'
import { LoginPage } from './features/auth/LoginPage'
import { ModulePage } from './features/shared/ModulePage'
import { AppShell } from './layouts/AppShell'

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<ProtectedRoute />}>
        <Route element={<AppShell />}>
          {navigationItems.map((item) => (
            <Route key={item.path} path={item.path} element={<ModulePage title={item.label} description={item.description} />} />
          ))}
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App
