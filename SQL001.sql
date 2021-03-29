/*
  Script para fazer copia da base de dados
	Create By Bitts
	(24/11/2015)
	
	USO: EXECUTE dbo.restdb 'Base Origem', 'Base Destino', @retorno OUTPUT;
*/

IF OBJECT_ID ( 'dbo.restdb', 'P' ) IS NOT NULL  
	DROP PROCEDURE restdb;
	
GO

CREATE PROCEDURE restdb(@dbname_origem SYSNAME, @dbname_destino SYSNAME, @return VARCHAR(MAX) OUTPUT) AS
BEGIN

	SET @return = @return + 'Inicionando processo de copia de database...' +  char(13) ;
	SET @return = @return + 'Definindo variaveis do escopo' + char(13) ;
	DECLARE 
		--@dbname_origem SYSNAME = 'Rematriculas',
		--@dbname_destino SYSNAME = 'RematriculasTeste',
		@file_origem VARCHAR(MAX),
		@file_origem_log VARCHAR(MAX),
		@logicalname_origem VARCHAR(MAX),
		@logicalname_origem_log VARCHAR(MAX),
		@path_files VARCHAR(MAX),
		@file_mdf VARCHAR(MAX),
		@file_ldf VARCHAR(MAX),
		@bkp_file VARCHAR(MAX),
		@dest_mdf_file VARCHAR(MAX),
		@dest_ldf_file VARCHAR(MAX),
		@cmd_delbkpfile VARCHAR(400);
		
	SET @return = @return + 'Localizando arquivo MDF da base de origem...' + char(13) ;
	SELECT @file_origem = [physical_name], @logicalname_origem = [name] 
	FROM sys.[master_files] 
	WHERE [database_id] IN (DB_ID(@dbname_origem)) AND [type_desc] = 'ROWS';

	SET @return = @return + 'Localizando arquivo LDF da base de origem...' + char(13) ;
	SELECT @file_origem_log = [physical_name], @logicalname_origem_log = [name] 
	FROM sys.[master_files] 
	WHERE [database_id] IN (DB_ID(@dbname_origem)) AND [type_desc] = 'LOG';	

	SET @return = @return + 'Definindo destino do arquivo de Backup...' + char(13) ;
	SELECT 
		@path_files = LEFT(@file_origem,LEN(@file_origem) - charindex('\',reverse(@file_origem),1) + 1), 
		@file_mdf = RIGHT(@file_origem, CHARINDEX('\', REVERSE(@file_origem)) -1),
		@file_ldf = RIGHT(@file_origem_log, CHARINDEX('\', REVERSE(@file_origem_log)) -1);

	SET @return = @return + 'Definindo destino completo do arquivo de Backup...' + char(13) ;
	SET @bkp_file = @path_files + 'restore_database.bak';


	SET @return = @return + 'Origens e destinos definidos...' + char(13) ;
	SET @return = @return + 'Caminho completo do arquivo MDF de origem: '+ @file_origem + char(13) ;
	SET @return = @return + 'Caminho completo do arquivo LDF de origem: '+ @file_origem_log + char(13) ;
	SET @return = @return + 'Nome lógico da database :'+ @logicalname_origem + char(13) ;
	SET @return = @return + 'Nome lógico do arquivo de logs :'+ @logicalname_origem_log + char(13) ;
	SET @return = @return + 'Local de destino do arquivo de Backup :'+ @path_files + char(13) ;
	SET @return = @return + 'Arquivo MDF origem '+ @file_mdf + char(13) ;
	SET @return = @return + 'Arquivo LDF origem '+ @file_ldf + char(13) ;
	SET @return = @return + 'Caminho completo do arquivo de Backup destino '+ @bkp_file + char(13) ;

	SET @return = @return + 'Inicionado processo de Backup, arquivo: '+ @bkp_file + char(13) ;
	BACKUP DATABASE @dbname_origem TO DISK = @bkp_file
	WITH CHECKSUM, COPY_ONLY, FORMAT, INIT, STATS = 10;

	SET @return = @return + 'Definindo caminho completo dos novos arquivo MDF e LDF para a database destino' + char(13) ;
	SET @dest_mdf_file = @path_files + @dbname_destino + '.mdf';
	SET @dest_ldf_file = @path_files + @dbname_destino + '_log.ldf';
	SET @return = @return + 'Caminho completo do MDF de destino '+ @dest_mdf_file + char(13) ;
	SET @return = @return + 'Caminho completo do LDF de destino '+ @dest_ldf_file + char(13) ;

	SET @return = @return + 'Restaurando a database...' + char(13) ;
	RESTORE DATABASE @dbname_destino FROM DISK = @bkp_file
	WITH CHECKSUM, 
	MOVE @logicalname_origem TO @dest_mdf_file, 
	MOVE @logicalname_origem_log TO @dest_ldf_file, 
	RECOVERY, REPLACE, STATS = 10;

	SET @return = @return + 'Removendo arquivo de Backup criado durante o processo' + char(13) ;
	SET @cmd_delbkpfile = 'del '+ @bkp_file;
	
	BEGIN TRY
		EXEC master.dbo.xp_cmdshell @cmd_delbkpfile;
	END TRY
	BEGIN CATCH
		SELECT @return = @return + 'Erro ao remover arquivo: ' + ERROR_MESSAGE() + char(13) ;
	END CATCH;
	
	SET @return = @return + 'Backup Finalizado!' + char(13) ;

END
