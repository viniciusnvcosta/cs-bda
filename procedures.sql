--
-- Consulta dos registros de lançamento de um Condomínio X
--
DELIMITER $$
CREATE PROCEDURE `condo_summary`(IN `cond_id` INT)
BEGIN
  SELECT m.Condo_ID, m.Nome, m.Tipo, SUM(l.Diario) AS Acumulado, AVG(l.Diario) AS Media,
  MIN(l.Diario) AS Consumo_Min, MAX(l.Diario) AS Consumo_Max, MAX(l.Diario)-MIN(l.Diario) AS Amplitude,
    COUNT(CASE WHEN r.Dia_Semana = 'SEG' THEN 1 END) AS SEG,
    COUNT(CASE WHEN r.Dia_Semana = 'TER' THEN 1 END) AS TER,
    COUNT(CASE WHEN r.Dia_Semana = 'QUA' THEN 1 END) AS QUA,
    COUNT(CASE WHEN r.Dia_Semana = 'QUI' THEN 1 END) AS QUI,
    COUNT(CASE WHEN r.Dia_Semana = 'SEX' THEN 1 END) AS SEX,
    COUNT(CASE WHEN r.Dia_Semana = 'SAB' THEN 1 END) AS SAB,
    COUNT(CASE WHEN r.Dia_Semana = 'DOM' THEN 1 END) AS DOM
  FROM Lancamento l
  INNER JOIN Medidor m ON l.Medidor_ID = m.mdidr_id
  INNER JOIN Condominio c ON m.Condo_ID = c.cond_id
  INNER JOIN Registro r ON l.Registro_ID = r.reg_id
  WHERE m.Condo_ID = cond_id AND r.`Dia` BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW()
  GROUP BY m.Condo_ID, m.Nome, m.Tipo;
END$$
DELIMITER ;

CALL condo_summary();

--
-- Consulta de Ranking de um condomínio X
--