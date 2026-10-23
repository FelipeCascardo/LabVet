import { useCallback, useEffect, useMemo, useState, type ChangeEvent, type FormEvent } from 'react'
import { ChevronDown, ChevronRight, ClipboardList, Edit3, FileDown, FolderTree, Plus, Save, Search, Trash2, X } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { useAuth } from '../../app/auth/useAuth'
import {
  modeloExamesApi,
  type Analito,
  type AnimalGrupo,
  type Exame,
  type ExameAnalito,
  type ModeloExame,
  type ModeloExameAnalito,
  type ModeloExameAnalitoInput,
  type ModeloExameInput,
} from '../../services/modeloExamesApi'
import { CadastroEdicao } from '../exames/shared/CadastroEdicao'

type NoGrupo = { grupo: AnimalGrupo; filhos: NoGrupo[] }
type GrupoAnalitos = {
  chave: string
  titulo: string
  ordem: number
  ordemGrupo: number
  itens: Array<{ item: ModeloExameAnalito; analito: Analito | undefined }>
}

const modeloInicial: ModeloExameInput = {
  codigo: '',
  nome: '',
  faixaIdade: '',
  arquivoOrigem: '',
  idExame: null,
  idAnimalGrupo: null,
}

const analitoInicial = (idModeloExame: number): ModeloExameAnalitoInput => ({
  idModeloExame,
  idExameAnalito: 0,
  secao: '',
  ordem: 1,
  rotulo: '',
  tecnica: '',
  unidadeMedida: '',
  referencia: '',
  referenciaMinima: null,
  referenciaMaxima: null,
  referenciaPercentualMinima: null,
  referenciaPercentualMaxima: null,
})

function descricaoTipoValor(tipoValor: Analito['tipoValor'] | undefined) {
  if (tipoValor === 1) return 'Inteiro'
  if (tipoValor === 2) return 'Decimal'
  if (tipoValor === 3) return 'Caractere'
  return 'Não informado'
}

function numeroDaReferencia(valor: string | null) {
  if (valor === null || !valor.trim()) return null
  const numero = Number(valor.trim().replace(',', '.'))
  return Number.isFinite(numero) ? numero : null
}

function formatarNumero(valor: number, casasDecimais: number) {
  return valor.toLocaleString('pt-BR', {
    useGrouping: false,
    minimumFractionDigits: casasDecimais,
    maximumFractionDigits: casasDecimais,
  })
}

function formatarReferencia(valor: string | null, tipoValor: Analito['tipoValor'] | undefined) {
  if (valor === null || !valor.trim()) return '—'
  if (tipoValor === 3 || tipoValor === undefined) return valor

  const numero = numeroDaReferencia(valor)
  if (numero === null) return valor
  return formatarNumero(numero, tipoValor === 2 ? 2 : 0)
}

function formatarReferenciaParaEdicao(valor: string | null, tipoValor: Analito['tipoValor'] | undefined) {
  if (valor === null || tipoValor === 3 || tipoValor === undefined) return valor
  const numero = numeroDaReferencia(valor)
  return numero === null ? valor : formatarNumero(numero, tipoValor === 2 ? 2 : 0)
}

function formatarFaixa(minimo: string | null, maximo: string | null, tipoValor: Analito['tipoValor'] | undefined) {
  if (minimo === null && maximo === null) return null
  return `${formatarReferencia(minimo, tipoValor)} — ${formatarReferencia(maximo, tipoValor)}`
}

function formatarPercentual(valor: number | null) {
  return valor === null ? '—' : `${formatarNumero(valor, 2)}%`
}

function nomeDoAnalitoNoCartao(item: ModeloExameAnalito, analito: Analito | undefined) {
  const nome = analito?.nome || item.rotulo || 'Analito'
  const unidadeMedida = item.unidadeMedida || analito?.unidadeMedida
  if (!unidadeMedida) return nome

  const sufixoDaUnidade = `(${unidadeMedida})`
  return nome.toLocaleLowerCase('pt-BR').endsWith(sufixoDaUnidade.toLocaleLowerCase('pt-BR'))
    ? nome.slice(0, -sufixoDaUnidade.length).trim()
    : nome
}

function escaparHtmlParaPdf(valor: string | number) {
  return String(valor)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;')
}

function secaoDoItem(secao: string) {
  const nome = secao.trim()
  const secaoSemNome = /^SN\s*(\d+)$/i.exec(nome)

  if (secaoSemNome) {
    const ordem = Number(secaoSemNome[1])
    return { chave: `sn-${ordem}`, titulo: '', ordemGrupo: 1, ordem }
  }

  if (!nome) return { chave: 'sem-secao', titulo: 'Sem seção', ordemGrupo: 2, ordem: 0 }
  return { chave: `secao-${nome.toLocaleLowerCase('pt-BR')}`, titulo: nome, ordemGrupo: 0, ordem: 0 }
}

function criarArvore(grupos: AnimalGrupo[]) {
  const porId = new Map(grupos.map((grupo) => [grupo.id, { grupo, filhos: [] as NoGrupo[] }]))
  const raizes: NoGrupo[] = []
  porId.forEach((no) => {
    const pai = no.grupo.idGrupoPai === null ? undefined : porId.get(no.grupo.idGrupoPai)
    if (pai && pai !== no) pai.filhos.push(no)
    else raizes.push(no)
  })
  const ordenar = (nos: NoGrupo[]) => {
    nos.sort((a, b) => a.grupo.nome.localeCompare(b.grupo.nome, 'pt-BR'))
    nos.forEach((no) => ordenar(no.filhos))
  }
  ordenar(raizes)
  return raizes
}

function Arvore({ nos, onAbrir }: { nos: NoGrupo[]; onAbrir: (id: number) => void }) {
  return <ul className="modelo-group-tree">{nos.map((no) => <li key={no.grupo.id}>
    <button type="button" onClick={() => onAbrir(no.grupo.id)}>
      <FolderTree size={18} /><span>{no.grupo.nome}</span><ChevronRight size={17} />
    </button>
    {no.filhos.length > 0 && <Arvore nos={no.filhos} onAbrir={onAbrir} />}
  </li>)}</ul>
}

function mensagemErro(error: unknown, padrao: string) {
  return error instanceof Error ? error.message : padrao
}

export function ModeloExamesInicioPage() {
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [grupos, setGrupos] = useState<AnimalGrupo[]>([])
  const [erro, setErro] = useState<string | null>(null)
  const [carregando, setCarregando] = useState(true)

  useEffect(() => {
    if (!accessToken) return
    void (async () => {
      try {
        setGrupos(await modeloExamesApi.listarGrupos(accessToken))
      } catch (error) {
        setErro(mensagemErro(error, 'Não foi possível carregar os grupos de animais.'))
      } finally {
        setCarregando(false)
      }
    })()
  }, [accessToken])

  return <section className="module-page modelo-flow-page">
    <div className="page-heading"><div>
      <p className="eyebrow">Cadastros</p><h1>Modelo de Exames</h1>
      <p>Selecione o grupo de animais para pesquisar e manter os modelos.</p>
    </div></div>
    {erro && <p className="form-error">{erro}</p>}
    <section className="modelo-group-picker">
      <header><FolderTree size={22} /><div><strong>Grupos de animais</strong><span>Escolha um grupo para continuar</span></div></header>
      {carregando
        ? <p className="card-status">Carregando grupos…</p>
        : <Arvore nos={criarArvore(grupos.filter((grupo) => grupo.ativo))} onAbrir={(id) => navigate(`/exames/modelos/grupo/${id}`)} />}
    </section>
  </section>
}

export function ModelosDoGrupoPage() {
  const { grupoId } = useParams()
  const idGrupo = Number(grupoId)
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [grupos, setGrupos] = useState<AnimalGrupo[]>([])
  const [modelos, setModelos] = useState<ModeloExame[]>([])
  const [busca, setBusca] = useState('')
  const [selecionadoId, setSelecionadoId] = useState<number | null>(null)
  const [erro, setErro] = useState<string | null>(null)
  const [carregando, setCarregando] = useState(true)

  const carregar = useCallback(async () => {
    if (!accessToken) return
    setCarregando(true)
    try {
      const [gruposCarregados, modelosCarregados] = await Promise.all([
        modeloExamesApi.listarGrupos(accessToken),
        modeloExamesApi.listarModelos(accessToken),
      ])
      setGrupos(gruposCarregados)
      setModelos(modelosCarregados)
    } catch (error) {
      setErro(mensagemErro(error, 'Não foi possível carregar os modelos.'))
    } finally {
      setCarregando(false)
    }
  }, [accessToken])

  useEffect(() => { void carregar() }, [carregar])

  const grupo = grupos.find((item) => item.id === idGrupo)
  const registros = useMemo(() => {
    const termo = busca.trim().toLocaleLowerCase('pt-BR')
    return modelos.filter((modelo) => modelo.idAnimalGrupo === idGrupo && (
      !termo || `${modelo.codigo} ${modelo.nome} ${modelo.faixaIdade}`.toLocaleLowerCase('pt-BR').includes(termo)
    ))
  }, [busca, idGrupo, modelos])
  const selecionado = modelos.find((modelo) => modelo.id === selecionadoId) ?? null

  async function excluir() {
    if (!accessToken || !selecionado || !window.confirm(`Deseja inativar o modelo ${selecionado.nome}?`)) return
    try {
      await modeloExamesApi.definirModeloAtivo(selecionado.id, false, accessToken)
      setSelecionadoId(null)
      await carregar()
    } catch (error) {
      setErro(mensagemErro(error, 'Não foi possível inativar o modelo.'))
    }
  }

  return <section className="module-page modelo-flow-page">
    <div className="modelo-flow-title"><button type="button" onClick={() => navigate('/exames/modelos')}>‹ Grupos</button><div>
      <p className="eyebrow">Grupo de animais</p><h1>{grupo?.nome ?? 'Modelos de Exame'}</h1>
    </div></div>
    {erro && <p className="form-error">{erro}</p>}
    <section className="modelo-list-panel"><header>
      <div className="modelo-list-search"><Search size={17} /><input value={busca} onChange={(event) => setBusca(event.target.value)} placeholder="Filtrar por código, nome ou faixa etária" /></div>
      <div className="modelo-list-actions">
        <button className="primary-button" type="button" onClick={() => navigate(`/exames/modelos/novo/${idGrupo}`)}><Plus size={17} />Novo modelo</button>
        <button className="secondary-button" type="button" disabled={!selecionado} onClick={() => selecionado && navigate(`/exames/modelos/${selecionado.id}/editar`)}><Edit3 size={17} />Alterar</button>
        <button className="danger-button" type="button" disabled={!selecionado} onClick={() => void excluir()}><Trash2 size={17} />Excluir</button>
      </div>
    </header>{carregando ? <p className="card-status">Carregando modelos…</p> : <div className="modelo-list-cards">
      {registros.map((modelo) => <button className={`modelo-list-card ${modelo.id === selecionadoId ? 'selected' : ''}`} key={modelo.id} type="button" onClick={() => setSelecionadoId(modelo.id)}>
        <span>{modelo.codigo}</span><strong>{modelo.nome}</strong><small>{modelo.faixaIdade || 'Faixa etária não informada'}</small>
      </button>)}
      {!registros.length && <p className="painel-vazio">Nenhum modelo cadastrado para este grupo.</p>}
    </div>}</section>
  </section>
}

export function ModeloExameEdicaoPage() {
  const { id, grupoId } = useParams()
  const idModelo = id ? Number(id) : null
  const idGrupoNovo = grupoId ? Number(grupoId) : null
  const { accessToken } = useAuth()
  const navigate = useNavigate()
  const [formulario, setFormulario] = useState<ModeloExameInput>({ ...modeloInicial, idAnimalGrupo: idGrupoNovo })
  const [modeloSalvo, setModeloSalvo] = useState<ModeloExame | null>(null)
  const [grupos, setGrupos] = useState<AnimalGrupo[]>([])
  const [exames, setExames] = useState<Exame[]>([])
  const [vinculos, setVinculos] = useState<ExameAnalito[]>([])
  const [catalogo, setCatalogo] = useState<Analito[]>([])
  const [itens, setItens] = useState<ModeloExameAnalito[]>([])
  const [itemEdicao, setItemEdicao] = useState<ModeloExameAnalitoInput | null>(null)
  const [itemId, setItemId] = useState<number | null>(null)
  const [erro, setErro] = useState<string | null>(null)
  const [salvando, setSalvando] = useState(false)

  const carregarItens = useCallback(async (modelo: number) => {
    if (!accessToken) return
    setItens(await modeloExamesApi.listarAnalitos(modelo, accessToken))
  }, [accessToken])

  useEffect(() => {
    if (!accessToken) return
    void (async () => {
      try {
        const [gruposCarregados, examesCarregados, vinculosCarregados, analitosCarregados] = await Promise.all([
          modeloExamesApi.listarGrupos(accessToken),
          modeloExamesApi.listarExames(accessToken),
          modeloExamesApi.listarExameAnalitos(accessToken),
          modeloExamesApi.listarCatalogoAnalitos(accessToken),
        ])
        setGrupos(gruposCarregados)
        setExames(examesCarregados.filter((exame) => exame.ativo))
        setVinculos(vinculosCarregados.filter((vinculo) => vinculo.ativo))
        setCatalogo(analitosCarregados.filter((analito) => analito.ativo))
        if (idModelo) {
          const modelo = await modeloExamesApi.obterModelo(idModelo, accessToken)
          setModeloSalvo(modelo)
          setFormulario({
            codigo: modelo.codigo,
            nome: modelo.nome,
            faixaIdade: modelo.faixaIdade,
            arquivoOrigem: modelo.arquivoOrigem,
            idExame: modelo.idExame,
            idAnimalGrupo: modelo.idAnimalGrupo,
          })
          await carregarItens(modelo.id)
        }
      } catch (error) {
        setErro(mensagemErro(error, 'Não foi possível carregar o modelo.'))
      }
    })()
  }, [accessToken, carregarItens, idModelo])

  const exame = exames.find((item) => item.id === formulario.idExame) ?? null
  const grupoAnimal = grupos.find((grupo) => grupo.id === formulario.idAnimalGrupo) ?? null
  const opcoesVinculo = useMemo(() => vinculos
    .filter((vinculo) => vinculo.idExame === formulario.idExame)
    .map((vinculo) => ({ vinculo, analito: catalogo.find((analito) => analito.id === vinculo.idAnalito) }))
    .filter((item): item is { vinculo: ExameAnalito; analito: Analito } => Boolean(item.analito)), [catalogo, formulario.idExame, vinculos])
  const analitoPorVinculo = useMemo(() => new Map(opcoesVinculo.map(({ vinculo, analito }) => [vinculo.id, analito])), [opcoesVinculo])
  const gruposAnalitos = useMemo(() => {
    const porSecao = new Map<string, GrupoAnalitos>()
    itens.filter((item) => item.ativo).forEach((item) => {
      const secao = secaoDoItem(item.secao)
      const grupo = porSecao.get(secao.chave) ?? { ...secao, itens: [] }
      grupo.itens.push({ item, analito: analitoPorVinculo.get(item.idExameAnalito) })
      porSecao.set(secao.chave, grupo)
    })
    return [...porSecao.values()]
      .map((grupo) => ({ ...grupo, itens: grupo.itens.sort((a, b) => a.item.ordem - b.item.ordem) }))
      .sort((a, b) => a.ordemGrupo - b.ordemGrupo || a.ordem - b.ordem || a.itens[0].item.ordem - b.itens[0].item.ordem)
  }, [analitoPorVinculo, itens])

  function abrirEdicaoItem(item: ModeloExameAnalito) {
    const analito = analitoPorVinculo.get(item.idExameAnalito)
    setItemId(item.id)
    setItemEdicao({
      idModeloExame: item.idModeloExame,
      idExameAnalito: item.idExameAnalito,
      secao: item.secao,
      ordem: item.ordem,
      rotulo: item.rotulo,
      tecnica: item.tecnica,
      unidadeMedida: item.unidadeMedida,
      referencia: item.referencia,
      referenciaMinima: formatarReferenciaParaEdicao(item.referenciaMinima, analito?.tipoValor),
      referenciaMaxima: formatarReferenciaParaEdicao(item.referenciaMaxima, analito?.tipoValor),
      referenciaPercentualMinima: item.referenciaPercentualMinima,
      referenciaPercentualMaxima: item.referenciaPercentualMaxima,
    })
  }

  function campoModelo(event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) {
    const { name, value } = event.target
    setFormulario((atual) => ({ ...atual, [name]: name === 'idExame' ? (value ? Number(value) : null) : value }))
  }

  async function salvarModelo(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!accessToken) return
    setSalvando(true)
    setErro(null)
    try {
      const input = {
        ...formulario,
        codigo: formulario.codigo.trim(),
        nome: formulario.nome.trim(),
        faixaIdade: formulario.faixaIdade.trim(),
        arquivoOrigem: formulario.arquivoOrigem.trim(),
      }
      const salvo = modeloSalvo
        ? await modeloExamesApi.atualizarModelo(modeloSalvo.id, input, accessToken)
        : await modeloExamesApi.criarModelo(input, accessToken)
      setModeloSalvo(salvo)
      if (!idModelo) navigate(`/exames/modelos/${salvo.id}/editar`, { replace: true })
    } catch (error) {
      setErro(mensagemErro(error, 'Não foi possível salvar o modelo.'))
    } finally {
      setSalvando(false)
    }
  }

  function novoItem() {
    if (!modeloSalvo) return
    setItemId(null)
    setItemEdicao(analitoInicial(modeloSalvo.id))
  }

  function campoItem(event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) {
    const { name, value } = event.target
    setItemEdicao((atual) => !atual ? atual : ({
      ...atual,
      [name]: ['idExameAnalito', 'ordem'].includes(name)
        ? Number(value)
        : ['referenciaPercentualMinima', 'referenciaPercentualMaxima'].includes(name)
          ? (value === '' ? null : Number(value.replace(',', '.')))
          : ['referenciaMinima', 'referenciaMaxima'].includes(name)
            ? (value || null)
            : value,
    }))
  }

  function formatarReferenciaDaEdicao(campo: 'referenciaMinima' | 'referenciaMaxima') {
    if (!itemEdicao || !analitoDoItem || analitoDoItem.tipoValor === 3) return
    const valor = itemEdicao[campo]
    const numero = numeroDaReferencia(valor)
    if (valor === null || numero === null) return
    setItemEdicao((atual) => atual ? {
      ...atual,
      [campo]: formatarNumero(numero, analitoDoItem.tipoValor === 2 ? 2 : 0),
    } : atual)
  }

  function prepararItemParaSalvar() {
    if (!itemEdicao) return { item: null, mensagem: 'Informe o analito do modelo.' }
    const analito = analitoPorVinculo.get(itemEdicao.idExameAnalito)
    if (!analito) return { item: null, mensagem: 'Selecione um analito do exame.' }

    const input = {
      ...itemEdicao,
      secao: itemEdicao.secao.trim(),
      rotulo: itemEdicao.rotulo.trim(),
      tecnica: itemEdicao.tecnica.trim(),
      unidadeMedida: itemEdicao.unidadeMedida.trim(),
      referencia: itemEdicao.referencia.trim(),
      referenciaMinima: itemEdicao.referenciaMinima?.trim() || null,
      referenciaMaxima: itemEdicao.referenciaMaxima?.trim() || null,
    }
    const minimo = numeroDaReferencia(input.referenciaMinima)
    const maximo = numeroDaReferencia(input.referenciaMaxima)

    if (analito.tipoValor === 1 && ([input.referenciaMinima, input.referenciaMaxima].some((valor) => valor !== null && !/^[+-]?\d+$/.test(valor)))) {
      return { item: null, mensagem: 'As referências deste analito devem ser números inteiros.' }
    }
    if (analito.tipoValor === 2 && ([input.referenciaMinima, input.referenciaMaxima].some((valor) => valor !== null && numeroDaReferencia(valor) === null))) {
      return { item: null, mensagem: 'As referências deste analito devem ser números decimais.' }
    }
    if (analito.tipoValor !== 3 && minimo !== null && maximo !== null && minimo > maximo) {
      return { item: null, mensagem: 'A referência mínima não pode ser maior que a máxima.' }
    }
    if ([input.referenciaPercentualMinima, input.referenciaPercentualMaxima].some((valor) => valor !== null && (!Number.isFinite(valor) || valor < 0 || valor > 100))) {
      return { item: null, mensagem: 'As referências percentuais devem estar entre 0 e 100.' }
    }
    if (input.referenciaPercentualMinima !== null && input.referenciaPercentualMaxima !== null && input.referenciaPercentualMinima > input.referenciaPercentualMaxima) {
      return { item: null, mensagem: 'A referência percentual mínima não pode ser maior que a máxima.' }
    }

    if (analito.tipoValor !== 3) {
      input.referenciaMinima = minimo === null
        ? null
        : analito.tipoValor === 1
          ? String(Math.trunc(minimo))
          : formatarNumero(minimo, 2)
      input.referenciaMaxima = maximo === null
        ? null
        : analito.tipoValor === 1
          ? String(Math.trunc(maximo))
          : formatarNumero(maximo, 2)
    }

    return { item: input, mensagem: null }
  }

  async function salvarItem() {
    if (!accessToken || !itemEdicao || !modeloSalvo) return
    const resultado = prepararItemParaSalvar()
    if (!resultado.item) {
      setErro(resultado.mensagem)
      return
    }
    setSalvando(true)
    setErro(null)
    try {
      if (itemId) await modeloExamesApi.atualizarAnalitoModelo(itemId, resultado.item, accessToken)
      else await modeloExamesApi.criarAnalitoModelo(resultado.item, accessToken)
      await carregarItens(modeloSalvo.id)
      setItemEdicao(null)
      setItemId(null)
    } catch (error) {
      setErro(mensagemErro(error, 'Não foi possível salvar o analito do modelo.'))
    } finally {
      setSalvando(false)
    }
  }

  function gerarPdfModelo() {
    if (!modeloSalvo) return

    const janela = window.open('', '_blank')
    if (!janela) {
      setErro('Não foi possível abrir a janela para gerar o PDF. Verifique se o navegador bloqueou pop-ups.')
      return
    }

    janela.addEventListener('load', () => {
      janela.focus()
      janela.print()
    }, { once: true })

    const secoes = gruposAnalitos.map((grupo) => {
      const possuiPercentual = grupo.itens.some(({ item, analito }) => (
        analito?.percentual
        && (item.referenciaPercentualMinima !== null || item.referenciaPercentualMaxima !== null)
      ))
      const rotulos = possuiPercentual
        ? '<div class="pdf-percentual"><span>Per Min</span><span>Per Max</span></div>'
        : ''
      const linhas = grupo.itens.map(({ item, analito }) => {
        const percentual = analito?.percentual && (item.referenciaPercentualMinima !== null || item.referenciaPercentualMaxima !== null)
        const faixaConvencional = formatarFaixa(item.referenciaMinima, item.referenciaMaxima, analito?.tipoValor)
        const unidadeMedida = item.unidadeMedida || analito?.unidadeMedida || '—'
        const valoresPercentuais = percentual
          ? `<div class="pdf-percentual"><strong>${escaparHtmlParaPdf(formatarPercentual(item.referenciaPercentualMinima))}</strong><strong>${escaparHtmlParaPdf(formatarPercentual(item.referenciaPercentualMaxima))}</strong></div>`
          : ''
        const valoresConvencionais = faixaConvencional
          ? `<div class="pdf-convencional"><strong>${escaparHtmlParaPdf(formatarReferencia(item.referenciaMinima, analito?.tipoValor))}</strong><strong>${escaparHtmlParaPdf(formatarReferencia(item.referenciaMaxima, analito?.tipoValor))}</strong><strong>${escaparHtmlParaPdf(unidadeMedida)}</strong></div>`
          : '<div class="pdf-convencional"><strong>—</strong><strong>—</strong><strong>—</strong></div>'

        return `<div class="pdf-linha">
          <span class="pdf-ordem">${escaparHtmlParaPdf(item.ordem)}</span>
          <div class="pdf-identificacao"><strong>${escaparHtmlParaPdf(nomeDoAnalitoNoCartao(item, analito))}</strong><small>${escaparHtmlParaPdf(item.tecnica || analito?.tecnica || '—')}</small></div>
          <div class="pdf-valores ${percentual ? 'possui-percentual' : ''}">${valoresPercentuais}${valoresConvencionais}</div>
        </div>`
      }).join('')

      return `<section class="pdf-secao">
        <header><h2>${escaparHtmlParaPdf(grupo.titulo)}</h2><div class="pdf-rotulos ${possuiPercentual ? 'possui-percentual' : ''}">${rotulos}<div class="pdf-convencional"><span>Vr Min</span><span>Vr Max</span><span>Und</span></div></div></header>
        ${linhas}
      </section>`
    }).join('')
    const tituloExame = exame ? `${exame.codigo} — ${exame.nome}` : 'Exame não informado'
    const valorExame = exame?.valor === null || exame?.valor === undefined
      ? 'Não informado'
      : exame.valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
    const analitosAtivos = itens.filter((item) => item.ativo).length
    const conteudoAnalitos = secoes || '<p class="pdf-vazio">Nenhum analito foi configurado neste modelo.</p>'

    janela.document.write(`<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><title>Modelo de Exame — ${escaparHtmlParaPdf(modeloSalvo.nome)}</title><style>
@page { margin: 14mm; size: A4 portrait; }
* { box-sizing: border-box; }
body { color: #1d3048; font-family: Arial, sans-serif; font-size: 10px; margin: 0; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
.pdf-cabecalho { border-bottom: 2px solid #159b70; margin-bottom: 14px; padding-bottom: 9px; }
.pdf-cabecalho h1 { color: #102b50; font-size: 20px; margin: 0 0 4px; }.pdf-cabecalho p { color: #526b87; margin: 2px 0; }
.pdf-resumos { display: grid; gap: 8px; grid-template-columns: repeat(3, 1fr); margin: 0 0 14px; }.pdf-resumo { border: 1px solid #d8e2eb; border-radius: 5px; break-inside: avoid; min-width: 0; padding: 8px; }.pdf-resumo h2 { color: #455a73; font-size: 9px; letter-spacing: .04em; margin: 0 0 6px; text-transform: uppercase; }.pdf-resumo p { margin: 3px 0; overflow-wrap: anywhere; }.pdf-resumo strong { color: #31516a; }.pdf-titulo-analitos { align-items: baseline; display: flex; justify-content: space-between; margin: 0 0 6px; }.pdf-titulo-analitos h2 { color: #102b50; font-size: 13px; margin: 0; }.pdf-titulo-analitos span { color: #697a90; font-size: 9px; }.pdf-vazio { border: 1px solid #d8e2eb; border-radius: 5px; color: #526b87; margin: 0 0 10px; padding: 10px; }
.pdf-secao { border: 1px solid #d8e2eb; border-radius: 5px; break-inside: avoid; margin: 0 0 10px; overflow: hidden; }
.pdf-secao header { align-items: center; background: #f2f6fa; border-bottom: 1px solid #d8e2eb; display: flex; justify-content: space-between; min-height: 28px; padding: 0 8px; }.pdf-secao h2 { color: #455a73; font-size: 9px; letter-spacing: .04em; margin: 0; text-transform: uppercase; }
.pdf-rotulos, .pdf-valores { display: grid; grid-template-columns: 190px; justify-content: end; min-width: 0; }.pdf-rotulos.possui-percentual, .pdf-valores.possui-percentual { column-gap: 8px; grid-template-columns: 114px 190px; }
.pdf-percentual { column-gap: 5px; display: grid; grid-template-columns: 1fr 1fr; }.pdf-convencional { column-gap: 5px; display: grid; grid-template-columns: 1fr 1fr 62px; }.pdf-rotulos span { color: #526b87; font-size: 8px; font-weight: 700; text-align: right; text-transform: uppercase; }.pdf-rotulos .pdf-convencional span:last-child, .pdf-convencional strong:last-child { text-align: center; }
.pdf-linha { align-items: center; background: #fbfcfe; border-bottom: 1px solid #e3eaf1; display: grid; gap: 8px; grid-template-columns: 20px minmax(0, 1fr) max-content; min-height: 34px; padding: 5px 8px; }.pdf-linha:last-child { border-bottom: 0; }.pdf-ordem { align-items: center; background: #e0f3eb; border-radius: 50%; color: #137a5c; display: flex; font-size: 8px; font-weight: 700; height: 18px; justify-content: center; width: 18px; }.pdf-identificacao { display: flex; flex-direction: column; gap: 2px; min-width: 0; }.pdf-identificacao strong { color: #263950; font-size: 10px; }.pdf-identificacao small { color: #697a90; font-size: 8px; }.pdf-valores strong { color: #263950; font-size: 9px; font-weight: 600; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap; }
.pdf-rodape { border-top: 1px solid #d8e2eb; color: #718097; font-size: 8px; margin-top: 13px; padding-top: 7px; text-align: right; }
</style></head><body><main>
<header class="pdf-cabecalho"><h1>Modelo de Exame</h1><p>${escaparHtmlParaPdf(modeloSalvo.nome)}</p></header>
<section class="pdf-resumos"><section class="pdf-resumo"><h2>Animal</h2><p><strong>Grupo:</strong> ${escaparHtmlParaPdf(grupoAnimal?.nome || 'Não informado')}</p><p><strong>Descrição:</strong> ${escaparHtmlParaPdf(grupoAnimal?.descricao || 'Não informada')}</p></section><section class="pdf-resumo"><h2>Modelo de Exame</h2><p><strong>Código:</strong> ${escaparHtmlParaPdf(modeloSalvo.codigo)}</p><p><strong>Faixa etária:</strong> ${escaparHtmlParaPdf(modeloSalvo.faixaIdade || 'Não informada')}</p><p><strong>Arquivo de origem:</strong> ${escaparHtmlParaPdf(modeloSalvo.arquivoOrigem || 'Não informado')}</p></section><section class="pdf-resumo"><h2>Exame</h2><p><strong>Identificação:</strong> ${escaparHtmlParaPdf(tituloExame)}</p><p><strong>Quantidade:</strong> ${escaparHtmlParaPdf(exame?.quantidade ?? 'Não informada')}</p><p><strong>Valor:</strong> ${escaparHtmlParaPdf(valorExame)}</p></section></section>
<section class="pdf-titulo-analitos"><h2>Analitos do modelo</h2><span>${escaparHtmlParaPdf(analitosAtivos)} configurados</span></section>
${conteudoAnalitos}<footer class="pdf-rodape">Gerado em ${escaparHtmlParaPdf(new Date().toLocaleDateString('pt-BR'))}</footer>
</main></body></html>`)
    janela.document.close()
  }

  const analitoDoItem = itemEdicao ? analitoPorVinculo.get(itemEdicao.idExameAnalito) ?? null : null
  const tipoReferencia = analitoDoItem?.tipoValor
  const inputModeReferencia = tipoReferencia === 1 ? 'numeric' : tipoReferencia === 2 ? 'decimal' : 'text'
  const padraoReferencia = tipoReferencia === 1 ? '[+-]?[0-9]*' : undefined

  return <CadastroEdicao
    icon={<span className="cadastro-title-icon"><ClipboardList size={43} /></span>}
    title="Modelo de Exames"
    actionLabel={modeloSalvo ? 'Edição' : 'Inclusão'}
    saving={salvando}
    onCancel={() => navigate(modeloSalvo?.idAnimalGrupo ? `/exames/modelos/grupo/${modeloSalvo.idAnimalGrupo}` : '/exames/modelos')}
    onSubmit={salvarModelo}
  >
    <section className="cadastro-form-panel modelo-editor-panel"><header><div><ClipboardList size={20} /><strong>Dados do modelo</strong></div><span>Campos com * são obrigatórios</span></header>
      {erro && <p className="form-error">{erro}</p>}
      <div className="cadastro-form-scroll-content">
        <fieldset><legend>Modelo de exame</legend><div className="form-grid two-columns">
          <label>Código *<input name="codigo" value={formulario.codigo} onChange={campoModelo} required maxLength={100} /></label>
          <label>Exame vinculado<select name="idExame" value={formulario.idExame ?? ''} onChange={campoModelo}><option value="">Sem exame vinculado</option>{exames.map((item) => <option key={item.id} value={item.id}>{item.codigo} — {item.nome}</option>)}</select></label>
          <label className="form-field-wide">Nome *<input name="nome" value={formulario.nome} onChange={campoModelo} required maxLength={250} /></label>
          <label>Faixa etária<input name="faixaIdade" value={formulario.faixaIdade} onChange={campoModelo} maxLength={100} /></label>
          <label>Arquivo de origem<input name="arquivoOrigem" value={formulario.arquivoOrigem} onChange={campoModelo} maxLength={250} /></label>
        </div></fieldset>
        {exame && <aside className="modelo-readonly-card"><strong>Exame do catálogo (somente consulta)</strong><span>{exame.codigo} — {exame.nome}</span><small>Quantidade: {exame.quantidade} · Valor: {exame.valor === null ? 'não informado' : exame.valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</small></aside>}
        {modeloSalvo ? <section className="modelo-analitos-editor"><header><div><ChevronDown size={19} /><strong>Analitos do modelo</strong><span>{itens.length} configurados</span></div><div className="modelo-analitos-actions"><button type="button" className="secondary-button" onClick={gerarPdfModelo}><FileDown size={16} />Gerar PDF</button><button type="button" className="secondary-button" onClick={novoItem} disabled={!formulario.idExame}><Plus size={16} />Adicionar analito</button></div></header>
          {!formulario.idExame ? <p className="painel-vazio">Selecione e salve um exame para configurar os analitos vinculados.</p> : <>
            <div className="modelo-analitos-items">
              {gruposAnalitos.map((grupo) => {
                const possuiPercentual = grupo.itens.some(({ item, analito }) => (
                  analito?.percentual
                  && (item.referenciaPercentualMinima !== null || item.referenciaPercentualMaxima !== null)
                ))

                return <section className="modelo-analitos-section" key={grupo.chave}>
                <header className="modelo-analitos-section-header">
                  {grupo.titulo && <h3>{grupo.titulo}</h3>}
                  <div className={`modelo-analito-cabecalho-referencias ${possuiPercentual ? 'possui-percentual' : ''}`}>
                    {possuiPercentual && <div className="modelo-analito-cabecalho-percentual"><span>Per Min</span><span>Per Max</span></div>}
                    <div className="modelo-analito-cabecalho-convencional"><span>Vr Min</span><span>Vr Max</span><span>Und</span></div>
                  </div>
                </header>
                <div className="modelo-analitos-section-items">{grupo.itens.map(({ item, analito }) => {
                  const percentual = analito?.percentual && (item.referenciaPercentualMinima !== null || item.referenciaPercentualMaxima !== null)
                  const faixaConvencional = formatarFaixa(item.referenciaMinima, item.referenciaMaxima, analito?.tipoValor)
                  const unidadeMedida = item.unidadeMedida || analito?.unidadeMedida
                  return <button type="button" key={item.id} onClick={() => abrirEdicaoItem(item)}>
                    <span>{item.ordem}</span>
                    <div className="modelo-analito-identificacao"><strong>{nomeDoAnalitoNoCartao(item, analito)}</strong><small>{item.tecnica || analito?.tecnica || '—'}</small></div>
                    {(percentual || faixaConvencional) && <div className={`modelo-analito-referencias ${percentual ? 'possui-percentual' : ''}`}>
                      {percentual && <div className="modelo-analito-faixa-percentual"><strong>{formatarPercentual(item.referenciaPercentualMinima)}</strong><strong>{formatarPercentual(item.referenciaPercentualMaxima)}</strong></div>}
                      {faixaConvencional && <div className="modelo-analito-faixa-convencional"><strong>{formatarReferencia(item.referenciaMinima, analito?.tipoValor)}</strong><strong>{formatarReferencia(item.referenciaMaxima, analito?.tipoValor)}</strong><strong>{unidadeMedida || '—'}</strong></div>}
                    </div>}
                  </button>
                })}</div>
              </section>
              })}
              {!itens.length && <p className="painel-vazio">Nenhum analito configurado.</p>}
            </div>
            {itemEdicao && <section className="modelo-item-form"><header><strong>{itemId ? 'Editar analito do modelo' : 'Adicionar analito ao modelo'}</strong><button type="button" onClick={() => { setItemEdicao(null); setItemId(null) }}><X size={17} /></button></header>
              <div className="form-grid two-columns">
                <label>Analito do exame *<select name="idExameAnalito" value={itemEdicao.idExameAnalito || ''} onChange={campoItem} required><option value="">Selecione</option>{opcoesVinculo.map(({ vinculo, analito }) => <option key={vinculo.id} value={vinculo.id}>{analito.nome} ({analito.unidadeMedida || 'sem unidade'})</option>)}</select></label>
                <label>Ordem *<input name="ordem" type="number" min="1" value={itemEdicao.ordem} onChange={campoItem} /></label>
                <label>Seção<input name="secao" value={itemEdicao.secao} onChange={campoItem} placeholder="Ex.: Eritrograma ou SN 1" /></label>
                <label>Rótulo<input name="rotulo" value={itemEdicao.rotulo} onChange={campoItem} /></label>
                <label>Técnica<input name="tecnica" value={itemEdicao.tecnica} onChange={campoItem} /></label>
                <label>Unidade de medida<input name="unidadeMedida" value={itemEdicao.unidadeMedida} onChange={campoItem} /></label>
                <label className="form-field-wide">Referência livre<input name="referencia" value={itemEdicao.referencia} onChange={campoItem} /></label>
                <fieldset className="modelo-referencias-editor form-field-wide"><legend>Valores de referência — {descricaoTipoValor(tipoReferencia)}</legend><div className="form-grid two-columns">
                  <label>Referência mínima<input name="referenciaMinima" value={itemEdicao.referenciaMinima ?? ''} onChange={campoItem} onBlur={() => formatarReferenciaDaEdicao('referenciaMinima')} inputMode={inputModeReferencia} pattern={padraoReferencia} /></label>
                  <label>Referência máxima<input name="referenciaMaxima" value={itemEdicao.referenciaMaxima ?? ''} onChange={campoItem} onBlur={() => formatarReferenciaDaEdicao('referenciaMaxima')} inputMode={inputModeReferencia} pattern={padraoReferencia} /></label>
                  {analitoDoItem?.percentual && <><label>Percentual mínimo<input name="referenciaPercentualMinima" value={itemEdicao.referenciaPercentualMinima ?? ''} onChange={campoItem} inputMode="decimal" /></label><label>Percentual máximo<input name="referenciaPercentualMaxima" value={itemEdicao.referenciaPercentualMaxima ?? ''} onChange={campoItem} inputMode="decimal" /></label></>}
                </div></fieldset>
                <aside className="modelo-readonly-card form-field-wide"><strong>Dados do analito (somente consulta)</strong><span>{analitoDoItem ? `${analitoDoItem.nome} · ${analitoDoItem.unidadeMedida || 'sem unidade'}` : 'Selecione um analito do exame'}</span><small>Tipo de valor: {descricaoTipoValor(tipoReferencia)}{analitoDoItem?.percentual ? ' · aceita referência percentual' : ''}</small></aside>
              </div>
              <footer><button type="button" className="secondary-button" onClick={() => { setItemEdicao(null); setItemId(null) }}>Cancelar</button><button type="button" className="primary-button" onClick={() => void salvarItem()} disabled={salvando || !itemEdicao.idExameAnalito}><Save size={16} />Salvar analito</button></footer>
            </section>}
          </>}
        </section> : <aside className="cadastro-impact-note">Salve o cabeçalho do modelo para liberar a configuração dos analitos.</aside>}
      </div>
    </section>
  </CadastroEdicao>
}
