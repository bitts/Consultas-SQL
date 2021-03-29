/*
	PLT041 - Script para habilitar o uso do comando xp_cmdshell
	Create By Bitts
	(24/11/2015)
*/

EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO

