-- DQL - Equipe Metametrics - Avalia��o 2 
--
-- lama@cesar.school - las@cesar.school - vnvc@cesar.school
--
-- As consultas realizadas s�o fi�is ao contexto di�rio da startup parceira GPC,
-- em que algumas j� s�o implementadas na solu��o final

--------------------------------------------------------------------------------

--
-- Consulta de todos os Condom�nios verificando a exist�ncia de um Grupo Administrativo
--
SELECT c.Nome, c.Endereco_CEP, c.CNPJ, COALESCE(ga.Nome, "Sem Grupo") AS Nome_GrupoAdmin
FROM Condominio c LEFT OUTER JOIN Grupo_Admin ga
ON c.Grupo_Admin_ID = ga.ID
ORDER BY Nome;

--
-- Consulta de todos os medidores associados aos Condom�nios clientes
--
-- uso de LEFT OUTER JOIN caso um medidor n�o possua um Condom�nio associado
SELECT Medidor.Nome, Medidor.Tipo, Condominio.Nome AS Condomino_Nome
FROM Medidor LEFT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
ORDER BY Condominio.Nome;

-- Consulta de todos os medidores dos Condom�nios associados ao Grupo Administrativo "Meu Condom�nio"
SELECT Medidor.Nome, Medidor.Tipo, Condominio.Nome AS Condomino_Nome
FROM Medidor LEFT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
WHERE Condominio.Nome = "Chapada Diamantina"
UNION
SELECT Medidor.Nome, Medidor.Tipo, Condominio.Nome AS Condomino_Nome
FROM Medidor LEFT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
WHERE Condominio.Nome = "Saint Marcus"

ORDER BY Condominio.Nome;


--
-- Contagem de todos os medidores por Condom�nio
--
-- uso de RIGHT OUTER JOIN caso um Condom�nio n�o possua medidores associados
SELECT Condominio.Nome AS Condomino_Nome, COUNT(Medidor.ID) AS Num_Medidores
FROM Medidor RIGHT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
GROUP BY Condominio.Nome ORDER BY Condominio.Nome;

--
-- Consulta de todos os registros de lan�amento de �gua no m�s de Outubro
--
SELECT Medidor.ID AS ID_Medidor,
CONCAT(Registro.Dia_Semana, " ", DATE_FORMAT(Registro.Dia, '%m-%d')) AS Data_Registro,
Lancamento.Diario AS Consumo_Diario
FROM Lancamento, Registro, Agua INNER JOIN Medidor ON Agua.Medidor_ID = Medidor.ID
WHERE Lancamento.Registro_ID = Registro.ID AND Registro.Medidor_ID = Medidor.ID
AND Registro.Dia BETWEEN '2021-10-01' AND '2021-10-31'
ORDER BY Medidor.ID;

--
-- Consulta dos registros de lan�amento do Condom�nio "Saint Everton"
--
SELECT UPPER(Registro.Dia_Semana), Registro.Dia, Medidor.Tipo,
Medidor.Nome AS Nome_Medidor, Lancamento.Diario AS Consumo_Diario
FROM Lancamento, Registro, Medidor, Condominio
WHERE Lancamento.Registro_ID = Registro.ID AND Registro.Medidor_ID = Medidor.ID
AND Medidor.Condo_ID = Condominio.ID AND Condominio.Nome = "Saint Everton"
ORDER BY Registro.Dia, Condominio.Nome, Medidor.Tipo;

--
-- Resultados dos lan�amentos de um medidor de Energia no m�s de Outubro
--
SELECT m.Condo_ID, m.Nome, SUM(l.Diario) AS Acumulado, AVG(l.Diario) AS Media,
MIN(l.Diario) AS Consumo_Min, MAX(l.Diario) AS Consumo_Max, MAX(l.Diario)-MIN(l.Diario) AS Amplitude
FROM Lancamento l JOIN Registro r ON l.Registro_ID = r.ID
JOIN Medidor m ON r.Medidor_ID = m.ID
WHERE m.Tipo = "Energia" AND r.Dia BETWEEN '2021-10-01' AND '2021-10-31'
GROUP BY m.ID ORDER BY m.Condo_ID;