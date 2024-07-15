--------------
-- Guia de Importação de Arquivos JSON
--------------

--------------
-- 1. Crie as tabelas que receberão os dados
--------------

IF OBJECT_ID('ENTIDADES') IS NOT NULL
  -- valide a existência da tabela para evitar duplicidades
  DROP TABLE ENTIDADES;

CREATE TABLE ENTIDADES
  (
     ID                INT IDENTITY(1, 1) NOT NULL
     , NOME            VARCHAR(255)
     , IDADE           INT
     , CPF             VARCHAR(11)
     , RG              VARCHAR(9)
     , DATA_NASCIMENTO DATE
     , SEXO            VARCHAR(1)
     , TIPO_SANGUINEO  VARCHAR(3)
     , ALTURA          NUMERIC(15, 2)
     , PESO            NUMERIC(15, 2)
	 , INDEX IX_NOME   NONCLUSTERED(NOME)
	 , INDEX IX_CPF    NONCLUSTERED(CPF)
	 , PRIMARY KEY(ID)
  ); 

IF OBJECT_ID('ENTIDADES_CONTATOS') IS NOT NULL
  -- valide a existência da tabela para evitar duplicidades
  DROP TABLE ENTIDADES_CONTATOS;

CREATE TABLE ENTIDADES_CONTATOS
  (
     ENTIDADE_ID INT NOT NULL
     , EMAIL     VARCHAR(255)
     , TELEFONE  VARCHAR(15)
     , CELULAR   VARCHAR(15),
     CONSTRAINT FK_ENTIDADES_CONTATOS FOREIGN KEY (ENTIDADE_ID) 
	 REFERENCES ENTIDADES(ID)
  ); 

IF OBJECT_ID('ENTIDADES_ENDERECOS') IS NOT NULL
  -- valide a existência da tabela para evitar duplicidades
  DROP TABLE ENTIDADES_ENDERECOS;

CREATE TABLE ENTIDADES_ENDERECOS
  (
     ENTIDADE_ID INT NOT NULL
     , CEP       VARCHAR(8)
     , ENDERECO  VARCHAR(255)
     , NUMERO    INT
     , BAIRRO    VARCHAR(255)
     , CIDADE    VARCHAR(60)
     , UF        VARCHAR(2),
     CONSTRAINT FK_ENTIDADES_ENDERECOS FOREIGN KEY (ENTIDADE_ID) 
	 REFERENCES ENTIDADES(ID)
  );
  
--------------
-- 2. Carregue o conteúdo do arquivo JSON numa variável
--------------

DECLARE @JSON VARCHAR(MAX);

SELECT @JSON = BULKCOLUMN
  FROM OPENROWSET(BULK '[especificar_diretório]\DADOS_PESSOAS.JSON', SINGLE_CLOB) AS J;
  
--------------
-- 3. Verifique os dados importados
--------------  

-- Exibe o conteúdo do arquivo JSON
SELECT @JSON AS CONTEUDO;

-- Exibe todos os registros presentes no arquivo JSON
SELECT J.*
  FROM OPENJSON(@JSON) AS J;

-- Exibe os nomes dos campos
SELECT DISTINCT [KEY] AS NOME_CAMPO
  FROM OPENJSON(@JSON, '$[0]')
 ORDER BY NOME_CAMPO; 
 
--------------
-- 4. Armazene os dados numa tabela temporária
--------------  

IF OBJECT_ID('TEMPDB..#TEMP') IS NOT NULL
  -- valide a existência da tabela para evitar duplicidades
  DROP TABLE #TEMP

-- Armazene os dados na tabela temporária
SELECT J.*
INTO   #TEMP
FROM   OPENJSON(@JSON) 
WITH (      
	 nome              VARCHAR(MAX)
     , idade           VARCHAR(MAX)
     , cpf             VARCHAR(MAX)
     , rg              VARCHAR(MAX)
     , data_nasc       VARCHAR(MAX)
     , sexo            VARCHAR(MAX)
     , tipo_sanguineo  VARCHAR(MAX)
     , altura          VARCHAR(MAX)
     , peso            VARCHAR(MAX)
     , email           VARCHAR(MAX)
     , telefone_fixo   VARCHAR(MAX)
     , celular         VARCHAR(MAX)
     , cep             VARCHAR(MAX)
     , endereco        VARCHAR(MAX)
     , numero          VARCHAR(MAX)
     , bairro          VARCHAR(MAX)
     , cidade          VARCHAR(MAX)
     , estado          VARCHAR(MAX)
) AS J

-- Exibe os dados importados
SELECT A.*
  FROM #TEMP AS A
  
--------------
-- 5. Trate os dados antes de importá-los para as tabelas do banco
--------------

-- Tratamento da coluna CPF
UPDATE #TEMP
   SET CPF = REPLACE(REPLACE(REPLACE(CPF, '.', ''), '-', ''), ' ', '');

-- Tratamento da coluna RG
UPDATE #TEMP
   SET RG = REPLACE(REPLACE(REPLACE(RG, '.', ''), '-', ''), ' ', '');

-- Tratamento da coluna TELEFONE_FIXO
UPDATE #TEMP
   SET TELEFONE_FIXO = REPLACE(REPLACE(REPLACE(REPLACE(TELEFONE_FIXO, '(', ''), ')', ''), '-', ''), ' ', '');

-- Tratamento da coluna CELULAR
UPDATE #TEMP
   SET CELULAR = REPLACE(REPLACE(REPLACE(REPLACE(CELULAR, '(', ''), ')', ''), '-', ''), ' ', '');

-- Tratamento da coluna CEP
UPDATE #TEMP
   SET CEP = REPLACE(CEP, '-', '');

-- Tratamento da coluna ALTURA
UPDATE #TEMP
   SET ALTURA = REPLACE(ALTURA, ',', '.');
   
-- Tratamento da coluna SEXO
UPDATE #TEMP
   SET SEXO = CASE
                WHEN UPPER(SEXO) = 'MASCULINO' THEN 'M'
                WHEN UPPER(SEXO) = 'FEMININO'  THEN 'F'                     
              END;
			  
-- Tratamento da coluna DATA_NASC 
IF NOT EXISTS (SELECT 1
                 FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME  = '#TEMP'
                  AND COLUMN_NAME = 'DATA_NASC_DATE')
BEGIN
  ALTER TABLE #TEMP ADD DATA_NASC_DATE DATE;
  
  UPDATE #TEMP
     SET DATA_NASC_DATE = TRY_CONVERT(DATE, DATA_NASC, 103);
END;

-- Tratamento de registros duplicados
WITH CTE AS (
  SELECT *
         , ROW_NUMBER() OVER (PARTITION BY NOME, CPF ORDER BY CPF) AS ROWNUMBER
    FROM #TEMP 
)
DELETE FROM CTE
 WHERE ROWNUMBER > 1; 
 
-- Exibe os dados tratados
SELECT A.*
  FROM #TEMP AS A;  
 
--------------
-- 6. Importe os dados da tabela temporária para tabela master (mãe)
--------------

-- Popule a tabela ENTIDADES
INSERT INTO ENTIDADES
            (NOME
             , IDADE
             , CPF
             , RG
             , DATA_NASCIMENTO
             , SEXO
             , TIPO_SANGUINEO
             , ALTURA
             , PESO)
SELECT NOME
       , IDADE
       , CPF
       , RG
       , DATA_NASC_DATE
       , SEXO
       , TIPO_SANGUINEO
       , ALTURA
       , PESO
  FROM #TEMP; 
  
-- Atualize a tabela temporária com o id da tabela ENTIDADES (mãe) para popular corretamente as tabelas detail (filhas)
IF NOT EXISTS (SELECT 1
                 FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME  = '#TEMP'
                  AND COLUMN_NAME = 'ENTIDADE_ID')
BEGIN
  ALTER TABLE #TEMP ADD ENTIDADE_ID INT;
  
  UPDATE T
     SET T.ENTIDADE_ID = E.ID
    FROM #TEMP T
         JOIN ENTIDADES E ON T.NOME = E.NOME AND T.CPF = E.CPF; 
END;

--------------
-- 7. Importe os dados da tabela temporária para as tabelas detail (filhas)
--------------

-- Popule a tabela ENTIDADES_CONTATOS
INSERT INTO ENTIDADES_CONTATOS
            (ENTIDADE_ID
             , EMAIL
             , TELEFONE
             , CELULAR)
SELECT ENTIDADE_ID
       , EMAIL
       , TELEFONE_FIXO
       , CELULAR
  FROM #TEMP; 
  
-- Popule a tabela ENTIDADES_ENDERECOS  
INSERT INTO ENTIDADES_ENDERECOS
            (ENTIDADE_ID
             , CEP
             , ENDERECO
             , NUMERO
             , BAIRRO
             , CIDADE
             , UF)
SELECT ENTIDADE_ID
       , CEP
       , ENDERECO
       , NUMERO
       , BAIRRO
       , CIDADE
       , ESTADO
  FROM #TEMP; 
  
--------------
-- 8. Visualize os dados importados
--------------

SELECT A.*
       , B.*
       , C.*
  FROM ENTIDADES                A (NOLOCK)
       JOIN ENTIDADES_CONTATOS  B (NOLOCK) ON A.ID = B.ENTIDADE_ID
       JOIN ENTIDADES_ENDERECOS C (NOLOCK) ON A.ID = C.ENTIDADE_ID
 ORDER BY A.ID;