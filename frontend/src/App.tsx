import { Navigate, Route, Routes } from 'react-router-dom'
import { ProtectedRoute } from './app/auth/ProtectedRoute'
import { navigationItems } from './app/navigation'
import { LoginPage } from './features/auth/LoginPage'
import { AnalitosPage } from './features/exames/analitos/AnalitosPage'
import { ModeloExamesPage } from './features/modelo-exames/ModeloExamesPage'
import { ModulePage } from './features/shared/ModulePage'
import { AppShell } from './layouts/AppShell'

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<ProtectedRoute />}>
        <Route element={<AppShell />}>
          {navigationItems.filter((item) => item.path !== '/exames/analitos' && item.path !== '/exames/modelos').map((item) => (
            <Route key={item.path} path={item.path} element={<ModulePage title={item.label} description={item.description} />} />
          ))}
          <Route path="/exames/analitos" element={<AnalitosPage />} />
          <Route path="/exames/modelos" element={<ModeloExamesPage />} />
          <Route path="/cadastros/modelos-exames" element={<Navigate to="/exames/modelos" replace />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App
