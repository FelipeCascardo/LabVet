import { Plus } from 'lucide-react'

type ModulePageProps = { title: string; description: string }

export function ModulePage({ title, description }: ModulePageProps) {
  const isHome = title === 'Home'
  return (
    <section className="module-page">
      <div className="page-heading">
        <div>
          <p className="eyebrow">LabVet</p>
          <h1>{isHome ? 'Olá, Felipe' : title}</h1>
          <p>{isHome ? 'Acompanhe a operação do laboratório em um só lugar.' : description}</p>
        </div>
        {!isHome && <button className="primary-button"><Plus size={18} /> Novo cadastro</button>}
      </div>
      {isHome ? <HomeSummary /> : <EmptyModule title={title} />}
    </section>
  )
}

function HomeSummary() {
  return <>
    <div className="summary-grid">
      <article><span>Atendimentos hoje</span><strong>—</strong><small>Disponível após conectar o dashboard à API</small></article>
      <article><span>Laudos pendentes</span><strong>—</strong><small>Acompanhe o fluxo de liberação</small></article>
      <article><span>Notificações</span><strong>—</strong><small>Sem dados carregados</small></article>
    </div>
    <article className="welcome-card">
      <div><p className="eyebrow">Primeiros passos</p><h2>Estrutura pronta para a operação.</h2><p>Os dados do painel serão alimentados pelos contratos do backend nas próximas entregas.</p></div>
    </article>
  </>
}

function EmptyModule({ title }: { title: string }) {
  return <article className="empty-card">
    <div className="empty-symbol">+</div>
    <h2>{title} está preparado</h2>
    <p>Esta tela já faz parte da navegação definitiva. O fluxo e os dados serão conectados ao respectivo endpoint da API.</p>
  </article>
}
