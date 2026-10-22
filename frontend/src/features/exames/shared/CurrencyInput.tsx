import { useEffect, useRef, useState, type InputHTMLAttributes } from 'react'

type ValorFormatado = {
  valor: string
  exibicao: string
}

const formatadorInteiro = new Intl.NumberFormat('pt-BR', { maximumFractionDigits: 0 })

function analisarValorMoeda(entrada: string): ValorFormatado {
  const texto = entrada.trim()
  if (!texto) return { valor: '', exibicao: '' }

  const posicaoVirgula = texto.lastIndexOf(',')
  const posicaoPonto = texto.lastIndexOf('.')
  const separador = posicaoVirgula >= 0 ? posicaoVirgula : posicaoPonto
  const possuiDecimal = separador >= 0 && (posicaoVirgula >= 0 || texto.length - separador - 1 <= 2)
  const fonteInteira = possuiDecimal ? texto.slice(0, separador) : texto
  const fonteDecimal = possuiDecimal ? texto.slice(separador + 1) : ''
  const parteInteira = fonteInteira.replace(/\D/g, '').replace(/^0+(?=\d)/, '') || '0'
  const parteDecimal = fonteDecimal.replace(/\D/g, '').slice(0, 2)
  const decimalExibido = parteDecimal.padEnd(2, '0')
  const numeroInteiro = Number(parteInteira)
  const inteiroExibido = formatadorInteiro.format(Number.isSafeInteger(numeroInteiro) ? numeroInteiro : 0)

  return {
    valor: `${parteInteira}.${decimalExibido}`,
    exibicao: `${inteiroExibido},${decimalExibido}`,
  }
}

function exibicaoDoValor(valor: string) {
  if (!valor) return ''
  const [parteInteira = '0', parteDecimal = ''] = valor.replace(',', '.').split('.')
  const inteiroExibido = formatadorInteiro.format(Number(parteInteira || 0))
  return `${inteiroExibido},${parteDecimal.slice(0, 2).padEnd(2, '0')}`
}

type CurrencyInputProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'type' | 'value' | 'onChange'> & {
  value: string | number
  onChange: (value: string) => void
}

export function CurrencyInput({ value, onChange, ...props }: CurrencyInputProps) {
  const valorNormalizado = String(value ?? '')
  const [exibicao, setExibicao] = useState(() => exibicaoDoValor(valorNormalizado))
  const campoRef = useRef<HTMLInputElement>(null)
  const editandoDecimal = useRef(false)

  useEffect(() => {
    setExibicao(exibicaoDoValor(valorNormalizado))
  }, [valorNormalizado])

  function posicionarCursor(noDecimal: boolean, selecionarDecimal = false, deslocamentoDecimal = 1) {
    window.requestAnimationFrame(() => {
      const campo = campoRef.current
      if (!campo) return
      const separador = campo.value.indexOf(',')
      if (separador < 0) return
      const inicio = noDecimal ? separador + Math.min(2, Math.max(1, deslocamentoDecimal)) : separador
      const fim = selecionarDecimal ? separador + 3 : inicio
      campo.setSelectionRange(inicio, fim)
    })
  }

  return <input
    {...props}
    ref={campoRef}
    className={`currency-input ${props.className ?? ''}`.trim()}
    type="text"
    inputMode="decimal"
    autoComplete="off"
    value={exibicao}
    onFocus={(event) => {
      const separador = event.currentTarget.value.indexOf(',')
      editandoDecimal.current = separador >= 0 && (event.currentTarget.selectionStart ?? 0) > separador
      props.onFocus?.(event)
    }}
    onKeyDown={(event) => {
      if (event.key === ',' || event.key === '.') {
        event.preventDefault()
        editandoDecimal.current = true
        posicionarCursor(true, true)
      }
      props.onKeyDown?.(event)
    }}
    onSelect={(event) => {
      const separador = event.currentTarget.value.indexOf(',')
      editandoDecimal.current = separador >= 0 && (event.currentTarget.selectionStart ?? 0) > separador
      props.onSelect?.(event)
    }}
    onChange={(event) => {
      const valorAnalisado = analisarValorMoeda(event.target.value)
      const separador = event.target.value.indexOf(',')
      const deslocamentoDecimal = separador >= 0
        ? (event.target.selectionStart ?? separador + 1) - separador
        : 1
      setExibicao(valorAnalisado.exibicao)
      onChange(valorAnalisado.valor)
      posicionarCursor(editandoDecimal.current, false, deslocamentoDecimal)
    }}
    onBlur={(event) => {
      const valorAnalisado = analisarValorMoeda(event.currentTarget.value)
      setExibicao(valorAnalisado.exibicao)
      onChange(valorAnalisado.valor)
      editandoDecimal.current = false
      props.onBlur?.(event)
    }}
  />
}
