import { ChevronDown, LogOut, Menu, Search, X } from 'lucide-react'
import { useState } from 'react'
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { primaryNavigation, navigationGroups, utilityNavigation, type NavigationGroup, type NavigationItem } from '../app/navigation'
import { useAuth } from '../app/auth/useAuth'

export function AppShell() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  return <div className="app-shell">
    <button className="mobile-menu" onClick={() => setSidebarOpen(true)} aria-label="Abrir menu"><Menu /></button>
    <aside className={`sidebar ${sidebarOpen ? 'is-open' : ''}`}>
      <div className="sidebar-header"><Brand /><button className="close-sidebar" onClick={() => setSidebarOpen(false)} aria-label="Fechar menu"><X /></button></div>
      <div className="menu-search"><Search size={16} /><input placeholder="Buscar no menu" aria-label="Buscar no menu" /></div>
      <nav className="sidebar-nav" aria-label="Navegação principal">
        {primaryNavigation.map((item) => <MenuLink key={item.path} item={item} onNavigate={() => setSidebarOpen(false)} />)}
        {navigationGroups.map((group) => <MenuGroup key={group.label} group={group} onNavigate={() => setSidebarOpen(false)} />)}
      </nav>
      <div className="sidebar-footer">
        {utilityNavigation.map((item) => <MenuLink key={item.path} item={item} onNavigate={() => setSidebarOpen(false)} />)}
        <UserCard />
      </div>
    </aside>
    {sidebarOpen && <button className="sidebar-overlay" onClick={() => setSidebarOpen(false)} aria-label="Fechar menu" />}
    <main className="app-content"><Topbar /><Outlet /></main>
  </div>
}

function Brand() { return <div className="brand sidebar-brand"><span className="brand-mark"><HeartIcon /></span><span>Lab<span>Vet</span></span></div> }
function HeartIcon() { return <span aria-hidden="true">✦</span> }

function MenuLink({ item, onNavigate }: { item: NavigationItem; onNavigate: () => void }) {
  const Icon = item.icon
  return <NavLink end={item.path === '/'} to={item.path} className={({ isActive }) => `menu-link ${isActive ? 'active' : ''}`} onClick={onNavigate}><Icon size={18} /><span>{item.label}</span>{item.label === 'Notificações' && <small className="notification-count">0</small>}</NavLink>
}

function MenuGroup({ group, onNavigate }: { group: NavigationGroup; onNavigate: () => void }) {
  const [expanded, setExpanded] = useState(true)
  const Icon = group.icon
  return <div className="menu-group"><button className="menu-group-title" onClick={() => setExpanded(!expanded)}><Icon size={18} /><span>{group.label}</span><ChevronDown size={16} className={expanded ? '' : 'rotated'} /></button>{expanded && <div className="menu-subitems">{group.items.map((item) => <MenuLink key={item.path} item={item} onNavigate={onNavigate} />)}</div>}</div>
}

function Topbar() {
  const location = useLocation()
  const page = [...primaryNavigation, ...navigationGroups.flatMap((group) => group.items), ...utilityNavigation].find((item) => item.path === location.pathname)
  return <header className="topbar"><div><p>Área de trabalho</p><strong>{page?.label ?? 'LabVet'}</strong></div><div className="topbar-status"><span />Ambiente local</div></header>
}

function UserCard() {
  const { logout } = useAuth()
  const navigate = useNavigate()
  async function handleLogout() { await logout(); navigate('/login') }
  return <div className="user-card"><div className="user-avatar">F</div><div><strong>Felipe Cascardo</strong><small>felipe.cascardo@gmail.com</small></div><button onClick={handleLogout} title="Sair" aria-label="Sair"><LogOut size={17} /></button></div>
}
