-- Labvet V1 — carga inicial do catálogo de exames.
-- Fonte: Catálogo Exames I.jpg e Catálogo Exames II.jpg.
-- Este script não deve inferir a composição dos pacotes.

BEGIN;

SET search_path TO labvet, public;

INSERT INTO examecategorias (nmcategoria, stativo)
VALUES
  ('Bioquímico', true),
  ('Hematologia', true),
  ('Urinálise', true),
  ('Outros Exames', true),
  ('Imunológico', true),
  ('Parasitológico', true),
  ('Pacotes', true),
  ('Hormonal', true),
  ('Citologia', true),
  ('Outros', true)
ON CONFLICT (nmcategoria) DO UPDATE
SET stativo = EXCLUDED.stativo;

WITH fonte (nmcategoria, cdexame, nmexame, qttotalexames, vlexame, stprimario) AS (
  VALUES
    -- Bioquímico
    ('Bioquímico', '16', 'Albumina', 1, 7.00, true),
    ('Bioquímico', '17', 'AST (TGO)', 1, 7.00, true),
    ('Bioquímico', '18', 'ALT (TGP)', 1, 7.00, true),
    ('Bioquímico', '19', 'Bilirrubina Total/Frações', 2, 14.00, true),
    ('Bioquímico', '20', 'Cálcio Total', 1, 7.00, true),
    ('Bioquímico', '21', 'Colesterol Total', 1, 7.00, true),
    ('Bioquímico', '22', 'Creatinina', 1, 7.00, true),
    ('Bioquímico', '23', 'Creatinoquinase (CK)', 1, 7.00, true),
    ('Bioquímico', '24', 'Fósforo', 1, 7.00, true),
    ('Bioquímico', '25', 'Fosfatase Alcalina', 1, 7.00, true),
    ('Bioquímico', '26', 'Gama GT', 1, 7.00, true),
    ('Bioquímico', '27', 'Glicose', 1, 7.00, true),
    ('Bioquímico', '28', 'LDH', 1, 7.00, true),
    ('Bioquímico', '29', 'Proteínas Totais', 1, 7.00, true),
    ('Bioquímico', '30', 'Proteínas Totais/Frações', 2, 7.00, true),
    ('Bioquímico', '31', 'Triglicerídeos', 1, 14.00, true),
    ('Bioquímico', '32', 'Uréia', 1, 7.00, true),
    ('Bioquímico', '33', 'Ácido Úrico', 1, 7.00, true),

    -- Hematologia
    ('Hematologia', '1', 'Hemograma I (Erit., Leuc., cont. plaq., PPT total)', 1, 20.00, true),
    ('Hematologia', '2', 'Hemograma II (Hemog. I + Pesq. capa leucocitária)', 2, 30.00, true),
    ('Hematologia', '3', 'Hemograma III (Hemog. I + cont. de reticulócitos)', 2, 30.00, true),
    ('Hematologia', '4', 'Hemograma Grandes Animais (Hemog. I + fibrinog.)', 2, 20.00, true),
    ('Hematologia', '5', 'Hemog. Selvagens (Erit., Leuc., plaq., PPT total)', 1, 30.00, true),

    -- Urinálise
    ('Urinálise', '34', 'EAS', 1, 20.00, true),
    ('Urinálise', '35', 'EAS + Relação Proteína / Creatinina Urinária', 3, 35.00, true),

    -- Outros Exames
    ('Outros Exames', '43', 'Teste de Hemoaglutinação em salina', 1, 10.00, true),
    ('Outros Exames', '44/45', 'Teste de Compatibilidade Sanguínea', 2, 50.00, true),
    ('Outros Exames', '46', 'Análise Líquido Cavitário', 1, 30.00, true),
    ('Outros Exames', '51', 'Coagulograma (TP/TTPA)', 1, 60.00, true),

    -- Imunológico
    ('Imunológico', '36', 'FIV/FeLV (plasma, soro)', 1, 135.00, true),
    ('Imunológico', '37', '4 DX Plus (plasma, soro)', 1, 135.00, true),
    ('Imunológico', '38', 'Parvovírus + Coronavírus (Antígeno)', 1, 45.00, true),
    ('Imunológico', '39', 'Dirofilária (Antígeno)', 1, 35.00, true),
    ('Imunológico', '40', 'Cinomose (Antígeno)', 1, 45.00, true),

    -- Parasitológico
    ('Parasitológico', '41', 'Técnica de Knott modificada (microfilárias)', 1, 15.00, true),
    ('Parasitológico', '42', 'Pesq. Hemoparasitos (esfregaço de ponta de orelha)', 1, 10.00, true),

    -- Pacotes: composição ainda não recebida
    ('Pacotes', '6', 'Rotina', 5, 50.00, false),
    ('Pacotes', '7', 'Check Up Pequenos Animais', 9, 75.00, false),
    ('Pacotes', '8', 'Hepático', 11, 90.00, false),
    ('Pacotes', '9', 'Pré-Operatório', 6, 55.00, false),
    ('Pacotes', '10', 'Renal I', 4, 40.00, false),
    ('Pacotes', '11', 'Check Up Grandes Animais', 10, 90.00, false),

    -- Hormonal e Citologia
    ('Hormonal', '48', 'Cortisol', 1, 45.00, true),
    ('Hormonal', '49', 'TSH', 1, 50.00, true),
    ('Hormonal', '50', 'T4 total', 1, 50.00, true),
    ('Citologia', '47', 'Citologia', 1, 30.00, true),

    -- Outros
    ('Outros', '52', 'Check up AMA', 5, NULL, false),
    ('Outros', '53', 'Pré-operatório AMA', 7, NULL, false)
)
INSERT INTO exames (
  idexamecategoria,
  cdexame,
  nmexame,
  qttotalexames,
  vlexame,
  stprimario,
  stativo
)
SELECT
  categoria.idexamecategoria,
  fonte.cdexame,
  fonte.nmexame,
  fonte.qttotalexames,
  fonte.vlexame,
  fonte.stprimario,
  true
FROM fonte
JOIN examecategorias categoria ON categoria.nmcategoria = fonte.nmcategoria
ON CONFLICT (cdexame) DO UPDATE
SET
  idexamecategoria = EXCLUDED.idexamecategoria,
  nmexame = EXCLUDED.nmexame,
  qttotalexames = EXCLUDED.qttotalexames,
  vlexame = EXCLUDED.vlexame,
  stprimario = EXCLUDED.stprimario,
  stativo = EXCLUDED.stativo,
  dhalteracao = CURRENT_TIMESTAMP;

-- "Hemograma Doador Sangue" não entrou na carga: o catálogo não informa
-- código nem total de exames. O cadastro deve aguardar essa confirmação.

COMMIT;
