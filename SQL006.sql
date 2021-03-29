/*
	PLT019 - Função para limpar um número ClearNumber - cNumber
	Create By Bitts
	(13/11/2015)
	
	UTILIZAÇÃO: SELECT dbo.cNumber(E.TELEFONE1) FROM PPESSOA
*/

CREATE FUNCTION [dbo].[cNumber](@Resultado VARCHAR(8000)) RETURNS VARCHAR(8000) AS
BEGIN
	DECLARE @CharInvalido SMALLINT
	SET @CharInvalido = PATINDEX('%[^0-9]%', @Resultado)
	WHILE @CharInvalido > 0
		BEGIN
			SET @Resultado = STUFF(@Resultado, @CharInvalido, 1, '')
			SET @CharInvalido = PATINDEX('%[^0-9]%', @Resultado)
		END
	SET @Resultado = @Resultado
	RETURN @Resultado
END;

