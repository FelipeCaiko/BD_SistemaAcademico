create database Faculdade;
use Faculdade;

create table Aluno (
	RA int not null,
	Nome Varchar(50) NOT NULL,
	constraint Pk_RA primary key(RA)
);

CREATE TABLE Disciplina(
	Sigla char(3)NOT NULL PRIMARY KEY,
	Nome varchar(20) NOT NULL,
	Carga_Horaria int NOT NULL
);

CREATE TABLE Matricula(
	RA int NOT NULL,
	Sigla char(3) NOT NULL,
	Data_Ano int NOT NULL,
	Data_Semestre int NOT  NULL,
	Falta  int,
	Nota_N1  float,
	Nota_N2 float,
	Nota_Sub float,
	Nota_Media float,
	Situacao bit,
	constraint PK_Matricula primary key (RA,Sigla,Data_Ano,Data_Semestre),
	constraint FK_Matricula_RA foreign key (RA) REFERENCES Aluno(RA),
	constraint FK_Matricula_Sigla FOREIGN KEY (Sigla) REFERENCES Disciplina(Sigla)
);

INSERT INTO Disciplina(Sigla,Nome,Carga_Horaria) VALUES
	('CA1','Calculo 1',100),
	('CA2','Calculo 2',100),
	('EST','Estatistica e Probabilidade',100),
	('ED','Estrutura de Dados',80),
	('AUD','Auditoria e Segurança',60),
	('BD1','Banco de Dados 1',80),
	('BD2','Banco de Dados 2',80),
	('LOG','Lógica de Programação',50),
	('COE','Comunicação Oral e Escrita',50),
    ('TCC','Trabalho Conclusão',60);

INSERT INTO Aluno(RA,Nome) VALUES
	(1,'Moranguinho'),
	(2,'Baratão'),
	(3,'Wes'),
	(4,'Thalya'),
	(5,'Mussarela'),
	(6,'Juliano'),
	(7,'Jhow'),
	(8,'Jota Jota'),
	(9,'Artur'),
	(10,'Gabi');

INSERT INTO Matricula(RA,Sigla,Data_Ano,Data_Semestre) values
	(1,'AUD', 2021, 1),
	(1,'EST', 2021, 2),
	(5,'TCC', 2021, 1),
	(5,'COE', 2021, 1),
	(8,'TCC', 2021, 2),
	(8,'LOG', 2021, 2);

CREATE TRIGGER TRG_Situacao
On Matricula
AFTER update
AS
BEGIN
	DECLARE
	@Falta int,
	@Carga_Horaria int,
	@Ra int,
	@Frequencia int,
	@SiglaD char(3),
	@SiglaM char(3),
	@Nota1 DECIMAL(10,1),
	@Nota2 DECIMAL(10,1),
	@Nota_Sub DECIMAL (10,1),
	@Media DECIMAL(10,1)

	select @Nota1 = m.Nota_N1, @Nota2 = m.Nota_N2, @RA = m.RA, @Nota_Sub = m.Nota_Sub from inserted
	JOIN Disciplina d on @SiglaD = d.Sigla JOIN Matricula m on @SiglaM = m.Sigla 
	WHERE  @SiglaM  = @SiglaD AND m.RA = @Ra;

	SELECT @Frequencia = @Carga_Horaria - @Falta
	if (@Frequencia < (@Carga_Horaria * 0.25))
	BEGIN
		UPDATE Matricula SET Situacao = 0 WHERE RA = @Ra;
		print('Reprovado por Falta!!');
		INSERT INTO Matricula(RA, Sigla, Data_Ano, Data_Semestre)
		(SELECT RA, Sigla, 2022, 2 FROM Matricula WHERE RA = @Ra AND Sigla = @SiglaM AND Situacao = 0 )
	END
	ELSE
	BEGIN
		UPDATE Matricula SET Nota_Media = (@Nota1 + @Nota2) / 2 where RA = @RA and Sigla = @SiglaM;
		IF(@Media < 5)
		BEGIN
			IF(@Nota1 > @Nota2)
			BEGIN
			UPDATE Matricula SET Nota_Media = (@Nota1 + @Nota_Sub) / 2
				WHERE RA = @Ra and Sigla = @SiglaM
			END
			ELSE
			BEGIN
				UPDATE Matricula SET Nota_Media = (@Nota_Sub + @Nota2) / 2
				WHERE RA = @Ra and Sigla = @SiglaM
			END
		END

		IF(@Media > 5)
		BEGIN
			UPDATE Matricula SET Situacao = 1 WHERE RA = @Ra;
		END
		ELSE
		BEGIN
			UPDATE Matricula SET Situacao = 0 WHERE RA = @Ra;
			print('Reprovado por Nota!!');
			INSERT INTO Matricula(RA, Sigla, Data_Ano, Data_Semestre)
			(SELECT RA, Sigla, 2022, 2 FROM Matricula WHERE RA = @Ra AND Sigla = @SiglaM AND Situacao = 0 )
		END
	END
END

update Matricula set Nota_N1 = 6,
					 Nota_N2 = 9,
					 Falta = 10,
					 Nota_Sub = 5
					 where RA = 1 and Sigla = 'AUD';

update Matricula set Nota_N1 = 6,
					 Nota_N2 = 3,
					 Falta = 15,
					 Nota_Sub = 4
					 where RA = 1 and Sigla = 'EST';

update Matricula set Nota_N1 = 1,
					 Nota_N2 = 3,
					 Falta = 1
					 where RA = 5 and Sigla = 'TCC';

update Matricula set Nota_N1 = 6,
					 Nota_N2 = 4,
					 Falta = 60
					 where RA = 8 and Sigla = 'TCC';

update Matricula set Nota_N1 = 10,
					 Nota_N2 = 9.5,
					 Falta = 11
					 where RA = 8 and Sigla = 'LOG';

/*Quais são alunos de uma determinada disciplina ministrada no ano de 2021, com suas notas, faltas e Situação Final.*/
SELECT a.RA, a.Nome as 'Aluno', d.Nome 'Disciplina', m.Situacao, m.Nota_N1, m.Nota_N2,m.Nota_Sub, m.Nota_Media,m.Falta
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Sigla = 'CA1'

/*Quais são as notas, faltas e situação final (Boletim) de um aluno em todas as disciplinas por ele cursadas no ano de 2021, no segundo semestre.*/
SELECT a.RA, a.Nome as 'Aluno', d.Nome 'Disciplina', m.Situacao, m.Nota_N1, m.Nota_N2,m.Nota_Sub, m.Nota_Media, m.Falta
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND a.RA = 5 AND Data_Ano = 2021

/*Quais são os alunos reprovados por nota (média inferior a cinco) no ano de 2021 e, o nome das disciplinas em que eles reprovaram, com suas notas e médias.*/
SELECT a.RA, a.Nome as 'Aluno', d.Nome 'Disciplina', m.Situacao, m.Nota_N1, m.Nota_N2,m.Nota_Sub, m.Nota_Media, m.Falta
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Situacao = 0 AND m.Nota_Media < 5

select * from Matricula;