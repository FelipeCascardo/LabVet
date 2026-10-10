import { HeartPulse, LockKeyhole, Mail } from 'lucide-react'
import { useState, type FormEvent } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../../app/auth/useAuth'

export function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [email, setEmail] = useState('felipe.cascardo@gmail.com')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    setLoading(true)
    try {
      await login(email, password)
      const destination = (location.state as { from?: { pathname?: string } })?.from?.pathname ?? '/'
      navigate(destination, { replace: true })
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'Não foi possível entrar.')
    } finally {
      setLoading(false)
    }
  }

  return <main className="login-page">
    <section className="login-panel">
      <div className="brand"><span className="brand-mark"><HeartPulse size={24} /></span><span>Lab<span>Vet</span></span></div>
      <div className="login-copy"><p className="eyebrow">Acesso seguro</p><h1>Bem-vindo de volta.</h1><p>Entre para acompanhar a rotina do seu laboratório veterinário.</p></div>
      <form onSubmit={handleSubmit} className="login-form">
        <label><span>E-mail</span><div className="input-wrap"><Mail size={18} /><input type="email" autoComplete="email" value={email} onChange={(event) => setEmail(event.target.value)} required /></div></label>
        <label><span>Senha</span><div className="input-wrap"><LockKeyhole size={18} /><input type="password" autoComplete="current-password" value={password} onChange={(event) => setPassword(event.target.value)} required /></div></label>
        {error && <p className="form-error" role="alert">{error}</p>}
        <button className="primary-button login-button" disabled={loading}>{loading ? 'Entrando…' : 'Entrar'}</button>
      </form>
      <p className="login-help">Precisa de ajuda? Fale com o suporte do LabVet.</p>
    </section>
    <aside className="login-aside"><div><span className="eyebrow">LabVet</span><h2>A gestão do laboratório, mais próxima do cuidado.</h2><p>Cadastros, atendimentos e laudos em uma experiência simples e confiável.</p></div></aside>
  </main>
}
