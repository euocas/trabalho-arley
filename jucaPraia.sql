CREATE TABLE Cliente(
idCliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nomeCliente VARCHAR(50) NOT NULL,
cpf CHAR(11) NOT NULL
);

CREATE TABLE Funcionario(
idFuncionario INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nomeFuncionario VARCHAR(50) NOT NULL,
cpf CHAR(11) NOT NULL,
celular CHAR(11) NOT NULL
);

CREATE TABLE Equipamento(
idEquipamento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nomeEquipamento VARCHAR(50) NOT NULL, 
qtd INT NOT NULL,
valorHora DECIMAL(5,2)
);

CREATE TABLE Aluguel(
idAluguel INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
idCliente INT NOT NULL,
idFuncionario INT NOT NULL,
dataHoraRetirada DATETIME NOT NULL,
dataHoraDevolucao DATETIME,
valorAPagar DECIMAL(10,2),
valorPago DECIMAL(10,2),
pago BIT,
formaPagamento VARCHAR(50),
qtVezes INT,
CONSTRAINT ck_formaPgto CHECK (formaPagamento IN ('DINHEIRO','PIX','DÉBITO','CRÉDITO','OUTROS')),
CONSTRAINT fk_Aluguel_Cliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
CONSTRAINT fk_Aluguel_Funcionario FOREIGN KEY (idFuncionario) REFERENCES Funcionario(idFuncionario)
);

CREATE TABLE AluguelEquipamentos(
idAluguelEquipamentos INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
idEquipamento INT NOT NULL,
idAluguel INT NOT NULL,
valorItem DECIMAL(10,2),
valorUnitario DECIMAL(10,2),
qtd INT,
CONSTRAINT fk_AluguelEquipamentos_Equipamento 
FOREIGN KEY (idEquipamento) REFERENCES Equipamento(idEquipamento),
CONSTRAINT fk_AluguelEquipamentos_Aluguel 
FOREIGN KEY (idAluguel) REFERENCES Aluguel(idAluguel)
);

/* EXERCÍCIO 1 */

INSERT INTO aluguel 
(idCliente, idFuncionario, dataHoraRetirada, dataHoraDevolucao, valorAPagar, valorPago, pago, formaPagamento, qtVezes)
VALUES 
(3,1,'2026-11-10 09:00:00','2026-11-10 15:00:00',3.00,0,0,NULL,NULL);

INSERT INTO aluguelequipamentos
(idEquipamento, idAluguel, valorItem, valorUnitario, qtd)
VALUES
(4,9,3.00,1.50,1);

/* EXERCÍCIO 2 */

SELECT 
f.nomeFuncionario AS Funcionario,
f.cpf AS CPF,
a.dataHoraRetirada AS HoraRetirada,
e.nomeEquipamento AS Equipamento
FROM funcionario f
JOIN aluguel a ON f.idFuncionario = a.idFuncionario
JOIN aluguelequipamentos ae ON a.idAluguel = ae.idAluguel
JOIN equipamento e ON ae.idEquipamento = e.idEquipamento;

/* EXERCÍCIO 3 */

SELECT 
cliente.nomeCliente AS Cliente,
cliente.cpf AS CPF,
aluguel.dataHoraRetirada AS HoraRetirada,
aluguel.dataHoraDevolucao AS HoraDevolucao,
funcionario.nomeFuncionario AS Funcionario
FROM aluguel
INNER JOIN cliente 
ON aluguel.idCliente = cliente.idCliente
INNER JOIN funcionario
ON aluguel.idFuncionario = funcionario.idFuncionario
WHERE aluguel.dataHoraRetirada 
BETWEEN '2024-12-01 00:00:00' AND '2024-12-31 23:59:59'
ORDER BY aluguel.dataHoraRetirada DESC;

/* EXERCÍCIO 4 */

SELECT 
equipamento.nomeEquipamento AS Equipamento,
COUNT(aluguelequipamentos.idEquipamento) AS TotalAlugado
FROM equipamento
LEFT JOIN aluguelequipamentos
ON aluguelequipamentos.idEquipamento = equipamento.idEquipamento
GROUP BY equipamento.nomeEquipamento
ORDER BY TotalAlugado DESC;

/* EXERCÍCIO 5 */

SELECT SUM(valorPago) AS ValorBruto
FROM aluguel
WHERE dataHoraRetirada 
BETWEEN '2024-12-25 00:00:00' AND '2025-01-01 23:59:59';

/* EXERCÍCIO 6 */

UPDATE equipamento
SET valorHora = valorHora * 1.10;

/* EXERCÍCIO 7 */

SELECT 
IFNULL(formaPagamento,'Não realizado') AS FormaPagamento,
COUNT(idCliente) AS qtdClientes
FROM aluguel
GROUP BY formaPagamento
ORDER BY qtdClientes DESC;

/* EXERCÍCIO 8 */

SELECT 
DATE(dataHoraRetirada) AS Dia,
SUM(valorPago) AS Faturamento
FROM aluguel
WHERE dataHoraRetirada 
BETWEEN '2024-12-01 00:00:00' AND '2024-12-31 23:59:59'
GROUP BY Dia
ORDER BY Dia;

/* EXERCÍCIO 9 */

/* Não é possível excluir direto da tabela aluguel porque existe uma chave
estrangeira na tabela AluguelEquipamentos.
Primeiro precisa excluir o AluguelEquipamentos e depois excluir o Aluguel
*/

DELETE FROM aluguelequipamentos
WHERE idAluguel = 7;

DELETE FROM aluguel
WHERE idAluguel = 7;


/* EXERCÍCIO 10 */


SELECT 
equipamento.nomeEquipamento,
COUNT(aluguelequipamentos.idAluguel) AS qtdAlugueis
FROM equipamento
LEFT JOIN aluguelequipamentos
ON aluguelequipamentos.idEquipamento = equipamento.idEquipamento
LEFT JOIN aluguel
ON aluguel.idAluguel = aluguelequipamentos.idAluguel
AND aluguel.dataHoraRetirada 
BETWEEN '2024-12-01' AND '2024-12-31'
GROUP BY equipamento.nomeEquipamento
HAVING COUNT(aluguelequipamentos.idAluguel) < 5
ORDER BY qtdAlugueis;

/**/
 
DELIMITER //
 
CREATE PROCEDURE sp_realizar_aluguel(
    IN p_idCliente        INT,
    IN p_idFuncionario    INT,
    IN p_idEquipamento    INT,
    IN p_qtd              INT,
    IN p_dataRetirada     DATETIME
)
BEGIN
 
    INSERT INTO aluguel
        (idCliente, idFuncionario, dataHoraRetirada, valorAPagar, valorPago, pago)
    VALUES
        (p_idCliente, p_idFuncionario, p_dataRetirada, 0.00, 0.00, 0);
 
    SET @idAluguel = LAST_INSERT_ID();
 
    INSERT INTO aluguelequipamento
        (idAluguel, idEquipamento, valorUnitario, qtd, valorItem)
    SELECT
        @idAluguel, idEquipamento, valorHora, p_qtd, (valorHora * p_qtd)
    FROM equipamento
    WHERE idEquipamento = p_idEquipamento;
 
    UPDATE equipamento
    SET qtd = qtd - p_qtd
    WHERE idEquipamento = p_idEquipamento;
 
    UPDATE aluguel
    SET valorAPagar = (
        SELECT SUM(valorItem)
        FROM aluguelequipamento
        WHERE idAluguel = @idAluguel
    )
    WHERE idAluguel = @idAluguel;
 
END // 
DELIMITER ;

CALL sp_realizar_aluguel(1,1,10,5,NOW())

SELECT * FROM	aluguel