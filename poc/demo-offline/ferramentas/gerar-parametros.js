import { readFileSync, writeFileSync } from 'node:fs';

const reports = JSON.parse(readFileSync(new URL('../dados/laudos.json', import.meta.url))).records ?? [];
const groups = new Map();
const ignored = /^(amostra|m[eé]todo|eritrograma|leucograma|resultados|valores de refer[eê]ncia|coment[aá]rios|observa[cç][oõ]es|m[eé]dicos veterin[aá]rios|universidade|tel\.|n[uú]mero|registro geral|esp[eé]cie|paciente)/i;
const textResults = /^(glicose|cetonas|sangue|prote[ií]nas|nitrito|hem[aá]cias\/campo|leuc[oó]citos\/campo|cristais|cilindros|c[eé]lulas epiteliais|bact[eé]rias|demais observa[cç][oõ]es)\s+/i;
const knownParameter = /^(albumina|alt|ast|bas[oó]filos|bact[eé]rias|bast[oõ]es|c[aá]lcio total|c[eé]lulas epiteliais|chcm|cilindros|ck|colesterol total|creatinina(?: urin[aá]ria)?|cristais|densidade espec[ií]fica|demais observa[cç][oõ]es|eosin[oó]filos|fibrinog[eê]nio|fosfatase alcalina|f[oó]sforo|ggt|glicose|globulinas|hemat[oó]crito|hem[aá]cias(?:\/campo)?|hemoglobina|lactato desidrogenase|ldh|leuc[oó]citos(?:\/campo)?|linf[oó]citos|metamiel[oó]citos|metarrubr[ií]citos|miel[oó]citos|mon[oó]citos|nitrito|ph|plaquetas|prote[ií]nas totais|rela[cç][aã]o albumina:globulina|rela[cç][aã]o prot\/creat|segmentados|sensiprot|sangue|triglicer[ií]deos|ur[eé]ia|valor absoluto|vcm)$/i;

function initialGroup(type) {
  if (type === 'Bioquímica') return 'Bioquímica';
  if (type === 'Imuno 4DX') return 'Imuno 4DX';
  if (type === 'Urinálise') return 'Urinálise';
  return 'Hemograma';
}

function groupFromLine(line, current, type) {
  const normalized = line.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  if (normalized.startsWith('eritrograma')) return 'Eritrograma';
  if (normalized.startsWith('leucograma')) return 'Leucograma';
  if (normalized.startsWith('contagem de reticulocitos')) return 'Contagem de reticulócitos';
  if (normalized.startsWith('exame fisico')) return 'Urinálise · Exame físico';
  if (normalized.startsWith('exame quimico')) return 'Urinálise · Exame químico';
  if (normalized.startsWith('sedimentoscopia')) return 'Urinálise · Sedimentoscopia';
  if (normalized.startsWith('bioquimica urinaria')) return 'Urinálise · Bioquímica urinária';
  return current || initialGroup(type);
}

for (const report of reports) {
  let current = initialGroup(report.tipo);
  for (const rawLine of String(report.texto ?? '').split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) continue;
    current = groupFromLine(line, current, report.tipo);
    if (ignored.test(line) || /\bCRMV\b|^\d{2}\/\d{2}\/|^\d{3,}\b|^[-–]/i.test(line)) continue;
    const numeric = line.match(/^(.+?)(?:\s+\([^)]*\))?\s+-?\d+(?:[.,]\d+)?/);
    const textual = line.match(textResults);
    const name = (numeric?.[1] ?? textual?.[1] ?? '').trim();
    if (!name || name.length > 60 || /^(data|volume|cor|aspecto|sexo|idade|raca|veterinario)$/i.test(name) || !knownParameter.test(name)) continue;
    const label = numeric && /^(.+?\([^)]*\))\s+-?\d+(?:[.,]\d+)?/.test(line) ? line.match(/^(.+?\([^)]*\))\s+-?\d+(?:[.,]\d+)?/)?.[1] : name;
    const group = groups.get(current) ?? new Map();
    group.set(name, { label, value: name });
    groups.set(current, group);
  }
}

const payload = { version: 1, groups: [...groups.entries()].map(([name, items]) => ({ name, parameters: [...items.values()].sort((a, b) => a.label.localeCompare(b.label, 'pt-BR')) })).filter((group) => group.parameters.length).sort((a, b) => a.name.localeCompare(b.name, 'pt-BR')) };
writeFileSync(new URL('../dados/parametros.json', import.meta.url), JSON.stringify(payload, null, 2), 'utf8');
