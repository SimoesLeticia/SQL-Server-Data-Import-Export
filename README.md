# SQL Server: Importação e Exportação de Dados via Arquivos

O propósito deste repositório é demonstrar o processo de importação e exportação de dados utilizando o **Microsoft SQL Server**, com foco em arquivos nos formatos .CSV e .JSON. 

Embora a ferramenta _SQL Server Management Studio (SSMS)_ ofereça soluções de importação e exportação de dados através da interface, aprender a executar essas operações via scripts SQL proporciona maior flexibilidade e automação.

## Por que aprender a fazer isso via script?
1. **Automação:** Scripts permitem automatizar processos, tornando as operações repetitivas mais eficientes e menos propensas a erros.
2. **Flexibilidade:** Oferecem maior controle sobre os dados, permitindo a aplicação de mudanças e validações durante o processo.
3. **Escalabilidade:** Scripts podem ser integrados em pipelines de ETL para processar grandes volumes de dados de maneira consistente.

Para quem prefere utilizar a interface do SQL Server Management Studio (SSMS), aqui estão alguns tutoriais úteis:
- [Assistente de importação de arquivo simples para SQL](https://learn.microsoft.com/pt-br/sql/relational-databases/import-export/import-flat-file-wizard?view=sql-server-ver16)
- [Importar e exportar dados do SQL Server](https://learn.microsoft.com/pt-br/sql/integration-services/import-export-data/start-the-sql-server-import-and-export-wizard?view=sql-server-ver16)

## Estrutura do Repositório
Este repositório é organizado em três diretórios principais: **data**, **scripts** e **docs**. 

### Diretórios e Arquivos

**data** - Este diretório contém os arquivos utilizados nos exemplos de importação de dados. Os arquivos disponíveis são:
| Arquivo               | Descrição                                                               |
|:----------------------|:------------------------------------------------------------------------|
| `dados_empresas.csv`  | Contém dados fictícios de empresas, usado como exemplo para importação de arquivos CSV. |
| `dados_pessoas.json`  | Contém dados fictícios de pessoas, usado como exemplo para importação de arquivos JSON. |

**scripts** - Neste diretório estão os scripts SQL que demonstram o processo de importação e exportação de dados. Cada script contém instruções detalhadas e passo a passo de como executar cada processo:
| Arquivo               | Descrição                                                               |
|:----------------------|:------------------------------------------------------------------------|
| `importacao_csv.sql`  | Como importar os dados de um arquivo CSV. |
| `exportacao_csv.sql`  | Como exportar os dados de uma consulta para um arquivo CSV. |
| `importacao_json.sql` | Como importar os dados de um arquivo JSON. |
| `exportacao_json.sql` | Como exportar os dados de uma consulta para um arquivo JSON. |

**docs** - Este diretório contém documentação adicional que explica os processos de importação e exportação:
| Arquivo               | Descrição                                                               |
|:----------------------|:------------------------------------------------------------------------|
| `Importacao_JSON.md`  | Artigo sobre o processo de importação de arquivos JSON. |
| `Importacao_CSV.md`   | Artigo sobre o processo de importação de arquivos CSV. |
| `Exportacao_BCP.md`   | Artigo sobre o processo de exportação utilizando a ferramenta BCP. |

## Contribuições
Contribuições são sempre bem-vindas! Se você tem sugestões de melhorias, encontrou algum bug ou simplesmente quer dizer "olá 👋🏽", sinta-se à vontade para abrir uma issue ou enviar um pull request.

## Referências
- [Microsoft Learn: BULK INSERT](https://learn.microsoft.com/pt-br/sql/t-sql/statements/bulk-insert-transact-sql?view=sql-server-ver16)
- [Microsoft Learn: OPENJSON](https://learn.microsoft.com/pt-br/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16)
- [Microsoft Learn: BCP](https://learn.microsoft.com/pt-br/sql/tools/bcp-utility?view=sql-server-ver16&tabs=windows)
