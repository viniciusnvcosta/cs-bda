--
-- Verificar se o Condominio possui grupo Admin
--
CREATE FUNCTION has_admin_group(condo_id INT)
RETURNS BOOLEAN BEGIN
DECLARE admin_group_id INT;
SELECT Grupo_Admin_ID INTO admin_group_id
FROM Condominio
WHERE cond_id = condo_id;
IF admin_group_id IS NOT NULL THEN RETURN TRUE;
ELSE RETURN FALSE;
END IF;
END;
--
-- Projeção da próxima medida de um medidor
--
DELIMITER $$
CREATE FUNCTION predict_next_month(mdidr_id INT) RETURNS DECIMAL(10, 2) BEGIN
DECLARE total_sum DECIMAL(10, 2);
DECLARE total_count INT;
DECLARE x_avg DECIMAL(10, 2);
DECLARE y_avg DECIMAL(10, 2);
DECLARE slope DECIMAL(10, 2);
DECLARE y_intercept DECIMAL(10, 2);
DECLARE predicted_measurement DECIMAL(10, 2);
SELECT SUM(Diario),
    COUNT(*) INTO total_sum,
    total_count
FROM Lancamento
WHERE Medidor_ID = mdidr_id
    AND Data BETWEEN DATE_SUB(NOW(), INTERVAL 5 MONTH)
    AND NOW();
SELECT AVG(Data) INTO x_avg
FROM Lancamento
WHERE Medidor_ID = mdidr_id
    AND Data BETWEEN DATE_SUB(NOW(), INTERVAL 5 MONTH)
    AND NOW();
SELECT AVG(Diario) INTO y_avg
FROM Lancamento
WHERE Medidor_ID = mdidr_id
    AND Data BETWEEN DATE_SUB(NOW(), INTERVAL 5 MONTH)
    AND NOW();
SELECT (
        (total_count * SUM(Data * Diario)) - (SUM(Data) * total_sum)
    ) / (
        (total_count * SUM(Data * Data)) - (SUM(Data) * SUM(Data))
    ) INTO slope
FROM Lancamento
WHERE Medidor_ID = mdidr_id
    AND Data BETWEEN DATE_SUB(NOW(), INTERVAL 5 MONTH)
    AND NOW();
SELECT y_avg - (slope * x_avg) INTO y_intercept;
SELECT (
        slope * UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 1 MONTH)) + y_intercept
    ) INTO predicted_measurement;
RETURN predicted_measurement;
END $$
DELIMITER;