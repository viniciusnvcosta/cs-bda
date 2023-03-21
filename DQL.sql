-- DQL - Equipe Metametrics - Avaliação 2 
--
-- lama@cesar.school - las@cesar.school - vnvc@cesar.school
--
-- As consultas realizadas são fiéis ao contexto diário da startup parceira GPC,
-- em que algumas já são implementadas na solução final

--------------------------------------------------------------------------------

--
-- Consulta de todos os Condomínios verificando a existência de um Grupo Administrativo
--
SELECT c.Nome, c.Endereco_CEP, c.CNPJ, COALESCE(ga.Nome, "Sem Grupo") AS Nome_GrupoAdmin
FROM Condominio c LEFT OUTER JOIN Grupo_Admin ga
ON c.Grupo_Admin_ID = ga.ID
ORDER BY Nome;

--
-- Consulta de todos os medidores associados aos Condomínios clientes
--
-- uso de LEFT OUTER JOIN caso um medidor não possua um Condomínio associado
SELECT Medidor.Nome, Medidor.Tipo, Condominio.Nome AS Condomino_Nome
FROM Medidor LEFT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
ORDER BY Condominio.Nome;

-- Consulta de todos os medidores dos Condomínios associados ao Grupo Administrativo "Meu Condomínio"
SELECT Medidor.Nome, Medidor.Tipo, Condominio.Nome AS Condomino_Nome
FROM Medidor LEFT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
WHERE Condominio.Nome = "Chapada Diamantina"
UNION
SELECT Medidor.Nome, Medidor.Tipo, Condominio.Nome AS Condomino_Nome
FROM Medidor LEFT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
WHERE Condominio.Nome = "Saint Marcus"

ORDER BY Condominio.Nome;


--
-- Contagem de todos os medidores por Condomínio
--
-- uso de RIGHT OUTER JOIN caso um Condomínio não possua medidores associados
SELECT Condominio.Nome AS Condomino_Nome, COUNT(Medidor.ID) AS Num_Medidores
FROM Medidor RIGHT OUTER JOIN Condominio ON Medidor.Condo_ID = Condominio.ID
GROUP BY Condominio.Nome ORDER BY Condominio.Nome;

--
-- Consulta de todos os registros de lançamento de Água no mês de Outubro
--
SELECT Medidor.ID AS ID_Medidor,
CONCAT(Registro.Dia_Semana, " ", DATE_FORMAT(Registro.Dia, '%m-%d')) AS Data_Registro,
Lancamento.Diario AS Consumo_Diario
FROM Lancamento, Registro, Agua INNER JOIN Medidor ON Agua.Medidor_ID = Medidor.ID
WHERE Lancamento.Registro_ID = Registro.ID AND Registro.Medidor_ID = Medidor.ID
AND Registro.Dia BETWEEN '2021-10-01' AND '2021-10-31'
ORDER BY Medidor.ID;

--
-- Consulta dos registros de lançamento do Condomínio "Saint Everton"
--
SELECT UPPER(Registro.Dia_Semana), Registro.Dia, Medidor.Tipo,
Medidor.Nome AS Nome_Medidor, Lancamento.Diario AS Consumo_Diario
FROM Lancamento, Registro, Medidor, Condominio
WHERE Lancamento.Registro_ID = Registro.ID AND Registro.Medidor_ID = Medidor.ID
AND Medidor.Condo_ID = Condominio.ID AND Condominio.Nome = "Saint Everton"
ORDER BY Registro.Dia, Condominio.Nome, Medidor.Tipo;

--
-- Resultados dos lançamentos de um medidor de Energia no mês de Outubro
--
SELECT m.Condo_ID, m.Nome, SUM(l.Diario) AS Acumulado, AVG(l.Diario) AS Media,
MIN(l.Diario) AS Consumo_Min, MAX(l.Diario) AS Consumo_Max, MAX(l.Diario)-MIN(l.Diario) AS Amplitude
FROM Lancamento l JOIN Registro r ON l.Registro_ID = r.ID
JOIN Medidor m ON r.Medidor_ID = m.ID
WHERE m.Tipo = "Energia" AND r.Dia BETWEEN '2021-10-01' AND '2021-10-31'
GROUP BY m.ID ORDER BY m.Condo_ID;

-- ------------------------- --
-- --------- VIEWS --------- --
-- ------------------------- --

--
-- todos os registros de lançamento
--
CREATE VIEW Registros_Lancamento AS
SELECT Registro.Dia_Semana, Registro.Dia, Condominio.Nome AS Nome_Condominio, Medidor.Tipo,
Medidor.Nome AS Nome_Medidor, Lancamento.Diario AS Consumo_Diario
FROM Lancamento, Registro, Medidor, Condominio
WHERE Lancamento.Registro_ID = Registro.ID AND Registro.Medidor_ID = Medidor.ID
AND Medidor.Condo_ID = Condominio.ID
ORDER BY Registro.Dia, Condominio.Nome, Medidor.Tipo;

SELECT * FROM Registros_Lancamento;

--
-- Resultado dos lançamentos de cada medidor
--
CREATE VIEW	Resultados_Medidor AS
SELECT m.Condo_ID, m.Nome, SUM(l.Diario) AS Acumulado, AVG(l.Diario) AS Media,
MIN(l.Diario) AS Consumo_Min, MAX(l.Diario) AS Consumo_Max, MAX(l.Diario)-MIN(l.Diario) AS Amplitude
FROM Lancamento l JOIN Registro r ON l.Registro_ID = r.ID
JOIN Medidor m ON r.Medidor_ID = m.ID
GROUP BY m.ID ORDER BY m.Condo_ID;

SELECT * FROM Resultados_Medidor;