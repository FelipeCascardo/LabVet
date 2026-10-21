import type { FormEvent, ReactNode } from 'react'
import { Save, X } from 'lucide-react'

type CadastroEdicaoProps = {
  icon: ReactNode
  title: string
  actionLabel: 'Inclusão' | 'Edição'
  children: ReactNode
  saving: boolean
  onCancel: () => void
  onSubmit: (event: FormEvent<HTMLFormElement>) => void
}

export function CadastroEdicao({ icon, title, actionLabel, children, saving, onCancel, onSubmit }: CadastroEdicaoProps) {
  return <section className="cadastro-page cadastro-edit-page">
    <header className="cadastro-titlebar cadastro-edit-titlebar">
      <div className="cadastro-title">{icon}<h1>{title}</h1></div>
      <span className="cadastro-mode">{actionLabel}</span>
    </header>
    <form className="cadastro-edit-form" onSubmit={onSubmit}>
      <div className="cadastro-edit-scroll">{children}</div>
      <footer className="cadastro-edit-footer">
        <button type="button" className="secondary-button" onClick={onCancel} disabled={saving}><X size={17} />Cancelar</button>
        <button type="submit" className="primary-button" disabled={saving}><Save size={17} />{saving ? 'Salvando…' : 'Salvar'}</button>
      </footer>
    </form>
  </section>
}
