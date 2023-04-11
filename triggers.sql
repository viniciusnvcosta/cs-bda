--
-- Atualizar as dimensões de Água, Energia e Gás ao inserir na tabela Medidores
--
DELIMITER $$
CREATE TRIGGER update_dimensoes_medidor
AFTER INSERT ON Medidores
FOR EACH ROW
BEGIN
    IF NEW.Tipo_Medidor = 'Agua' THEN
        INSERT INTO Agua (Cobranca, Unidade_Medidor, Medidor_ID)
        VALUES ('', '', NEW.id);
    END IF;
    IF NEW.Tipo_Medidor = 'Energia' THEN
        INSERT INTO Energia (Classificacao, Medidor_ID)
        VALUES ('', NEW.id);
    END IF;
    IF NEW.Tipo_Medidor = 'Gas' THEN
        INSERT INTO Gas (Unidade_Medidor, Tanques, Medidor_ID)
        VALUES ('', 0, NEW.id);
    END IF;
END $$
DELIMITER ;

--
-- Verificar se um condomínio teve um consumo elevado em comparação aos outros dias do mês
--
DELIMITER $$
CREATE TRIGGER lancamento_before_insert
BEFORE INSERT ON Lancamento
FOR EACH ROW
BEGIN
    DECLARE iqr DECIMAL(10,2);
    DECLARE median DECIMAL(10,2);
    DECLARE q1 DECIMAL(10,2);
    DECLARE q3 DECIMAL(10,2);
    DECLARE consumption DECIMAL(10,2);
    DECLARE month_start DATE;
    DECLARE month_end DATE;
    SELECT MIN(r.Dia) INTO month_start FROM Registro WHERE Medidor_ID = NEW.Medidor_ID;
    SELECT MAX(r.Dia) INTO month_end FROM Registro WHERE Medidor_ID = NEW.Medidor_ID;
    SELECT (MAX(Diario) - MIN(Diario)) * 0.75 INTO iqr FROM Lancamento
        JOIN Registro r ON Lancamento.Medidor_ID = Registro.Medidor_ID
        WHERE Lancamento.Medidor_ID = NEW.Medidor_ID AND Lancamento.Dia BETWEEN month_start AND month_end;
    SELECT (MAX(Diario) + MIN(Diario)) / 2 INTO median FROM Lancamento
        JOIN Registro ON Lancamento.Medidor_ID = Registro.Medidor_ID
        WHERE Lancamento.Medidor_ID = NEW.Medidor_ID AND Lancamento.Dia BETWEEN month_start AND month_end;
    SELECT Diario INTO consumption FROM Lancamento
        JOIN Registro ON Lancamento.Medidor_ID = Registro.Medidor_ID
        WHERE Lancamento.Medidor_ID = NEW.Medidor_ID AND Lancamento.Dia = NEW.Dia;
    SELECT MIN(Diario) INTO q1 FROM Lancamento
        JOIN Registro ON Lancamento.Medidor_ID = Registro.Medidor_ID
        WHERE Lancamento.Medidor_ID = NEW.Medidor_ID AND Lancamento.Dia BETWEEN month_start AND month_end AND Diario >= median - iqr;
    SELECT MAX(Diario) INTO q3 FROM Lancamento
        JOIN Registro ON Lancamento.Medidor_ID = Registro.Medidor_ID
        WHERE Lancamento.Medidor_ID = NEW.Medidor_ID AND Lancamento.Dia BETWEEN month_start AND month_end AND Diario <= median + iqr;
    IF consumption < q1 OR consumption > q3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Medida de consumo invalida, verifique o valor e tente novamente';
    END IF;
END $$
DELIMITER ;
