const byId = (id) => document.getElementById(id);
const palette = ['#08716c', '#277da1', '#7b5ea7', '#cf6b3c', '#a84b64', '#668c2d', '#b38320', '#4f6d7a', '#9b5b9b', '#566bc4', '#4a8e87', '#b55d45', '#748f41', '#5c7896'];
const state = { months: [], selectedMonth: '', attendances: [], reports: [], results: [], view: 'laudos', species: '', animalCode: '' };
const monthLabel = new Intl.DateTimeFormat('pt-BR', { month: 'long', year: 'numeric' });
const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character]));
const diseaseCatalog = [
  ['Anemia', ['anemia', 'anemico', 'anemica']], ['Eosinofilia', ['eosinofilia']], ['Neutrofilia', ['neutrofilia']], ['Neutropenia', ['neutropenia']],
  ['Linfopenia', ['linfopenia']], ['Linfocitose', ['linfocitose']], ['Leucocitose', ['leucocitose']], ['Leucopenia', ['leucopenia']],
  ['Monocitose', ['monocitose']], ['Monocitopenia', ['monocitopenia']], ['Trombocitopenia', ['trombocitopenia']], ['Trombocitose', ['trombocitose']],
  ['Hiperproteinemia', ['hiperproteinemia']], ['Hipoproteinemia', ['hipoproteinemia']], ['Hemoparasitose', ['hemoparasita', 'hemoparasitos']],
  ['Piroplasmose', ['piroplasmida', 'piroplasmose']], ['Hiperadrenocorticismo', ['hiperadrenocorticismo']], ['Hipotireoidismo', ['hipotireoidismo']]
];

function attendanceKey(item) { return `${item.origem ?? ''}|${item.registro}`; }
function dateFrom(value) { const [day, month, year] = String(value || '').split('/'); return year ? new Date(Number(year), Number(month) - 1, Number(day)) : null; }
function monthKey(date) { return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`; }
function monthDate(key) { const [year, month] = key.split('-').map(Number); return new Date(year, month - 1, 1); }
function colorFor(types) { return new Map(types.map((type, index) => [type, palette[index % palette.length]])); }
function normalizeText(value) { return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim(); }
function editDistance(left, right) { const previous = Array.from({ length: right.length + 1 }, (_, index) => index); for (let i = 1; i <= left.length; i += 1) { let diagonal = previous[0]; previous[0] = i; for (let j = 1; j <= right.length; j += 1) { const saved = previous[j]; previous[j] = Math.min(previous[j] + 1, previous[j - 1] + 1, diagonal + (left[i - 1] === right[j - 1] ? 0 : 1)); diagonal = saved; } } return previous[right.length]; }
function diseasesFor(report) { const text = normalizeText(report.comentarios); const words = text.split(' '); return diseaseCatalog.filter(([, aliases]) => aliases.some((alias) => text.includes(alias) || (alias.length >= 8 && !alias.includes(' ') && words.some((word) => Math.abs(word.length - alias.length) <= 2 && editDistance(word, alias) <= Math.max(1, Math.floor(alias.length * 0.15)))))).map(([name]) => name); }

async function loadData() {
  const [attendances, reports, results] = await Promise.all([
    fetch('dados/atendimentos.json').then((response) => response.json()),
    fetch('dados/laudos.json').then((response) => response.json()),
    fetch('dados/resultados.json').then((response) => response.json())
  ]);
  state.attendances = attendances.records || [];
  state.results = results.records || [];
  const attendanceData = new Map(state.attendances.map((item) => [attendanceKey(item), item]));
  state.reports = (reports.records || []).map((report) => {
    const attendance = attendanceData.get(attendanceKey(report));
    return { ...report, date: attendance ? dateFrom(attendance.data) : null, especie: attendance?.especie || 'Não informada', codigoAnimal: attendance?.codigo || '' };
  }).filter((report) => report.date);
  state.months = [...new Set(state.reports.map((report) => monthKey(report.date)))].sort();
  const species = [...new Set(state.reports.map((report) => report.especie))].sort((left, right) => left.localeCompare(right, 'pt-BR'));
  byId('especie-dashboard').innerHTML = `<option value="">Todas as espécies</option>${species.map((speciesName) => `<option value="${escapeHtml(speciesName)}">${escapeHtml(speciesName)}</option>`).join('')}`;
  const animals = [...new Map(state.attendances.filter((item) => item.codigo && item.codigo !== '-').map((item) => [String(item.codigo), item])).values()].sort((left, right) => String(left.codigo).localeCompare(String(right.codigo), 'pt-BR', { numeric: true }));
  byId('animais-historico').innerHTML = animals.flatMap((animal) => {
    const label = `${animal.codigo} · ${animal.animal || 'Sem nome'} · ${animal.especie || 'Espécie não informada'}`;
    return [`<option value="${escapeHtml(animal.codigo)}" label="${escapeHtml(label)}"></option>`, `<option value="${escapeHtml(animal.animal || '')}" label="${escapeHtml(label)}"></option>`];
  }).join('');
  state.selectedMonth = state.months.at(-1) || '';
  render();
}

function render() {
  const current = monthDate(state.selectedMonth);
  const historyView = state.view === 'historico';
  document.querySelector('.navegacao-mes').hidden = historyView;
  byId('mes-anterior').closest('.navegacao-mes').hidden = historyView;
  document.querySelector('.dashboard-indicadores').hidden = historyView;
  document.querySelector('.dashboard-grade').hidden = historyView;
  byId('historico-animal').hidden = !historyView;
  document.querySelectorAll('[data-dashboard]').forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.dashboard === state.view)));
  if (historyView) {
    byId('titulo-dashboard').textContent = 'Histórico Animal';
    byId('subtitulo-dashboard').textContent = 'Evolução dos resultados de exames por número de registro do animal';
    renderAnimalHistory();
    return;
  }
  const monthlyReports = state.reports.filter((report) => monthKey(report.date) === state.selectedMonth);
  const reports = state.view === 'doencas' && state.species ? monthlyReports.filter((report) => report.especie === state.species) : monthlyReports;
  const dimension = state.view === 'especie' ? 'especie' : state.view === 'doencas' ? 'doenca' : 'tipo';
  const label = state.view === 'especie' ? 'espécie' : state.view === 'doencas' ? 'alteração' : 'tipo de laudo';
  const pluralLabel = state.view === 'especie' ? 'Espécies' : state.view === 'doencas' ? 'Alterações identificadas' : 'Tipos de laudo';
  const chartRecords = state.view === 'doencas' ? reports.flatMap((report) => diseasesFor(report).map((doenca) => ({ date: report.date, doenca }))) : reports;
  const types = [...new Set(chartRecords.map((report) => report[dimension]))].sort((a, b) => a.localeCompare(b, 'pt-BR'));
  const colors = colorFor(types);
  const byType = new Map(types.map((type) => [type, chartRecords.filter((report) => report[dimension] === type).length]));
  const byDay = new Map(Array.from({ length: new Date(current.getFullYear(), current.getMonth() + 1, 0).getDate() }, (_, index) => [index + 1, new Map(types.map((type) => [type, 0]))]));
  chartRecords.forEach((report) => byDay.get(report.date.getDate()).set(report[dimension], byDay.get(report.date.getDate()).get(report[dimension]) + 1));
  const speciesFilter = byId('filtro-especie-dashboard');
  speciesFilter.hidden = state.view !== 'doencas';
  speciesFilter.style.display = state.view === 'doencas' ? 'grid' : 'none';
  byId('titulo-dashboard').textContent = state.view === 'especie' ? 'Dashboard de Laudos por Espécie' : state.view === 'doencas' ? 'Dashboard de Alterações por Espécie' : 'Dashboard de Laudos';
  byId('subtitulo-dashboard').textContent = state.view === 'especie' ? 'Distribuição mensal de laudos por espécie' : state.view === 'doencas' ? 'Alterações e condições identificadas nos comentários dos laudos' : 'Distribuição mensal de laudos e tipos de exame';
  byId('rotulo-total').textContent = state.view === 'doencas' ? 'Alterações no mês' : 'Laudos no mês';
  byId('rotulo-dias').textContent = state.view === 'doencas' ? 'Dias com alterações' : 'Dias com laudos';
  byId('rotulo-dimensao').textContent = pluralLabel;
  byId('titulo-distribuicao').textContent = `Distribuição por ${label}`;
  byId('titulo-barras').textContent = `Laudos por dia e ${label}`;
  byId('subtitulo-barras').textContent = `Barras empilhadas: cada cor representa ${state.view === 'especie' ? 'uma espécie' : 'um tipo de laudo'}.`;
  byId('mes-atual').textContent = state.selectedMonth ? monthLabel.format(current) : 'Sem dados';
  byId('total-laudos-mes').textContent = chartRecords.length;
  byId('dias-com-laudos').textContent = [...byDay.values()].filter((day) => [...day.values()].some(Boolean)).length;
  byId('tipos-laudo').textContent = types.length;
  byId('mes-anterior').disabled = state.months.indexOf(state.selectedMonth) <= 0;
  byId('mes-proximo').disabled = state.months.indexOf(state.selectedMonth) >= state.months.length - 1;
  renderDonut(types, byType, colors, chartRecords.length);
  renderBars(current, types, byDay, colors, state.view === 'doencas' ? 'identificação' : 'laudo');
}

function renderDonut(types, byType, colors, total) {
  let cursor = 0;
  const segments = types.map((type) => { const percent = total ? (byType.get(type) / total) * 100 : 0; const segment = `${colors.get(type)} ${cursor}% ${cursor + percent}%`; cursor += percent; return segment; });
  byId('grafico-anel').innerHTML = `<div class="anel" style="background:conic-gradient(${segments.join(',') || '#dce7e9 0 100%'})"><div><strong>${total}</strong><span>laudos</span></div></div>`;
  byId('legenda-tipos').innerHTML = types.map((type) => { const count = byType.get(type); const percent = total ? (count / total) * 100 : 0; return `<div class="item-legenda"><i style="background:${colors.get(type)}"></i><span>${type}</span><strong>${count}</strong><em>${percent.toLocaleString('pt-BR', { maximumFractionDigits: 1 })}%</em></div>`; }).join('') || '<p class="estado-vazio">Não há laudos no mês selecionado.</p>';
}

function renderBars(current, types, byDay, colors, recordLabel) {
  const days = [...byDay.keys()];
  const max = Math.max(1, ...days.map((day) => [...byDay.get(day).values()].reduce((sum, value) => sum + value, 0)));
  const height = 430; const chartTop = 22; const chartBottom = 38; const plotHeight = height - chartTop - chartBottom; const width = Math.max(700, days.length * 30 + 58); const barWidth = 19;
  const bars = days.map((day, index) => { let bottom = chartTop + plotHeight; const x = 42 + index * 30 + 5; const segments = types.map((type) => { const count = byDay.get(day).get(type); const segmentHeight = (count / max) * plotHeight; bottom -= segmentHeight; return count ? `<rect x="${x}" y="${bottom}" width="${barWidth}" height="${segmentHeight}" rx="2" fill="${colors.get(type)}" pointer-events="none"/>` : ''; }).join(''); const barHeight = chartTop + plotHeight - bottom; const area = barHeight ? `<rect class="area-dia" data-dia="${day}" x="${x - 4}" y="${bottom}" width="${barWidth + 8}" height="${barHeight}" fill="transparent" pointer-events="all"/>` : ''; return `${segments}${area}<text x="${x + barWidth / 2}" y="${height - 15}" text-anchor="middle">${day}</text>`; }).join('');
  const grid = [0, 0.5, 1].map((level) => { const value = Math.round(max * (1 - level)); const y = chartTop + plotHeight * level; return `<line x1="38" y1="${y}" x2="${width - 8}" y2="${y}" class="linha-grade"/><text x="32" y="${y + 4}" text-anchor="end">${value}</text>`; }).join('');
  byId('legenda-barras').innerHTML = types.map((type) => `<span><i style="background:${colors.get(type)}"></i>${type}</span>`).join('');
  byId('grafico-barras').innerHTML = `<svg viewBox="0 0 ${width} ${height}" role="img" aria-label="Laudos por dia do mês"><g class="eixos">${grid}${bars}</g></svg>`;
  document.querySelectorAll('[data-dia]').forEach((area) => {
    const showTooltip = (event) => {
      const day = Number(area.dataset.dia);
      const values = byDay.get(day);
      const total = [...values.values()].reduce((sum, value) => sum + value, 0);
      const date = `${String(day).padStart(2, '0')}/${String(current.getMonth() + 1).padStart(2, '0')}/${current.getFullYear()}`;
      const recordText = recordLabel === 'identificação' ? (total === 1 ? 'identificação' : 'identificações') : `${recordLabel}${total === 1 ? '' : 's'}`;
      byId('tooltip-grafico').innerHTML = `<strong>${date} · ${total} ${recordText}</strong>${types.filter((type) => values.get(type)).map((type) => `<span><i style="background:${colors.get(type)}"></i>${escapeHtml(type)}: <b>${values.get(type)}</b></span>`).join('') || '<span>Sem registros neste dia.</span>'}`;
      byId('tooltip-grafico').hidden = false;
      byId('tooltip-grafico').style.left = `${event.clientX + 14}px`;
      byId('tooltip-grafico').style.top = `${event.clientY + 14}px`;
    };
    area.addEventListener('pointerenter', showTooltip);
    area.addEventListener('pointermove', showTooltip);
    area.addEventListener('pointerleave', () => { byId('tooltip-grafico').hidden = true; });
    area.addEventListener('mouseleave', () => { byId('tooltip-grafico').hidden = true; });
  });
  byId('grafico-barras').addEventListener('pointerleave', () => { byId('tooltip-grafico').hidden = true; });
  byId('grafico-barras').addEventListener('mousemove', (event) => { if (!event.target.closest('.area-dia')) byId('tooltip-grafico').hidden = true; });
}

function reportFileKey(item) { return `${item.origem || ''}|${item.arquivo || ''}`; }
function formatHistoryDate(date) { return date ? date.toLocaleDateString('pt-BR') : 'Sem data'; }
function formatHistoryValue(result) {
  const value = result.valorNumerico !== null && result.valorNumerico !== undefined ? Number(result.valorNumerico).toLocaleString('pt-BR', { maximumFractionDigits: 6 }) : result.valorTexto;
  return [value, result.unidade].filter(Boolean).join(' ') || '—';
}
function historyReference(result) {
  if (result.referenciaInicial !== null && result.referenciaInicial !== undefined && result.referenciaFinal !== null && result.referenciaFinal !== undefined) return `${Number(result.referenciaInicial).toLocaleString('pt-BR')} – ${Number(result.referenciaFinal).toLocaleString('pt-BR')}`;
  if (result.referenciaInicial !== null && result.referenciaInicial !== undefined) return `≥ ${Number(result.referenciaInicial).toLocaleString('pt-BR')}`;
  if (result.referenciaFinal !== null && result.referenciaFinal !== undefined) return `≤ ${Number(result.referenciaFinal).toLocaleString('pt-BR')}`;
  return result.referenciaTexto || '—';
}
function historyStatus(result) {
  if (result.valorNumerico === null || result.valorNumerico === undefined) return '';
  const value = Number(result.valorNumerico);
  if (result.referenciaInicial !== null && result.referenciaInicial !== undefined && value < Number(result.referenciaInicial)) return 'baixo';
  if (result.referenciaFinal !== null && result.referenciaFinal !== undefined && value > Number(result.referenciaFinal)) return 'alto';
  return '';
}
function normalizeAnimalSearch(value) { return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim(); }
function resolveAnimalCode(value) {
  const search = normalizeAnimalSearch(value);
  if (!search) return '';
  const directCode = state.attendances.find((item) => String(item.codigo) === String(value).trim());
  if (directCode) return String(directCode.codigo);
  const exactName = state.attendances.find((item) => normalizeAnimalSearch(item.animal) === search);
  if (exactName) return String(exactName.codigo);
  const candidates = state.attendances.filter((item) => normalizeAnimalSearch(item.animal).includes(search));
  return candidates.length === 1 ? String(candidates[0].codigo) : '';
}
function renderAnimalHistory() {
  const content = byId('conteudo-historico-animal');
  const summary = byId('resumo-animal-historico');
  const code = state.animalCode;
  if (!code) { summary.innerHTML = ''; content.innerHTML = '<p class="estado-vazio">Selecione o número de registro de um animal para consultar seus exames.</p>'; return; }
  const attendances = state.attendances.filter((item) => String(item.codigo) === String(code)).sort((left, right) => dateFrom(left.data) - dateFrom(right.data));
  const representative = attendances.at(-1);
  const reports = state.reports.filter((report) => String(report.codigoAnimal) === String(code)).sort((left, right) => left.date - right.date);
  summary.innerHTML = representative ? `<strong>${escapeHtml(`${representative.codigo} · ${representative.animal || 'Sem nome'} · ${representative.especie || 'Espécie não informada'}`)}</strong><span>${reports.length} laudo${reports.length === 1 ? '' : 's'} vinculado${reports.length === 1 ? '' : 's'} em ${attendances.length} atendimento${attendances.length === 1 ? '' : 's'}.</span>` : '';
  if (!reports.length) { content.innerHTML = '<p class="estado-vazio">Não há laudos estruturados vinculados a este animal.</p>'; return; }
  const dateByReport = new Map(reports.map((report) => [reportFileKey(report), formatHistoryDate(report.date)]));
  const dates = [...new Set([...dateByReport.values()])].sort((left, right) => {
    const [leftDay, leftMonth, leftYear] = left.split('/').map(Number); const [rightDay, rightMonth, rightYear] = right.split('/').map(Number);
    return new Date(leftYear, leftMonth - 1, leftDay) - new Date(rightYear, rightMonth - 1, rightDay);
  });
  const validKeys = new Set(dateByReport.keys());
  const groups = new Map();
  state.results.filter((result) => validKeys.has(reportFileKey(result))).forEach((result) => {
    const report = reports.find((item) => reportFileKey(item) === reportFileKey(result));
    const groupKey = `${report?.tipo || 'Exame'}|${result.secao || 'Resultados'}`;
    if (!groups.has(groupKey)) groups.set(groupKey, new Map());
    const rows = groups.get(groupKey); const rowKey = `${result.codigoParametro || result.parametro}|${result.unidade || ''}`;
    if (!rows.has(rowKey)) rows.set(rowKey, { ...result, values: new Map() });
    const row = rows.get(rowKey); const date = dateByReport.get(reportFileKey(result));
    row.values.set(date, [...(row.values.get(date) || []), result]);
  });
  if (!groups.size) { content.innerHTML = '<p class="estado-vazio">Os laudos deste animal não possuem parâmetros estruturados.</p>'; return; }
  content.innerHTML = [...groups.entries()].map(([groupKey, rows]) => {
    const [type, section] = groupKey.split('|');
    return `<section class="historico-secao"><h3>${escapeHtml(type)} <span>· ${escapeHtml(section)}</span></h3><div class="tabela-historico-wrap"><table class="tabela-historico"><thead><tr><th>Parâmetro</th>${dates.map((date) => `<th>${escapeHtml(date)}</th>`).join('')}<th>Referência</th></tr></thead><tbody>${[...rows.values()].sort((left, right) => left.ordem - right.ordem).map((row) => `<tr><td>${escapeHtml([row.parametro, row.unidade].filter(Boolean).join(' ') || 'Parâmetro não informado')}</td>${dates.map((date) => { const values = row.values.get(date) || []; const status = values.some((value) => historyStatus(value) === 'baixo') ? 'baixo' : values.some((value) => historyStatus(value) === 'alto') ? 'alto' : ''; const indicator = status === 'baixo' ? '↓ ' : status === 'alto' ? '↑ ' : ''; return `<td class="${status}">${escapeHtml(indicator + values.map(formatHistoryValue).join(' / ') || '—')}</td>`; }).join('')}<td>${escapeHtml(historyReference(row))}</td></tr>`).join('')}</tbody></table></div></section>`;
  }).join('');
}

byId('mes-anterior').addEventListener('click', () => { state.selectedMonth = state.months[state.months.indexOf(state.selectedMonth) - 1]; render(); });
byId('mes-proximo').addEventListener('click', () => { state.selectedMonth = state.months[state.months.indexOf(state.selectedMonth) + 1]; render(); });
document.querySelectorAll('[data-dashboard]').forEach((button) => button.addEventListener('click', () => { state.view = button.dataset.dashboard; render(); }));
byId('especie-dashboard').addEventListener('change', (event) => { state.species = event.target.value; render(); });
byId('animal-historico').addEventListener('change', (event) => { state.animalCode = resolveAnimalCode(event.target.value); renderAnimalHistory(); });
byId('animal-historico').addEventListener('keydown', (event) => { if (event.key === 'Enter') { state.animalCode = resolveAnimalCode(event.target.value); renderAnimalHistory(); } });
document.addEventListener('pointermove', (event) => { if (!event.target.closest?.('.area-dia')) byId('tooltip-grafico').hidden = true; });
loadData().catch(() => { byId('mes-atual').textContent = 'Não foi possível abrir os dados locais'; });
