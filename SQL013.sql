/*
PLT027 - Listando processos do Banco
	Create By Bitts
	(11/12/2015)
*/

-- Lista todos os processos
sp_who

DECLARE @DATABASE VARCHAR(10) = 'NOME_DA_BASE';

DECLARE @kill varchar(8000) = '';  

-- Lista processos de uma determinada Base
SELECT spid FROM master..sysprocesses WHERE dbid=db_id(@DATABASE)

-- Matar processo, comando: kill idProcesso
--kill 53

-- Matando todos os processos de uma determinada base
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), spid) + ';'  
FROM master..sysprocesses
WHERE dbid=db_id(@DATABASE)

EXEC(@kill);






