# Guia de Importação de Arquivos CSV

## Introdução
A importação de dados usando arquivos **CSV (_Comma-separated values_)** é uma tarefa comum no dia a dia de desenvolvedores. Arquivos CSV são amplamente utilizados devido à sua simplicidade e compatibilidade com diversas ferramentas e plataformas. Eles são frequentemente usados para transferir dados entre sistemas diferentes, realizar backups e compartilhar informações entre equipes.

No contexto do **SQL Server**, importar dados de arquivos CSV permite que grandes volumes de dados sejam rapidamente inseridos em tabelas do banco. Esse processo é fundamental para diversas operações, tais como a integração de novos dados, a migração de sistemas, e a realização de análises complexas.

## O que é o BULK INSERT
Podemos usar o comando **BULK INSERT** do SQL Server para importar dados de arquivos de texto para tabelas do banco de dados. Este método é a forma mais rápida e eficiente de realizar essa tarefa, especialmente para transferir uma grande massa de dados, otimizando o desempenho e simplificando o processo de importação.

## Importação Usando a Interface
Podemos utilizar a interface do _SQL Server Management Studio (SSMS)_ para importar arquivos CSV. Para mais detalhes, consulte o artigo [Importar Arquivos Flat com o Assistente de Importação e Exportação](https://learn.microsoft.com/pt-br/sql/relational-databases/import-export/import-flat-file-wizard?view=sql-server-ver16).

## Sintaxe
```SQL
BULK INSERT
   { database_name.schema_name.table_or_view_name | schema_name.table_or_view_name | table_or_view_name }
      FROM 'data_file'
     [ WITH
    (
   [ [ , ] BATCHSIZE = batch_size ]
   [ [ , ] CHECK_CONSTRAINTS ]
   [ [ , ] CODEPAGE = { 'ACP' | 'OEM' | 'RAW' | 'code_page' } ]
   [ [ , ] DATAFILETYPE = { 'char' | 'native' | 'widechar' | 'widenative' } ]
   [ [ , ] DATA_SOURCE = 'data_source_name' ]
   [ [ , ] ERRORFILE = 'file_name' ]
   [ [ , ] ERRORFILE_DATA_SOURCE = 'errorfile_data_source_name' ]
   [ [ , ] FIRSTROW = first_row ]
   [ [ , ] FIRE_TRIGGERS ]
   [ [ , ] FORMATFILE_DATA_SOURCE = 'data_source_name' ]
   [ [ , ] KEEPIDENTITY ]
   [ [ , ] KEEPNULLS ]
   [ [ , ] KILOBYTES_PER_BATCH = kilobytes_per_batch ]
   [ [ , ] LASTROW = last_row ]
   [ [ , ] MAXERRORS = max_errors ]
   [ [ , ] ORDER ( { column [ ASC | DESC ] } [ ,...n ] ) ]
   [ [ , ] ROWS_PER_BATCH = rows_per_batch ]
   [ [ , ] ROWTERMINATOR = 'row_terminator' ]
   [ [ , ] TABLOCK ]

   -- input file format options
   [ [ , ] FORMAT = 'CSV' ]
   [ [ , ] FIELDQUOTE = 'quote_characters']
   [ [ , ] FORMATFILE = 'format_file_path' ]
   [ [ , ] FIELDTERMINATOR = 'field_terminator' ]
   [ [ , ] ROWTERMINATOR = 'row_terminator' ]
    )]
```

## Passo a Passo

### Análise do Arquivo de Dados
Neste exemplo, usaremos o arquivo `dados_empresas.csv`, que contém dados fictícios de empresas. Abaixo estão os campos disponíveis no arquivo:
| Campo                 | Descrição                               |
|-----------------------|:----------------------------------------|
| razao_social          | Razão social da empresa                 |
| nome_fantasia         | Nome fantasia da empresa                |
| cnpj                  | CNPJ da empresa                         |
| ie                    | Inscrição estadual da empresa           |
| data_abertura         | Data de abertura da empresa             |
| numero_funcionarios   | Número de funcionários da empresa       |
| telefone              | Telefone da empresa                     |
| celular               | Celular da empresa                      |
| site                  | Website da empresa                      |
| email                 | E-mail de contato da empresa            |
| nome_socio_1          | Nome do primeiro sócio                  |
| cpf_socio_1           | CPF do primeiro sócio                   |
| participacao_socio_1  | Participação do primeiro sócio (%)      |
| nome_socio_2          | Nome do segundo sócio                   |
| cpf_socio_2           | CPF do segundo sócio                    |
| participacao_socio_2  | Participação do segundo sócio (%)       |
| cep                   | CEP do endereço da empresa              |
| endereco              | Endereço completo da empresa            |
| bairro                | Bairro onde a empresa está localizada   |
| cidade                | Cidade onde a empresa está localizada   |
| estado                | Estado onde a empresa está localizada   |

### Preparação do Ambiente
Para fins didáticos, criaremos a tabela que receberá os dados do arquivo importado. Em uma situação real, a tabela provavelmente já estaria criada.
```SQL
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
```
### Importação de Dados com BULK INSERT
```SQL
--------------
-- 2. Importe os dados de um arquivo .CSV usando o comando BULK INSERT
--------------
BULK INSERT EMPRESAS
-- Especifica o caminho completo do arquivo CSV a ser importado.
FROM '[especificar_diretório]\DADOS_EMPRESAS.CSV'
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
```
#### Detalhamento do Comando
- `BULK INSERT [TABELA]`: Chamada do comando e declaração da tabela que receberá os dados. Também poderíamos usar uma tabela temporária.
- `FROM '[especificar_diretório]\DADOS_EMPRESAS.CSV'`: Indica o local do arquivo a ser importado.
- `CODEPAGE = 'ACP'`: Especifica a página de código dos dados no arquivo. Este parâmetro é relevante se os dados contiverem colunas char, varchar ou text. `ACP` significa que essas colunas são convertidas da página de código _ANSI/Microsoft_ do Windows.
- `DATAFILETYPE = 'WIDECHAR'`: Especifica que o **BULK INSERT** executa a operação de importação usando caracteres _Unicode_.
- `FIRSTROW = 2`: Especifica o número da primeira linha a ser carregada. Usamos 2 para ignorar o cabeçalho.
- `KEEPNULLS`: Especifica que colunas vazias devem reter valores nulos durante a importação.
- `FORMAR = 'CSV'`: Especifica o formato do arquivo.
- `FIELDTERMINATOR = ','`: Especifica o delimitador de campo a ser usado, neste caso, uma vírgula.
- `ROWTERMINATOR = '\n'`: Especifica o terminador de linha a ser usado.

### Visualização dos Dados Importados
```SQL
--------------
-- 3. Consulte os dados importados
--------------
SELECT A.*
FROM   EMPRESAS A (NOLOCK)
```

## Conclusão
Com os exemplos e explicações fornecidos neste guia, você deve estar apto a realizar a importação de arquivos CSV para o banco de dados utilizando o comando **BULK INSERT**.

Espero que o conteúdo tenha sido útil e que você se sinta confiante para aplicar esses conhecimentos em seus projetos. Continue explorando as capacidades do SQL Server e aprimorando suas habilidades.
