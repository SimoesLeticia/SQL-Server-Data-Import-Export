# Guia de Importação de Arquivos JSON

## Introdução
O **JSON (_JavaScript Object Notation_)** é um formato de dados leve, altamente compatível com diferentes sistemas e fácil de compreender tanto para humanos quanto para máquinas. Ele se tornou popular em serviços Web por conseguir transmitir um grande volume de informações entre cliente e servidor com menos caracteres.

Embora a lógica de organização do JSON seja semelhante à do **XML (_Extensive Markup Language_)**, sua notação é diferente. O JSON é basicamente uma alternativa mais simples e leve ao XML.

No contexto do **SQL Server**, importar dados no formato JSON pode ser extremamente útil para várias aplicações, como a integração de dados de sistemas externos, o armazenamento de configurações e logs, e a transferência de dados entre diferentes sistemas. O SQL Server oferece suporte nativo para JSON, permitindo a leitura e manipulação de dados JSON de forma eficiente e integrada.

## ETL (Extract, Transform, Load)
**ETL** é a sigla para _Extração_, _Transformação_ e _Carregamento_. Trata-se de um processo de integração de dados utilizado para combinar informações de diversas fontes em um armazenamento unificado.

### Importância no Processo de Importação
O processo de ETL é essencial para garantir que os dados importados estejam limpos, formatados corretamente e prontos para uso. Neste guia, abordamos todas as etapas do ETL.

### Etapas do Processo ETL
1. **Extração**: Leitura do conteúdo do arquivo JSON e armazenamento dos dados em uma variável ou estrutura temporária.
2. **Transformação**: Ajuste dos dados para conformidade com o esquema do banco de dados, incluindo a conversão de tipos de dados, tratamento de valores nulos e eliminação de duplicatas.
3. **Carregamento**: Inserção dos dados transformados nas tabelas do banco, garantindo que todas as relações e integridades referenciais sejam mantidas.

Essa abordagem diminui chances de erros e assegura que os dados estejam prontos para uso imediato após a importação, proporcionando um processo de importação mais eficiente e confiável.

## Passo a Passo
### Análise do Arquivo de Dados
Neste exemplo, usaremos o arquivo `dados_pessoas.csv`, que contém dados fictícios sobre pessoas. Antes de iniciarmos o processo de importação, é importante entender sobre o conjunto de dados disponibilizado. Abaixo está a lista dos campos presentes no arquivo:
|                |                |                |                |                |
|----------------|----------------|----------------|----------------|----------------|
| nome           | idade          | cpf            | rg             | data_nasc      |
| sexo           | signo          | mae            | pai            | email          |
| senha          | cep            | endereco       | numero         | bairro         |
| cidade         | estado         | telefone_fixo  | celular        | altura         |
| peso           | tipo_sanguineo | cor            |                |                |

### Preparação do Ambiente
Para fins didáticos, criaremos as tabelas que receberão os dados do arquivo importado. Em uma situação real, essas tabelas provavelmente já estariam criadas. No entanto, aqui vamos abordar uma situação comum do dia a dia, onde os dados chegam em um único arquivo e devem ser importados para duas ou mais tabelas diferentes. 

Neste exemplo, vamos importar os dados para três tabelas: `ENTIDADES`, `ENTIDADES_CONTATOS` e `ENTIDADES_ENDERECOS`.
```SQL
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
```

**Observação:**
> É importante observar que nem todos os campos presentes no arquivo são pertinentes para nossa importação. Por exemplo, os campos `senha`, `pai`, `mae` e `cor` serão ignorados neste processo.

### Extração de Dados
Após preparar o ambiente e criar as tabelas necessárias, o próximo passo é a extração dos dados do arquivo JSON. Nesta etapa, vamos armazenar o conteúdo do arquivo em uma variável, o que nos permitirá manipular e transformar os dados. 

Usaremos a função [`OPENROWSET`](https://learn.microsoft.com/pt-br/sql/t-sql/functions/openrowset-transact-sql?view=sql-server-ver16) para ler o conteúdo do arquivo e armazená-lo em uma variável chamada `@JSON`.
```SQL
--------------
-- 2. Carregue o conteúdo do arquivo JSON numa variável
--------------

DECLARE @JSON VARCHAR(MAX);

SELECT @JSON = BULKCOLUMN
  FROM OPENROWSET(BULK '[especificar_diretório]\DADOS_PESSOAS.JSON', SINGLE_CLOB) AS J;
```

### Verificação do Conteúdo Carregado
Após importar o conteúdo do arquivo JSON, é fundamental verificar se os dados foram carregados corretamente e estão organizados de maneira adequada.

Para visualizar o conteúdo bruto do arquivo JSON carregado, utilizamos a seguinte consulta:
```SQL
--------------
-- 3. Verifique os dados importados
--------------  

-- Exibe o conteúdo do arquivo JSON
SELECT @JSON AS CONTEUDO;
```

Para verificar todos os registros contidos no arquivo JSON,  utilizamos a seguinte consulta:
```SQL
-- Exibe todos os registros presentes no arquivo JSON
SELECT J.*
  FROM OPENJSON(@JSON) AS J;
```

Para obter os nomes dos campos presentes no arquivo JSON,  utilizamos a seguinte consulta:
```SQL
-- Exibe os nomes dos campos
SELECT DISTINCT [KEY] AS NOME_CAMPO
  FROM OPENJSON(@JSON, '$[0]')
 ORDER BY NOME_CAMPO; 
```

### Carregamento de Dados em Tabela Temporária
O próximo passo é importar os dados relevantes para uma tabela temporária com a estrutura apropriada para armazenar as informações do arquivo. Para isso, usamos a função [`OPENJSON`](https://learn.microsoft.com/pt-br/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16), que realiza a leitura de estruturas de dados JSON e as converte em formato tabular. Essa função é essencial para analisar o texto JSON e transformá-lo em linhas na tabela.
```SQL
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
       nome            VARCHAR(MAX)
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
```

### Tratamento de Dados
O tratamento de dados antes da importação para as tabelas do banco é crucial para garantir que os dados estejam em conformidade com o esquema do banco de dados e para evitar erros durante a inserção, pois as informações no arquivo JSON podem estar em um formato diferente do esperado pelas tabelas do banco.

**Dados de Exemplo:**

| nome             | idade | cpf            | rg           | data_nasc  | sexo      | tipo_sanguineo | altura | peso | email                       | telefone fixo  | celular         | cep       | endereco         | numero | bairro    | cidade      | estado |
|------------------|-------|----------------|--------------|------------|-----------|----------------|--------|------|-----------------------------|----------------|-----------------|-----------|------------------|--------|-----------|-------------|--------|
| Diogo Igor Lopes | 57    | 524.665.837-63 | 39.694.244-1 | 20/03/1967 | Masculino | A-             | 1,91   | 67   | diogo_lopes@eyejoy.com.br   | (54) 3767-1094 | (54) 98358-3917 | 99025-420 | Rua Tupinambás   | 838    | Boqueirão | Passo Fundo | RS     |

Por exemplo, nossa tabela `ENTIDADES` contém uma coluna `SEXO` do tipo `VARCHAR(1)`, mas no arquivo JSON, o campo `sexo` possui valores como `"feminino"` ou `"masculino"`. Ao tentar importar esses dados diretamente, ocorreria um erro de dados truncados. Além disso, é necessário tratar possíveis dados duplicados para manter a integridade do banco.
```SQL
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
```

### Carregamento de Dados Tratados
#### Tabela Mãe (master)
Com os dados devidamente tratados, o próximo passo é iniciar a importação para as tabelas principais. Começamos importando os dados da tabela temporária para a tabela principal `ENTIDADES`. Precisamos dos IDs gerados durante essa inserção para popular corretamente as tabelas filhas.
```SQL
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
```

Após a inserção na tabela `ENTIDADES`, realizamos a atualização da tabela temporária com os IDs gerados. Isso viabiliza a referência e a subsequente população das tabelas filhas.
```SQL
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
```

#### Tabelas filhas (details)
Agora é possível realizar a importação dos dados para as tabelas seguintes.

Iniciamos importando os dados de contatos da tabela temporária para a tabela `ENTIDADES_CONTATOS`, utilizando os IDs das entidades para assegurar a integridade referencial.
```SQL
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
```
Em seguida, importamos os dados de endereços da tabela temporária para a tabela `ENTIDADES_ENDERECOS`, utilizando novamente os IDs das entidades para manter a consistência dos dados.
```SQL
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
```

### Revisão dos dados importados
O processo de importação de dados está quase concluído. O próximo passo é revisar os dados importados para garantir sua conformidade. Abaixo está a consulta que exibe os dados importados. 
```SQL
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
```

## Conclusão
Com os exemplos e explicações fornecidos neste guia, você estará pronto para importar arquivos JSON e realizar o processo de extração, transformação e carregamento (ETL) de dados com SQL Server. 

Espero que o conteúdo tenha sido útil e que você se sinta confiante para aplicar esses conhecimentos em seus projetos, explorando as capacidades do SQL Server e aprimorando suas habilidades!
