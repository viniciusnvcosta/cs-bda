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
    DECLARE average_consumption FLOAT DEFAULT 0;
    DECLARE total_consumption FLOAT DEFAULT 0;
    DECLARE projected_consumption FLOAT DEFAULT 0;
    DECLARE projected_difference FLOAT DEFAULT 0;
    DECLARE consumption_rank INT DEFAULT 0;
    DECLARE economy_rank INT DEFAULT 0;

    -- Checar se o condominio possui grupo admin
    SET	has_admin_group = has_admin_group(cond_id);

    -- Se o condominio nao possui grupo admin, sair da procedure
    IF has_admin_group = 0 THEN
        SET error_message = "Condominio nao possui grupo administrativo";
        LEAVE condo_meter_ranking_label;
    END IF;

    -- Consulta o id do medidor do tipo informado e do condominio informado
    SELECT mdidr_id INTO meter_id
    FROM Medidor
    WHERE Condo_ID = cond_id
        AND Tipo = meter_type;

    -- Se nao encontrar nenhum medidor do tipo informado, sair da procedure
    IF meter_id = 0 THEN
        SET error_message = "Tipo de medidor nao encontrado para o condominio escolhido";
        LEAVE condo_meter_ranking_label;
    END IF;

    -- Calcula o consumo projetado para o proximo mes usando a funcao predict_next_month
    SET projected_consumption = predict_next_month(meter_id);

    -- Calcula o consumo total do medidor informado para o ultimo mes
    SELECT SUM(Diario) INTO total_consumption
    FROM Lancamento l
    WHERE Medidor_ID = meter_id
        AND l.Dia >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

    -- Calcula o consumo medio do medidor informado para o ultimo mes
    SELECT AVG(Diario) INTO average_consumption
    FROM Lancamento
    WHERE Medidor_ID = meter_id
        AND l.Dia >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

    -- Calcula a diferenca percentual entre o consumo projetado e o consumo medio
    SET projected_difference = (
            (projected_consumption - average_consumption) / average_consumption
        ) * 100;

    -- * Ranking de consumo
    -- Consulta o ranking do condominio informado baseado no consumo total do medidor informado para o ultimo mes
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

    -- * Ranking de economia
    -- Consulta o ranking do condominio informado baseado na diferenca percentual entre o consumo projetado e o consumo medio
    SELECT COUNT(*) + 1 INTO economy_rank
    FROM (
            SELECT Condo_ID,
                (
                    (
                        predict_next_month(m.mdidr_id) - AVG(l.Diario)
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

    -- Retorna os rankings para o condominio informado e o tipo de medidor informado
    SELECT cond_id AS CondominiumID,
        meter_type AS MeterType,
        consumption_rank AS ConsumptionRank,
        economy_rank AS EconomyRank;
END $$
DELIMITER ;