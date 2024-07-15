--------------
-- Guia de exportação de Arquivos JSON
--------------
-- O utilitário Bulk Copy Program (bcp) é uma ferramenta que permite copiar dados em massa entre 
-- o Microsoft SQL Server e arquivos de dados em formatos específicos escolhidos pelo usuário. 
-- Essa ferramenta é útil para transferir dados de um banco de dados SQL Server para arquivos externos, 
-- como JSON e CSV, facilitando a exportação e importação de dados de maneira eficiente e organizada.
--------------

-- Para executar o comando abaixo, você pode usar o SSMS com o modo SQLCMD ativado (vá para Consulta > Modo SQL CMD) ou diretamente no PowerShell do Windows:
!!bcp "SELECT A.* FROM ENTIDADES A FOR JSON PATH" queryout [especificar_diretório]\nome_do_arquivo.json -c -k -T -C -E -S -d [nome_do_banco]

--------------
-- Explicação
--------------

-- Sintaxe: {dbtable | query} {in | out | queryout | format} arquivo de dados --

-- - query: (SELECT A.* FROM ENTIDADES A FOR JSON PATH) Retorna os dados da tabela ENTIDADES e formata os resultados como JSON usando a cláusula FOR JSON PATH.
-- - queryout: determina o local, nome e formato do arquivo de saída.

-- Parâmetros
-- Parâmetros são usados para configurar detalhes específicos da conexão e formatação dos dados durante a exportação.

-- - -c: Especifica o tipo de caractere a ser usado.
-- - -k: Mantém valores nulos.
-- - -T: Usa autenticação confiável.
-- - -C: Determina um especificador de página de código.
-- - -E: Mantém os valores de identidade.
-- - -S: Especifica o nome do servidor SQL Server.
-- - -d: Especifica o nome do banco de dados no qual a consulta será executada.
--------------
