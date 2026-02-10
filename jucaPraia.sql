CREATE TABLE Cliente(
idCliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nomeCliente VARCHAR(50) NOT NULL,
cpf CHAR(11) NOT NULL
)

CREATE TABLE Funcionario(
idFuncionario INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nomeFuncionairo VARCHAR(50) NOT NULL,
cpf CHAR(11) NOT NULL,
celular CHAR(11) NOT NULL
)

CREATE TABLE Equipamento(
idEquipamento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nomeEquipamento VARCHAR(50) NOT NULL, 
qtd INT NOT NULL,
valorHora DECIMAL(5,2)
)

CREATE TABLE Aluguel(
idAluguel INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
idCliente INT NOT NULL,
idFuncionario INT NOT NULL,
dataHoraRetirada DATETIME NOT NULL,
dataHoraDevolucao DATETIME,
valorAPagar DECIMAL (10,2),
valorPago DECIMAL (10,2),
pago BIT,
formaPagamento VARCHAR(50),
qtVezes INT,
CONSTRAINT ck_formaPgto CHECK (formaPagto IN ('DINHEIRO','PIX','DÉBITO','CRÉDITO','OUTROS')),
CONSTRAINT fk_Aluguel_Cliente FOREIGN KEY (idCliente) REFERENCES cliente(idCliente),
CONSTRAINT fk_Aluguel_Funcionario FOREIGN KEY (idFuncionario) REFERENCES Funcionario(idFuncionario)
)



CREATE TABLE AluguelEquipamentos(
idAluguelEquipamentos INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
idEquipamento INT NOT NULL,
idAluguel INT NOT NULL,
valorItem DECIMAL(10,2),
valorUnitario DECIMAL(10,2),
qtd INT,
CONSTRAINT fk_AluguelEquipamentos_Equipamento FOREIGN KEY (idEquipamento) REFERENCES Equipamento(idEquipamento),
CONSTRAINT fk__AluguelEquipamento_Alugue FOREIGN KEY (idAluguel) REFERENCES Aluguel(idAluguel)
)

DROP DATABASE modelopraia
CREATE DATABASE modelopraia