-- Recompõe as colunas da planilha a partir da carga armazenada no schema labvet.
-- Execute no banco labvet.

WITH exames_por_atendimento AS (
  SELECT
    associacao.attendance_id,
    string_agg(
      exame.external_code,
      ' | ' ORDER BY
        CASE WHEN exame.external_code ~ '^[0-9]+([.][0-9]+)?$'
          THEN exame.external_code::NUMERIC
        END NULLS LAST,
        exame.external_code
    ) AS exames
  FROM labvet.attendance_exams associacao
  JOIN labvet.exams exame ON exame.exam_id = associacao.exam_id
  CROSS JOIN LATERAL generate_series(1, associacao.quantity) AS repeticao(numero)
  GROUP BY associacao.attendance_id
), proprietario_atual AS (
  SELECT DISTINCT ON (vinculo.animal_id)
    vinculo.animal_id,
    proprietario.full_name
  FROM labvet.animal_owners vinculo
  JOIN labvet.owners proprietario ON proprietario.owner_id = vinculo.owner_id
  WHERE vinculo.is_current
  ORDER BY vinculo.animal_id, proprietario.full_name
)
SELECT
  atendimento.source_origin AS "Origem",
  atendimento.source_record_number AS "Registro",
  atendimento.attended_on AS "Data",
  animal.external_code AS "Código",
  animal.name AS "Animal",
  proprietario.full_name AS "Proprietário",
  animal.species AS "Especie",
  atendimento.age_text AS "Idade",
  CASE animal.sex
    WHEN 'INDEFINIDO' THEN 'Indef'
    WHEN 'NAO_INFORMADO' THEN NULL
    ELSE animal.sex::TEXT
  END AS "Sexo",
  animal.breed AS "Raça",
  setor.name AS "Setor",
  atendimento.clinical_history AS "Histórico",
  exames.exames AS "Exames",
  atendimento.reported_exam_total AS "Total de exames",
  atendimento.charged_amount AS "Valor"
FROM labvet.attendances atendimento
LEFT JOIN labvet.animals animal ON animal.animal_id = atendimento.animal_id
LEFT JOIN proprietario_atual proprietario ON proprietario.animal_id = atendimento.animal_id
LEFT JOIN labvet.sectors setor ON setor.sector_id = atendimento.sector_id
LEFT JOIN exames_por_atendimento exames ON exames.attendance_id = atendimento.attendance_id
ORDER BY atendimento.source_origin, atendimento.source_record_number;
