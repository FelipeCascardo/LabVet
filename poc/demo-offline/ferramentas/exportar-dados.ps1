param(
  [string]$Container = 'itriax-postgres-1',
  [string]$Database = 'labvet',
  [string]$User = 'labvet_app'
)

$ErrorActionPreference = 'Stop'
$destination = Join-Path $PSScriptRoot '..\dados'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

function Export-QueryToJson([string]$Query, [string]$FileName) {
  $json = & docker exec $Container psql -U $User -d $Database -v ON_ERROR_STOP=1 -At -c $Query
  if ($LASTEXITCODE -ne 0) { throw "Não foi possível exportar $FileName da base $Database." }
  $target = Join-Path $destination $FileName
  [System.IO.File]::WriteAllText($target, $json, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Gerado: $target"
}

$attendancesQuery = @'
WITH exames_por_atendimento AS (
  SELECT ae.attendance_id, string_agg(
    e.external_code,
    ' | ' ORDER BY
      CASE WHEN e.external_code ~ '^[0-9]+([.][0-9]+)?$' THEN e.external_code::NUMERIC END NULLS LAST,
      e.external_code
  ) AS exames
  FROM labvet.attendance_exams ae
  JOIN labvet.exams e ON e.exam_id = ae.exam_id
  CROSS JOIN LATERAL generate_series(1, ae.quantity)
  GROUP BY ae.attendance_id
), proprietario_atual AS (
  SELECT DISTINCT ON (ao.animal_id) ao.animal_id, o.full_name
  FROM labvet.animal_owners ao
  JOIN labvet.owners o ON o.owner_id = ao.owner_id
  WHERE ao.is_current
  ORDER BY ao.animal_id, o.full_name
)
SELECT jsonb_build_object(
  'version', 1,
  'exportadoEm', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SSOF'),
  'records', COALESCE(jsonb_agg(jsonb_build_object(
    'registro', a.source_record_number,
    'origem', a.source_origin,
    'data', to_char(a.attended_on, 'DD/MM/YYYY'),
    'codigo', an.external_code,
    'animal', an.name,
    'proprietario', p.full_name,
    'especie', an.species,
    'raca', an.breed,
    'sexo', an.sex,
    'idade', a.age_text,
    'setor', s.name,
    'historico', a.clinical_history,
    'exames', epa.exames,
    'valor', a.charged_amount
  ) ORDER BY a.source_origin, a.source_record_number), '[]'::jsonb)
)
FROM labvet.attendances a
LEFT JOIN labvet.animals an ON an.animal_id = a.animal_id
LEFT JOIN proprietario_atual p ON p.animal_id = a.animal_id
LEFT JOIN labvet.sectors s ON s.sector_id = a.sector_id
LEFT JOIN exames_por_atendimento epa ON epa.attendance_id = a.attendance_id;
'@

$reportsQuery = @'
SELECT jsonb_build_object(
  'version', 1,
  'exportadoEm', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SSOF'),
  'records', COALESCE(jsonb_agg(jsonb_build_object(
    'registro', r.source_record_number,
    'origem', r.source_origin,
    'tipo', t.name,
    'codigoTipo', t.code,
    'arquivo', r.source_file_name,
    'emitidoEm', r.reported_at,
    'pacienteNoLaudo', r.reported_patient_name,
    'proprietarioNoLaudo', r.reported_owner_name,
    'veterinario', r.reported_veterinarian_name,
    'comentarios', (
      SELECT string_agg(note.note_text, E'\n\n' ORDER BY note.display_order)
      FROM labvet.laboratory_report_notes note
      WHERE note.laboratory_report_id = r.laboratory_report_id
        AND note.note_type = 'OBSERVATION'
    ),
    'texto', r.raw_text
  ) ORDER BY r.source_record_number, t.code), '[]'::jsonb)
)
FROM labvet.laboratory_reports r
JOIN labvet.lab_report_types t ON t.lab_report_type_id = r.lab_report_type_id;
'@

$resultsQuery = @'
SELECT jsonb_build_object(
  'version', 1,
  'exportadoEm', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SSOF'),
  'records', COALESCE(jsonb_agg(jsonb_build_object(
    'arquivo', report.source_file_name,
    'registro', report.source_record_number,
    'origem', report.source_origin,
    'codigoParametro', analyte.code,
    'parametro', analyte.name,
    'secao', result.section_name,
    'ordem', result.display_order,
    'valorNumerico', result.result_numeric,
    'valorTexto', result.result_text,
    'unidade', result.unit,
    'referenciaInicial', result.reference_low,
    'referenciaFinal', result.reference_high,
    'referenciaTexto', result.reference_text
  ) ORDER BY report.source_origin, report.source_record_number, report.source_file_name, result.display_order), '[]'::jsonb)
)
FROM labvet.laboratory_results result
JOIN labvet.laboratory_reports report ON report.laboratory_report_id = result.laboratory_report_id
JOIN labvet.lab_analytes analyte ON analyte.lab_analyte_id = result.lab_analyte_id;
'@

$parametersQuery = @'
SELECT jsonb_build_object(
  'version', 2,
  'groups', COALESCE(jsonb_agg(jsonb_build_object(
    'name', grouped.section_name,
    'parameters', grouped.parameters
  ) ORDER BY grouped.section_name), '[]'::jsonb)
)
FROM (
  SELECT
    result.section_name,
    jsonb_agg(DISTINCT jsonb_build_object(
      'label', analyte.name || COALESCE(' (' || analyte.default_unit || ')', ''),
      'value', analyte.code
    ) ORDER BY jsonb_build_object(
      'label', analyte.name || COALESCE(' (' || analyte.default_unit || ')', ''),
      'value', analyte.code
    )) AS parameters
  FROM labvet.laboratory_results result
  JOIN labvet.lab_analytes analyte ON analyte.lab_analyte_id = result.lab_analyte_id
  GROUP BY result.section_name
) grouped;
'@

Export-QueryToJson $attendancesQuery 'atendimentos.json'
Export-QueryToJson $reportsQuery 'laudos.json'
Export-QueryToJson $resultsQuery 'resultados.json'
Export-QueryToJson $parametersQuery 'parametros.json'
