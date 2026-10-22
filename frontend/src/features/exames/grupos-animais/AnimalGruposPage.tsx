import { useCallback, useEffect, useMemo, useRef, useState, type ChangeEvent, type FormEvent, type PointerEvent as ReactPointerEvent } from 'react'
import { ArrowDown, ArrowUp, ChevronDown, ChevronRight, FolderTree, PawPrint } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../../app/auth/useAuth'
import { examesApi, type AnimalGrupo, type AnimalGrupoInput } from '../../../services/examesApi'
import { CadastroEdicao } from '../shared/CadastroEdicao'
import { CadastroPesquisaSelecao } from '../shared/CadastroPesquisaSelecao'

type Ordenacao = keyof Pick<AnimalGrupo, 'nome' | 'ativo'>
type NoArvore = { grupo: AnimalGrupo; filhos: NoArvore[] }

const formularioInicial: AnimalGrupoInput = { nome: '', descricao: '', idGrupoPai: null }
const registrosPorPagina = 25

function tituloGrupos() {
  return <span className="cadastro-title-icon"><FolderTree size={43} aria-hidden="true" /></span>
}

function badgeSituacao(ativo: boolean) {
  return <span className={`status-badge ${ativo ? 'active' : 'inactive'}`}>{ativo ? 'Ativo' : 'Inativo'}</span>
}

function montarArvore(grupos: AnimalGrupo[]) {
  const porId = new Map(grupos.map((grupo) => [grupo.id, { grupo, filhos: [] as NoArvore[] }]))
  const raizes: NoArvore[] = []

  porId.forEach((no) => {
    const pai = no.grupo.idGrupoPai === null ? undefined : porId.get(no.grupo.idGrupoPai)
    if (pai && pai.grupo.id !== no.grupo.id) pai.filhos.push(no)
    else raizes.push(no)
  })

  const ordenar = (nos: NoArvore[]) => {
    nos.sort((primeiro, segundo) => primeiro.grupo.nome.localeCompare(segundo.grupo.nome, 'pt-BR', { numeric: true }))
    nos.forEach((no) => ordenar(no.filhos))
  }
  ordenar(raizes)
  return raizes
}

function idsDescendentes(id: number, grupos: AnimalGrupo[]) {
  const filhosPorPai = new Map<number, number[]>()
  grupos.forEach((grupo) => {
    if (grupo.idGrupoPai === null) return
    filhosPorPai.set(grupo.idGrupoPai, [...(filhosPorPai.get(grupo.idGrupoPai) ?? []), grupo.id])
  })
  const encontrados = new Set<number>([id])
  const pendentes = [id]
  while (pendentes.length) {
    const atual = pendentes.pop()!
    for (const filho of filhosPorPai.get(atual) ?? []) {
      if (!encontrados.has(filho)) { encontrados.add(filho); pendentes.push(filho) }
    }
  }
  return encontrados
}

function opçõesPai(nos: NoArvore[], profundidade = 0): { id: number; texto: string }[] {
  return nos.flatMap((no) => [
    { id: no.grupo.id, texto: `${'— '.repeat(profundidade)}${no.grupo.nome}` },
    ...opçõesPai(no.filhos, profundidade + 1),
  ])
}

type ArvoreProps = {
  nos: NoArvore[]
  selecionadoId: number | null
  recolhidos: Set<number>
  onSelecionar: (id: number) => void
  onAlternar: (id: number) => void
}

function ArvoreGrupos({ nos, selecionadoId, recolhidos, onSelecionar, onAlternar }: ArvoreProps) {
  return <ul className="animal-groups-tree" role="tree">
    {nos.map((no) => {
      const possuiFilhos = no.filhos.length > 0
      const recolhido = recolhidos.has(no.grupo.id)
      return <li key={no.grupo.id} role="treeitem" aria-expanded={possuiFilhos ? !recolhido : undefined}>
        <div className={`animal-groups-tree-node ${selecionadoId === no.grupo.id ? 'selected' : ''}`}>
          <button className="animal-groups-tree-toggle" type="button" disabled={!possuiFilhos} onClick={() => possuiFilhos && onAlternar(no.grupo.id)} aria-label={recolhido ? `Expandir ${no.grupo.nome}` : `Recolher ${no.grupo.nome}`}>
            {possuiFilhos ? recolhido ? <ChevronRight size={15} /> : <ChevronDown size={15} /> : <span />}
          </button>
          <button className="animal-groups-tree-label" type="button" onClick={() => onSelecionar(no.grupo.id)}>
            <PawPrint size={15} /><span>{no.grupo.nome}</span>{!no.grupo.ativo && <small>inativo</small>}
          </button>
        </div>
        {possuiFilhos && !recolhido && <ArvoreGrupos nos={no.filhos} selecionadoId={selecionadoId} recolhidos={recolhidos} onSelecionar={onSelecionar} onAlternar={onAlternar} />}
      </li>
    })}
  </ul>
}

export function AnimalGruposPage() {
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [grupos, setGrupos] = useState<AnimalGrupo[]>([])
  const [selecionados, setSelecionados] = useState<number[]>([])
  const [grupoNaArvore, setGrupoNaArvore] = useState<number | null>(null)
  const [recolhidos, setRecolhidos] = useState<Set<number>>(new Set())
  const [busca, setBusca] = useState('')
  const [situacao, setSituacao] = useState<'todos' | 'ativos' | 'inativos'>('ativos')
  const [ordenacao, setOrdenacao] = useState<Ordenacao>('nome')
  const [direcao, setDirecao] = useState<'asc' | 'desc'>('asc')
  const [paginaAtual, setPaginaAtual] = useState(1)
  const [filtrosAbertos, setFiltrosAbertos] = useState(false)
  const [carregando, setCarregando] = useState(true)
  const [erro, setErro] = useState<string | null>(null)
  const [registroEmEdicao, setRegistroEmEdicao] = useState<AnimalGrupo | null | undefined>(undefined)
  const [formulario, setFormulario] = useState<AnimalGrupoInput>(formularioInicial)
  const [salvando, setSalvando] = useState(false)
  const temporizadorPressionamento = useRef<number | null>(null)

  const carregar = useCallback(async () => {
    if (!accessToken) return
    setCarregando(true); setErro(null)
    try { setGrupos(await examesApi.listarGruposAnimais(accessToken, true)) }
    catch (error) { setErro(error instanceof Error ? error.message : 'Não foi possível carregar os grupos de animais.') }
    finally { setCarregando(false) }
  }, [accessToken])

  useEffect(() => { void Promise.resolve().then(carregar) }, [carregar])
  useEffect(() => () => { if (temporizadorPressionamento.current !== null) window.clearTimeout(temporizadorPressionamento.current) }, [])

  const gruposPorSituacao = useMemo(() => grupos.filter((grupo) => situacao === 'todos' || (situacao === 'ativos') === grupo.ativo), [grupos, situacao])
  const gruposVisiveisNaArvore = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    if (!termo) return gruposPorSituacao
    const visiveis = new Set<number>()
    gruposPorSituacao.forEach((grupo) => {
      if (!grupo.nome.toLocaleLowerCase('pt-BR').includes(termo) && !grupo.descricao.toLocaleLowerCase('pt-BR').includes(termo)) return
      let atual: AnimalGrupo | undefined = grupo
      while (atual) {
        visiveis.add(atual.id)
        atual = atual.idGrupoPai === null ? undefined : gruposPorSituacao.find((item) => item.id === atual!.idGrupoPai)
      }
    })
    return gruposPorSituacao.filter((grupo) => visiveis.has(grupo.id))
  }, [busca, gruposPorSituacao])
  const arvore = useMemo(() => montarArvore(gruposVisiveisNaArvore), [gruposVisiveisNaArvore])
  const escopoDaArvore = useMemo(() => grupoNaArvore === null ? null : idsDescendentes(grupoNaArvore, grupos), [grupoNaArvore, grupos])
  const registros = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    return gruposPorSituacao
      .filter((grupo) => escopoDaArvore === null || escopoDaArvore.has(grupo.id))
      .filter((grupo) => !termo || grupo.nome.toLocaleLowerCase('pt-BR').includes(termo) || grupo.descricao.toLocaleLowerCase('pt-BR').includes(termo))
      .sort((primeiro, segundo) => {
        const resultado = String(primeiro[ordenacao]).localeCompare(String(segundo[ordenacao]), 'pt-BR', { numeric: true })
        return direcao === 'asc' ? resultado : -resultado
      })
  }, [busca, direcao, escopoDaArvore, gruposPorSituacao, ordenacao])

  const selecionado = selecionados.length === 1 ? grupos.find((grupo) => grupo.id === selecionados[0]) ?? null : null
  const totalPaginas = Math.max(1, Math.ceil(registros.length / registrosPorPagina))
  const paginaExibida = Math.min(paginaAtual, totalPaginas)
  const registrosDaPagina = registros.slice((paginaExibida - 1) * registrosPorPagina, paginaExibida * registrosPorPagina)
  const todosSelecionados = registrosDaPagina.length > 0 && registrosDaPagina.every((grupo) => selecionados.includes(grupo.id))
  const nomesPai = useMemo(() => new Map(grupos.map((grupo) => [grupo.id, grupo.nome])), [grupos])

  function alternarOrdenacao(campo: Ordenacao) {
    if (campo === ordenacao) setDirecao((valor) => valor === 'asc' ? 'desc' : 'asc')
    else { setOrdenacao(campo); setDirecao('asc') }
    setPaginaAtual(1)
  }

  function alternarSelecao(id: number) { setSelecionados((atuais) => atuais.includes(id) ? atuais.filter((item) => item !== id) : [...atuais, id]) }
  function cancelarPressionamento() {
    if (temporizadorPressionamento.current === null) return
    window.clearTimeout(temporizadorPressionamento.current); temporizadorPressionamento.current = null
  }
  function iniciarPressionamento(id: number, event: ReactPointerEvent<HTMLElement>) {
    if (event.target instanceof HTMLInputElement || (event.pointerType === 'mouse' && event.button !== 0)) return
    cancelarPressionamento()
    temporizadorPressionamento.current = window.setTimeout(() => { alternarSelecao(id); temporizadorPressionamento.current = null }, 300)
  }
  function selecionarNo(id: number) { setGrupoNaArvore((atual) => atual === id ? null : id); setPaginaAtual(1) }
  function alternarNo(id: number) { setRecolhidos((atuais) => { const proximo = new Set(atuais); if (proximo.has(id)) proximo.delete(id); else proximo.add(id); return proximo }) }
  function abrirInclusao() { setFormulario({ ...formularioInicial, idGrupoPai: grupoNaArvore }); setRegistroEmEdicao(null); setErro(null) }

  async function abrirEdicao() {
    if (!selecionado || !accessToken) return
    setErro(null)
    try {
      const grupo = await examesApi.obterGrupoAnimal(selecionado.id, accessToken)
      setFormulario({ nome: grupo.nome, descricao: grupo.descricao, idGrupoPai: grupo.idGrupoPai })
      setRegistroEmEdicao(grupo)
    } catch (error) { setErro(error instanceof Error ? error.message : 'Não foi possível abrir o grupo de animais.') }
  }
  async function alterarSituacao(ativo: boolean) {
    if (!accessToken || selecionados.length === 0) return
    const registrosSelecionados = grupos.filter((grupo) => selecionados.includes(grupo.id))
    const acao = ativo ? 'reativar' : 'inativar'
    const avisoHistorico = ativo ? '' : '\nModelos que referenciem estes grupos preservarão o histórico.'
    if (!window.confirm(`Deseja ${acao} ${registrosSelecionados.map((grupo) => grupo.nome).join(', ')}?${avisoHistorico}`)) return
    try {
      await Promise.all(registrosSelecionados.filter((grupo) => grupo.ativo !== ativo).map((grupo) => examesApi.definirGrupoAnimalAtivo(grupo.id, ativo, accessToken)))
      setSelecionados([]); await carregar()
    } catch (error) { setErro(error instanceof Error ? error.message : 'Não foi possível alterar a situação dos grupos de animais.') }
  }
  function alterarCampo(event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) {
    const { name, value } = event.target
    setFormulario((atual) => ({ ...atual, [name]: name === 'idGrupoPai' ? (value ? Number(value) : null) : value }))
  }
  async function salvar(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); if (!accessToken) return
    setSalvando(true); setErro(null)
    const input: AnimalGrupoInput = { nome: formulario.nome.trim().replace(/\s+/g, ' '), descricao: formulario.descricao.trim(), idGrupoPai: formulario.idGrupoPai }
    try {
      if (registroEmEdicao) await examesApi.atualizarGrupoAnimal(registroEmEdicao.id, input, accessToken)
      else await examesApi.criarGrupoAnimal(input, accessToken)
      setRegistroEmEdicao(undefined); await carregar()
    } catch (error) { setErro(error instanceof Error ? error.message : 'Não foi possível salvar o grupo de animais.') }
    finally { setSalvando(false) }
  }

  if (registroEmEdicao !== undefined) {
    const bloqueados = registroEmEdicao ? idsDescendentes(registroEmEdicao.id, grupos) : new Set<number>()
    const paisDisponiveis = opçõesPai(montarArvore(grupos.filter((grupo) => grupo.ativo && !bloqueados.has(grupo.id))))
    return <CadastroEdicao icon={tituloGrupos()} title="Grupos de Animais" actionLabel={registroEmEdicao ? 'Edição' : 'Inclusão'} saving={salvando} onCancel={() => { setRegistroEmEdicao(undefined); setErro(null) }} onSubmit={salvar}>
      <section className="cadastro-form-panel">
        <header><div><FolderTree size={20} /><strong>Dados do grupo</strong></div><span>Campos com * são obrigatórios</span></header>
        {erro && <p className="form-error">{erro}</p>}
        <div className="cadastro-form-scroll-content">
          <fieldset><legend>Hierarquia</legend><div className="form-grid">
            <label>Nome do grupo *<input name="nome" value={formulario.nome} onChange={alterarCampo} required maxLength={150} autoFocus /></label>
            <label>Grupo pai<select name="idGrupoPai" value={formulario.idGrupoPai ?? ''} onChange={alterarCampo}><option value="">Sem grupo pai (raiz)</option>{paisDisponiveis.map((pai) => <option key={pai.id} value={pai.id}>{pai.texto}</option>)}</select></label>
            <label className="form-field-wide">Descrição<textarea name="descricao" value={formulario.descricao} onChange={alterarCampo} maxLength={500} rows={4} placeholder="Descrição opcional do agrupamento" /></label>
          </div></fieldset>
          <aside className="cadastro-impact-note">A hierarquia facilita a organização dos animais nos modelos de exames. Grupos inativos não podem ser usados como grupo pai.</aside>
        </div>
      </section>
    </CadastroEdicao>
  }

  const cabecalho = (titulo: string, campo: Ordenacao) => <button className={`cadastro-sort ${ordenacao === campo ? 'active' : ''}`} onClick={() => alternarOrdenacao(campo)}>{titulo}{ordenacao === campo ? direcao === 'asc' ? <ArrowUp size={13} /> : <ArrowDown size={13} /> : <span>↕</span>}</button>

  return <CadastroPesquisaSelecao
    icon={tituloGrupos()} title="Grupos de Animais" selectedCount={selecionados.length} totalRecords={registros.length} allSelected={todosSelecionados} currentPage={paginaExibida} totalPages={totalPaginas} filtersOpen={filtrosAbertos} editingEnabled={selecionado !== null} reactivationEnabled={selecionados.some((id) => grupos.find((grupo) => grupo.id === id && !grupo.ativo))}
    onToggleFilters={() => setFiltrosAbertos((aberto) => !aberto)} onSelectAll={() => setSelecionados(todosSelecionados ? (atuais) => atuais.filter((id) => !registrosDaPagina.some((grupo) => grupo.id === id)) : (atuais) => [...new Set([...atuais, ...registrosDaPagina.map((grupo) => grupo.id)])])} onCreate={abrirInclusao} onEdit={() => void abrirEdicao()} onDeactivate={() => void alterarSituacao(false)} onReactivate={() => void alterarSituacao(true)} onFirstPage={() => setPaginaAtual(1)} onPreviousPage={() => setPaginaAtual((pagina) => Math.max(1, pagina - 1))} onNextPage={() => setPaginaAtual((pagina) => Math.min(totalPaginas, pagina + 1))} onLastPage={() => setPaginaAtual(totalPaginas)} onBack={() => navigate(-1)}
    filterContent={<><label>Buscar grupo<input value={busca} onChange={(event) => { setBusca(event.target.value); setPaginaAtual(1) }} placeholder="Nome ou descrição" /></label><label>Situação<select value={situacao} onChange={(event) => { setSituacao(event.target.value as typeof situacao); setPaginaAtual(1) }}><option value="todos">Todos</option><option value="ativos">Ativos</option><option value="inativos">Inativos</option></select></label></>}
  >
    {erro && <p className="form-error cadastro-list-error">{erro}</p>}
    {carregando ? <p className="cadastro-state">Carregando grupos de animais…</p> : <div className="animal-groups-workspace">
      <aside className="animal-groups-tree-panel"><header><FolderTree size={18} /><div><strong>Hierarquia de grupos</strong><span>{grupoNaArvore === null ? 'Todos os grupos' : 'Grupo e subgrupos selecionados'}</span></div>{grupoNaArvore !== null && <button type="button" onClick={() => selecionarNo(grupoNaArvore)}>Limpar</button>}</header>{arvore.length ? <ArvoreGrupos nos={arvore} selecionadoId={grupoNaArvore} recolhidos={recolhidos} onSelecionar={selecionarNo} onAlternar={alternarNo} /> : <p className="cadastro-state">Nenhum grupo encontrado.</p>}</aside>
      <section className="animal-groups-table-panel"><div className="cadastro-grid animal-groups-grid" role="table" aria-label="Grupos de animais cadastrados"><div className="cadastro-grid-header animal-groups-grid-header" role="row"><span></span>{cabecalho('Grupo', 'nome')}<span>Grupo pai</span><span>Descrição</span>{cabecalho('Situação', 'ativo')}</div>{registrosDaPagina.map((grupo) => <article className="cadastro-row animal-group-row" key={grupo.id} role="row" onPointerDown={(event) => iniciarPressionamento(grupo.id, event)} onPointerUp={cancelarPressionamento} onPointerCancel={cancelarPressionamento} onPointerLeave={cancelarPressionamento} onPointerMove={cancelarPressionamento}><input type="checkbox" checked={selecionados.includes(grupo.id)} onChange={() => alternarSelecao(grupo.id)} aria-label={`Selecionar ${grupo.nome}`} /><strong>{grupo.nome}</strong><span>{grupo.idGrupoPai === null ? 'Raiz' : nomesPai.get(grupo.idGrupoPai) ?? 'Grupo não encontrado'}</span><span title={grupo.descricao}>{grupo.descricao || '—'}</span>{badgeSituacao(grupo.ativo)}</article>)}{registros.length === 0 && <p className="cadastro-state">Nenhum grupo encontrado com os filtros informados.</p>}</div></section>
    </div>}
  </CadastroPesquisaSelecao>
}
