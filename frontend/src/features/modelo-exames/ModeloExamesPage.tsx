import { ChevronDown, ChevronRight, FlaskConical, FolderTree, Layers3 } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useAuth } from '../../app/auth/useAuth'
import {
  modeloExamesApi,
  type Analito,
  type AnimalGrupo,
  type Exame,
  type ExameAnalito,
  type ModeloExame,
  type ModeloExameAnalito,
} from '../../services/modeloExamesApi'

type GrupoNo = AnimalGrupo & { filhos: GrupoNo[] }

function criarArvore(grupos: AnimalGrupo[]): GrupoNo[] {
  const porId = new Map<number, GrupoNo>()
  grupos.filter((grupo) => grupo.ativo).forEach((grupo) => porId.set(grupo.id, { ...grupo, filhos: [] }))
  const raizes: GrupoNo[] = []

  porId.forEach((grupo) => {
    const pai = grupo.idGrupoPai === null ? undefined : porId.get(grupo.idGrupoPai)
    if (pai) pai.filhos.push(grupo)
    else raizes.push(grupo)
  })

  const ordenar = (itens: GrupoNo[]) => {
    itens.sort((primeiro, segundo) => primeiro.nome.localeCompare(segundo.nome, 'pt-BR'))
    itens.forEach((item) => ordenar(item.filhos))
  }
  ordenar(raizes)
  return raizes
}

function moeda(valor: number | null) {
  return valor === null ? 'Não informado' : valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
}

function formatarNumero(valor: number, casasDecimais: number) {
  return valor.toLocaleString('pt-BR', {
    minimumFractionDigits: casasDecimais,
    maximumFractionDigits: casasDecimais,
  })
}

function formatarReferencia(
  referencia: string | null,
  percentual: number | null,
  tipoValor: number | undefined,
) {
  if (referencia === null && percentual === null) return '—'

  let valor = referencia ?? '—'
  if (referencia !== null && tipoValor !== 3) {
    const numero = Number(referencia.replace(',', '.'))
    if (!Number.isNaN(numero)) {
      valor = formatarNumero(numero, tipoValor === 2 ? 2 : 0)
    }
  }

  return percentual === null ? valor : `${valor} (${formatarNumero(percentual, 2)}%)`
}

function GrupoArvore({ grupo, selecionadoId, onSelecionar }: {
  grupo: GrupoNo
  selecionadoId: number | null
  onSelecionar: (id: number) => void
}) {
  const [aberto, setAberto] = useState(true)
  const possuiFilhos = grupo.filhos.length > 0

  return <li>
    <div className={`grupo-item ${selecionadoId === grupo.id ? 'selecionado' : ''}`}>
      <button className="grupo-expandir" onClick={() => setAberto(!aberto)} disabled={!possuiFilhos} aria-label={aberto ? `Recolher ${grupo.nome}` : `Expandir ${grupo.nome}`}>
        {possuiFilhos && (aberto ? <ChevronDown size={15} /> : <ChevronRight size={15} />)}
      </button>
      <button className="grupo-seletor" onClick={() => onSelecionar(grupo.id)}><FolderTree size={16} /><span>{grupo.nome}</span></button>
    </div>
    {possuiFilhos && aberto && <ul className="grupo-filhos">{grupo.filhos.map((filho) => <GrupoArvore key={filho.id} grupo={filho} selecionadoId={selecionadoId} onSelecionar={onSelecionar} />)}</ul>}
  </li>
}

export function ModeloExamesPage() {
  const { accessToken } = useAuth()
  const [grupos, setGrupos] = useState<AnimalGrupo[]>([])
  const [modelos, setModelos] = useState<ModeloExame[]>([])
  const [exames, setExames] = useState<Exame[]>([])
  const [exameAnalitos, setExameAnalitos] = useState<ExameAnalito[]>([])
  const [catalogoAnalitos, setCatalogoAnalitos] = useState<Analito[]>([])
  const [analitosModelo, setAnalitosModelo] = useState<ModeloExameAnalito[]>([])
  const [grupoSelecionadoId, setGrupoSelecionadoId] = useState<number | null>(null)
  const [modeloSelecionadoId, setModeloSelecionadoId] = useState<number | null>(null)
  const [carregando, setCarregando] = useState(true)
  const [carregandoAnalitos, setCarregandoAnalitos] = useState(false)
  const [erro, setErro] = useState<string | null>(null)

  useEffect(() => {
    if (!accessToken) return
    const token = accessToken
    async function carregarCatalogo() {
      setCarregando(true)
      setErro(null)
      try {
        const [
          gruposCarregados,
          modelosCarregados,
          examesCarregados,
          exameAnalitosCarregados,
          catalogoAnalitosCarregado,
        ] = await Promise.all([
          modeloExamesApi.listarGrupos(token),
          modeloExamesApi.listarModelos(token),
          modeloExamesApi.listarExames(token),
          modeloExamesApi.listarExameAnalitos(token),
          modeloExamesApi.listarCatalogoAnalitos(token),
        ])
        setGrupos(gruposCarregados)
        setModelos(modelosCarregados)
        setExames(examesCarregados)
        setExameAnalitos(exameAnalitosCarregados)
        setCatalogoAnalitos(catalogoAnalitosCarregado)
        setGrupoSelecionadoId(gruposCarregados.find((grupo) => grupo.ativo)?.id ?? null)
      } catch (error) {
        setErro(error instanceof Error ? error.message : 'Não foi possível carregar os dados de modelos de exame.')
      } finally {
        setCarregando(false)
      }
    }
    void carregarCatalogo()
  }, [accessToken])

  const arvore = useMemo(() => criarArvore(grupos), [grupos])
  const grupoSelecionado = grupos.find((grupo) => grupo.id === grupoSelecionadoId) ?? null
  const modelosDoGrupo = useMemo(() => modelos.filter((modelo) => modelo.ativo && modelo.idAnimalGrupo === grupoSelecionadoId), [grupoSelecionadoId, modelos])
  const modeloSelecionado = modelosDoGrupo.find((modelo) => modelo.id === modeloSelecionadoId) ?? null
  const tipoValorPorExameAnalito = useMemo(() => {
    const tipoPorAnalito = new Map(catalogoAnalitos.map((analito) => [analito.id, analito.tipoValor]))
    return new Map(exameAnalitos.map((vinculo) => [vinculo.id, tipoPorAnalito.get(vinculo.idAnalito)]))
  }, [catalogoAnalitos, exameAnalitos])

  useEffect(() => {
    setModeloSelecionadoId(modelosDoGrupo[0]?.id ?? null)
  }, [grupoSelecionadoId, modelosDoGrupo])

  useEffect(() => {
    if (!accessToken || modeloSelecionadoId === null) {
      setAnalitosModelo([])
      return
    }
    const token = accessToken
    const idModeloExame = modeloSelecionadoId
    async function carregarAnalitos() {
      setCarregandoAnalitos(true)
      try {
        setAnalitosModelo(await modeloExamesApi.listarAnalitos(idModeloExame, token))
      } catch (error) {
        setErro(error instanceof Error ? error.message : 'Não foi possível carregar os analitos do modelo.')
      } finally {
        setCarregandoAnalitos(false)
      }
    }
    void carregarAnalitos()
  }, [accessToken, modeloSelecionadoId])

  const secoes = useMemo(() => {
    const porSecao = new Map<string, ModeloExameAnalito[]>()
    analitosModelo.filter((item) => item.ativo).forEach((item) => {
      const secao = item.secao.trim() || 'Sem seção'
      porSecao.set(secao, [...(porSecao.get(secao) ?? []), item])
    })
    return [...porSecao.entries()].map(([secao, itens]) => ({ secao, itens: itens.sort((a, b) => a.ordem - b.ordem) }))
  }, [analitosModelo])

  return <section className="module-page modelo-exames-page">
    <div className="page-heading"><div><p className="eyebrow">Cadastros</p><h1>Modelo de Exames</h1><p>Grupos, modelos e analitos organizados para consulta do catálogo laboratorial.</p></div></div>
    {erro && <p className="form-error">{erro}</p>}
    <div className="modelo-exames-layout">
      <aside className="grupos-card painel"><div className="card-title"><FolderTree size={18} /><div><strong>Grupos de animais</strong><span>Estrutura hierárquica</span></div></div>{carregando ? <p className="card-status">Carregando grupos…</p> : <ul className="grupos-arvore">{arvore.map((grupo) => <GrupoArvore key={grupo.id} grupo={grupo} selecionadoId={grupoSelecionadoId} onSelecionar={setGrupoSelecionadoId} />)}</ul>}</aside>
      <section className="painel modelos-painel"><div className="painel-cabecalho"><div><p className="eyebrow">Grupo selecionado</p><h2>{grupoSelecionado?.nome ?? 'Selecione um grupo'}</h2></div><span className="modelo-contagem"><Layers3 size={16} />{modelosDoGrupo.length}</span></div>{carregando ? <p className="card-status">Carregando modelos…</p> : modelosDoGrupo.length === 0 ? <p className="painel-vazio">Nenhum modelo ativo para este grupo.</p> : <div className="modelos-lista">{modelosDoGrupo.map((modelo) => { const exame = exames.find((item) => item.id === modelo.idExame); return <button className={`modelo-card ${modelo.id === modeloSelecionadoId ? 'selecionado' : ''}`} key={modelo.id} onClick={() => setModeloSelecionadoId(modelo.id)}><header className="modelo-cabecalho"><span className="modelo-codigo-circulo">{exame?.codigo ?? modelo.codigo}</span><strong>{exame?.nome ?? 'Exame não vinculado'}</strong></header><div className="modelo-campos"><div><span>Faixa etária</span><strong>{modelo.faixaIdade || 'Não informada'}</strong></div><div><span>Total de exames</span><strong>{exame?.quantidade ?? '—'}</strong></div><div><span>Valor</span><strong>{moeda(exame?.valor ?? null)}</strong></div><div className="modelo-arquivo"><span>Arquivo origem</span><strong>{modelo.arquivoOrigem || 'Não informado'}</strong></div></div></button> })}</div>}</section>
      <section className="painel analitos-painel"><div className="painel-cabecalho"><div><p className="eyebrow">Modelo selecionado</p><h2>{modeloSelecionado?.nome ?? 'Selecione um modelo'}</h2></div><FlaskConical size={19} /></div>{modeloSelecionado === null ? <p className="painel-vazio">Selecione um modelo para visualizar seus analitos.</p> : carregandoAnalitos ? <p className="card-status">Carregando analitos…</p> : secoes.length === 0 ? <p className="painel-vazio">Nenhum analito configurado.</p> : <div className="secoes-lista">{secoes.map(({ secao, itens }) => <section className="secao-analitos" key={secao}><h3>{secao}</h3>{itens.map((item) => <article className="analito-card" key={item.id}><div className="analito-dados"><span className="ordem">{item.ordem}</span><strong>{item.rotulo || '—'}</strong><strong>{formatarReferencia(item.referenciaMinima, item.referenciaPercentualMinima, tipoValorPorExameAnalito.get(item.idExameAnalito))}</strong><strong>{formatarReferencia(item.referenciaMaxima, item.referenciaPercentualMaxima, tipoValorPorExameAnalito.get(item.idExameAnalito))}</strong></div>{item.tecnica && <em className="analito-tecnica">{item.tecnica}</em>}</article>)}</section>)}</div>}</section>
    </div>
  </section>
}
