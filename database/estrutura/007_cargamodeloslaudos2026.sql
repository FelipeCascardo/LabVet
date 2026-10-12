-- Labvet V1 — carga dos 161 modelos .xlsx de laudos de 2026.
-- Fonte: Importação/Laudos 2026 e análise consolidada dos modelos.
-- Os quatro arquivos .xls permanecem fora desta carga, pois não foram lidos estruturalmente.
-- A relação com exame é nula somente nos quatro modelos cujo serviço não existe no catálogo atual:
-- IMUNO_WOO_CÃO, IMUNO_LEPTO_CÃO, B_POP_FEL e IMUNO_LIPASE_FEL.

BEGIN;

SET search_path TO labvet, public;

-- Modelos históricos podem aguardar o vínculo ao catálogo comercial.
ALTER TABLE modeloslaudos
  ALTER COLUMN idexame DROP NOT NULL;

COMMENT ON COLUMN modeloslaudos.idexame IS
  'Exame comercial associado ao modelo. Pode ficar nulo temporariamente em carga histórica quando o serviço ainda não existir no catálogo.';

INSERT INTO tiposanimais (nmtipoanimal, dsdescricao, stativo)
VALUES
  ('Bovino', 'Agrupamento operacional do laboratório.', true),
  ('Bubalino', 'Agrupamento operacional do laboratório.', true),
  ('Caprino', 'Agrupamento operacional do laboratório.', true),
  ('Cão', 'Agrupamento operacional do laboratório.', true),
  ('Equinos', 'Agrupamento operacional do laboratório.', true),
  ('Gato', 'Agrupamento operacional do laboratório.', true),
  ('Ovino', 'Agrupamento operacional do laboratório.', true),
  ('Silvestres', 'Agrupamento operacional do laboratório.', true),
  ('Suino', 'Agrupamento operacional do laboratório.', true)
ON CONFLICT DO NOTHING;

INSERT INTO tiposanimais (idtipoanimalpai, nmtipoanimal, dsdescricao, stativo)
SELECT pai.idtipoanimal, filho.nmtipoanimal, filho.dsdescricao, true
FROM (
  VALUES
    ('Aves', 'Agrupamento operacional do laboratório.'),
    ('Mamíferos', 'Agrupamento operacional do laboratório.'),
    ('Peixes', 'Agrupamento operacional do laboratório.'),
    ('Répteis', 'Agrupamento operacional do laboratório.')
) AS filho(nmtipoanimal, dsdescricao)
JOIN tiposanimais pai ON pai.nmtipoanimal = 'Silvestres' AND pai.idtipoanimalpai IS NULL
ON CONFLICT DO NOTHING;

WITH fonte (
  cdmodelolaudo, cdexame, nmtipoanimal, nmtipoanimalpai,
  nmmodelolaudo, dsfaixaidade, nmarquivoorigem
) AS (
VALUES
  ('ML2026-001', '11', 'Bovino', NULL, 'CHECKUP_BOV_Ad - Labvet 2026', NULL, 'Bovino 2026\CHECKUP_BOV_Ad - Labvet 2026.xlsx'),
  ('ML2026-002', '4', 'Bovino', NULL, 'HEM_BOV_Ad - Labvet 2026', NULL, 'Bovino 2026\HEM_BOV_Ad - Labvet 2026.xlsx'),
  ('ML2026-003', '3', 'Bovino', NULL, 'HEM_BOV_Ad - RETICULOCITOS - Labvet 2026', NULL, 'Bovino 2026\HEM_BOV_Ad - RETICULOCITOS - Labvet 2026.xlsx'),
  ('ML2026-004', '35', 'Bovino', NULL, 'U_EAS_BOV relação- Labvet 2026', NULL, 'Bovino 2026\U_EAS_BOV relação- Labvet 2026.xlsx'),
  ('ML2026-005', '4', 'Bubalino', NULL, 'HEM_BUB_Ad - Labvet 2026', NULL, 'Bubalino 2026\HEM_BUB_Ad - Labvet 2026.xlsx'),
  ('ML2026-006', '11', 'Caprino', NULL, 'AVESSO BIOQUÍMICA_CAP - Labvet 2026', NULL, 'Caprino 2026\AVESSO BIOQUÍMICA_CAP - Labvet 2026.xlsx'),
  ('ML2026-007', '11', 'Caprino', NULL, 'CHECKUP_CAP - Labvet 2026', NULL, 'Caprino 2026\CHECKUP_CAP - Labvet 2026.xlsx'),
  ('ML2026-008', '44/45', 'Caprino', NULL, 'COMPATIBILIADE_Caprino - Labvet 2026', NULL, 'Caprino 2026\COMPATIBILIADE_Caprino - Labvet 2026.xlsx'),
  ('ML2026-009', '34', 'Caprino', NULL, 'EAS_CAP - Labvet 2026', NULL, 'Caprino 2026\EAS_CAP - Labvet 2026.xlsx'),
  ('ML2026-010', '4', 'Caprino', NULL, 'HEM_CAP_Ad - Labvet 2026', NULL, 'Caprino 2026\HEM_CAP_Ad - Labvet 2026.xlsx'),
  ('ML2026-011', '3', 'Caprino', NULL, 'HEM_CAP_Ad -RETICULOCITOS - Labvet 2026', NULL, 'Caprino 2026\HEM_CAP_Ad -RETICULOCITOS - Labvet 2026.xlsx'),
  ('ML2026-012', '7', 'Cão', NULL, 'B_AVESSO_CÃO_ADULTO - Labvet', 'ADULTO', 'Cão 2026\B_AVESSO_CÃO_ADULTO - Labvet.xlsx'),
  ('ML2026-013', '7', 'Cão', NULL, 'B_CHECK UP + Calcio+Fósf_CÃO - Labvet 2026', NULL, 'Cão 2026\B_CHECK UP + Calcio+Fósf_CÃO - Labvet 2026.xlsx'),
  ('ML2026-014', '7', 'Cão', NULL, 'B_CHECK UP + Fósf_CÃO - Labvet 2026', NULL, 'Cão 2026\B_CHECK UP + Fósf_CÃO - Labvet 2026.xlsx'),
  ('ML2026-015', '7', 'Cão', NULL, 'B_CHECK UP _CÃO - Labvet 2026', '2 ano', 'Cão 2026\B_CHECK UP _CÃO - Labvet 2026.xlsx'),
  ('ML2026-016', '7', 'Cão', NULL, 'B_CHECK UP+FOSF+CA+TRIG+COL+GLI_CÃO - Labvet 2026', '2 ano', 'Cão 2026\B_CHECK UP+FOSF+CA+TRIG+COL+GLI_CÃO - Labvet 2026.xlsx'),
  ('ML2026-017', '7', 'Cão', NULL, 'B_CHECK UP+TRIG+COL+GLIC_CÃO - Labvet 2026', '2 ano', 'Cão 2026\B_CHECK UP+TRIG+COL+GLIC_CÃO - Labvet 2026.xlsx'),
  ('ML2026-018', '7', 'Cão', NULL, 'B_CHECK UP+TRIG+COL_CÃO - Labvet 2026', '2 ano', 'Cão 2026\B_CHECK UP+TRIG+COL_CÃO - Labvet 2026.xlsx'),
  ('ML2026-019', '7', 'Cão', NULL, 'B_CHECK UP_CÃO_FILHOTE - Labvet 2026', 'FILHOTE', 'Cão 2026\B_CHECK UP_CÃO_FILHOTE - Labvet 2026.xlsx'),
  ('ML2026-020', '19', 'Cão', NULL, 'B_CÃO_BT_BD - Labvet 2026', NULL, 'Cão 2026\B_CÃO_BT_BD - Labvet 2026.xlsx'),
  ('ML2026-021', '7', 'Cão', NULL, 'B_CÃO_CHECKUP+BIL - Labvet 2026', NULL, 'Cão 2026\B_CÃO_CHECKUP+BIL - Labvet 2026.xlsx'),
  ('ML2026-022', '7', 'Cão', NULL, 'B_CÃO_CHECKUP+BIL+CÁLCIO+FOSF - Labvet 2026', NULL, 'Cão 2026\B_CÃO_CHECKUP+BIL+CÁLCIO+FOSF - Labvet 2026.xlsx'),
  ('ML2026-023', '7', 'Cão', NULL, 'B_CÃO_CHECKUP+BIL+TRI+COL - Labvet 2026', NULL, 'Cão 2026\B_CÃO_CHECKUP+BIL+TRI+COL - Labvet 2026.xlsx'),
  ('ML2026-024', '10', 'Cão', NULL, 'B_UREIA+CREAT _CÃO - Labvet 2026', '2 ano', 'Cão 2026\B_UREIA+CREAT _CÃO - Labvet 2026.xlsx'),
  ('ML2026-025', '47', 'Cão', NULL, 'CITOLOGIA_Cão - Labvet 2026', NULL, 'Cão 2026\CITOLOGIA_Cão - Labvet 2026.xlsx'),
  ('ML2026-026', '47', 'Cão', NULL, 'CITOLOGIA_CÃO', NULL, 'Cão 2026\CITOLOGIA_CÃO.xlsx'),
  ('ML2026-027', '51', 'Cão', NULL, 'COAGULOGRAMA_Cão - Labvet 2026', NULL, 'Cão 2026\COAGULOGRAMA_Cão - Labvet 2026.xlsx'),
  ('ML2026-028', '44/45', 'Cão', NULL, 'COMPATIBILIADE simples_CAN - Labvet 2026', NULL, 'Cão 2026\COMPATIBILIADE simples_CAN - Labvet 2026.xlsx'),
  ('ML2026-029', '48', 'Cão', NULL, 'CORTISOL_CÃO - Labvet 2026 Layout atualizado', NULL, 'Cão 2026\CORTISOL_CÃO - Labvet 2026 Layout atualizado.xlsx'),
  ('ML2026-030', '48', 'Cão', NULL, 'CORTISOL_CÃO - Labvet 2026', NULL, 'Cão 2026\CORTISOL_CÃO - Labvet 2026.xlsx'),
  ('ML2026-031', '3', 'Cão', NULL, 'HEM_CÃO_ AD_ RETICULÓCITOS 2026', NULL, 'Cão 2026\HEM_CÃO_ AD_ RETICULÓCITOS 2026.xlsx'),
  ('ML2026-032', '4', 'Cão', NULL, 'HEM_CÃO_ FIB E RET 2026', NULL, 'Cão 2026\HEM_CÃO_ FIB E RET 2026.xlsx'),
  ('ML2026-033', '1', 'Cão', NULL, 'HEM_CÃO_FILHOTE - Labvet 2026', 'FILHOTE', 'Cão 2026\HEM_CÃO_FILHOTE - Labvet 2026.xlsx'),
  ('ML2026-034', '1', 'Cão', NULL, 'HEM_CÃO_FILHOTE - MENOS 1 mês - Labvet 22026', 'FILHOTE; 1 mês', 'Cão 2026\HEM_CÃO_FILHOTE - MENOS 1 mês - Labvet 22026.xlsx'),
  ('ML2026-035', '3', 'Cão', NULL, 'HEM_CÃO_FILHOTE - RETICULOCITOS - Labvet 2026', 'FILHOTE', 'Cão 2026\HEM_CÃO_FILHOTE - RETICULOCITOS - Labvet 2026.xlsx'),
  ('ML2026-036', '41', 'Cão', NULL, 'IMUNO_ KNOTT_CÃO - Labvet 2026', NULL, 'Cão 2026\IMUNO_ KNOTT_CÃO - Labvet 2026.xlsx'),
  ('ML2026-037', NULL, 'Cão', NULL, 'IMUNO_ WOO_CÃO - Labvet 2026', NULL, 'Cão 2026\IMUNO_ WOO_CÃO - Labvet 2026.xlsx'),
  ('ML2026-038', '37', 'Cão', NULL, 'IMUNO_4DX- CAO - Labvet 2026', NULL, 'Cão 2026\IMUNO_4DX- CAO - Labvet 2026.xlsx'),
  ('ML2026-039', NULL, 'Cão', NULL, 'IMUNO_LEPTO CAO - Labvet 2026', NULL, 'Cão 2026\IMUNO_LEPTO CAO - Labvet 2026.xlsx'),
  ('ML2026-040', '46', 'Cão', NULL, 'LAVADO BRONCOALVEOLAR Labvet 2026', NULL, 'Cão 2026\LAVADO BRONCOALVEOLAR Labvet 2026.xlsx'),
  ('ML2026-041', '46', 'Cão', NULL, 'LC_LIQUIDO_CAVITARIO_CÃO - Labvet 2026', NULL, 'Cão 2026\LC_LIQUIDO_CAVITARIO_CÃO - Labvet 2026.xlsx'),
  ('ML2026-042', '42', 'Cão', NULL, 'PONTA_ORELHA_CÃO - Labvet 2026', NULL, 'Cão 2026\PONTA_ORELHA_CÃO - Labvet 2026.xlsx'),
  ('ML2026-043', '50', 'Cão', NULL, 'T4_CÃO - Labvet 2026', NULL, 'Cão 2026\T4_CÃO - Labvet 2026.xlsx'),
  ('ML2026-044', '43', 'Cão', NULL, 'TESTE DE HEMOAGLUTINAÇÃO EM SALINA - Labvet 2026', NULL, 'Cão 2026\TESTE DE HEMOAGLUTINAÇÃO EM SALINA - Labvet 2026.xlsx'),
  ('ML2026-045', '49', 'Cão', NULL, 'TSH_CÃO - Labvet 2026', NULL, 'Cão 2026\TSH_CÃO - Labvet 2026.xlsx'),
  ('ML2026-046', '35', 'Cão', NULL, 'U_EAS+CR+UR URI_Cão - Labvet 2026', NULL, 'Cão 2026\U_EAS+CR+UR URI_Cão - Labvet 2026.xlsx'),
  ('ML2026-047', '34', 'Cão', NULL, 'U_EAS_Cão - Labvet 2026', NULL, 'Cão 2026\U_EAS_Cão - Labvet 2026.xlsx'),
  ('ML2026-048', '11', 'Equinos', NULL, '3593_26B', '24 ano', 'Equinos 2026\3593_26B.xlsx'),
  ('ML2026-049', '11', 'Equinos', NULL, 'B_AVESSO_EQ - Labvet', NULL, 'Equinos 2026\B_AVESSO_EQ - Labvet.xlsx'),
  ('ML2026-050', '11', 'Equinos', NULL, 'B_Checkup (11)__Eq 2026', NULL, 'Equinos 2026\B_Checkup (11)__Eq 2026.xlsx'),
  ('ML2026-051', '11', 'Equinos', NULL, 'B_CHECKUP_EQ - Labvet 2026', NULL, 'Equinos 2026\B_CHECKUP_EQ - Labvet 2026.xlsx'),
  ('ML2026-052', '11', 'Equinos', NULL, 'B_CHECKUP_MUAR - Labvet 2026', NULL, 'Equinos 2026\B_CHECKUP_MUAR - Labvet 2026.xlsx'),
  ('ML2026-053', '44/45', 'Equinos', NULL, 'COMPATIBILIDADE_EQ - Labvet 2026', NULL, 'Equinos 2026\COMPATIBILIDADE_EQ - Labvet 2026.xlsx'),
  ('ML2026-054', '42', 'Equinos', NULL, 'ESFREG_PONTA DE ORELHA_EQ - Labvet 2026', NULL, 'Equinos 2026\ESFREG_PONTA DE ORELHA_EQ - Labvet 2026.xlsx'),
  ('ML2026-055', '4', 'Equinos', NULL, 'HEM_EQUI_Ad - Labvet 2026', NULL, 'Equinos 2026\HEM_EQUI_Ad - Labvet 2026.xlsx'),
  ('ML2026-056', '4', 'Equinos', NULL, 'HEM_MUAR_Ad - Labvet 2026', NULL, 'Equinos 2026\HEM_MUAR_Ad - Labvet 2026.xlsx'),
  ('ML2026-057', '34', 'Equinos', NULL, 'U_EAS_EQ - Labvet 2026', NULL, 'Equinos 2026\U_EAS_EQ - Labvet 2026.xlsx'),
  ('ML2026-058', '35', 'Equinos', NULL, 'U_EAS_EQ relação - Labvet 2026', NULL, 'Equinos 2026\U_EAS_EQ relação - Labvet 2026.xlsx'),
  ('ML2026-059', '7', 'Gato', NULL, 'B_AVESSO_FELINOS - labvet', NULL, 'Gato 2026\B_AVESSO_FELINOS - labvet.xlsx'),
  ('ML2026-060', '7', 'Gato', NULL, 'B_CHECK UP + COL + TRIG_FELINOS - labvet', NULL, 'Gato 2026\B_CHECK UP + COL + TRIG_FELINOS - labvet.xlsx'),
  ('ML2026-061', '7', 'Gato', NULL, 'B_CHECK UP + FOSF + COL + TRIG_FELINOS - labvet', NULL, 'Gato 2026\B_CHECK UP + FOSF + COL + TRIG_FELINOS - labvet.xlsx'),
  ('ML2026-062', '7', 'Gato', NULL, 'B_CHECK UP +GLICOSE + FOSF + COL + TRIG_FELINOS - labvet', NULL, 'Gato 2026\B_CHECK UP +GLICOSE + FOSF + COL + TRIG_FELINOS - labvet.xlsx'),
  ('ML2026-063', '7', 'Gato', NULL, 'B_CHECKUP+FOS+CA_FEL - Labvet', NULL, 'Gato 2026\B_CHECKUP+FOS+CA_FEL - Labvet.xlsx'),
  ('ML2026-064', '7', 'Gato', NULL, 'B_CHECKUP+FOS_FEL - Labvet', NULL, 'Gato 2026\B_CHECKUP+FOS_FEL - Labvet.xlsx'),
  ('ML2026-065', '7', 'Gato', NULL, 'B_CHECKUP_FEL - Labvet', NULL, 'Gato 2026\B_CHECKUP_FEL - Labvet.xlsx'),
  ('ML2026-066', '7', 'Gato', NULL, 'B_CHECKUP_FEL+BIL - Labvet', NULL, 'Gato 2026\B_CHECKUP_FEL+BIL - Labvet.xlsx'),
  ('ML2026-067', '8', 'Gato', NULL, 'B_HEP_FEL - Labvet', NULL, 'Gato 2026\B_HEP_FEL - Labvet.xlsx'),
  ('ML2026-068', '46', 'Gato', NULL, 'B_LIQ_CAV_FEL - Labvet', NULL, 'Gato 2026\B_LIQ_CAV_FEL - Labvet.xlsx'),
  ('ML2026-069', NULL, 'Gato', NULL, 'B_POP_FEL - Labvet', NULL, 'Gato 2026\B_POP_FEL - Labvet.xlsx'),
  ('ML2026-070', '10', 'Gato', NULL, 'B_RENAL_FEL - Labvet', NULL, 'Gato 2026\B_RENAL_FEL - Labvet.xlsx'),
  ('ML2026-071', '7', 'Gato', NULL, 'Bioquímica - Projeto Magda', NULL, 'Gato 2026\Bioquímica - Projeto Magda.xlsx'),
  ('ML2026-072', '47', 'Gato', NULL, 'CITOLOGIA_FEL - Labvet', NULL, 'Gato 2026\CITOLOGIA_FEL - Labvet.xlsx'),
  ('ML2026-073', '51', 'Gato', NULL, 'COAGU_Fel - Labvet', NULL, 'Gato 2026\COAGU_Fel - Labvet.xlsx'),
  ('ML2026-074', '51', 'Gato', NULL, 'COAGULOGRAMA_FEL-LABVET', NULL, 'Gato 2026\COAGULOGRAMA_FEL-LABVET.xlsx'),
  ('ML2026-075', '44/45', 'Gato', NULL, 'COMPATIBILIDADE_FEL - Labvet', NULL, 'Gato 2026\COMPATIBILIDADE_FEL - Labvet.xlsx'),
  ('ML2026-076', '1', 'Gato', NULL, 'HEM_FEL_Ad - Labvet 2024', NULL, 'Gato 2026\HEM_FEL_Ad - Labvet 2024.xlsx'),
  ('ML2026-077', '3', 'Gato', NULL, 'HEM_FEL_Ad - RETICULOCITOS - Labvet 2024', NULL, 'Gato 2026\HEM_FEL_Ad - RETICULOCITOS - Labvet 2024.xlsx'),
  ('ML2026-078', '1', 'Gato', NULL, 'HEM_FEL_filhote - Labvet 2024', 'filhote', 'Gato 2026\HEM_FEL_filhote - Labvet 2024.xlsx'),
  ('ML2026-079', '3', 'Gato', NULL, 'HEM_FEL_filhote - RETICULOCITOS - AMA - Labvet 2024', 'filhote', 'Gato 2026\HEM_FEL_filhote - RETICULOCITOS - AMA - Labvet 2024.xlsx'),
  ('ML2026-080', '3', 'Gato', NULL, 'HEM_FEL_filhote - RETICULOCITOS - Labvet 2024', 'filhote', 'Gato 2026\HEM_FEL_filhote - RETICULOCITOS - Labvet 2024.xlsx'),
  ('ML2026-081', '36', 'Gato', NULL, 'IMUNO_FEL- Labvet', NULL, 'Gato 2026\IMUNO_FEL- Labvet.xlsx'),
  ('ML2026-082', NULL, 'Gato', NULL, 'IMUNO_LIPASE- FEL- Labvet', NULL, 'Gato 2026\IMUNO_LIPASE- FEL- Labvet.xlsx'),
  ('ML2026-083', '38', 'Gato', NULL, 'IMUNO_PARVO_CORONA - FEL - Labvet', NULL, 'Gato 2026\IMUNO_PARVO_CORONA - FEL - Labvet.xlsx'),
  ('ML2026-084', '46', 'Gato', NULL, 'LC_LIQUIDO_CAVITARIO_FELINO - Labvet', NULL, 'Gato 2026\LC_LIQUIDO_CAVITARIO_FELINO - Labvet.xlsx'),
  ('ML2026-085', '50', 'Gato', NULL, 'T4_FEL - Labvet', NULL, 'Gato 2026\T4_FEL - Labvet.xlsx'),
  ('ML2026-086', '43', 'Gato', NULL, 'Teste de Hemoaglutinação em Salina - Labvet', NULL, 'Gato 2026\Teste de Hemoaglutinação em Salina - Labvet.xlsx'),
  ('ML2026-087', '34', 'Gato', NULL, 'U_EAS_Felino - Labvet', NULL, 'Gato 2026\U_EAS_Felino - Labvet.xlsx'),
  ('ML2026-088', '35', 'Gato', NULL, 'U_EAS_RPC_Felino - Labvet', NULL, 'Gato 2026\U_EAS_RPC_Felino - Labvet.xlsx'),
  ('ML2026-089', '44/45', NULL, NULL, 'MODELO DE COMPATIBILIDADE COM 2 DOADORES PARA QUALQUER ESPECIE', NULL, 'MODELO DE COMPATIBILIDADE COM 2 DOADORES PARA QUALQUER ESPECIE.xlsx'),
  ('ML2026-090', '11', 'Ovino', NULL, 'B_AVESSO_BIOQUÍMICA_OVINO - Labvet 2026', NULL, 'Ovino 2026\B_AVESSO_BIOQUÍMICA_OVINO - Labvet 2026.xlsx'),
  ('ML2026-091', '11', 'Ovino', NULL, 'B_CHECKUP_OVI - Labvet 2026', NULL, 'Ovino 2026\B_CHECKUP_OVI - Labvet 2026.xlsx'),
  ('ML2026-092', '4', 'Ovino', NULL, 'HEM_OVI_Ad - Labvet 2026', NULL, 'Ovino 2026\HEM_OVI_Ad - Labvet 2026.xlsx'),
  ('ML2026-093', '34', 'Ovino', NULL, 'U_EAS_OVINO - Labvet 2026', NULL, 'Ovino 2026\U_EAS_OVINO - Labvet 2026.xlsx'),
  ('ML2026-094', '5', 'Aves', 'Silvestres', 'Agapornis - HEMOGRAMA 2026', NULL, 'Silvestres 2026\Aves\Agapornis - HEMOGRAMA 2026.xlsx'),
  ('ML2026-095', '11', 'Aves', 'Silvestres', 'CALOPSITA - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\CALOPSITA - BIOQ Labvet 2026.xlsx'),
  ('ML2026-096', '5', 'Aves', 'Silvestres', 'CALOPSITA - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\CALOPSITA - HEM Labvet 2026.xlsx'),
  ('ML2026-097', '11', 'Aves', 'Silvestres', 'CISNE NEGRO - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\CISNE NEGRO - BIOQ Labvet 2026.xlsx'),
  ('ML2026-098', '5', 'Aves', 'Silvestres', 'CISNE NEGRO - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\CISNE NEGRO - HEM Labvet 2026.xlsx'),
  ('ML2026-099', '5', 'Aves', 'Silvestres', 'Coruja Orelhuda - HEMOGRAMA 2026', NULL, 'Silvestres 2026\Aves\Coruja Orelhuda - HEMOGRAMA 2026.xlsx'),
  ('ML2026-100', '11', 'Aves', 'Silvestres', 'GALO DOMÉSTICO - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\GALO DOMÉSTICO - BIOQ Labvet 2026.xlsx'),
  ('ML2026-101', '5', 'Aves', 'Silvestres', 'GALO DOMÉSTICO - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\GALO DOMÉSTICO - HEM Labvet 2026.xlsx'),
  ('ML2026-102', '11', 'Aves', 'Silvestres', 'GANSO BRAVO - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\GANSO BRAVO - BIOQ Labvet 2026.xlsx'),
  ('ML2026-103', '5', 'Aves', 'Silvestres', 'GANSO BRAVO - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\GANSO BRAVO - HEM Labvet 2026.xlsx'),
  ('ML2026-104', '11', 'Aves', 'Silvestres', 'GARÇA BRANCA - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\GARÇA BRANCA - BIOQ Labvet 2026.xlsx'),
  ('ML2026-105', '5', 'Aves', 'Silvestres', 'GARÇA BRANCA - Hem Labvet 2026', NULL, 'Silvestres 2026\Aves\GARÇA BRANCA - Hem Labvet 2026.xlsx'),
  ('ML2026-106', '11', 'Aves', 'Silvestres', 'GARÇA VAQUEIRA - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\GARÇA VAQUEIRA - BIOQ Labvet 2026.xlsx'),
  ('ML2026-107', '5', 'Aves', 'Silvestres', 'GARÇA VAQUEIRA - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\GARÇA VAQUEIRA - HEM Labvet 2026.xlsx'),
  ('ML2026-108', '11', 'Aves', 'Silvestres', 'POMBO COMUM - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\POMBO COMUM - BIOQ Labvet 2026.xlsx'),
  ('ML2026-109', '5', 'Aves', 'Silvestres', 'POMBO COMUM - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\POMBO COMUM - HEM Labvet 2026.xlsx'),
  ('ML2026-110', '11', 'Aves', 'Silvestres', 'TUCANO TOCO - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Aves\TUCANO TOCO - BIOQ Labvet 2026.xlsx'),
  ('ML2026-111', '5', 'Aves', 'Silvestres', 'TUCANO TOCO - HEM Labvet 2026', NULL, 'Silvestres 2026\Aves\TUCANO TOCO - HEM Labvet 2026.xlsx'),
  ('ML2026-112', '11', 'Mamíferos', 'Silvestres', 'ANTA_B', '2 ano', 'Silvestres 2026\Mamíferos\ANTA_B.xlsx'),
  ('ML2026-113', '5', 'Mamíferos', 'Silvestres', 'ANTA_H', NULL, 'Silvestres 2026\Mamíferos\ANTA_H.xlsx'),
  ('ML2026-114', '11', 'Mamíferos', 'Silvestres', 'BUGIO (Alouata guariba) BIOQ - Labvet 2025', NULL, 'Silvestres 2026\Mamíferos\BUGIO (Alouata guariba) BIOQ - Labvet 2025.xlsx'),
  ('ML2026-115', '5', 'Mamíferos', 'Silvestres', 'BUGIO (Alouata guariba) HEM - Labvet 2025', NULL, 'Silvestres 2026\Mamíferos\BUGIO (Alouata guariba) HEM - Labvet 2025.xlsx'),
  ('ML2026-116', '5', 'Mamíferos', 'Silvestres', 'CACHORRO-DO-MATO - HEM Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\CACHORRO-DO-MATO - HEM Labvet 2026.xlsx'),
  ('ML2026-117', '11', 'Mamíferos', 'Silvestres', 'CACHORRO-DO-MATO- BIOQ 2026', NULL, 'Silvestres 2026\Mamíferos\CACHORRO-DO-MATO- BIOQ 2026.xlsx'),
  ('ML2026-118', '11', 'Mamíferos', 'Silvestres', 'CATETO BIOQUIMICA', '1 ano', 'Silvestres 2026\Mamíferos\CATETO BIOQUIMICA.xlsx'),
  ('ML2026-119', '5', 'Mamíferos', 'Silvestres', 'CATETO HEMOGRAMA', NULL, 'Silvestres 2026\Mamíferos\CATETO HEMOGRAMA.xlsx'),
  ('ML2026-120', '11', 'Mamíferos', 'Silvestres', 'COELHO - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\COELHO - BIOQ Labvet 2026.xlsx'),
  ('ML2026-121', '5', 'Mamíferos', 'Silvestres', 'COELHO - HEM Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\COELHO - HEM Labvet 2026.xlsx'),
  ('ML2026-122', '35', 'Mamíferos', 'Silvestres', 'COELHO - URI+REL Labvet', NULL, 'Silvestres 2026\Mamíferos\COELHO - URI+REL Labvet.xlsx'),
  ('ML2026-123', '11', 'Mamíferos', 'Silvestres', 'GAMBÁ - BIOQ Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\GAMBÁ - BIOQ Labvet 2024.xlsx'),
  ('ML2026-124', '5', 'Mamíferos', 'Silvestres', 'GAMBÁ - HEM Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\GAMBÁ - HEM Labvet 2024.xlsx'),
  ('ML2026-125', '5', 'Mamíferos', 'Silvestres', 'HEDGEHOG - HEM Labvet 2025', NULL, 'Silvestres 2026\Mamíferos\HEDGEHOG - HEM Labvet 2025.xlsx'),
  ('ML2026-126', '5', 'Mamíferos', 'Silvestres', 'HEM_RATO_TWISTER - Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\HEM_RATO_TWISTER - Labvet 2024.xlsx'),
  ('ML2026-127', '11', 'Mamíferos', 'Silvestres', 'IRARA_BIOQ - Labvet', NULL, 'Silvestres 2026\Mamíferos\IRARA_BIOQ - Labvet.xlsx'),
  ('ML2026-128', '5', 'Mamíferos', 'Silvestres', 'IRARA_HEM - Labvet', NULL, 'Silvestres 2026\Mamíferos\IRARA_HEM - Labvet.xlsx'),
  ('ML2026-129', '11', 'Mamíferos', 'Silvestres', 'MACACO JAPONÊS - BIOQ Labvet 2025', NULL, 'Silvestres 2026\Mamíferos\MACACO JAPONÊS - BIOQ Labvet 2025.xlsx'),
  ('ML2026-130', '5', 'Mamíferos', 'Silvestres', 'MACACO JAPONÊS - HEMOG Labvet 2025', NULL, 'Silvestres 2026\Mamíferos\MACACO JAPONÊS - HEMOG Labvet 2025.xlsx'),
  ('ML2026-131', '5', 'Mamíferos', 'Silvestres', 'MACACO PREGO - HEM Labvet 2026 (atualizado)', NULL, 'Silvestres 2026\Mamíferos\MACACO PREGO - HEM Labvet 2026 (atualizado).xlsx'),
  ('ML2026-132', '11', 'Mamíferos', 'Silvestres', 'MACACO-PREGO- BIOQ Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\MACACO-PREGO- BIOQ Labvet 2026.xlsx'),
  ('ML2026-133', '11', 'Mamíferos', 'Silvestres', 'MÃO PELADA - BIOQ Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\MÃO PELADA - BIOQ Labvet 2024.xlsx'),
  ('ML2026-134', '5', 'Mamíferos', 'Silvestres', 'MÃO PELADA - HEM Labvet 2024', '2 ano', 'Silvestres 2026\Mamíferos\MÃO PELADA - HEM Labvet 2024.xlsx'),
  ('ML2026-135', '11', 'Mamíferos', 'Silvestres', 'OURIÇO CACHEIRO - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\OURIÇO CACHEIRO - BIOQ Labvet 2026.xlsx'),
  ('ML2026-136', '5', 'Mamíferos', 'Silvestres', 'OURIÇO CACHEIRO - HEM Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\OURIÇO CACHEIRO - HEM Labvet 2026.xlsx'),
  ('ML2026-137', '11', 'Mamíferos', 'Silvestres', 'PACA BIOQ - Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\PACA BIOQ - Labvet 2026.xlsx'),
  ('ML2026-138', '5', 'Mamíferos', 'Silvestres', 'PACA HEMOGRAMA - Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\PACA HEMOGRAMA - Labvet 2026.xlsx'),
  ('ML2026-139', '11', 'Mamíferos', 'Silvestres', 'PORQUINHO-INDIA BIOQ Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\PORQUINHO-INDIA BIOQ Labvet 2024.xlsx'),
  ('ML2026-140', '5', 'Mamíferos', 'Silvestres', 'PORQUINHO-INDIA-HEM Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\PORQUINHO-INDIA-HEM Labvet 2024.xlsx'),
  ('ML2026-141', '11', 'Mamíferos', 'Silvestres', 'PREGUIÇA COMUM - BIOQUIMICA', '5 ano', 'Silvestres 2026\Mamíferos\PREGUIÇA COMUM - BIOQUIMICA.xlsx'),
  ('ML2026-142', '5', 'Mamíferos', 'Silvestres', 'PREGUIÇA COMUM - HEMOGRAMA', '5 ano', 'Silvestres 2026\Mamíferos\PREGUIÇA COMUM - HEMOGRAMA.xlsx'),
  ('ML2026-143', '11', 'Mamíferos', 'Silvestres', 'QUATI - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\QUATI - BIOQ Labvet 2026.xlsx'),
  ('ML2026-144', '5', 'Mamíferos', 'Silvestres', 'QUATI - HEM Labvet 2026', NULL, 'Silvestres 2026\Mamíferos\QUATI - HEM Labvet 2026.xlsx'),
  ('ML2026-145', '11', 'Mamíferos', 'Silvestres', 'TAMANDUA-MIRIM - BIOQ Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\TAMANDUA-MIRIM - BIOQ Labvet 2024.xlsx'),
  ('ML2026-146', '5', 'Mamíferos', 'Silvestres', 'TAMANDUA-MIRIM - HEM Labvet 2024', NULL, 'Silvestres 2026\Mamíferos\TAMANDUA-MIRIM - HEM Labvet 2024.xlsx'),
  ('ML2026-147', '5', 'Peixes', 'Silvestres', 'L. Caeruleus - HEM Labvet 2026', NULL, 'Silvestres 2026\Peixes\L. Caeruleus - HEM Labvet 2026.xlsx'),
  ('ML2026-148', '5', 'Peixes', 'Silvestres', 'Labidochromis Caeruleus', NULL, 'Silvestres 2026\Peixes\Labidochromis Caeruleus.xlsx'),
  ('ML2026-149', '11', 'Répteis', 'Silvestres', 'CORN SNAKE - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Répteis\CORN SNAKE - BIOQ Labvet 2026.xlsx'),
  ('ML2026-150', '5', 'Répteis', 'Silvestres', 'CORN SNAKE - HEM Labvet 2026', NULL, 'Silvestres 2026\Répteis\CORN SNAKE - HEM Labvet 2026.xlsx'),
  ('ML2026-151', '11', 'Répteis', 'Silvestres', 'JABUTI PIRANGA - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Répteis\JABUTI PIRANGA - BIOQ Labvet 2026.xlsx'),
  ('ML2026-152', '5', 'Répteis', 'Silvestres', 'JABUTI PIRANGA - HEM Labvet 2026', NULL, 'Silvestres 2026\Répteis\JABUTI PIRANGA - HEM Labvet 2026.xlsx'),
  ('ML2026-153', '11', 'Répteis', 'Silvestres', 'JIBOIA - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Répteis\JIBOIA - BIOQ Labvet 2026.xlsx'),
  ('ML2026-154', '5', 'Répteis', 'Silvestres', 'JIBOIA - HEM Labvet 2026', NULL, 'Silvestres 2026\Répteis\JIBOIA - HEM Labvet 2026.xlsx'),
  ('ML2026-155', '11', 'Répteis', 'Silvestres', 'TEIÚ - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Répteis\TEIÚ - BIOQ Labvet 2026.xlsx'),
  ('ML2026-156', '5', 'Répteis', 'Silvestres', 'TEIÚ - HEM Labvet 2026', NULL, 'Silvestres 2026\Répteis\TEIÚ - HEM Labvet 2026.xlsx'),
  ('ML2026-157', '11', 'Répteis', 'Silvestres', 'TIGRE D_ÁGUA - BIOQ Labvet 2026', NULL, 'Silvestres 2026\Répteis\TIGRE D_ÁGUA - BIOQ Labvet 2026.xlsx'),
  ('ML2026-158', '5', 'Répteis', 'Silvestres', 'TIGRE D_ÁGUA - HEM Labvet 2026', NULL, 'Silvestres 2026\Répteis\TIGRE D_ÁGUA - HEM Labvet 2026.xlsx'),
  ('ML2026-159', '11', 'Suino', NULL, 'AVESSO BIOQUÍMICA_SUI - Labvet 2026', NULL, 'Suino 2026\AVESSO BIOQUÍMICA_SUI - Labvet 2026.xlsx'),
  ('ML2026-160', '11', 'Suino', NULL, 'CHECK_UP_SUI - Labvet 2026', NULL, 'Suino 2026\CHECK_UP_SUI - Labvet 2026.xlsx'),
  ('ML2026-161', '4', 'Suino', NULL, 'HEM_SUINO_Ad - Labvet 2026', NULL, 'Suino 2026\HEM_SUINO_Ad - Labvet 2026.xlsx')
), resolvido AS (
  SELECT
    fonte.*,
    exame.idexame,
    tipo.idtipoanimal
  FROM fonte
  LEFT JOIN exames exame ON exame.cdexame = fonte.cdexame
  LEFT JOIN tiposanimais tipo
    ON tipo.nmtipoanimal = fonte.nmtipoanimal
   AND (
     (fonte.nmtipoanimalpai IS NULL AND tipo.idtipoanimalpai IS NULL)
     OR tipo.idtipoanimalpai = (
       SELECT pai.idtipoanimal
       FROM tiposanimais pai
       WHERE pai.nmtipoanimal = fonte.nmtipoanimalpai
         AND pai.idtipoanimalpai IS NULL
     )
   )
)
INSERT INTO modeloslaudos (
  idexame, idtipoanimal, cdmodelolaudo, nmmodelolaudo,
  dsfaixaidade, nmarquivoorigem, stativo
)
SELECT
  idexame, idtipoanimal, cdmodelolaudo, nmmodelolaudo,
  dsfaixaidade, nmarquivoorigem, true
FROM resolvido
ON CONFLICT (cdmodelolaudo) DO UPDATE
SET
  idexame = EXCLUDED.idexame,
  idtipoanimal = EXCLUDED.idtipoanimal,
  nmmodelolaudo = EXCLUDED.nmmodelolaudo,
  dsfaixaidade = EXCLUDED.dsfaixaidade,
  nmarquivoorigem = EXCLUDED.nmarquivoorigem,
  stativo = EXCLUDED.stativo,
  dhalteracao = CURRENT_TIMESTAMP;

DO $$
DECLARE
  quantidade INTEGER;
  semexame INTEGER;
BEGIN
  SELECT COUNT(*) INTO quantidade
  FROM modeloslaudos
  WHERE cdmodelolaudo LIKE 'ML2026-%';

  IF quantidade <> 161 THEN
    RAISE EXCEPTION 'Carga incompleta: esperados 161 modelos, encontrados %.', quantidade;
  END IF;

  SELECT COUNT(*) INTO semexame
  FROM modeloslaudos
  WHERE cdmodelolaudo LIKE 'ML2026-%'
    AND idexame IS NULL;

  IF semexame <> 4 THEN
    RAISE EXCEPTION 'Mapeamento de exames inconsistente: esperados 4 modelos pendentes, encontrados %.', semexame;
  END IF;
END;
$$;

COMMIT;
