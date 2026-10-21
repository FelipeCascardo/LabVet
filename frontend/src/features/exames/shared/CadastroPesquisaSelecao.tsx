import type { ReactNode } from 'react'
import { ChevronDown, ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight, Filter, Pencil, Plus, RotateCcw, Trash2 } from 'lucide-react'

type CadastroPesquisaSelecaoProps = {
  icon: ReactNode
  title: string
  children: ReactNode
  filterContent: ReactNode
  selectedCount: number
  totalRecords: number
  allSelected: boolean
  currentPage: number
  totalPages: number
  filtersOpen: boolean
  editingEnabled: boolean
  reactivationEnabled: boolean
  onToggleFilters: () => void
  onSelectAll: () => void
  onCreate: () => void
  onEdit: () => void
  onDeactivate: () => void
  onReactivate: () => void
  onFirstPage: () => void
  onPreviousPage: () => void
  onNextPage: () => void
  onLastPage: () => void
  onBack: () => void
}

export function CadastroPesquisaSelecao({
  icon,
  title,
  children,
  filterContent,
  selectedCount,
  totalRecords,
  allSelected,
  currentPage,
  totalPages,
  filtersOpen,
  editingEnabled,
  reactivationEnabled,
  onToggleFilters,
  onSelectAll,
  onCreate,
  onEdit,
  onDeactivate,
  onReactivate,
  onFirstPage,
  onPreviousPage,
  onNextPage,
  onLastPage,
  onBack,
}: CadastroPesquisaSelecaoProps) {
  return <section className="cadastro-page cadastro-list-page">
    <header className="cadastro-titlebar">
      <div className="cadastro-title">{icon}<h1>{title}</h1></div>
      <div className="cadastro-actions" aria-label="Ações principais">
        <button className="cadastro-action primary" onClick={onCreate}><Plus size={18} />Incluir</button>
        <button className="cadastro-action" disabled={!editingEnabled} onClick={onEdit}><Pencil size={17} />Editar</button>
        <button className="cadastro-action danger" disabled={selectedCount === 0} onClick={onDeactivate}><Trash2 size={17} />Inativar</button>
        <button className="cadastro-action" disabled={!reactivationEnabled} onClick={onReactivate}><RotateCcw size={17} />Reativar</button>
      </div>
    </header>

    <section className="cadastro-filter">
      <button className="cadastro-filter-toggle" onClick={onToggleFilters} aria-expanded={filtersOpen}>
        <span><Filter size={17} />Filtros <em>{filtersOpen ? 'abertos' : 'fechados'}</em></span>
        <ChevronDown className={filtersOpen ? 'is-open' : ''} size={17} />
      </button>
      {filtersOpen && <div className="cadastro-filter-content">{filterContent}</div>}
    </section>

    <div className="cadastro-list-content">{children}</div>

    <footer className="cadastro-footer">
      <label className="cadastro-select-all"><input type="checkbox" checked={allSelected} onChange={onSelectAll} aria-label="Selecionar todos os registros desta página" /><strong>{selectedCount} / {totalRecords}</strong></label>
      <div className="cadastro-pager" aria-label="Navegação de páginas">
        <button aria-label="Primeira página" onClick={onFirstPage} disabled={currentPage === 1}><ChevronsLeft size={17} /></button>
        <button aria-label="Página anterior" onClick={onPreviousPage} disabled={currentPage === 1}><ChevronLeft size={17} /></button>
        <span>{currentPage} / {totalPages}</span>
        <button aria-label="Próxima página" onClick={onNextPage} disabled={currentPage === totalPages}><ChevronRight size={17} /></button>
        <button aria-label="Última página" onClick={onLastPage} disabled={currentPage === totalPages}><ChevronsRight size={17} /></button>
      </div>
      <button className="cadastro-back" onClick={onBack} aria-label="Retornar à página chamadora"><ChevronLeft size={19} /></button>
    </footer>
  </section>
}
