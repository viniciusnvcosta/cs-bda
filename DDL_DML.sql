--
-- Tabela Grupo Admin 1-1
--
CREATE TABLE Grupo_Admin(
	admin_id INT(10) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	Nome VARCHAR(15) NOT NULL,
	CNPJ VARCHAR(30) NOT NULL,
	Qtd_Condominios INT(10) NOT NULL,
	PRIMARY KEY (admin_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Grupo Admin
INSERT INTO Grupo_Admin (admin_id, Email, Nome, CNPJ, Qtd_Condominios)
  VALUES (724902, "meucondominio@recife.com", "Meu Condominio", "25.059.294/0001-58", 2);

--
-- Tabela Endereco 1-2
--
CREATE TABLE Endereco (
	CEP	VARCHAR(20) NOT NULL,
	Rua VARCHAR(50) NOT NULL,
	Numero INT(5) NOT NULL,
	Bairro VARCHAR(25)	NOT NULL,
	Cidade VARCHAR(25) NOT NULL,
	PRIMARY KEY (CEP)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Endereco
INSERT INTO Endereco (CEP, Rua, Numero, Bairro, Cidade)
  VALUES ("52110-471", "Travessa Avenca", 425, "Alto Jose do Pinho", "Recife"),
  ("53615-075", "Professor Clovis Lacerda Leite", 12, "Sitio dos Marcos", "Igarassu"), ("54100-249", "2a Travessa Capitao Luis Sabino", 112, "Centro", "Jaboatao dos Guararapes"),
  ("54330-820", "Rua Frei Felix Boter", 208, "Cajueiro Seco", "Jaboatao dos Guararapes"),
  ("50721-340", "Rua Rolandia", 39, "Cordeiro", "Recife"),
  ("50930-111", "Travessa Alto do Ceu", 315, "Coqueiral", "Recife"),
  ("52150-010", "Subida da Medalha Milagrosa", 112, "Dois Unidos", "Recife");

--
-- Tabela Condominio 2-1
--
CREATE TABLE Condominio(
	cond_id INT(10) NOT NULL,
 	Nome VARCHAR(25) NOT NULL,
	Endereco_CEP VARCHAR(20) NOT NULL,
	Qtd_medidores INT(10) NOT NULL,
	CNPJ VARCHAR(30) NOT NULL,
	Grupo_Admin_ID INT(10),
	PRIMARY KEY (cond_id),
	FOREIGN KEY (Endereco_CEP)
	REFERENCES Endereco (CEP),
	FOREIGN KEY (Grupo_Admin_ID)
	REFERENCES Grupo_Admin (admin_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Condominio
INSERT INTO Condominio (cond_id, Nome, Endereco_CEP, Qtd_medidores, CNPJ, Grupo_Admin_ID)
  VALUES (1, "Saint Marcus", "50721-340", 2, "51.455.725/0001-05", 724902),
	(2, "Saint Everton", "53615-075", 2, "66.167.406/0001-71", NULL),
	(3, "Chapada Diamantina", "54330-820", 2, "20.212.865/0009-10", 724902),
	(4, "Reserva Mondragon", "54100-249", 2, "34.125.565/0088-77", NULL),
	(5, "La Casa", "52150-010", 1, "35.266.556/0001-09", NULL),
	(6, "Edificio Lacarte", "50930-111", 3, "98.741.167/0001-08", NULL);

--
-- Tabela Medidor 3-1
--
CREATE TABLE Medidor (
	mdidr_id INT(10) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Tipo VARCHAR(15) NOT NULL,
	Condo_ID INT(20) NOT NULL,
  Fator_Correcao FLOAT(5),
	PRIMARY KEY (mdidr_id),
	FOREIGN KEY (Condo_ID)
	REFERENCES Condominio (cond_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Medidor
INSERT INTO Medidor (mdidr_id, Nome, Tipo, Condo_ID, Fator_Correcao)
  VALUES (753, "Concessionaria", "Agua", 2, NULL),
	(831, "Hidrometer Multijato", "Agua", 4, NULL),
	(829, "Medidor de gas Lao", "Gas", 3, NULL),
	(545, "Medidor de energia monofasico Nobrand", "Energia",  3, NULL),
	(441, "Medidor de energia monofasico Nobrand", "Energia", 2, NULL),
	(781, "Concessionaria", "Agua", 1, NULL),
	(789, "Medidor de energia D52 2047", "Energia", 4, NULL),
	(346, "Medidor de gas Daeflex", "Gas", 1, NULL),
	(299, "Hidrometro TR8703", "Agua", 5, NULL),
	(725, "Hidrometer Multijato", "Agua", 6, NULL),
	(536, "Medidor de energia monofasico Nobrand", "Energia", 6, NULL),
	(927, "Medidor de gas Daeflex", "Gas", 6, NULL);


--
-- Tabela Aparelho Movel 3-2
--
CREATE TABLE Aparelho_Movel(
	apmov_id INT(10) NOT NULL,
	Marca VARCHAR(15) NOT NULL,
	Modelo VARCHAR(25) NOT NULL,
	Condo_ID INT(10) NOT NULL,
	PRIMARY KEY (apmov_id),
	FOREIGN KEY (Condo_ID)
	REFERENCES Condominio (cond_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Aparelho Movel
INSERT INTO Aparelho_Movel (apmov_id, Marca, Modelo, Condo_ID)
  VALUES (78274, "LG", "K22", 2),
	(47389, "Samsung", "A015 Galaxy A01", 4),
	(83152, "Nokia", "C2", 6),
	(96462, "Multilaser", "E Lite", 4),
	(27458, "Motorola", "G8 Plus", 1),
	(63827, "Multilaser", "F Pro", 3),
	(82699, "Positivo", "Twist 4", 5);

--
-- Tabela Agua 4-1
--
CREATE TABLE Agua (
	hidr_id INT(11) NOT NULL,
	Cobranca VARCHAR(25),
	Unidade_Medidor VARCHAR(10),
	Medidor_ID INT(10) NOT NULL,
	PRIMARY KEY (hidr_id),
	FOREIGN KEY (Medidor_ID)
	REFERENCES Medidor (mdidr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Agua
INSERT INTO Agua (hidr_id, Cobranca, Unidade_Medidor, Medidor_ID)
  VALUES (1, "Entrada e Saida", "M100", 753),
  (2, "Entrada e Saida", "M100", 831),
	(3, "Entrada e Saida", "M100", 781),
  (4, "Entrada e Saida", "M100", 299),
	(5, "Entrada e Saida", "M100", 725);

--
-- Tabela Energia 4-2
--
CREATE TABLE Energia (
	relg_id INT(11) NOT NULL,
	Classificacao VARCHAR(20),
	Medidor_ID INT(10) NOT NULL,
	PRIMARY KEY (relg_id),
	FOREIGN KEY (Medidor_ID)
	REFERENCES Medidor (mdidr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Energia
INSERT INTO Energia (relg_id, Classificacao, Medidor_ID)
  VALUES (987224, "Residencial", 545),
  (864752, "Residencial", 441),
	(977264, "Residencial", 789),
  (714946, "Residencial", 536);

--
-- Tabela Gas 4-3
--
CREATE TABLE Gas (
	clndr_id INT(11) NOT NULL,
	Unidade_Medidor VARCHAR(20),
	Tanques INT(5),
	Medidor_ID INT(10) NOT NULL,
	PRIMARY KEY (clndr_id),
	FOREIGN KEY (Medidor_ID)
	REFERENCES Medidor (mdidr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Gas
INSERT INTO Gas (clndr_id, Unidade_Medidor, Tanques, Medidor_ID)
  VALUES (187, "Kg para m3", 3, 829), (652, "Kg para m3", 2, 346), (893, "Kg para m3", 2, 927);

--
-- Tabela Usuario 4-4
--
CREATE TABLE Usuario(
	Nome VARCHAR(25) NOT NULL,
	usr_id INT(10) NOT NULL,
	ID_Aparelho	INT(10) NOT NULL,
	Funcao VARCHAR(20)	NOT NULL,
	Turno VARCHAR(15) NOT NULL,
	PRIMARY KEY (usr_id),
	FOREIGN KEY (ID_Aparelho)
	REFERENCES Aparelho_Movel (apmov_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Usuario
INSERT INTO Usuario (Nome, usr_id, ID_Aparelho, Funcao, Turno)
  VALUES ("Rogerio", 63298, 78274, "Porteiro", "Manha"),
	("Angela", 92749, 96462, "Porteiro", "Noite"), ("Valdemir", 51748, 83152, "Zelador", "Integral"),
	("Carlos", 15386, 47389, "Zelador", "Integral"), ("Sonia", 92903, 27458, "Gerente", "Integral"),
	("Agatha", 28730, 63827, "Zelador", "Integral"), ("Jonas", 91882, 82699, "Zelador", "Integral");

--
-- Tabela Registro 5
--
CREATE TABLE Registro (
	reg_id	INT(10) NOT NULL,
	Dia DATE NOT NULL,
	Dia_Semana VARCHAR(4) NOT NULL,
	Medidor_ID INT(10) NOT NULL,
	PRIMARY KEY (reg_id),
	FOREIGN KEY (Medidor_ID)
	REFERENCES Medidor (mdidr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Registro
INSERT INTO Registro (reg_id, Dia, Dia_Semana, Medidor_ID)
  VALUES (001, "2021-10-02", "Qua", 753),
	(002, "2021-10-02", "Qua", 545),
	(003, "2021-10-02", "Qua", 829),
	(004, "2021-10-02", "Qua", 441),
	(005, "2021-10-02", "Qua", 781),
	(006, "2021-10-02", "Qua", 346),
	(007, "2021-10-02", "Qua", 299),
	(008, "2021-10-02", "Qua", 789),
	(009, "2021-10-02", "Qua", 725),
	(010, "2021-10-02", "Qua", 536),
	(011, "2021-10-02", "Qua", 927),
	(012, "2021-10-03", "Qui", 545),
	(013, "2021-10-03", "Qui", 753),
	(014, "2021-10-03", "Qui", 831),
	(015, "2021-10-03", "Qui", 441),
	(016, "2021-10-03", "Qui", 829),
	(017, "2021-10-03", "Qui", 781),
	(018, "2021-10-03", "Qui", 789),
	(019, "2021-10-03", "Qui", 346),
	(020, "2021-10-03", "Qui", 299),
	(021, "2021-10-03", "Qui", 927),
	(022, "2021-10-03", "Qui", 536),
	(023, "2021-10-03", "Qui", 725),
	(024, "2021-10-04", "Sex", 753),
	(025, "2021-10-04", "Sex", 441),
	(026, "2021-10-04", "Sex", 831),
	(027, "2021-10-04", "Sex", 346),
	(028, "2021-10-04", "Sex", 829),
	(029, "2021-10-04", "Sex", 545),
	(030, "2021-10-04", "Sex", 789),
	(031, "2021-10-04", "Sex", 725),
	(032, "2021-10-04", "Sex", 927),
	(033, "2021-10-04", "Sex", 299),
	(034, "2021-10-04", "Sex", 781),
	(035, "2021-10-04", "Sex", 536),
	(036, "2021-10-05", "Sab", 927),
	(037, "2021-10-05", "Sab", 299),
	(038, "2021-10-05", "Sab", 781),
	(039, "2021-10-05", "Sab", 346),
	(040, "2021-10-05", "Sab", 829),
	(041, "2021-10-05", "Sab", 545),
	(042, "2021-10-05", "Sab", 789),
	(043, "2021-10-05", "Sab", 536),
	(044, "2021-10-05", "Sab", 753),
	(045, "2021-10-05", "Sab", 441),
	(046, "2021-10-05", "Sab", 831),
	(047, "2021-10-05", "Sab", 725);

--
-- Tabela Lancamento 6-1
--
CREATE TABLE Lancamento (
	lanc_id	INT(10) NOT NULL,
	Diario FLOAT(5) NOT NULL,
	Registro_ID INT(10) NOT NULL,
	Medidor_ID INT(10) NOT NULL,
	PRIMARY KEY (lanc_id),
	FOREIGN KEY (Registro_ID)
	REFERENCES Registro (reg_id),
	FOREIGN KEY (Medidor_ID)
	REFERENCES Registro (Medidor_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Lancamento

INSERT INTO Lancamento (lanc_id, Diario, Registro_ID, Medidor_ID)
  VALUES (01, 65, 002, 536), -- energia 1
	(02, 33.4, 003, 829), -- gas 1
	(03, 55.0, 004, 441), -- energia 2
	(04, 16.0, 005. 781), -- agua 3
	(05, 40.3, 006, 346), -- gas 2
	(06, 18.3, 007, 299), -- agua 4
	(07, 53.0, 008, 789), -- energia 3
	(08, 16.2, 009, 725), -- agua 5
	(09, 57.0, 010, 545), -- energia 4
	(10, 55.2, 011, 927), -- gas 3
	(11, 53.0, 012, 536), -- energia 1
	(12, 19.0, 013, 753), -- agua 1
	(13, 27.1, 014, 831), -- agua 2
	(14, 51.0, 015, 441), -- energia 2
	(15, 35.9, 016, 829), -- gas 1
	(16, 26.7, 017. 781), -- agua 3
	(17, 52.0, 018, 789), -- energia 3
	(18, 37.1, 019, 346), -- gas 2
	(19, 59.2, 021, 927), -- gas 3
	(20, 43.0, 022, 545), -- energia 4
	(21, 18.2, 023, 725), -- agua 5
	(22, 24.0, 024, 753), -- agua 1
	(23, 63.0, 025, 441), -- energia 2
	(24, 18.5, 026, 831), -- agua 2
	(25, 32.5, 028, 829), -- gas 1
	(26, 50.0, 029, 536), -- energia 1
	(27, 46.0, 030, 789), -- energia 3
	(28, 25.1, 031, 725), -- agua 5
	(29, 52.7, 032, 927), -- gas 3
	(30, 12.1, 033, 299), -- agua 4
	(31, 53.0, 035, 545), -- energia 4
	(32, 54.0, 036, 927), -- gas 3
	(33, 14.9, 037, 299), -- agua 4
	(34, 18.7, 038. 781), -- agua 3
	(35, 41.3, 039, 346), -- gas 2
	(36, 43.0, 041, 536), -- energia 1
	(37, 53.0, 042, 789), -- energia 3
	(38, 56.0, 043, 545), -- energia 4
	(39, 16.4, 044, 753), -- agua 1
	(40, 51.0, 045, 441), -- energia 2
	(41, 13.7, 046, 831), -- agua 2
	(42, 17.6, 047, 725); -- agua 5

--
-- Tabela Compra 6-2
--
CREATE TABLE Compra (
	cmpr_id INT(10) NOT NULL,
	Volume FLOAT(10) NOT NULL,
	Tarifa FLOAT(5) NOT NULL,
	Registro_ID INT(10) NOT NULL,
	PRIMARY KEY (cmpr_id),
	FOREIGN KEY (Registro_ID)
	REFERENCES Registro (reg_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populando Compra

INSERT INTO Compra (cmpr_id, Volume, Tarifa, Registro_ID)
  VALUES (01, 50.0, 5.9, 001), -- agua
	(02, 25.0, 5.9, 020), -- agua
	(03, 66.6, 7.73, 034), -- agua
	(04, 150.8, 3.4, 040), -- gas
	(05, 200.0, 3.4, 027) -- gas
