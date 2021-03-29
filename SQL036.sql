/*
	PLT65 - Script para correção de endereços da Tabela FCFO 
	Create By Bitts (15/09/2017)
	
	Situação: endereço dos boletos não devem possuir mais que 40 caracteres para não dar problema no arquivo de envio	de remessa bancaria. 
	Solução: criar script que abrevia o máximo possível palavras dos campos RUA, NUMERO e COMPLEMENTO da tabela FCFO
	- possivel incluir novas palavras, para adicionar modificar o script:	
	SET @TextoTmp = REPLACE(	======> SET @TextoTmp = REPLACE(REPLACE(	/* adicione a REPLACE( */
	...
	'RUA','R.'),				======> 'RUA','R.'),'LIVRO','L.'),			/* adicione a palavra e a sua substituta a lista das demais */
*/


DECLARE 
	@CODCFO VARCHAR(25), 
	@NOMEFANTASIA VARCHAR(100), 
	@ENDERECO VARCHAR(200),
	@TAMANHOE INT,
	@CODFILIAL SMALLINT,
	@RUA VARCHAR(100),
	@NUMERO VARCHAR(8),
	@COMPLEMENTO VARCHAR(60),
    
	@TextoTmp VARCHAR(100),

	@debug CHAR(1) = 'S',

	@SQL VARCHAR(MAX)


DECLARE c_ENDERECO CURSOR FOR
	SELECT 
		a.CODCFO, a.NOMEFANTASIA, (a.RUA +' ' + a.NUMERO+' / '+ a.COMPLEMENTO) as ENDERECO,
		LEN(a.RUA +' ' + a.NUMERO+' / '+ a.COMPLEMENTO) as TAMANHOE, 
		a.RUA,a.NUMERO, a.COMPLEMENTO,
		c.CODFILIAL
	FROM 
		FCFO as a, SALUNO as b, SCONTRATO as c
	WHERE 
		b.RA = c.RA AND
		a.CODCFO = b.CODCFO AND 
		LEN(a.RUA +' ' + a.NUMERO+' / '+ a.COMPLEMENTO) > 40 
	ORDER BY 
		c.codfilial, TAMANHOE 
	DESC

OPEN c_ENDERECO 

FETCH NEXT FROM c_ENDERECO INTO 
	@CODCFO,
	@NOMEFANTASIA, 
	@ENDERECO, 
	@TAMANHOE,
	@RUA, 
	@NUMERO, 
	@COMPLEMENTO,
	@CODFILIAL

	WHILE @@FETCH_STATUS = 0 
		BEGIN
			
			IF(@debug = 'S')PRINT 'ENDEREÇO COMPLETO: '+ CONVERT(VARCHAR(200), @ENDERECO) + ' ['+ CONVERT(VARCHAR, @TAMANHOE) +']'

			SET @SQL = 'UPDATE FCFO SET '

			DECLARE @I AS INT = 1
			DECLARE @nTextTmp VARCHAR(100)
			DECLARE @PALAVRA VARCHAR(30)
			DECLARE V_PALAVRA CURSOR FOR
				SELECT @RUA UNION SELECT @NUMERO UNION SELECT @COMPLEMENTO
				OPEN V_PALAVRA;
				FETCH NEXT FROM V_PALAVRA INTO @PALAVRA
				WHILE (@@FETCH_STATUS = 0)
					BEGIN
						IF(@debug = 'S')PRINT 'Palavra original: '+ @PALAVRA + ' ['+ CONVERT(VARCHAR,LEN(@PALAVRA)) +']'

						SET @TextoTmp = UPPER( REPLACE(REPLACE(REPLACE(REPLACE(@PALAVRA,'  ',' '),'  ',' '),'   ',' '),'..','.') )
						SET @TextoTmp = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TextoTmp,
							'RUA','R.'),
							'BITTENCOURT','BITENCOURT'),
							'PROXIMO','PROX.'),
							'LIVRO', 'L.'),
							'DOUTOR','DR.'),
							'PROFESSOR','PROF.'),
							'VEREADORES','VER.'),
							'VEREADORA','VER.'),
							'VEREADOR','VER.'),
							'DESEMBARGADOR','DESEMB'),
							'GENERAL','GEN'),
							'CAPITÃO','CAP'),
							'CORONEL','CEL'),
							'TENENTE','TEN'),
							'JUSCELINO KUBITSCHEK','JK'),
							'RESIDENCIAL','RES.'),
							'DIVISÃO','DIV.'),
							'TRAVESSA','T.'),
							'HOSPITAL','HOSP.'),
							'AVENIDA','AV.'),
							'RUA','R.'),
							'COLÉGIO','COL.'),
							'PADRE','PE.'),
							'FAIXA','FX.'),
							'BLOCO','BL.'),
							'LOTE','LT.'),
							'NÚMERO','N.'),
							'VILA','V.'),
							'APARTAMENTO','APTO'),
							'QUADRA','QD.'),
							'CONSTRUCAO','CONSTR.'),
							'CONDOMINIO','COND.'),
							'LOTE','LT.'),
							'NOSSA SENHORA','N.SRA.'),
							'ESTRADA','EST.'),
							'..','.')
								
						SET @TextoTmp = LTRIM(RTRIM(@TextoTmp))

						IF(@debug = 'S')PRINT 'Palavra após substituição: '+ @TextoTmp + ' ['+ CONVERT(VARCHAR, LEN(@TextoTmp)) +']'+CHAR(13);
					
						IF(@I = 3) SET @SQL = @SQL + ', RUA = '+ CHAR(39) + @TextoTmp + CHAR(39)
						IF(@I = 1) SET @SQL = @SQL + 'NUMERO = '+ CHAR(39) + @TextoTmp + CHAR(39)
						IF(@I = 2) SET @SQL = @SQL + ', COMPLEMENTO = '+ CHAR(39) + @TextoTmp + CHAR(39)
							
						SET @I = @I + 1;

						FETCH NEXT FROM V_PALAVRA INTO @PALAVRA;
					END
			CLOSE V_PALAVRA;
			DEALLOCATE V_PALAVRA;
		
			SET @SQL = @SQL + ' WHERE CODCFO='+ CHAR(39) + @CODCFO + CHAR(39)+'; '+CHAR(13);

			IF(@debug = 'S')PRINT 'Novo Endereço : '+ @TextoTmp + ' ['+ CONVERT(VARCHAR, LEN(@TextoTmp)) +']'
			IF( LEN(@TextoTmp) <= 40)PRINT @SQL
			PRINT '--------------------------'

			FETCH NEXT FROM c_ENDERECO INTO 
				@CODCFO,
				@NOMEFANTASIA, 
				@ENDERECO, 
				@TAMANHOE,
				@RUA, 
				@NUMERO, 
				@COMPLEMENTO,
				@CODFILIAL 
		END

CLOSE c_ENDERECO

DEALLOCATE c_ENDERECO





