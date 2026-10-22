import { useCallback, useEffect, useMemo, useRef, useState, type ChangeEvent, type FormEvent, type PointerEvent as ReactPointerEvent } from 'react'
import { ArrowDown, ArrowUp, Tags } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../../app/auth/useAuth'
import { examesApi, type ExameCategoria, type ExameCategoriaInput } from '../../../services/examesApi'
import { CadastroEdicao } from '../shared/CadastroEdicao'
import { CadastroPesquisaSelecao } from '../shared/CadastroPesquisaSelecao'

type Ordenacao = keyof Pick<ExameCategoria, 'nome' | 'ativo'>

const formularioInicial: ExameCategoriaInput = {
  nome: '',
}

const registrosPorPagina = 25

function tituloCategoria() {
  return <span className="cadastro-title-icon"><Tags size={43} aria-hidden="true" /></span>
}

function badgeSituacao(ativo: boolean) {
  return <span className={`status-badge ${ativo ? 'active' : 'inactive'}`}>{ativo ? 'Ativa' : 'Inativa'}</span>
}

export function CategoriasExamePage() {
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [categorias, setCategorias] = useState<ExameCategoria[]>([])
  const [selecionados, setSelecionados] = useState<number[]>([])
  const [busca, setBusca] = useState('')
  const [situacao, setSituacao] = useState<'todos' | 'ativos' | 'inativos'>('ativos')
  const [ordenacao, setOrdenacao] = useState<Ordenacao>('nome')
  const [direcao, setDirecao] = useState<'asc' | 'desc'>('asc')
  const [paginaAtual, setPaginaAtual] = useState(1)
  const [filtrosAbertos, setFiltrosAbertos] = useState(false)
  const [carregando, setCarregando] = useState(true)
  const [erro, setErro] = useState<string | null>(null)
  const [registroEmEdicao, setRegistroEmEdicao] = useState<ExameCategoria | null | undefined>(undefined)
  const [formulario, setFormulario] = useState<ExameCategoriaInput>(formularioInicial)
  const [salvando, setSalvando] = useState(false)
  const temporizadorPressionamento = useRef<number | null>(null)

  const carregar = useCallback(async () => {
    if (!accessToken) return
    setCarregando(true)
    setErro(null)
    try {
      setCategorias(await examesApi.listarCategorias(accessToken, true))
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível carregar as categorias de exame.')
    } finally {
      setCarregando(false)
    }
  }, [accessToken])

  useEffect(() => { void Promise.resolve().then(carregar) }, [carregar])

  useEffect(() => () => {
    if (temporizadorPressionamento.current !== null) window.clearTimeout(temporizadorPressionamento.current)
  }, [])

  const registros = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    return categorias
      .filter((categoria) => situacao === 'todos' || (situacao === 'ativos') === categoria.ativo)
      .filter((categoria) => !termo || categoria.nome.toLocaleLowerCase('pt-BR').includes(termo))
      .sort((primeira, segunda) => {
        const resultado = String(primeira[ordenacao]).localeCompare(String(segunda[ordenacao]), 'pt-BR', { numeric: true })
        return direcao === 'asc' ? resultado : -resultado
      })
  }, [busca, categorias, direcao, ordenacao, situacao])

  const selecionado = selecionados.length === 1 ? categorias.find((categoria) => categoria.id === selecionados[0]) ?? null : null
  const totalPaginas = Math.max(1, Math.ceil(registros.length / registrosPorPagina))
  const paginaExibida = Math.min(paginaAtual, totalPaginas)
  const registrosDaPagina = registros.slice((paginaExibida - 1) * registrosPorPagina, paginaExibida * registrosPorPagina)
  const todosSelecionados = registrosDaPagina.length > 0 && registrosDaPagina.every((categoria) => selecionados.includes(categoria.id))

  function alternarOrdenacao(campo: Ordenacao) {
    if (campo === ordenacao) setDirecao((valor) => valor === 'asc' ? 'desc' : 'asc')
    else { setOrdenacao(campo); setDirecao('asc') }
    setPaginaAtual(1)
  }

  function alternarSelecao(id: number) {
    setSelecionados((atuais) => atuais.includes(id) ? atuais.filter((item) => item !== id) : [...atuais, id])
  }

  function cancelarPressionamento() {
    if (temporizadorPressionamento.current === null) return
    window.clearTimeout(temporizadorPressionamento.current)
    temporizadorPressionamento.current = null
  }

  function iniciarPressionamento(id: number, event: ReactPointerEvent<HTMLElement>) {
    if (event.target instanceof HTMLInputElement || (event.pointerType === 'mouse' && event.button !== 0)) return
    cancelarPressionamento()
    temporizadorPressionamento.current = window.setTimeout(() => {
      alternarSelecao(id)
      temporizadorPressionamento.current = null
    }, 300)
  }

  function abrirInclusao() {
    setFormulario(formularioInicial)
    setRegistroEmEdicao(null)
    setErro(null)
  }

  async function abrirEdicao() {
    if (!selecionado || !accessToken) return
    setErro(null)
    try {
      const categoria = await examesApi.obterCategoria(selecionado.id, accessToken)
      setFormulario({ nome: categoria.nome })
      setRegistroEmEdicao(categoria)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível abrir a categoria de exame.')
    }
  }

  async function alterarSituacao(ativo: boolean) {
    if (!accessToken || selecionados.length === 0) return
    const registrosSelecionados = categorias.filter((categoria) => selecionados.includes(categoria.id))
    const nomes = registrosSelecionados.map((categoria) => categoria.nome).join(', ')
    const acao = ativo ? 'reativar' : 'inativar'
    if (!window.confirm(`Deseja ${acao} ${nomes}?`)) return

    try {
      await Promise.all(registrosSelecionados.filter((categoria) => categoria.ativo !== ativo).map((categoria) => examesApi.definirCategoriaAtiva(categoria.id, ativo, accessToken)))
      setSelecionados([])
      await carregar()
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível alterar a situação das categorias de exame.')
    }
  }

  function alterarCampo(event: ChangeEvent<HTMLInputElement>) {
    setFormulario({ nome: event.target.value })
  }

  async function salvar(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!accessToken) return
    setSalvando(true)
    setErro(null)
    const input: ExameCategoriaInput = { nome: formulario.nome.trim().replace(/\s+/g, ' ') }
    try {
      if (registroEmEdicao) await examesApi.atualizarCategoria(registroEmEdicao.id, input, accessToken)
      else await examesApi.criarCategoria(input, accessToken)
      setRegistroEmEdicao(undefined)
      await carregar()
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível salvar a categoria de exame.')
    } finally {
      setSalvando(false)
    }
  }

  if (registroEmEdicao !== undefined) return <CadastroEdicao
    icon={tituloCategoria()}
    title="Categorias de Exame"
    actionLabel={registroEmEdicao ? 'Edição' : 'Inclusão'}
    saving={salvando}
    onCancel={() => { setRegistroEmEdicao(undefined); setErro(null) }}
    onSubmit={salvar}
  >
    <section className="cadastro-form-panel">
      <header><div><Tags size={20} /><strong>Dados da categoria</strong></div><span>Campos com * são obrigatórios</span></header>
      {erro && <p className="form-error">{erro}</p>}
      <div className="cadastro-form-scroll-content">
        <fieldset><legend>Identificação</legend><div className="form-grid">
          <label>Nome da categoria *<input name="nome" value={formulario.nome} onChange={alterarCampo} required maxLength={100} autoFocus /></label>
        </div></fieldset>
        <aside className="cadastro-impact-note">A categoria organiza o catálogo de exames e pode ser usada nos filtros e na manutenção dos exames.</aside>
      </div>
    </section>
  </CadastroEdicao>

  const cabecalho = (titulo: string, campo: Ordenacao) => <button className={`cadastro-sort ${ordenacao === campo ? 'active' : ''}`} onClick={() => alternarOrdenacao(campo)}>{titulo}{ordenacao === campo ? direcao === 'asc' ? <ArrowUp size={13} /> : <ArrowDown size={13} /> : <span>↕</span>}</button>

  return <CadastroPesquisaSelecao
    icon={tituloCategoria()}
    title="Categorias de Exame"
    selectedCount={selecionados.length}
    totalRecords={registros.length}
    allSelected={todosSelecionados}
    currentPage={paginaExibida}
    totalPages={totalPaginas}
    filtersOpen={filtrosAbertos}
    editingEnabled={selecionado !== null}
    reactivationEnabled={selecionados.some((id) => categorias.find((categoria) => categoria.id === id && !categoria.ativo))}
    onToggleFilters={() => setFiltrosAbertos((aberto) => !aberto)}
    onSelectAll={() => setSelecionados(todosSelecionados ? (atuais) => atuais.filter((id) => !registrosDaPagina.some((categoria) => categoria.id === id)) : (atuais) => [...new Set([...atuais, ...registrosDaPagina.map((categoria) => categoria.id)])])}
    onCreate={abrirInclusao}
    onEdit={() => void abrirEdicao()}
    onDeactivate={() => void alterarSituacao(false)}
    onReactivate={() => void alterarSituacao(true)}
    onFirstPage={() => setPaginaAtual(1)}
    onPreviousPage={() => setPaginaAtual((pagina) => Math.max(1, pagina - 1))}
    onNextPage={() => setPaginaAtual((pagina) => Math.min(totalPaginas, pagina + 1))}
    onLastPage={() => setPaginaAtual(totalPaginas)}
    onBack={() => navigate(-1)}
    filterContent={<><label>Buscar categoria<input value={busca} onChange={(event) => { setBusca(event.target.value); setPaginaAtual(1) }} placeholder="Nome da categoria" /></label><label>Situação<select value={situacao} onChange={(event) => { setSituacao(event.target.value as typeof situacao); setPaginaAtual(1) }}><option value="todos">Todos</option><option value="ativos">Ativas</option><option value="inativos">Inativas</option></select></label></>}
  >
    {erro && <p className="form-error cadastro-list-error">{erro}</p>}
    {carregando ? <p className="cadastro-state">Carregando categorias de exame…</p> : <div className="cadastro-grid categorias-grid" role="table" aria-label="Categorias de exame cadastradas">
      <div className="cadastro-grid-header categorias-grid-header" role="row"><span></span>{cabecalho('Categoria', 'nome')}{cabecalho('Situação', 'ativo')}</div>
      {registrosDaPagina.map((categoria) => <article className="cadastro-row categoria-row" key={categoria.id} role="row" onPointerDown={(event) => iniciarPressionamento(categoria.id, event)} onPointerUp={cancelarPressionamento} onPointerCancel={cancelarPressionamento} onPointerLeave={cancelarPressionamento} onPointerMove={cancelarPressionamento}>
        <input type="checkbox" checked={selecionados.includes(categoria.id)} onChange={() => alternarSelecao(categoria.id)} aria-label={`Selecionar ${categoria.nome}`} />
        <strong className="categoria-name">{categoria.nome}</strong>{badgeSituacao(categoria.ativo)}
      </article>)}
      {registros.length === 0 && <p className="cadastro-state">Nenhuma categoria encontrada com os filtros informados.</p>}
    </div>}
  </CadastroPesquisaSelecao>
}
