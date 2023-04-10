-- ------------------------- --
-- --------- VIEWS --------- --
-- ------------------------- --
--
-- todos os registros de lancamento
--
CREATE VIEW Registros_Lancamento AS
SELECT Registro.Dia_Semana,
    Registro.Dia,
    Condominio.Nome AS Nome_Condominio,
    Medidor.Tipo,
    Medidor.Nome AS Nome_Medidor,
    Lancamento.Diario AS Consumo_Diario
FROM Lancamento,
    Registro,
    Medidor,
    Condominio
WHERE Lancamento.Registro_ID = Registro.ID
    AND Registro.Medidor_ID = Medidor.ID
    AND Medidor.Condo_ID = Condominio.ID
ORDER BY Registro.Dia,
    Condominio.Nome,
    Medidor.Tipo;
SELECT *
FROM Registros_Lancamento;
--
-- Resultado dos lancamentos de cada medidor
--
CREATE VIEW	Resultados_Medidor AS
SELECT m.Condo_ID,
    m.Nome,
    SUM(l.Diario) AS Acumulado,
    AVG(l.Diario) AS Media,
    MIN(l.Diario) AS Consumo_Min,
    MAX(l.Diario) AS Consumo_Max,
    MAX(l.Diario) - MIN(l.Diario) AS Amplitude
FROM Lancamento l
    JOIN Registro r ON l.Registro_ID = r.ID
    JOIN Medidor m ON r.Medidor_ID = m.ID
GROUP BY m.ID
ORDER BY m.Condo_ID;
SELECT *
FROM Resultados_Medidor;
--
-- Consulta de todos os medidores dos Condominios associados ao maior Grupo Admin
--
SELECT m.Condo_ID, m.Nome, SUM(l.Diario) AS Acumulado, AVG(l.Diario) AS Media,
MIN(l.Diario) AS Consumo_Min,
MAX(l.Diario) AS Consumo_Max,
MAX(l.Diario) - MIN(l.Diario) AS Amplitude
FROM Lancamento l
INNER JOIN Medidor m ON l.Medidor_ID = m.mdidr_id
INNER JOIN Condominio c ON m.Condo_ID = c.cond_id
WHERE c.Grupo_Admin_ID = (
  SELECT Grupo_Admin_ID
  FROM (
    SELECT Grupo_Admin_ID, COUNT(*) AS num_condos
    FROM Medidor
    GROUP BY Grupo_Admin_ID
    ORDER BY num_condos DESC
    LIMIT 1
  ) AS t
)
GROUP BY m.Condo_ID, m.Nome;
