 
/*
  Script para desbloquear base de dados 
	Create By Bitts
	(24/10/2015)
*/

USE master

DECLARE @dbname sysname
SET @dbname = 'NomedaBase';

EXEC('
	ALTER DATABASE '+ @dbname + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	ALTER DATABASE '+ @dbname + ' SET MULTI_USER; '
)

EXEC('DROP DATABASE '+ @dbname )

IF DB_ID(@dbname) IS NULL
BEGIN 
	/*ALTER DATABASE @dbname SET SINGLE_USER WITH
	ROLLBACK IMMEDIATE;
	
	DROP DATABASE @dbname;*/
END


SELECT 
  DB_NAME([database_id]) [database_name], [database_id]
, [file_id]
, [type_desc] [file_type]
, [name] 
, [physical_name]
FROM sys.[master_files]
WHERE [database_id] IN (DB_ID('NomedaBasedeDados'), DB_ID('NomedaBasedeDados2'))
ORDER BY [type], DB_NAME([database_id]);


DECLARE @full_path VARCHAR(1000)
SET @full_path = '\\SERVER\D$\EXPORTFILES\EXPORT001.csv'

SELECT LEFT(@full_path,LEN(@full_path) - charindex('\',reverse(@full_path),1) + 1) [path], 
       RIGHT(@full_path, CHARINDEX('\', REVERSE(@full_path)) -1) 
