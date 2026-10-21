import { useCallback, useEffect, useMemo, useState, type ChangeEvent, type FormEvent } from 'react'
import { ArrowDown, ArrowUp, FlaskConical } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../../app/auth/useAuth'
import { examesApi, type Analito, type AnalitoInput } from '../../../services/examesApi'
import { CadastroEdicao } from '../shared/CadastroEdicao'
import { CadastroPesquisaSelecao } from '../shared/CadastroPesquisaSelecao'

type Ordenacao = keyof Pick<Analito, 'codigo' | 'nome' | 'unidadeMedida' | 'tipoValor' | 'ativo'>
type FormularioAnalito = AnalitoInput

const formularioInicial: FormularioAnalito = {
  codigo: '',
  nome: '',
  tecnica: '',
  unidadeMedida: '',
  tipoValor: 2,
  percentual: false,
}

const registrosPorPagina = 25

function tituloAnalito() {
  return <span className="cadastro-title-icon analito-title-icon"><img src="/images/analito.png" alt="" /></span>
}

function descricaoTipo(tipo: Analito['tipoValor']) {
  return tipo === 1 ? 'Inteiro' : tipo === 2 ? 'Decimal' : 'Caractere'
}

function badgeSituacao(ativo: boolean) {
  return <span className={`status-badge ${ativo ? 'active' : 'inactive'}`}>{ativo ? 'Ativo' : 'Inativo'}</span>
}

export function AnalitosPage() {
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [analitos, setAnalitos] = useState<Analito[]>([])
  const [selecionados, setSelecionados] = useState<number[]>([])
  const [busca, setBusca] = useState('')
  const [situacao, setSituacao] = useState<'todos' | 'ativos' | 'inativos'>('ativos')
  const [tipoValor, setTipoValor] = useState<'todos' | '1' | '2' | '3'>('todos')
  const [ordenacao, setOrdenacao] = useState<Ordenacao>('nome')
  const [direcao, setDirecao] = useState<'asc' | 'desc'>('asc')
  const [paginaAtual, setPaginaAtual] = useState(1)
  const [filtrosAbertos, setFiltrosAbertos] = useState(true)
  const [carregando, setCarregando] = useState(true)
  const [erro, setErro] = useState<string | null>(null)
  const [registroEmEdicao, setRegistroEmEdicao] = useState<Analito | null | undefined>(undefined)
  const [formulario, setFormulario] = useState<FormularioAnalito>(formularioInicial)
  const [salvando, setSalvando] = useState(false)

  const carregar = useCallback(async () => {
    if (!accessToken) return
    setCarregando(true)
    setErro(null)
    try {
      setAnalitos(await examesApi.listarAnalitos(accessToken))
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível carregar os analitos.')
    } finally {
      setCarregando(false)
    }
  }, [accessToken])

  useEffect(() => { void Promise.resolve().then(carregar) }, [carregar])

  const registros = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    return analitos
      .filter((analito) => situacao === 'todos' || (situacao === 'ativos') === analito.ativo)
      .filter((analito) => tipoValor === 'todos' || String(analito.tipoValor) === tipoValor)
      .filter((analito) => !termo || `${analito.codigo} ${analito.nome}`.toLocaleLowerCase('pt-BR').includes(termo))
      .sort((primeiro, segundo) => {
        const valorPrimeiro = String(primeiro[ordenacao])
        const valorSegundo = String(segundo[ordenacao])
        const resultado = valorPrimeiro.localeCompare(valorSegundo, 'pt-BR', { numeric: true })
        return direcao === 'asc' ? resultado : -resultado
      })
  }, [analitos, busca, direcao, ordenacao, situacao, tipoValor])

  const selecionado = selecionados.length === 1 ? analitos.find((analito) => analito.id === selecionados[0]) ?? null : null
  const totalPaginas = Math.max(1, Math.ceil(registros.length / registrosPorPagina))
  const paginaExibida = Math.min(paginaAtual, totalPaginas)
  const registrosDaPagina = registros.slice((paginaExibida - 1) * registrosPorPagina, paginaExibida * registrosPorPagina)
  const todosSelecionados = registrosDaPagina.length > 0 && registrosDaPagina.every((analito) => selecionados.includes(analito.id))

  function alternarOrdenacao(campo: Ordenacao) {
    if (campo === ordenacao) setDirecao((valor) => valor === 'asc' ? 'desc' : 'asc')
    else { setOrdenacao(campo); setDirecao('asc') }
    setPaginaAtual(1)
  }

  function alternarSelecao(id: number) {
    setSelecionados((atuais) => atuais.includes(id) ? atuais.filter((item) => item !== id) : [...atuais, id])
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
      const analito = await examesApi.obterAnalito(selecionado.id, accessToken)
      setFormulario({
        codigo: analito.codigo,
        nome: analito.nome,
        tecnica: analito.tecnica,
        unidadeMedida: analito.unidadeMedida,
        tipoValor: analito.tipoValor,
        percentual: analito.percentual,
      })
      setRegistroEmEdicao(analito)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível abrir o analito.')
    }
  }

  async function alterarSituacao(ativo: boolean) {
    if (!accessToken || selecionados.length === 0) return
    const registrosSelecionados = analitos.filter((analito) => selecionados.includes(analito.id))
    const nomes = registrosSelecionados.map((analito) => analito.nome).join(', ')
    const acao = ativo ? 'reativar' : 'inativar'
    if (!window.confirm(`Deseja ${acao} ${nomes}?`)) return

    try {
      await Promise.all(registrosSelecionados.filter((analito) => analito.ativo !== ativo).map((analito) => examesApi.definirAnalitoAtivo(analito.id, ativo, accessToken)))
      setSelecionados([])
      await carregar()
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível alterar a situação.')
    }
  }

  function alterarCampo(event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) {
    const { name, value, type } = event.target
    const marcado = type === 'checkbox' && 'checked' in event.target ? event.target.checked : undefined
    setFormulario((atual) => ({
      ...atual,
      [name]: marcado ?? (name === 'tipoValor' ? Number(value) : value),
    }))
  }

  async function salvar(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!accessToken) return
    setSalvando(true)
    setErro(null)
    const input: AnalitoInput = {
      ...formulario,
      codigo: formulario.codigo.trim(),
      nome: formulario.nome.trim(),
      tecnica: formulario.tecnica.trim(),
      unidadeMedida: formulario.unidadeMedida.trim(),
    }
    try {
      if (registroEmEdicao) await examesApi.atualizarAnalito(registroEmEdicao.id, input, accessToken)
      else await examesApi.criarAnalito(input, accessToken)
      setRegistroEmEdicao(undefined)
      await carregar()
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível salvar o analito.')
    } finally {
      setSalvando(false)
    }
  }

  if (registroEmEdicao !== undefined) return <CadastroEdicao
    icon={tituloAnalito()}
    title="Analitos"
    actionLabel={registroEmEdicao ? 'Edição' : 'Inclusão'}
    saving={salvando}
    onCancel={() => { setRegistroEmEdicao(undefined); setErro(null) }}
    onSubmit={salvar}
  >
    <section className="cadastro-form-panel">
      <header><div><FlaskConical size={20} /><strong>Dados do analito</strong></div><span>Campos com * são obrigatórios</span></header>
      {erro && <p className="form-error">{erro}</p>}
      <div className="cadastro-form-scroll-content">
        <fieldset><legend>Identificação</legend><div className="form-grid two-columns">
          <label>Código *<input name="codigo" value={formulario.codigo} onChange={alterarCampo} required maxLength={50} /></label>
          <label>Nome *<input name="nome" value={formulario.nome} onChange={alterarCampo} required maxLength={200} /></label>
        </div></fieldset>
        <fieldset><legend>Configuração laboratorial</legend><div className="form-grid two-columns">
          <label>Técnica<input name="tecnica" value={formulario.tecnica} onChange={alterarCampo} maxLength={200} /></label>
          <label>Unidade de medida<input name="unidadeMedida" value={formulario.unidadeMedida} onChange={alterarCampo} maxLength={50} /></label>
          <label>Tipo de valor *<select name="tipoValor" value={formulario.tipoValor} onChange={alterarCampo}><option value="1">Inteiro</option><option value="2">Decimal</option><option value="3">Caractere</option></select></label>
          <label className="switch-field"><span>Aceita referência percentual</span><span><input name="percentual" type="checkbox" checked={formulario.percentual} onChange={alterarCampo} />Aceita referência percentual</span></label>
        </div></fieldset>
        <aside className="cadastro-impact-note">O tipo de valor determina a validação de referências nos modelos de exames. Mudanças em analitos já usados podem ser bloqueadas pela API.</aside>
      </div>
    </section>
  </CadastroEdicao>

  const cabecalho = (titulo: string, campo: Ordenacao) => <button className={`cadastro-sort ${ordenacao === campo ? 'active' : ''}`} onClick={() => alternarOrdenacao(campo)}>{titulo}{ordenacao === campo ? direcao === 'asc' ? <ArrowUp size={13} /> : <ArrowDown size={13} /> : <span>↕</span>}</button>

  return <CadastroPesquisaSelecao
    icon={tituloAnalito()}
    title="Analitos"
    selectedCount={selecionados.length}
    totalRecords={registros.length}
    allSelected={todosSelecionados}
    currentPage={paginaExibida}
    totalPages={totalPaginas}
    filtersOpen={filtrosAbertos}
    editingEnabled={selecionado !== null}
    reactivationEnabled={selecionados.some((id) => analitos.find((analito) => analito.id === id && !analito.ativo))}
    onToggleFilters={() => setFiltrosAbertos((aberto) => !aberto)}
    onSelectAll={() => setSelecionados(todosSelecionados ? (atuais) => atuais.filter((id) => !registrosDaPagina.some((analito) => analito.id === id)) : (atuais) => [...new Set([...atuais, ...registrosDaPagina.map((analito) => analito.id)])])}
    onCreate={abrirInclusao}
    onEdit={() => void abrirEdicao()}
    onDeactivate={() => void alterarSituacao(false)}
    onReactivate={() => void alterarSituacao(true)}
    onFirstPage={() => setPaginaAtual(1)}
    onPreviousPage={() => setPaginaAtual((pagina) => Math.max(1, pagina - 1))}
    onNextPage={() => setPaginaAtual((pagina) => Math.min(totalPaginas, pagina + 1))}
    onLastPage={() => setPaginaAtual(totalPaginas)}
    onBack={() => navigate(-1)}
    filterContent={<><label>Buscar analito<input value={busca} onChange={(event) => { setBusca(event.target.value); setPaginaAtual(1) }} placeholder="Nome ou código" /></label><label>Situação<select value={situacao} onChange={(event) => { setSituacao(event.target.value as typeof situacao); setPaginaAtual(1) }}><option value="todos">Todos</option><option value="ativos">Ativos</option><option value="inativos">Inativos</option></select></label><label>Tipo de valor<select value={tipoValor} onChange={(event) => { setTipoValor(event.target.value as typeof tipoValor); setPaginaAtual(1) }}><option value="todos">Todos</option><option value="1">Inteiro</option><option value="2">Decimal</option><option value="3">Caractere</option></select></label></>}
  >
    {erro && <p className="form-error cadastro-list-error">{erro}</p>}
    {carregando ? <p className="cadastro-state">Carregando analitos…</p> : <div className="cadastro-grid" role="table" aria-label="Analitos cadastrados">
      <div className="cadastro-grid-header" role="row"><span></span>{cabecalho('Código', 'codigo')}{cabecalho('Analito', 'nome')}{cabecalho('Unidade', 'unidadeMedida')}{cabecalho('Tipo de valor', 'tipoValor')}{cabecalho('Status', 'ativo')}</div>
      {registrosDaPagina.map((analito) => <article className="cadastro-row" key={analito.id} role="row">
        <input type="checkbox" checked={selecionados.includes(analito.id)} onChange={() => alternarSelecao(analito.id)} aria-label={`Selecionar ${analito.nome}`} />
        <span className="cadastro-code">{analito.codigo}</span><strong>{analito.nome}</strong><span>{analito.unidadeMedida || '—'}</span><span>{descricaoTipo(analito.tipoValor)}</span>{badgeSituacao(analito.ativo)}
      </article>)}
      {registros.length === 0 && <p className="cadastro-state">Nenhum analito encontrado com os filtros informados.</p>}
    </div>}
  </CadastroPesquisaSelecao>
}
