--
-- Consulta dos registros de lançamento de um Condomínio X
--
DELIMITER $$
CREATE PROCEDURE `condo_summary`(IN `cond_id` INT) BEGIN
SELECT m.Condo_ID,
    m.Nome,
    m.Tipo,
    SUM(l.Diario) AS Acumulado,
    AVG(l.Diario) AS Media,
    MIN(l.Diario) AS Consumo_Min,
    MAX(l.Diario) AS Consumo_Max,
    MAX(l.Diario) - MIN(l.Diario) AS Amplitude,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'SEG' THEN 1
        END
    ) AS SEG,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'TER' THEN 1
        END
    ) AS TER,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'QUA' THEN 1
        END
    ) AS QUA,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'QUI' THEN 1
        END
    ) AS QUI,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'SEX' THEN 1
        END
    ) AS SEX,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'SAB' THEN 1
        END
    ) AS SAB,
    COUNT(
        CASE
            WHEN r.Dia_Semana = 'DOM' THEN 1
        END
    ) AS DOM
FROM Lancamento l
    INNER JOIN Medidor m ON l.Medidor_ID = m.mdidr_id
    INNER JOIN Condominio c ON m.Condo_ID = c.cond_id
    INNER JOIN Registro r ON l.Registro_ID = r.reg_id
WHERE m.Condo_ID = cond_id
    AND r.`Dia` BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH)
    AND NOW()
GROUP BY m.Condo_ID,
    m.Nome,
    m.Tipo;
END $$ DELIMITER;

CALL condo_summary();

--
-- Consulta de Ranking de um condomínio X
--
DELIMITER $$
CREATE PROCEDURE `condo_meter_ranking`(INOUT `cond_id` INT, IN `meter_type` VARCHAR(50), OUT `error_message` VARCHAR(255))
condo_meter_ranking_label:
BEGIN

	DECLARE meter_id INT DEFAULT 0;
	DECLARE has_admin_group TINYINT DEFAULT 0;

	DECLARE projected_consumption FLOAT DEFAULT 0;
	DECLARE total_consumption FLOAT DEFAULT 0;

	DECLARE projected_difference FLOAT DEFAULT 0;
	DECLARE average_consumption FLOAT DEFAULT 0;

	DECLARE consumption_rank INT DEFAULT 0;
	DECLARE economy_rank INT DEFAULT 0;



	-- Check if the given condominium has an admin group
	SET	has_admin_group = has_admin_group(cond_id);

	-- If the condominium doesn't have an admin group, exit the procedure
	IF has_admin_group = 0 THEN
		SET error_message = "Condominium doesn't have an admin group";
        LEAVE condo_meter_ranking_label;
	END IF;

	-- Get the meter_id of the given meter type and condominium
	SELECT mdidr_id INTO meter_id
	FROM Medidor
	WHERE Condo_ID = cond_id
	    AND Tipo = meter_type;

	-- If no meter of the given type is found, exit the procedure
	IF meter_id = 0 THEN
		SET error_message = "Meter type not found for the given condominium";
        LEAVE condo_meter_ranking_label;
	END IF;

	-- Calculate the projected consumption for the next month using the predict_next_monthly_measurement function
	SET projected_consumption = predict_next_monthly_measurement(meter_id);

	-- Calculate the total consumption of the given meter type for the last month
	SELECT SUM(Diario) INTO total_consumption
	FROM Lancamento
	WHERE Medidor_ID = meter_id
	    AND Dia >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

	-- Calculate the average consumption of the given meter type for the last month
	SELECT AVG(Diario) INTO average_consumption
	FROM Lancamento
	WHERE Medidor_ID = meter_id
	    AND Dia >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

	-- Calculate the percent difference between the projected consumption and the average consumption
	SET projected_difference = (
	        (projected_consumption - average_consumption) / average_consumption
	    ) * 100;

	-- Get the ranking of the given condominium based on the total consumption of the given meter type for the last month
	SELECT COUNT(*) + 1 INTO consumption_rank
	FROM (
	        SELECT Condo_ID,
	            SUM(Diario) AS TotalConsumption
	        FROM Lancamento l
	            INNER JOIN Medidor m ON l.Medidor_ID = m.mdidr_id
	        WHERE m.Tipo = meter_type
	            AND l.Dia >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
	        GROUP BY Condo_ID
	        ORDER BY TotalConsumption DESC
	    ) AS ranked_condos
	WHERE Condo_ID = cond_id;

	-- Get the ranking of the given condominium based on the projected difference between the average consumption and the projected consumption
	SELECT COUNT(*) + 1 INTO economy_rank
	FROM (
	        SELECT Condo_ID,
	            (
	                (
	                    predict_next_monthly_measurement(m.mdidr_id) - AVG(l.Diario)
	                ) / AVG(l.Diario)
	            ) * 100 AS ProjectedDifference
	        FROM Lancamento l
	            INNER JOIN Medidor m ON l.Medidor_ID = m.mdidr_id
	        WHERE m.Tipo = meter_type
	            AND l.Dia >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
	        GROUP BY Condo_ID
	        ORDER BY ProjectedDifference ASC
	    ) AS ranked_condos
	WHERE Condo_ID = cond_id;

	-- Return the rankings for the given condominium and meter type
	SELECT cond_id AS CondominiumID,
	    meter_type AS MeterType,
	    consumption_rank AS ConsumptionRank,
	    economy_rank AS EconomyRank;
END $$
DELIMITER ;