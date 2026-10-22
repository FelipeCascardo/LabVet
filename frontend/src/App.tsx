import { Navigate, Route, Routes } from 'react-router-dom'
import { ProtectedRoute } from './app/auth/ProtectedRoute'
import { navigationItems } from './app/navigation'
import { LoginPage } from './features/auth/LoginPage'
import { AnalitosPage } from './features/exames/analitos/AnalitosPage'
import { CategoriasExamePage } from './features/exames/categorias/CategoriasExamePage'
import { ExamesPage } from './features/exames/exames/ExamesPage'
import { AnimalGruposPage } from './features/exames/grupos-animais/AnimalGruposPage'
import { ModeloExameEdicaoPage, ModeloExamesInicioPage } from './features/modelo-exames/ModeloExamesCrudPage'
import { ModelosDoGrupoPesquisaPage } from './features/modelo-exames/ModelosDoGrupoPesquisaPage'
import { ModulePage } from './features/shared/ModulePage'
import { AppShell } from './layouts/AppShell'

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<ProtectedRoute />}>
        <Route element={<AppShell />}>
          {navigationItems.filter((item) => item.path !== '/exames' && item.path !== '/exames/categorias' && item.path !== '/exames/analitos' && item.path !== '/exames/grupos-animais' && item.path !== '/exames/modelos').map((item) => (
            <Route key={item.path} path={item.path} element={<ModulePage title={item.label} description={item.description} />} />
          ))}
          <Route path="/exames/categorias" element={<CategoriasExamePage />} />
          <Route path="/exames" element={<ExamesPage />} />
          <Route path="/exames/analitos" element={<AnalitosPage />} />
          <Route path="/exames/grupos-animais" element={<AnimalGruposPage />} />
          <Route path="/exames/modelos" element={<ModeloExamesInicioPage />} />
          <Route path="/exames/modelos/grupo/:grupoId" element={<ModelosDoGrupoPesquisaPage />} />
          <Route path="/exames/modelos/novo/:grupoId" element={<ModeloExameEdicaoPage />} />
          <Route path="/exames/modelos/:id/editar" element={<ModeloExameEdicaoPage />} />
          <Route path="/cadastros/modelos-exames" element={<Navigate to="/exames/modelos" replace />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App
