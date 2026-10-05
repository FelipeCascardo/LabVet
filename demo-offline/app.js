const state = { attendances: [], reports: [], results: [], resultsByFile: new Map(), parameters: [], parameterFilters: [], selected: null, page: 1, pageSize: 25 };
const byId = (id) => document.getElementById(id);
const normalize = (value) => String(value ?? '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[char]));

async function loadData() {
  const [attendances, reports, results, parameters] = await Promise.all([
    fetch('dados/atendimentos.json').then((response) => response.json()),
    fetch('dados/laudos.json').then((response) => response.json()),
    fetch('dados/resultados.json').then((response) => response.json()),
    fetch('dados/parametros.json').then((response) => response.json())
  ]);
  state.attendances = attendances.records ?? [];
  state.reports = reports.records ?? [];
  state.results = results.records ?? [];
  state.resultsByFile = new Map();
  state.results.forEach((result) => {
    const items = state.resultsByFile.get(result.arquivo) ?? [];
    items.push(result);
    state.resultsByFile.set(result.arquivo, items);
  });
  state.parameters = parameters.groups ?? [];
  fillOptions('especie', state.attendances.map((item) => item.especie));
  fillOptions('tipo-laudo', state.reports.map((item) => item.tipo));
  renderParameterTree();
  render();
}

function fillOptions(id, values) {
  const select = byId(id);
  [...new Set(values.filter(Boolean))].sort((left, right) => left.localeCompare(right, 'pt-BR')).forEach((value) => {
    select.insertAdjacentHTML('beforeend', `<option value="${escapeHtml(value)}">${escapeHtml(value)}</option>`);
  });
}

function renderParameterTree() {
  const tree = byId('parametro-arvore');
  tree.innerHTML = state.parameters.map((group) => `<details class="grupo-parametro" open><summary>${escapeHtml(group.name)}</summary>${group.parameters.map((parameter) => `<button class="opcao-parametro" type="button" role="treeitem" data-parameter="${escapeHtml(parameter.value)}" data-label="${escapeHtml(parameter.label)}">${escapeHtml(parameter.label)}</button>`).join('')}</details>`).join('');
  document.querySelectorAll('[data-parameter]').forEach((option) => option.addEventListener('click', () => {
    byId('parametro').value = option.dataset.parameter;
    byId('parametro-botao').textContent = option.dataset.label;
    tree.hidden = true;
    byId('parametro-botao').setAttribute('aria-expanded', 'false');
  }));
}

function renderParameterFilters() {
  const container = byId('parametros-selecionados');
  container.innerHTML = state.parameterFilters.map((filter, index) => {
    const range = [filter.start === '' ? 'sem mínimo' : `de ${filter.start}`, filter.end === '' ? 'sem máximo' : `até ${filter.end}`].join(' · ');
    return `<div class="criterio-parametro"><div><strong>${escapeHtml(filter.label)}</strong><span>${escapeHtml(range)}</span></div><button type="button" data-remover-parametro="${index}" aria-label="Remover ${escapeHtml(filter.label)}">Remover</button></div>`;
  }).join('');
  document.querySelectorAll('[data-remover-parametro]').forEach((button) => button.addEventListener('click', () => {
    state.parameterFilters.splice(Number(button.dataset.removerParametro), 1);
    state.page = 1;
    renderParameterFilters();
    render();
  }));
}

function attendanceKey(attendance) { return `${attendance.origem ?? ''}|${attendance.registro}`; }
function reportsFor(attendance) {
  return state.reports.filter((report) => String(report.registro) === String(attendance.registro)
    && (!attendance.origem || !report.origem || report.origem === attendance.origem));
}
function resultsFor(report) { return state.resultsByFile.get(report.arquivo) ?? []; }

function parseDate(value) { const [day, month, year] = String(value ?? '').split('/'); return year ? `${year}-${month}-${day}` : ''; }
function filterTerms(value) { return String(value ?? '').split('|').map((term) => normalize(term.trim())).filter(Boolean); }
function examCodes(value) { return String(value ?? '').split(/[|,]/).map((code) => normalize(code.trim())).filter(Boolean); }
function ageInMonths(value) {
  const text = normalize(value);
  let total = 0; let found = false;
  for (const part of text.matchAll(/(\d+(?:[.,]\d+)?)\s*(anos?|a|meses?|mes|m)\b/g)) {
    const quantity = Number(part[1].replace(',', '.'));
    if (!Number.isFinite(quantity)) continue;
    total += quantity * (/^a|^ano/.test(part[2]) ? 12 : 1);
    found = true;
  }
  return found ? total : null;
}
function hasAllExamCodes(exams, searchedCodes) {
  const available = new Set(examCodes(exams));
  return filterTerms(searchedCodes).every((code) => available.has(code));
}
function commentsFrom(report) {
  if (report.comentarios) return report.comentarios;
  const lines = String(report.texto ?? '').split(/\r?\n/);
  const start = lines.findIndex((line) => /^\s*(coment[aá]rios|observa[cç][oõ]es)\s*:/i.test(line));
  const end = lines.findIndex((line, index) => index > start && /m[eé]dicos veterin[aá]rios respons[aá]veis/i.test(line));
  return start < 0 ? '' : lines.slice(start + 1, end < 0 ? undefined : end).join('\n');
}
function getFilters() { return { record: byId('registro').value.trim(), animalCode: normalize(byId('codigo-animal').value), origin: document.querySelector('input[name="origem"]:checked')?.value ?? '', start: byId('data-inicio').value, end: byId('data-fim').value, ageStart: ageInMonths(byId('idade-inicio').value), ageEnd: ageInMonths(byId('idade-fim').value), animal: normalize(byId('animal').value), owner: normalize(byId('tutor').value), species: byId('especie').value, exams: normalize(byId('exames').value), type: byId('tipo-laudo').value, parameters: state.parameterFilters, comments: byId('comentarios').value }; }
function reportMatches(report, filters) {
  if (filters.type && report.tipo !== filters.type) return false;
  return filterTerms(filters.comments).every((term) => normalize(commentsFrom(report)).includes(term));
}

function parametersMatch(reports, filters) {
  const eligibleReports = filters.type ? reports.filter((report) => report.tipo === filters.type) : reports;
  const reportResults = eligibleReports.flatMap(resultsFor);
  return filters.parameters.every((filter) => reportResults.some((result) => result.codigoParametro === filter.parameter
    && result.valorNumerico !== null && result.valorNumerico !== undefined
    && (filter.start === '' || Number(result.valorNumerico) >= Number(filter.start))
    && (filter.end === '' || Number(result.valorNumerico) <= Number(filter.end))));
}
function filteredAttendances() {
  const filters = getFilters();
  const hasReportFilter = filters.type || filters.parameters.length > 0 || filters.comments;
  return state.attendances.filter((attendance) => {
    const reports = reportsFor(attendance);
    const date = parseDate(attendance.data);
    const age = ageInMonths(attendance.idade);
    const reportTextMatches = (!filters.type && !filters.comments) || reports.some((report) => reportMatches(report, filters));
    return (!filters.record || String(attendance.registro).includes(filters.record)) && (!filters.animalCode || normalize(attendance.codigo).includes(filters.animalCode)) && (!filters.origin || attendance.origem === filters.origin) && (!filters.start || date >= filters.start) && (!filters.end || date <= filters.end) && (filters.ageStart === null || (age !== null && age >= filters.ageStart)) && (filters.ageEnd === null || (age !== null && age <= filters.ageEnd)) && (!filters.animal || normalize(attendance.animal).includes(filters.animal)) && (!filters.owner || normalize(attendance.proprietario).includes(filters.owner)) && (!filters.species || attendance.especie === filters.species) && (!filters.exams || hasAllExamCodes(attendance.exames, filters.exams)) && (!hasReportFilter || (reportTextMatches && parametersMatch(reports, filters)));
  });
}

function render() {
  const matches = filteredAttendances();
  const totalPages = Math.max(1, Math.ceil(matches.length / state.pageSize));
  state.page = Math.min(state.page, totalPages);
  const pageStart = (state.page - 1) * state.pageSize;
  const pageMatches = matches.slice(pageStart, pageStart + state.pageSize);
  const reportCount = matches.reduce((total, attendance) => total + reportsFor(attendance).length, 0);
  byId('total-atendimentos').textContent = matches.length;
  byId('total-pacientes').textContent = new Set(matches.map((item) => `${item.animal}|${item.proprietario}`)).size;
  byId('total-laudos').textContent = reportCount;
  byId('contagem').textContent = `${matches.length} atendimento${matches.length === 1 ? '' : 's'} encontrado${matches.length === 1 ? '' : 's'}`;
  byId('lista-resultados').innerHTML = pageMatches.map((attendance) => {
    const reports = reportsFor(attendance);
    const label = [attendance.origem, attendance.registro].filter(Boolean).join(' · ');
    const clinicalData = [attendance.codigo, attendance.especie, attendance.animal, attendance.proprietario, attendance.idade].filter(Boolean).join(' · ');
    const reportTypes = [...new Set(reports.map((report) => report.tipo).filter(Boolean))].join(' | ');
    return `<button class="resultado" type="button" data-atendimento="${escapeHtml(attendanceKey(attendance))}" aria-pressed="${state.selected === attendanceKey(attendance)}"><div class="resultado-topo"><span class="registro">${escapeHtml(label || attendance.registro)}</span><span class="resultado-data">${escapeHtml(attendance.data)}</span></div><div class="dados-clinicos">${escapeHtml(clinicalData || 'Dados do paciente não informados')}</div><div class="resultado-rodape"><span><strong>Exames:</strong> ${escapeHtml(attendance.exames || 'Não informados')}</span><span><strong>Laudos:</strong> ${escapeHtml(reportTypes || 'Não informados')}</span></div></button>`;
  }).join('');
  byId('paginacao').innerHTML = matches.length > state.pageSize ? `<button type="button" data-page="previous" ${state.page === 1 ? 'disabled' : ''}>Anterior</button><span>Página ${state.page} de ${totalPages}</span><button type="button" data-page="next" ${state.page === totalPages ? 'disabled' : ''}>Próxima</button>` : '';
  byId('estado-vazio').hidden = matches.length > 0;
  document.querySelectorAll('[data-atendimento]').forEach((button) => button.addEventListener('click', () => showDetail(button.dataset.atendimento)));
  document.querySelectorAll('[data-page]').forEach((button) => button.addEventListener('click', () => { state.page += button.dataset.page === 'next' ? 1 : -1; render(); }));
  if (state.selected && !matches.some((attendance) => attendanceKey(attendance) === state.selected)) showDetail(null);
}

function formatNumber(value) {
  return Number(value).toLocaleString('pt-BR', { maximumFractionDigits: 6 });
}
function formatResultValue(result) {
  const value = result.valorNumerico !== null && result.valorNumerico !== undefined ? formatNumber(result.valorNumerico) : result.valorTexto;
  return [value, result.unidade].filter(Boolean).join(' ');
}
function formatReference(result) {
  if (result.referenciaInicial !== null && result.referenciaInicial !== undefined && result.referenciaFinal !== null && result.referenciaFinal !== undefined) return `${formatNumber(result.referenciaInicial)} – ${formatNumber(result.referenciaFinal)}`;
  if (result.referenciaInicial !== null && result.referenciaInicial !== undefined) return `≥ ${formatNumber(result.referenciaInicial)}`;
  if (result.referenciaFinal !== null && result.referenciaFinal !== undefined) return `≤ ${formatNumber(result.referenciaFinal)}`;
  return result.referenciaTexto || '—';
}
function referenceStatus(result) {
  if (result.valorNumerico === null || result.valorNumerico === undefined) return '';
  const value = Number(result.valorNumerico);
  if (!Number.isFinite(value)) return '';
  if (result.referenciaInicial !== null && result.referenciaInicial !== undefined && value < Number(result.referenciaInicial)) return 'baixo';
  if (result.referenciaFinal !== null && result.referenciaFinal !== undefined && value > Number(result.referenciaFinal)) return 'alto';
  return '';
}
function parameterLabel(result) {
  return `${result.parametro}${result.unidade ? ` (${result.unidade})` : ''}`;
}
function reportTable(report) {
  const groups = new Map();
  resultsFor(report).forEach((result) => {
    const items = groups.get(result.secao) ?? [];
    items.push(result);
    groups.set(result.secao, items);
  });
  const sections = [...groups.entries()].map(([section, items]) => `<section class="laudo-secao"><h4>${escapeHtml(section)}</h4><table class="tabela-laudo"><thead><tr><th>Parâmetro</th><th>Resultado</th><th>Valores de referência</th></tr></thead><tbody>${items.sort((a, b) => a.ordem - b.ordem).map((result) => { const status = referenceStatus(result); const indicator = status ? `<span class="indicador-faixa ${status}" aria-label="Resultado ${status === 'alto' ? 'acima' : 'abaixo'} da faixa de referência">${status === 'alto' ? '↑' : '↓'}</span>` : ''; return `<tr class="${status ? `fora-faixa ${status}` : ''}"><td>${escapeHtml(parameterLabel(result))}</td><td>${indicator}${escapeHtml(formatResultValue(result) || '—')}</td><td>${escapeHtml(formatReference(result))}</td></tr>`; }).join('')}</tbody></table></section>`).join('');
  const comments = report.comentarios ? `<div class="comentario-laudo"><strong>Comentários</strong><p>${escapeHtml(report.comentarios)}</p></div>` : '';
  return `<section class="laudo-formatado"><h3>${escapeHtml(report.tipo)} <span>· ${escapeHtml(report.arquivo)}</span></h3>${sections || '<p class="nota">Não há resultados estruturados neste laudo.</p>'}${comments}</section>`;
}
function showDetail(record) {
  state.selected = record;
  const attendance = state.attendances.find((item) => attendanceKey(item) === String(record));
  if (!attendance) { byId('detalhe').innerHTML = '<p class="estado-vazio">Selecione um atendimento para cruzar o histórico com os resultados dos exames.</p>'; render(); return; }
  const reports = reportsFor(attendance);
  const patientHighlight = [attendance.codigo, attendance.animal, attendance.especie].filter(Boolean).join(' · ');
  byId('detalhe').innerHTML = `<h2>${escapeHtml(attendance.animal || 'Paciente não informado')}</h2><p class="paciente-destaque">${escapeHtml(patientHighlight || 'Código e espécie não informados')}</p><p class="nota">${escapeHtml([attendance.origem, `Registro ${attendance.registro}`, attendance.data].filter(Boolean).join(' · '))}</p><div class="campo"><strong>Proprietário</strong>${escapeHtml(attendance.proprietario || 'Não informado')}</div><div class="campo"><strong>Paciente</strong>${escapeHtml([attendance.especie, attendance.raca, attendance.sexo, attendance.idade].filter(Boolean).join(' · ') || 'Não informado')}</div><div class="campo"><strong>Atendimento</strong>${escapeHtml([attendance.setor, attendance.historico].filter(Boolean).join(' · ') || 'Sem histórico registrado')}</div><div class="campo"><strong>Exames solicitados</strong>${escapeHtml(attendance.exames || 'Não informado')}</div><h3>Laudos e resultados vinculados</h3>${reports.length ? reports.map(reportTable).join('') : '<p class="nota">Não há laudo vinculado a este atendimento.</p>'}`;
  render();
}

['registro', 'codigo-animal', 'data-inicio', 'data-fim', 'idade-inicio', 'idade-fim', 'animal', 'tutor', 'especie', 'exames', 'tipo-laudo', 'comentarios'].forEach((id) => byId(id).addEventListener('input', () => { state.page = 1; render(); }));
document.querySelectorAll('input[name="origem"]').forEach((option) => option.addEventListener('change', () => { state.page = 1; render(); }));
byId('parametro-botao').addEventListener('click', () => { const tree = byId('parametro-arvore'); tree.hidden = !tree.hidden; byId('parametro-botao').setAttribute('aria-expanded', String(!tree.hidden)); });
byId('adicionar-parametro').addEventListener('click', () => {
  const parameter = byId('parametro').value.trim();
  if (!parameter) { byId('parametro-botao').focus(); return; }
  const label = byId('parametro-botao').textContent;
  const start = byId('valor-inicio').value;
  const end = byId('valor-fim').value;
  const existing = state.parameterFilters.find((filter) => filter.parameter === parameter);
  if (existing) Object.assign(existing, { label, start, end }); else state.parameterFilters.push({ parameter, label, start, end });
  byId('parametro').value = ''; byId('parametro-botao').textContent = 'Selecione um parâmetro'; byId('valor-inicio').value = ''; byId('valor-fim').value = '';
  state.page = 1;
  renderParameterFilters();
  render();
});
byId('limpar').addEventListener('click', () => { ['registro', 'codigo-animal', 'data-inicio', 'data-fim', 'idade-inicio', 'idade-fim', 'animal', 'tutor', 'especie', 'exames', 'tipo-laudo', 'parametro', 'valor-inicio', 'valor-fim', 'comentarios'].forEach((id) => { byId(id).value = ''; }); document.querySelectorAll('input[name="origem"]').forEach((option) => { option.checked = false; }); byId('parametro-botao').textContent = 'Selecione um parâmetro'; byId('parametro-arvore').hidden = true; state.parameterFilters = []; renderParameterFilters(); state.selected = null; state.page = 1; render(); });
loadData().catch(() => { byId('contagem').textContent = 'Não foi possível abrir os dados locais. Execute Abrir demonstracao.bat.'; });
