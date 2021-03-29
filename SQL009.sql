/*
	PLT025 - Retorna todas as tabelas que possui determinada coluna
	Create By Bitts
	(17/12/2015)
	
	UTILIZAÇÃO: altera var
*/

USE CorporeRM

DECLARE @coluna VARCHAR(50)
 
-- inicia a declaração do sql
SET @coluna = '%CODPESSOA%'

SELECT 
    T.name AS Tabela, 
    C.name AS Coluna
FROM 
    sys.sysobjects AS T (NOLOCK) 
		INNER JOIN sys.all_columns AS C (NOLOCK) ON 
			T.id = C.object_id AND 
			T.XTYPE = 'U' 
WHERE 
	C.NAME LIKE @coluna
ORDER BY 
    T.name ASC
