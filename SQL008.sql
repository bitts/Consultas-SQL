/*
	PLT024 - Retorna todas as tabelas que possui determinada coluna
	Create By Bitts
	(17/12/2015)
	
	UTILIZAÇÃO: altera variavel @coluna
*/
DECLARE @SQL VARCHAR(8000)
DECLARE @filtro VARCHAR(200)
DECLARE @filtro_www VARCHAR(200)
 
-- inicia a declaração do sql
SET @SQL = ''
SET @filtro = '%BUSCAR_STRING%'
 
SELECT 
	tabelas.name AS Tabela, colunas.name AS Coluna, tipos.name AS Tipo, colunas.LENGTH AS Tamanho
INTO
	#result
FROM 
	sysobjects tabelas
	INNER JOIN syscolumns colunas ON 
		colunas.id = tabelas.id
	INNER JOIN systypes tipos ON 
		tipos.xtype = colunas.xtype
WHERE 
	tabelas.xtype = 'u' AND
	-- colocar aqui os tipos de coluna que serão buscados
	tipos.name IN('text', 'ntext', 'varchar', 'nvarchar', 'memo')
 
-- cursor para varrer as tabelas
DECLARE cTabelas cursor LOCAL fast_forward FOR
SELECT DISTINCT Tabela FROM #result
 
DECLARE @nomeTabela VARCHAR(255) 
OPEN cTabelas
 
FETCH NEXT FROM cTabelas INTO @nomeTabela
 
WHILE @@fetch_status = 0
BEGIN
 
  -- cursor para varrer as colunas da tabela corrente
  DECLARE cColunas cursor LOCAL fast_forward FOR
  SELECT Coluna, Tipo, Tamanho FROM #result WHERE Tabela = @nomeTabela
 
  DECLARE @nomeColuna VARCHAR(255)
  DECLARE @tipoColuna VARCHAR(255)
  DECLARE @tamanhoColuna VARCHAR(255)
 
  OPEN cColunas
 
  -- monta as colunas da cláusula select 
  FETCH NEXT FROM cColunas INTO @nomeColuna, @tipoColuna, @tamanhoColuna
 
  WHILE @@fetch_status = 0
  BEGIN
    -- cria a declaração da variável
    SET @SQL = 'DECLARE @hasresults bit' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    -- cria o select
    SET @SQL = @SQL + 'SELECT' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL + CHAR(9) + '''' + @nomeTabela + ''' AS NomeTabela'
    SET @SQL = @SQL + CHAR(9) + ',' + @nomeColuna + CHAR(13) + CHAR(10)
    -- adiciona uma coluna com o tipo e o tamanho do campo
    SET @SQL = @SQL  + CHAR(9) + ',' + '''' + @tipoColuna + ''' AS ''' + @nomeColuna + '_Tipo''' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL  + CHAR(9) + ',' + 'DATALENGTH(' + @nomeColuna + ') AS ''' + @nomeColuna + '_Tamanho_Ocupado''' + CHAR(13) + CHAR(10)    
    SET @SQL = @SQL  + CHAR(9) + ',' + '''' + @tamanhoColuna + ''' AS ''' + @nomeColuna + '_Tamanho_Maximo''' + CHAR(13) + CHAR(10)
 
    -- define a tabela temporária (#result)
    SET @SQL = @SQL + 'INTO' + CHAR(13) + CHAR(10) + CHAR(9) + '#result_' + @nomeTabela + CHAR(13) + CHAR(10)
    -- adiciona a cláusula from
    SET @SQL = @SQL +  'FROM' + CHAR(13) + CHAR(10) + CHAR(9) + @nomeTabela + CHAR(13) + CHAR(10)
    -- inicia a montagem do where
    SET @SQL = @SQL + 'WHERE' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL + CHAR(9) + @nomeColuna + ' LIKE ''' + @filtro + '''' + CHAR(13) + CHAR(10)
 
    SET @SQL = @SQL + CHAR(13) + CHAR(10) + 'SELECT @hasresults = COUNT(*) FROM #result_' + @nomeTabela + CHAR(13) + CHAR(10)
    SET @SQL = @SQL + CHAR(13) + CHAR(10) + 'IF @hasresults > 0'
    SET @SQL = @SQL + CHAR(13) + CHAR(10) + 'BEGIN'
    SET @SQL = @SQL + CHAR(13) + CHAR(10) + CHAR(9) + 'SELECT * FROM #result_' + @nomeTabela
    SET @SQL = @SQL + CHAR(13) + CHAR(10) + 'END' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL + CHAR(13) + CHAR(10) + 'DROP TABLE #result_' + @nomeTabela
    SET @SQL = @SQL + CHAR(13) + CHAR(10)
 
    FETCH NEXT FROM cColunas INTO @nomeColuna, @tipoColuna, @tamanhoColuna
	-- descomente a linha abaixo para ver o SQL produzido no janela de Messages
    PRINT @sql
    EXEC(@SQL)
    SET @SQL = ''
  END
 
  CLOSE cColunas
  DEALLOCATE cColunas
 
  FETCH NEXT FROM cTabelas INTO @nomeTabela
END
 
CLOSE cTabelas
DEALLOCATE cTabelas
 

SELECT * FROM #result

DROP TABLE #result
