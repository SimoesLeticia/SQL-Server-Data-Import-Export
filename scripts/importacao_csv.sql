--------------
-- Guia de Importação de Arquivos CSV
--------------

--------------
-- 1. Crie a tabela que receberá os dados
--------------
IF OBJECT_ID('EMPRESAS') IS NOT NULL
  -- Valide a existência da tabela para evitar duplicidades
  DROP TABLE EMPRESAS

CREATE TABLE EMPRESAS
  (
     RAZAO_SOCIAL           VARCHAR(250)
     , NOME_FANTASIA        VARCHAR(250)
     , CNPJ                 VARCHAR(14)
     , IE                   VARCHAR(15)
     , DATA_ABERTURA        DATE
     , NUMERO_FUNCIONARIOS  INT
     , TELEFONE             VARCHAR(15)
     , CELULAR              VARCHAR(15)
     , SITE                 VARCHAR (150)
     , EMAIL                VARCHAR(150)
     , NOME_SOCIO_1         VARCHAR(150)
     , CPF_SOCIO_1          VARCHAR(11)
     , PARTICIPACAO_SOCIO_1 VARCHAR(3)
     , NOME_SOCIO_2         VARCHAR(150)
     , CPF_SOCIO_2          VARCHAR(11)
     , PARTICIPACAO_SOCIO_2 VARCHAR(3)
     , CEP                  VARCHAR(9)
     , ENDERECO             VARCHAR(200)
     , BAIRRO               VARCHAR(200)
     , CIDADE               VARCHAR(100)
     , ESTADO               VARCHAR(2)
  );

--------------
-- 2. Importe os dados de um arquivo .CSV usando o comando BULK INSERT
--------------
BULK INSERT EMPRESAS
-- Especifica o caminho completo do arquivo CSV a ser importado.
FROM 'D:\PYTHON\IMPORTACAO\DADOS_EMPRESAS.CSV'
WITH
  ( 
    -- Parâmetros
    CODEPAGE = 'ACP',    
    DATAFILETYPE = 'WIDECHAR',    
    FIRSTROW = 2,
    KEEPNULLS,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
  );  

--------------
-- 3. Consulte os dados importados
--------------
SELECT A.*
FROM   EMPRESAS A (NOLOCK)