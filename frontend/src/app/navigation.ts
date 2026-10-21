import type { LucideIcon } from 'lucide-react'
import {
  Bell, ClipboardList, FileInput, FileText, FlaskConical, FolderTree, HeartPulse,
  Home, LayoutDashboard, PawPrint, Settings, ShieldQuestion, Stethoscope, Tags,
  UserRound, Users,
} from 'lucide-react'

export type NavigationItem = {
  label: string
  path: string
  description: string
  icon: LucideIcon
}

export type NavigationGroup = {
  label: string
  icon: LucideIcon
  items: NavigationItem[]
}

export const navigationItems: NavigationItem[] = [
  { label: 'Home', path: '/', description: 'Visão geral da operação do laboratório.', icon: Home },
  { label: 'Dashboards', path: '/dashboards', description: 'Indicadores e acompanhamento da operação.', icon: LayoutDashboard },
  { label: 'Médicos veterinários', path: '/cadastros/veterinarios', description: 'Cadastro e acompanhamento de médicos veterinários.', icon: Stethoscope },
  { label: 'Tutores', path: '/cadastros/tutores', description: 'Responsáveis pelos animais atendidos.', icon: Users },
  { label: 'Espécies', path: '/cadastros/especies', description: 'Catálogo de espécies atendidas.', icon: Tags },
  { label: 'Animais', path: '/cadastros/animais', description: 'Cadastro clínico dos animais.', icon: PawPrint },
  { label: 'Categorias', path: '/exames/categorias', description: 'Classificação do catálogo de exames.', icon: Tags },
  { label: 'Exames', path: '/exames', description: 'Catálogo de exames e seus analitos.', icon: ClipboardList },
  { label: 'Grupos de Animais', path: '/exames/grupos-animais', description: 'Hierarquia de grupos para os modelos de exames.', icon: FolderTree },
  { label: 'Analitos', path: '/exames/analitos', description: 'Parâmetros laboratoriais reutilizáveis.', icon: FlaskConical },
  { label: 'Modelo de Exames', path: '/exames/modelos', description: 'Configuração dos modelos, analitos e referências dos exames.', icon: ClipboardList },
  { label: 'Tipos de exames', path: '/laboratorio/tipos-exames', description: 'Configuração do catálogo de exames.', icon: ClipboardList },
  { label: 'Atendimentos', path: '/laboratorio/atendimentos', description: 'Acompanhamento dos atendimentos laboratoriais.', icon: HeartPulse },
  { label: 'Laudos', path: '/laboratorio/laudos', description: 'Emissão e consulta dos laudos.', icon: FileText },
  { label: 'Importação de atendimentos', path: '/laboratorio/importacoes/atendimentos', description: 'Importe e acompanhe lotes de atendimentos.', icon: FileInput },
  { label: 'Notificações', path: '/notificacoes', description: 'Avisos e atualizações da sua operação.', icon: Bell },
  { label: 'Suporte', path: '/suporte', description: 'Canais de ajuda e orientações.', icon: ShieldQuestion },
  { label: 'Configurações', path: '/configuracoes', description: 'Preferências e parâmetros da aplicação.', icon: Settings },
  { label: 'Usuários', path: '/usuarios', description: 'Gestão de usuários e acessos.', icon: UserRound },
]

export const navigationGroups: NavigationGroup[] = [
  {
    label: 'Cadastros',
    icon: ClipboardList,
    items: navigationItems.slice(2, 6),
  },
  {
    label: 'Exames',
    icon: FlaskConical,
    items: navigationItems.slice(6, 11),
  },
  {
    label: 'Laboratório',
    icon: HeartPulse,
    items: navigationItems.slice(11, 15),
  },
]

export const primaryNavigation = navigationItems.slice(0, 2)
export const utilityNavigation = navigationItems.slice(15)
