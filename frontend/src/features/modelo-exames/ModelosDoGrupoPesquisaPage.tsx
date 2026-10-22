import { useCallback, useEffect, useMemo, useRef, useState, type PointerEvent as ReactPointerEvent } from 'react'
import { ClipboardList } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { useAuth } from '../../app/auth/useAuth'
import { modeloExamesApi, type AnimalGrupo, type ModeloExame } from '../../services/modeloExamesApi'
import { CadastroPesquisaSelecao } from '../exames/shared/CadastroPesquisaSelecao'

const registrosPorPagina = 25

function titulo() {
  return <span className="cadastro-title-icon"><ClipboardList size={43} aria-hidden="true" /></span>
}

export function ModelosDoGrupoPesquisaPage() {
  const { grupoId } = useParams()
  const idGrupo = Number(grupoId)
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [grupos, setGrupos] = useState<AnimalGrupo[]>([])
  const [modelos, setModelos] = useState<ModeloExame[]>([])
  const [selecionados, setSelecionados] = useState<number[]>([])
  const [busca, setBusca] = useState('')
  const [filtrosAbertos, setFiltrosAbertos] = useState(false)
  const [paginaAtual, setPaginaAtual] = useState(1)
  const [carregando, setCarregando] = useState(true)
  const [erro, setErro] = useState<string | null>(null)
  const temporizadorPressionamento = useRef<number | null>(null)

  const carregar = useCallback(async () => {
    if (!accessToken) return
    setCarregando(true)
    setErro(null)
    try {
      const [gruposCarregados, modelosCarregados] = await Promise.all([
        modeloExamesApi.listarGrupos(accessToken),
        modeloExamesApi.listarModelos(accessToken),
      ])
      setGrupos(gruposCarregados)
      setModelos(modelosCarregados)
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível carregar os modelos de exame.')
    } finally {
      setCarregando(false)
    }
  }, [accessToken])

  useEffect(() => { void carregar() }, [carregar])
  useEffect(() => () => {
    if (temporizadorPressionamento.current !== null) window.clearTimeout(temporizadorPressionamento.current)
  }, [])

  const grupo = grupos.find((item) => item.id === idGrupo)
  const registros = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    return modelos.filter((modelo) => modelo.idAnimalGrupo === idGrupo && (!termo || `${modelo.codigo} ${modelo.nome} ${modelo.faixaIdade}`.toLocaleLowerCase('pt-BR').includes(termo)))
  }, [busca, idGrupo, modelos])
  const selecionado = selecionados.length === 1 ? modelos.find((modelo) => modelo.id === selecionados[0]) ?? null : null
  const totalPaginas = Math.max(1, Math.ceil(registros.length / registrosPorPagina))
  const paginaExibida = Math.min(paginaAtual, totalPaginas)
  const registrosDaPagina = registros.slice((paginaExibida - 1) * registrosPorPagina, paginaExibida * registrosPorPagina)
  const todosSelecionados = registrosDaPagina.length > 0 && registrosDaPagina.every((modelo) => selecionados.includes(modelo.id))

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
  async function inativar() {
    if (!accessToken || selecionados.length === 0) return
    const escolhidos = modelos.filter((modelo) => selecionados.includes(modelo.id))
    if (!window.confirm(`Deseja inativar ${escolhidos.map((modelo) => modelo.nome).join(', ')}?`)) return
    try {
      await Promise.all(escolhidos.map((modelo) => modeloExamesApi.definirModeloAtivo(modelo.id, false, accessToken)))
      setSelecionados([])
      await carregar()
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível inativar o modelo de exame.')
    }
  }

  return <CadastroPesquisaSelecao
    icon={titulo()}
    title={`Modelos — ${grupo?.nome ?? 'Grupo de animais'}`}
    selectedCount={selecionados.length}
    totalRecords={registros.length}
    allSelected={todosSelecionados}
    currentPage={paginaExibida}
    totalPages={totalPaginas}
    filtersOpen={filtrosAbertos}
    editingEnabled={selecionado !== null}
    reactivationEnabled={false}
    onToggleFilters={() => setFiltrosAbertos((aberto) => !aberto)}
    onSelectAll={() => setSelecionados(todosSelecionados ? (atuais) => atuais.filter((id) => !registrosDaPagina.some((modelo) => modelo.id === id)) : (atuais) => [...new Set([...atuais, ...registrosDaPagina.map((modelo) => modelo.id)])])}
    onCreate={() => navigate(`/exames/modelos/novo/${idGrupo}`)}
    onEdit={() => selecionado && navigate(`/exames/modelos/${selecionado.id}/editar`)}
    onDeactivate={() => void inativar()}
    onReactivate={() => undefined}
    onFirstPage={() => setPaginaAtual(1)}
    onPreviousPage={() => setPaginaAtual((pagina) => Math.max(1, pagina - 1))}
    onNextPage={() => setPaginaAtual((pagina) => Math.min(totalPaginas, pagina + 1))}
    onLastPage={() => setPaginaAtual(totalPaginas)}
    onBack={() => navigate('/exames/modelos')}
    filterContent={<label>Buscar modelo<input value={busca} onChange={(event) => { setBusca(event.target.value); setPaginaAtual(1) }} placeholder="Código, nome ou faixa etária" /></label>}
  >
    {erro && <p className="form-error cadastro-list-error">{erro}</p>}
    {carregando ? <p className="cadastro-state">Carregando modelos de exame…</p> : <div className="cadastro-grid modelos-grupo-grid" role="table" aria-label="Modelos de exame do grupo selecionado">
      {registrosDaPagina.map((modelo) => <article className="cadastro-row modelo-grupo-row" key={modelo.id} role="row" onPointerDown={(event) => iniciarPressionamento(modelo.id, event)} onPointerUp={cancelarPressionamento} onPointerCancel={cancelarPressionamento} onPointerLeave={cancelarPressionamento} onPointerMove={cancelarPressionamento}>
        <input type="checkbox" checked={selecionados.includes(modelo.id)} onChange={() => alternarSelecao(modelo.id)} aria-label={`Selecionar ${modelo.nome}`} />
        <div><strong>{modelo.codigo}</strong><span>{modelo.nome}</span></div><small>{modelo.faixaIdade || 'Faixa etária não informada'}</small>
      </article>)}
      {registros.length === 0 && <p className="cadastro-state">Nenhum modelo encontrado para este grupo.</p>}
    </div>}
  </CadastroPesquisaSelecao>
}
