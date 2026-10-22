import { useCallback, useEffect, useMemo, useRef, useState, type ChangeEvent, type FormEvent, type PointerEvent as ReactPointerEvent } from 'react'
import { ArrowDown, ArrowUp, FlaskConical, Link2, Plus, Trash2 } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../../app/auth/useAuth'
import { examesApi, type Analito, type Exame, type ExameAnalito, type ExameInput, type ExameCategoria } from '../../../services/examesApi'
import { CadastroEdicao } from '../shared/CadastroEdicao'
import { CadastroPesquisaSelecao } from '../shared/CadastroPesquisaSelecao'
import { CurrencyInput } from '../shared/CurrencyInput'

type Ordenacao = keyof Pick<Exame, 'codigo' | 'nome' | 'idCategoria' | 'primario' | 'quantidade' | 'valor' | 'ativo'>
type FormularioExame = {
  idCategoria: string
  codigo: string
  nome: string
  quantidade: string
  valor: string
  primario: boolean
  idExamePai: string
}

const formularioInicial: FormularioExame = {
  idCategoria: '',
  codigo: '',
  nome: '',
  quantidade: '1',
  valor: '',
  primario: true,
  idExamePai: '',
}

const registrosPorPagina = 25

function tituloExames() {
  return <span className="cadastro-title-icon"><FlaskConical size={43} aria-hidden="true" /></span>
}

function badgeSituacao(ativo: boolean) {
  return <span className={`status-badge ${ativo ? 'active' : 'inactive'}`}>{ativo ? 'Ativo' : 'Inativo'}</span>
}

function descricaoTipoValor(tipo: Analito['tipoValor']) {
  return tipo === 1 ? 'Inteiro' : tipo === 2 ? 'Decimal' : 'Caractere'
}

function formatarValor(valor: number | null) {
  if (valor === null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor)
}

function paraFormulario(exame: Exame): FormularioExame {
  return {
    idCategoria: String(exame.idCategoria),
    codigo: exame.codigo,
    nome: exame.nome,
    quantidade: String(exame.quantidade),
    valor: exame.valor === null ? '' : String(exame.valor).replace('.', ','),
    primario: exame.primario,
    idExamePai: exame.idExamePai === null ? '' : String(exame.idExamePai),
  }
}

function converterValor(texto: string) {
  const valor = texto.trim()
  if (!valor) return null
  return Number(valor.includes(',') ? valor.replace(/\./g, '').replace(',', '.') : valor)
}

export function ExamesPage() {
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [exames, setExames] = useState<Exame[]>([])
  const [categorias, setCategorias] = useState<ExameCategoria[]>([])
  const [analitos, setAnalitos] = useState<Analito[]>([])
  const [vinculos, setVinculos] = useState<ExameAnalito[]>([])
  const [selecionados, setSelecionados] = useState<number[]>([])
  const [busca, setBusca] = useState('')
  const [categoriaFiltro, setCategoriaFiltro] = useState('todas')
  const [situacao, setSituacao] = useState<'todos' | 'ativos' | 'inativos'>('ativos')
  const [ordenacao, setOrdenacao] = useState<Ordenacao>('nome')
  const [direcao, setDirecao] = useState<'asc' | 'desc'>('asc')
  const [paginaAtual, setPaginaAtual] = useState(1)
  const [filtrosAbertos, setFiltrosAbertos] = useState(false)
  const [carregando, setCarregando] = useState(true)
  const [erro, setErro] = useState<string | null>(null)
  const [registroEmEdicao, setRegistroEmEdicao] = useState<Exame | null | undefined>(undefined)
  const [formulario, setFormulario] = useState<FormularioExame>(formularioInicial)
  const [salvando, setSalvando] = useState(false)
  const [analitoParaAdicionar, setAnalitoParaAdicionar] = useState('')
  const [buscaAnalito, setBuscaAnalito] = useState('')
  const [atualizandoAnalitos, setAtualizandoAnalitos] = useState(false)
  const temporizadorPressionamento = useRef<number | null>(null)

  const carregar = useCallback(async () => {
    if (!accessToken) return
    setCarregando(true)
    setErro(null)
    try {
      const [itens, categoriasCarregadas] = await Promise.all([
        examesApi.listarExames(accessToken, true),
        examesApi.listarCategorias(accessToken, true),
      ])
      setExames(itens)
      setCategorias(categoriasCarregadas)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível carregar os exames.')
    } finally {
      setCarregando(false)
    }
  }, [accessToken])

  const carregarAnalitosDoExame = useCallback(async (idExame: number) => {
    if (!accessToken) return
    setAtualizandoAnalitos(true)
    try {
      const [analitosCarregados, vinculosCarregados] = await Promise.all([
        examesApi.listarAnalitos(accessToken, true),
        examesApi.listarExameAnalitos(accessToken, true),
      ])
      setAnalitos(analitosCarregados)
      setVinculos(vinculosCarregados.filter((vinculo) => vinculo.idExame === idExame))
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível carregar os analitos do exame.')
    } finally {
      setAtualizandoAnalitos(false)
    }
  }, [accessToken])

  useEffect(() => { void Promise.resolve().then(carregar) }, [carregar])

  useEffect(() => () => {
    if (temporizadorPressionamento.current !== null) window.clearTimeout(temporizadorPressionamento.current)
  }, [])

  const nomesCategorias = useMemo(() => new Map(categorias.map((categoria) => [categoria.id, categoria.nome])), [categorias])
  const registros = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    return exames
      .filter((exame) => situacao === 'todos' || (situacao === 'ativos') === exame.ativo)
      .filter((exame) => categoriaFiltro === 'todas' || exame.idCategoria === Number(categoriaFiltro))
      .filter((exame) => !termo || `${exame.codigo} ${exame.nome} ${nomesCategorias.get(exame.idCategoria) ?? ''}`.toLocaleLowerCase('pt-BR').includes(termo))
      .sort((primeiro, segundo) => {
        const resultado = String(primeiro[ordenacao] ?? '').localeCompare(String(segundo[ordenacao] ?? ''), 'pt-BR', { numeric: true })
        return direcao === 'asc' ? resultado : -resultado
      })
  }, [busca, categoriaFiltro, direcao, exames, nomesCategorias, ordenacao, situacao])

  const selecionado = selecionados.length === 1 ? exames.find((exame) => exame.id === selecionados[0]) ?? null : null
  const totalPaginas = Math.max(1, Math.ceil(registros.length / registrosPorPagina))
  const paginaExibida = Math.min(paginaAtual, totalPaginas)
  const registrosDaPagina = registros.slice((paginaExibida - 1) * registrosPorPagina, paginaExibida * registrosPorPagina)
  const todosSelecionados = registrosDaPagina.length > 0 && registrosDaPagina.every((exame) => selecionados.includes(exame.id))
  const categoriasDoFormulario = categorias.filter((categoria) => categoria.ativo || categoria.id === Number(formulario.idCategoria))
  const examesPais = exames.filter((exame) => exame.id !== registroEmEdicao?.id && exame.ativo)
  const vinculosComAnalito = vinculos.map((vinculo) => ({ vinculo, analito: analitos.find((analito) => analito.id === vinculo.idAnalito) })).filter((item): item is { vinculo: ExameAnalito; analito: Analito } => item.analito !== undefined)
  const analitosDisponiveis = analitos.filter((analito) => analito.ativo && !vinculos.some((vinculo) => vinculo.idAnalito === analito.id))
  const termoAnalito = buscaAnalito.trim().toLocaleLowerCase('pt-BR')
  const analitosVisiveis = vinculosComAnalito.filter(({ analito }) => !termoAnalito || `${analito.codigo} ${analito.nome} ${analito.unidadeMedida}`.toLocaleLowerCase('pt-BR').includes(termoAnalito))

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
    setVinculos([])
    setAnalitos([])
    setErro(null)
  }

  async function abrirEdicao() {
    if (!selecionado || !accessToken) return
    setErro(null)
    try {
      const exame = await examesApi.obterExame(selecionado.id, accessToken)
      setFormulario(paraFormulario(exame))
      setRegistroEmEdicao(exame)
      void carregarAnalitosDoExame(exame.id)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível abrir o exame.')
    }
  }

  async function alterarSituacao(ativo: boolean) {
    if (!accessToken || selecionados.length === 0) return
    const registrosSelecionados = exames.filter((exame) => selecionados.includes(exame.id))
    const nomes = registrosSelecionados.map((exame) => exame.nome).join(', ')
    const acao = ativo ? 'reativar' : 'inativar'
    if (!window.confirm(`Deseja ${acao} ${nomes}?`)) return
    try {
      await Promise.all(registrosSelecionados.filter((exame) => exame.ativo !== ativo).map((exame) => examesApi.definirExameAtivo(exame.id, ativo, accessToken)))
      setSelecionados([])
      await carregar()
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível alterar a situação dos exames.')
    }
  }

  function alterarCampo(event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) {
    const { name, value, type } = event.target
    const marcado = type === 'checkbox' && 'checked' in event.target ? event.target.checked : undefined
    setFormulario((atual) => ({
      ...atual,
      [name]: marcado ?? value,
      ...(name === 'primario' && marcado ? { idExamePai: '' } : {}),
    }))
  }

  async function salvar(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!accessToken) return
    setSalvando(true)
    setErro(null)
    const valor = converterValor(formulario.valor)
    if (valor !== null && !Number.isFinite(valor)) {
      setErro('Informe um valor monetário válido.')
      setSalvando(false)
      return
    }
    const input: ExameInput = {
      idCategoria: Number(formulario.idCategoria),
      codigo: formulario.codigo.trim(),
      nome: formulario.nome.trim(),
      quantidade: Number(formulario.quantidade),
      valor,
      primario: formulario.primario,
      idExamePai: formulario.primario || !formulario.idExamePai ? null : Number(formulario.idExamePai),
    }
    try {
      const exameSalvo = registroEmEdicao
        ? await examesApi.atualizarExame(registroEmEdicao.id, input, accessToken)
        : await examesApi.criarExame(input, accessToken)
      setRegistroEmEdicao(exameSalvo)
      setFormulario(paraFormulario(exameSalvo))
      await Promise.all([carregar(), carregarAnalitosDoExame(exameSalvo.id)])
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível salvar o exame.')
    } finally {
      setSalvando(false)
    }
  }

  async function adicionarAnalito() {
    if (!accessToken || !registroEmEdicao || !analitoParaAdicionar) return
    setAtualizandoAnalitos(true)
    setErro(null)
    try {
      await examesApi.criarExameAnalito({ idExame: registroEmEdicao.id, idAnalito: Number(analitoParaAdicionar) }, accessToken)
      setAnalitoParaAdicionar('')
      await carregarAnalitosDoExame(registroEmEdicao.id)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível vincular o analito ao exame.')
    } finally {
      setAtualizandoAnalitos(false)
    }
  }

  async function removerAnalito(vinculo: ExameAnalito, analito: Analito) {
    if (!accessToken || !registroEmEdicao) return
    if (!window.confirm(`Deseja remover ${analito.nome} deste exame?`)) return
    setAtualizandoAnalitos(true)
    setErro(null)
    try {
      await examesApi.definirExameAnalitoAtivo(vinculo.id, false, accessToken)
      await carregarAnalitosDoExame(registroEmEdicao.id)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível remover o analito do exame.')
    } finally {
      setAtualizandoAnalitos(false)
    }
  }

  async function reativarAnalito(vinculo: ExameAnalito, analito: Analito) {
    if (!accessToken || !registroEmEdicao) return
    if (!window.confirm(`Deseja reativar ${analito.nome} neste exame?`)) return
    setAtualizandoAnalitos(true)
    setErro(null)
    try {
      await examesApi.definirExameAnalitoAtivo(vinculo.id, true, accessToken)
      await carregarAnalitosDoExame(registroEmEdicao.id)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível reativar o analito no exame.')
    } finally {
      setAtualizandoAnalitos(false)
    }
  }

  if (registroEmEdicao !== undefined) return <CadastroEdicao
    icon={tituloExames()}
    title="Exames"
    actionLabel={registroEmEdicao ? 'Edição' : 'Inclusão'}
    saving={salvando}
    onCancel={() => { setRegistroEmEdicao(undefined); setErro(null); void carregar() }}
    onSubmit={salvar}
  >
    <section className="cadastro-form-panel exame-form-panel">
      <header><div><FlaskConical size={20} /><strong>Dados do exame</strong></div><span>Campos com * são obrigatórios</span></header>
      {erro && <p className="form-error">{erro}</p>}
      <div className="cadastro-form-scroll-content">
        <fieldset><legend>Dados principais</legend><div className="form-grid exame-form-grid">
          <label>Código *<input name="codigo" value={formulario.codigo} onChange={alterarCampo} required maxLength={50} autoFocus /></label>
          <label>Categoria *<select name="idCategoria" value={formulario.idCategoria} onChange={alterarCampo} required><option value="">Selecione uma categoria</option>{categoriasDoFormulario.map((categoria) => <option key={categoria.id} value={categoria.id}>{categoria.nome}{categoria.ativo ? '' : ' (inativa)'}</option>)}</select></label>
          <label className="form-field-wide">Nome *<input name="nome" value={formulario.nome} onChange={alterarCampo} required maxLength={200} /></label>
          <label>Quantidade *<input name="quantidade" type="number" value={formulario.quantidade} onChange={alterarCampo} required min="1" step="1" /></label>
          <label>Valor (R$)<CurrencyInput value={formulario.valor} onChange={(valor) => setFormulario((atual) => ({ ...atual, valor }))} placeholder="0,00" /></label>
          <label className="switch-field"><span>Exame unitário *</span><span><input name="primario" type="checkbox" checked={formulario.primario} onChange={alterarCampo} />Exame unitário</span></label>
          {!formulario.primario && <label>Exame-pai<select name="idExamePai" value={formulario.idExamePai} onChange={alterarCampo}><option value="">Sem exame-pai</option>{examesPais.map((exame) => <option key={exame.id} value={exame.id}>{exame.codigo} — {exame.nome}</option>)}</select></label>}
        </div></fieldset>
        {!registroEmEdicao && <aside className="cadastro-impact-note">Salve os dados do exame para liberar a manutenção dos analitos que o compõem.</aside>}
      </div>
    </section>

    {registroEmEdicao && <section className="exame-analitos-panel">
      <header><div><Link2 size={20} /><strong>Analitos do exame</strong></div><span>{vinculosComAnalito.length} vinculados</span></header>
      <div className="exame-analitos-content">
        <div className="exame-analitos-toolbar">
          <label className="exame-analito-selector">Adicionar analito
            <select value={analitoParaAdicionar} onChange={(event) => setAnalitoParaAdicionar(event.target.value)} disabled={atualizandoAnalitos}>
              <option value="">Selecione um analito ativo</option>
              {analitosDisponiveis.map((analito) => <option key={analito.id} value={analito.id}>{analito.codigo} — {analito.nome}</option>)}
            </select>
          </label>
          <button type="button" className="secondary-button" onClick={() => void adicionarAnalito()} disabled={!analitoParaAdicionar || atualizandoAnalitos}><Plus size={17} />Adicionar</button>
          <label className="exame-analito-search">Pesquisar vínculos<input value={buscaAnalito} onChange={(event) => setBuscaAnalito(event.target.value)} placeholder="Nome ou código" /></label>
        </div>
        {atualizandoAnalitos ? <p className="cadastro-state">Atualizando analitos…</p> : <div className="exame-analitos-list">
          {analitosVisiveis.map(({ vinculo, analito }) => <article key={vinculo.id} className="exame-analito-row">
            <div><span className="cadastro-code">{analito.codigo}</span><strong>{analito.nome}</strong></div>
            <span>{analito.unidadeMedida || '—'}</span>
            <span>{descricaoTipoValor(analito.tipoValor)}</span>
            {badgeSituacao(vinculo.ativo)}
            {vinculo.ativo
              ? <button type="button" className="exame-analito-remove" onClick={() => void removerAnalito(vinculo, analito)} aria-label={`Remover ${analito.nome} do exame`} title="Remover analito"><Trash2 size={16} /></button>
              : <button type="button" className="secondary-button exame-analito-reactivate" onClick={() => void reativarAnalito(vinculo, analito)} aria-label={`Reativar ${analito.nome} no exame`}>Reativar</button>}
          </article>)}
          {analitosVisiveis.length === 0 && <p className="cadastro-state">Nenhum analito vinculado a este exame.</p>}
        </div>}
      </div>
    </section>}
  </CadastroEdicao>

  const cabecalho = (titulo: string, campo: Ordenacao) => <button className={`cadastro-sort ${ordenacao === campo ? 'active' : ''}`} onClick={() => alternarOrdenacao(campo)}>{titulo}{ordenacao === campo ? direcao === 'asc' ? <ArrowUp size={13} /> : <ArrowDown size={13} /> : <span>↕</span>}</button>

  return <CadastroPesquisaSelecao
    icon={tituloExames()}
    title="Exames"
    selectedCount={selecionados.length}
    totalRecords={registros.length}
    allSelected={todosSelecionados}
    currentPage={paginaExibida}
    totalPages={totalPaginas}
    filtersOpen={filtrosAbertos}
    editingEnabled={selecionado !== null}
    reactivationEnabled={selecionados.some((id) => exames.find((exame) => exame.id === id && !exame.ativo))}
    onToggleFilters={() => setFiltrosAbertos((aberto) => !aberto)}
    onSelectAll={() => setSelecionados(todosSelecionados ? (atuais) => atuais.filter((id) => !registrosDaPagina.some((exame) => exame.id === id)) : (atuais) => [...new Set([...atuais, ...registrosDaPagina.map((exame) => exame.id)])])}
    onCreate={abrirInclusao}
    onEdit={() => void abrirEdicao()}
    onDeactivate={() => void alterarSituacao(false)}
    onReactivate={() => void alterarSituacao(true)}
    onFirstPage={() => setPaginaAtual(1)}
    onPreviousPage={() => setPaginaAtual((pagina) => Math.max(1, pagina - 1))}
    onNextPage={() => setPaginaAtual((pagina) => Math.min(totalPaginas, pagina + 1))}
    onLastPage={() => setPaginaAtual(totalPaginas)}
    onBack={() => navigate(-1)}
    filterContent={<><label>Buscar exame<input value={busca} onChange={(event) => { setBusca(event.target.value); setPaginaAtual(1) }} placeholder="Nome, código ou categoria" /></label><label>Categoria<select value={categoriaFiltro} onChange={(event) => { setCategoriaFiltro(event.target.value); setPaginaAtual(1) }}><option value="todas">Todas</option>{categorias.filter((categoria) => categoria.ativo).map((categoria) => <option key={categoria.id} value={categoria.id}>{categoria.nome}</option>)}</select></label><label>Situação<select value={situacao} onChange={(event) => { setSituacao(event.target.value as typeof situacao); setPaginaAtual(1) }}><option value="todos">Todos</option><option value="ativos">Ativos</option><option value="inativos">Inativos</option></select></label></>}
  >
    {erro && <p className="form-error cadastro-list-error">{erro}</p>}
    {carregando ? <p className="cadastro-state">Carregando exames…</p> : <div className="cadastro-grid exames-grid" role="table" aria-label="Exames cadastrados">
      <div className="cadastro-grid-header exames-grid-header" role="row"><span></span>{cabecalho('Código', 'codigo')}{cabecalho('Exame', 'nome')}{cabecalho('Categoria', 'idCategoria')}{cabecalho('Tipo', 'primario')}{cabecalho('Qtd.', 'quantidade')}{cabecalho('Valor', 'valor')}{cabecalho('Situação', 'ativo')}</div>
      {registrosDaPagina.map((exame) => <article className="cadastro-row exame-row" key={exame.id} role="row" onPointerDown={(event) => iniciarPressionamento(exame.id, event)} onPointerUp={cancelarPressionamento} onPointerCancel={cancelarPressionamento} onPointerLeave={cancelarPressionamento} onPointerMove={cancelarPressionamento}>
        <input type="checkbox" checked={selecionados.includes(exame.id)} onChange={() => alternarSelecao(exame.id)} aria-label={`Selecionar ${exame.nome}`} />
        <span className="cadastro-code">{exame.codigo}</span><strong className="exame-name">{exame.nome}</strong><span className="exame-category">{nomesCategorias.get(exame.idCategoria) ?? '—'}</span><span className="exame-type">{exame.primario ? 'Unitário' : 'Pacote'}</span><span className="exame-quantity">{exame.quantidade}</span><span className="exame-value">{formatarValor(exame.valor)}</span><span className="exame-detail">{exame.primario ? 'Unitário' : 'Pacote'} · {exame.quantidade} · {formatarValor(exame.valor)}</span>{badgeSituacao(exame.ativo)}
      </article>)}
      {registros.length === 0 && <p className="cadastro-state">Nenhum exame encontrado com os filtros informados.</p>}
    </div>}
  </CadastroPesquisaSelecao>
}
