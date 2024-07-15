# Guia de Exportação de Arquivos com BCP

## Introdução
O utilitário **Bulk Copy Program (BCP)** permite copiar dados em massa entre o Microsoft SQL Server e arquivos de dados em formatos específicos, como JSON e CSV. Essa ferramenta facilita a exportação e importação de dados de maneira eficiente e organizada.

## Versão do BCP
A versão do BCP está em Disponibilidade Geral (GA). As ferramentas de linha de comando, incluindo o BCP, estão incluídas no pacote do instalador para o _SQL Server 2019 (15.x) e versões posteriores_.

## Exportação via interface
É possível exportar os dados retornados de uma consulta clicando com o botão direito sobre o resultado desta consulta e selecionando a opção **"Salvar Resultados Como"**. O SSMS permitirá escolher o diretório e salvar o arquivo nos formatos **.csv** ou **.txt**.

## Sintaxe
A sintaxe básica do comando BCP é a seguinte:

```CSharp
bcp {dbtable | query} {in | out | queryout | format} arquivo_de_dados [opções]
```

## Exemplos de Uso

### Exportação para CSV
Para exportar dados de uma consulta para um arquivo CSV, utilize o seguinte comando:

```CSharp
!!bcp "SELECT [campos] FROM [tabela]" queryout [especificar_diretório]\nome_do_arquivo.csv -c -k -t, -T -C -E -S -d [nome_do_banco]
```

### Exportação para JSON
Para exportar dados de consulta para um arquivo JSON, utilize o seguinte comando:

```Csharp
!!bcp "SELECT [campos] FROM [tabela] FOR JSON PATH" queryout [especificar_diretório]\nome_do_arquivo.json -c -k -T -C -E -S -d [nome_do_banco]
```

**Cláusula `FOR JSON`**

Para formatar os resultados da consulta como JSON, adicione a cláusula **`FOR JSON`** a uma instrução **`SELECT`**. Ao usar esta cláusula, você pode especificar explicitamente a estrutura da saída JSON. Para maior controle sobre a formatação da saída JSON, utilize a opção **`PATH`**.

## Execução dos Comandos
Para executar os comandos acima, você pode usar o _SQL Server Management Studio (SSMS)_ com o modo _SQLCMD_ ativado (vá para **Consulta** > **Modo SQL CMD**) ou diretamente no **PowerShell do Windows**, removendo os pontos de exclamação (`!!`) no início do comando.

## Principais Parâmetros do Comando BCP
- **`queryout`**: O parâmetro queryout determina o local, nome e formato do arquivo de saída.
- **`-c`**: Especifica o tipo de caractere a ser usado. Utiliza o formato de caractere nativo do SQL Server.
- **`-t,`**: Especifica o delimitador de campo como "," (vírgula). Esse parâmetro é utilizado ao exportar dados para um formato CSV.
- **`-k`**: Mantém valores nulos em colunas, ao invés de inserir valores padrão.
- **`-T`**: Usa autenticação confiável do Windows para se conectar ao SQL Server.
- **`-C`**: Determina um especificador de página de código. Este parâmetro é útil para especificar o conjunto de caracteres a ser utilizado.
- **`-E`**: Mantém os valores de identidade existentes durante a exportação.
- **`-S`**: Especifica o nome do servidor SQL Server ao qual se conectar.
- **`-d`**: Especifica o nome do banco de dados no qual a consulta será executada.

## Dica
Para visualizar todos os parâmetros disponíveis em sua versão e as orientações a serem seguidas durante a importação de dados, utilize o comando abaixo:
```CSharp
bcp -h
```

## Conclusão
O utilitário BCP é uma ferramenta versátil e eficiente para copiar grandes volumes de dados entre o SQL Server e arquivos externos. Com os exemplos e explicações fornecidos neste guia, você deve estar apto a realizar exportações de dados em formatos CSV e JSON.