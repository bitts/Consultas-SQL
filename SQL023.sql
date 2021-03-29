/*
	PLT043 - Script para fazer copia da base de dados
	Create By Bitts
	(24/11/2016)
	
	USO: Trocar valores das variaveis @dbname_origem e @dbname_destino
*/

USE master;

print 'Inicionando processo de cópia/restauração de Database...' ;
print 'Definindo variáveis do escopo...' ;
DECLARE 
	--Informar valor aqui caso seja copia de base ativa
	@dbname_origem SYSNAME = 'CorporeRM',			
	@dbname_destino SYSNAME = 'TCorporeRM',
	--Informar Path do arquivo de origem do backup
	--@bkp_file VARCHAR(MAX) = 'D:\BACKUP_TOTVSRM\CorporeRM_backup_2016_12_13_010001_6242661.bak1',	
	@bkp_file VARCHAR(MAX) = '',	
		
	@file_origem VARCHAR(MAX),
	@file_origem_log VARCHAR(MAX),
	@logicalname_origem VARCHAR(MAX),
	@logicalname_origem_log VARCHAR(MAX),
	@path_files VARCHAR(MAX),
	@file_mdf VARCHAR(MAX),
	@file_ldf VARCHAR(MAX),
						
	@dest_mdf_file VARCHAR(MAX),
	@dest_ldf_file VARCHAR(MAX),
	@cmd_delbkpfile VARCHAR(400),
	@retorno_delete VARCHAR(MAX),
	@kill AS VARCHAR(20), 
	@spid AS INT;
	
IF(@bkp_file = '' AND @dbname_origem != '')	
BEGIN

	print 'Localizando arquivo MDF da base de origem...' ;
	SELECT @file_origem = [physical_name], @logicalname_origem = [name] 
	FROM sys.[master_files] 
	WHERE [database_id] IN (DB_ID(@dbname_origem)) AND [type_desc] = 'ROWS';

	print 'Localizando arquivo LDF da base de origem...' ;
	SELECT @file_origem_log = [physical_name], @logicalname_origem_log = [name] 
	FROM sys.[master_files] 
	WHERE [database_id] IN (DB_ID(@dbname_origem)) AND [type_desc] = 'LOG';	

	print 'Definindo destino do arquivo de Backup...' ;
	SELECT 
		@path_files = LEFT(@file_origem,LEN(@file_origem) - charindex('\',reverse(@file_origem),1) + 1), 
		@file_mdf = RIGHT(@file_origem, CHARINDEX('\', REVERSE(@file_origem)) -1),
		@file_ldf = RIGHT(@file_origem_log, CHARINDEX('\', REVERSE(@file_origem_log)) -1);

	print 'Definindo destino completo do arquivo de Backup...' ;
	--SET @bkp_file = @path_files + 'restore_database.bak';
	SET @bkp_file = 'z:\bkp\';

	print 'Origens e destinos definidos...' ;
	print 'Caminho completo do arquivo MDF de origem: '+ @file_origem ;
	print 'Caminho completo do arquivo LDF de origem: '+ @file_origem_log ;
	print 'Nome lógico da database: '+ @logicalname_origem ;
	print 'Nome lógico do arquivo de logs: '+ @logicalname_origem_log ;
	print 'Local de destino do arquivo de Backup: '+ @path_files ;
	print 'Arquivo MDF origem: '+ @file_mdf ;
	print 'Arquivo LDF origem: '+ @file_ldf ;
	print 'Caminho completo do arquivo de Backup destino: '+ @bkp_file ;
END

IF DB_ID( @dbname_destino ) IS NOT NULL 
BEGIN	
	SELECT @spid = MIN(spid) FROM master..sysprocesses WHERE dbid = db_id(@dbname_destino) AND spid != @@spid    

	IF ( @spid IS NOT NULL ) 
	BEGIN 
		WHILE (@spid IS NOT NULL)
		BEGIN
			print 'Matando processos ' + CAST(@spid AS VARCHAR) + ' ...'
			SET @kill = 'kill ' + CAST(@spid AS VARCHAR);
			EXEC (@kill);

			SELECT @spid = MIN(spid) FROM master..sysprocesses WHERE dbid = db_id(@dbname_destino) AND spid != @@spid
		END 
	END
	ELSE print 'Nenhum processo pendente na base de destino';
	
	EXEC('
		ALTER DATABASE '+ @dbname_destino + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		ALTER DATABASE '+ @dbname_destino + ' SET MULTI_USER; '
	);
END 

IF(@dbname_origem != '')	
	BEGIN
		print 'Definindo caminho completo dos novos arquivo MDF e LDF para a database destino' ;
		SET @dest_mdf_file = @path_files + @dbname_destino + '.mdf';
		SET @dest_ldf_file = @path_files + @dbname_destino + '_log.ldf';
		print 'Caminho completo do MDF de destino '+ @dest_mdf_file + char(13) ;
		print 'Caminho completo do LDF de destino '+ @dest_ldf_file + char(13) ;

		print 'Restaurando a database...' ;
		RESTORE DATABASE @dbname_destino FROM DISK = @bkp_file
		WITH CHECKSUM, 
		MOVE @logicalname_origem TO @dest_mdf_file, 
		MOVE @logicalname_origem_log TO @dest_ldf_file, 
		RECOVERY, REPLACE, STATS = 10;
	END
ELSE
	BEGIN
		print 'Inicionado processo de Backup, arquivo de origem: '+ @bkp_file ;
		print 'Restaurando a database...' ;
		RESTORE DATABASE @dbname_destino FROM DISK = @bkp_file;
	END
									      
/*	
-- FAZER LISTA SIMPLES SEPARADO SOMENTE POR VIRGULA E TRANSFORMAR EM: (informar usuario que deseja bloquear)
@user_list =  
		CHAR(39) + 'usuario1' +  CHAR(39) +', '+  
		CHAR(39) + 'usuario2' +  CHAR(39) +', '+ 
		CHAR(39) + 'usuario3' +  CHAR(39) +', '+  
		CHAR(39) + 'mestre' +  CHAR(39) +', '+  
		CHAR(39) + 'totvs' +  CHAR(39) +'
@bloqueia_user = 'UPDATE GUSUARIO SET STATUS = '0' WHERE CODUSUARIO NOT IN ('+ @user_list +')';
EXEC @bloqueia_user ;
*/

print 'Backup Finalizado!';

