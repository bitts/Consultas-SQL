 
/*
PLT030 - Boletim Turma-Aluno
	Create By Bitts
	(11/12/2015)
*/



--GO
--DECLARE @N1 FLOAT, @N2 FLOAT, @N3 FLOAT, @MF FLOAT;
/*
@N1 = CASE @N1 WHEN = '' THEN (, '') 
ELSE @NOTA1 (A.CODDISCREQ, '') 
END
*/

SELECT
	A.CODFILIAL,
	F.NOME AS ALUNO,
	A.RA AS RA,
	I.NOME AS CURSO,
	A.CODTURMA AS TURMA,
	D.NUMDIARIO AS NUMCHAMADA,
	L.NOME AS DISCIPLINA,
	Q.CH AS CARGA_HORARIA,
	C.CODPERLET AS PLETIVO,
	P.NOME AS SERIE,
	A.CODSTATUSRES,
	C.DIASLETIVOS,
	N1.NOTA AS N1, F1.FALTAS AS F1, 
	N2.NOTA AS N2, F2.FALTAS AS F2,
	N3.NOTA AS N3, F3.FALTAS AS F3,	
	MA.NOTA AS MA,
	EX.NOTA AS EX,	
	CASE 
	
	-- N1 (NOT NULL) | N2 (NOT NULL) | N3 (NOT NULL) | MA >= 7
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NOT NULL AND ((N1.NOTA + N2.NOTA + N3.NOTA)/3) >= 7    
	THEN 
		(N1.NOTA + N2.NOTA + N3.NOTA)/3  
	
	-- N1 (NULL) | N2 (NOT NULL) | N3 (NOT NULL) | MA >= 7	
	WHEN
		N1.NOTA IS NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NOT NULL AND ((N2.NOTA + N3.NOTA)/2) >= 7    
	THEN 
		(N2.NOTA + N3.NOTA)/2 
	
	-- N1 (NOT NULL) | N2 (NULL) | N3 (NOT NULL) | MA >= 7	
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NULL AND N3.NOTA IS NOT NULL AND ((N1.NOTA + N3.NOTA)/2) >= 7    
	THEN 
		(N1.NOTA + N3.NOTA)/2 
	
	-- N1 (NOT NULL) | N2 (NOT NULL) | N3 (NULL) | MA >= 7		
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NULL AND ((N1.NOTA + N2.NOTA)/2) >= 7    
	THEN 
		(N1.NOTA + N2.NOTA)/2 
	
	-- N1 (NOT NULL) | N2 (NOT NULL) | N3 (NOT NULL) | MA < 7			
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NOT NULL AND ((N1.NOTA + N2.NOTA + N3.NOTA)/3) < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(((N1.NOTA + N2.NOTA + N3.NOTA)/3) + EX.NOTA)/2
	
	-- N1 (NULL) | N2 (NOT NULL) | N3 (NOT NULL) | MA < 7			
	WHEN
		N1.NOTA IS NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NOT NULL AND ((N2.NOTA + N3.NOTA)/2) < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(((N2.NOTA + N3.NOTA)/2) + EX.NOTA)/2
	
	-- N1 (NOT NULL) | N2 (NULL) | N3 (NOT NULL) | MA < 7			
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NULL AND N3.NOTA IS NOT NULL AND ((N1.NOTA + N3.NOTA)/2) < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(((N1.NOTA + N3.NOTA)/2) + EX.NOTA)/2
	
	-- N1 (NOT NULL) | N2 (NOT NULL) | N3 ( NULL) | MA < 7 | EX		
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NULL AND ((N1.NOTA + N2.NOTA)/2) < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(((N2.NOTA + N3.NOTA)/2) + EX.NOTA)/2
		
	WHEN
		N1.NOTA IS NOT NULL AND N2.NOTA IS NULL AND N3.NOTA IS NULL AND N1.NOTA < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(N1.NOTA + EX.NOTA)/2
	WHEN
		N1.NOTA IS NULL AND N2.NOTA IS NOT NULL AND N3.NOTA IS NULL AND N2.NOTA < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(N2.NOTA + EX.NOTA)/2	
	WHEN
		N1.NOTA IS NULL AND N2.NOTA IS NULL AND N3.NOTA IS NOT NULL AND N3.NOTA < 7 AND EX.NOTA IS NOT NULL
	THEN 
		(N3.NOTA + EX.NOTA)/2
		
	
		
	ELSE NULL
		END AS MF,
	AULAS.TOTAL AS TOTALAULAS,
	CASE WHEN 
		N.DESCRICAO = 'Matriculado'
			THEN '-'
			ELSE N.DESCRICAO
		END AS SITUACAO,
	CASE
		WHEN O.DESCRICAO IS NULL
			THEN 'N/C'
			ELSE O.DESCRICAO
		END AS RESFINAL
FROM
	
	SMATRICPL AS A (NOLOCK)
		INNER JOIN GFILIAL AS B (NOLOCK) ON
			A.CODCOLIGADA = B.CODCOLIGADA AND
			A.CODFILIAL = B.CODFILIAL
		INNER JOIN SPLETIVO AS C (NOLOCK) ON
			A.CODCOLIGADA = C.CODCOLIGADA AND
			A.IDPERLET = C.IDPERLET
		INNER JOIN SMATRICULA AS D (NOLOCK) ON
			A.CODCOLIGADA = D.CODCOLIGADA AND
			A.IDPERLET = D.IDPERLET AND
			A.RA = D.RA AND
			A.IDHABILITACAOFILIAL = D.IDHABILITACAOFILIAL
		INNER JOIN SALUNO AS E (NOLOCK) ON
			D.CODCOLIGADA = E.CODCOLIGADA AND 
			E.CODTIPOCURSO = C.CODTIPOCURSO AND
			D.RA = E.RA 
		INNER JOIN PPESSOA AS F (NOLOCK) ON
			E.CODPESSOA = F.CODIGO
		INNER JOIN SHABILITACAOFILIAL AS G (NOLOCK) ON
			A.CODCOLIGADA = G.CODCOLIGADA AND
			A.IDHABILITACAOFILIAL = G.IDHABILITACAOFILIAL AND 
			A.CODFILIAL = G.CODFILIAL
		INNER JOIN STURNO AS H (NOLOCK) ON
			H.CODCOLIGADA = G.CODCOLIGADA AND
			H.CODTURNO = G.CODTURNO AND 
			H.CODFILIAL = G.CODFILIAL AND 
			H.CODTIPOCURSO = C.CODTIPOCURSO
		LEFT JOIN SCURSO I (NOLOCK) ON
			I.CODCOLIGADA = G.CODCOLIGADA AND
			I.CODCURSO = G.CODCURSO AND 
			I.CODAREA = E.CODAREA 
		INNER JOIN SHABILITACAO AS J (NOLOCK) ON
			J.CODCOLIGADA = G.CODCOLIGADA AND
			J.CODCURSO = G.CODCURSO AND
			J.CODHABILITACAO = G.CODHABILITACAO
		INNER JOIN STURMADISC AS K (NOLOCK) ON
			K.CODCOLIGADA = D.CODCOLIGADA AND
			K.IDTURMADISC = D.IDTURMADISC 
		INNER JOIN SDISCIPLINA AS L (NOLOCK) ON 
			L.CODCOLIGADA = K.CODCOLIGADA AND
			L.CODDISC = K.CODDISC 
		INNER JOIN SSTATUS AS N (NOLOCK) ON
			N.CODCOLIGADA = D.CODCOLIGADA AND
			N.CODSTATUS = D.CODSTATUS AND 
			N.CODTIPOCURSO = C.CODTIPOCURSO
		LEFT JOIN SSTATUS AS O (NOLOCK) ON
			O.CODCOLIGADA = A.CODCOLIGADA AND
			O.CODSTATUS = A.CODSTATUSRES AND 
			O.CODTIPOCURSO = C.CODTIPOCURSO
		INNER JOIN SHABILITACAO AS P (NOLOCK) ON
			P.CODCURSO = G.CODCURSO AND
			P.CODHABILITACAO = G.CODHABILITACAO	
		LEFT JOIN SDISCGRADE AS Q (NOLOCK) ON
			Q.CODDISC = L.CODDISC AND
			Q.CODHABILITACAO = P.CODHABILITACAO AND
			Q.CODCURSO = I.CODCURSO AND 
			Q.CODCOLIGADA = A.CODCOLIGADA AND 
			Q.CODGRADE = G.CODGRADE
		LEFT JOIN SPERIODO AS R (NOLOCK) ON
			R.CODCURSO = Q.CODCURSO AND
			R.CODHABILITACAO = P.CODHABILITACAO AND
			R.CODGRADE = Q.CODGRADE AND
			R.CODPERIODO = Q.CODPERIODO
		INNER JOIN STURMA AS S (NOLOCK) ON
			S.CODCOLIGADA = A.CODCOLIGADA AND
			S.CODFILIAL = A.CODFILIAL AND
			S.IDPERLET = A.IDPERLET AND
			S.CODTURMA = A.CODTURMA 
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) N1 (RA, NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			N1.CODCOLIGADA = D.CODCOLIGADA AND 
			N1.IDTURMADISC = D.IDTURMADISC AND
			N1.RA = D.RA AND 
			N1.CODETAPA = '1'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS FALTAS, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) F1 (RA, FALTAS, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			F1.CODCOLIGADA = D.CODCOLIGADA AND 
			F1.IDTURMADISC = D.IDTURMADISC AND
			F1.RA = D.RA AND 
			F1.CODETAPA = '2'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) N2 (RA, NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			N2.CODCOLIGADA = D.CODCOLIGADA AND 
			N2.IDTURMADISC = D.IDTURMADISC AND
			N2.RA = D.RA AND 
			N2.CODETAPA = '3'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS FALTAS, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) F2 (RA, FALTAS, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			F2.CODCOLIGADA = D.CODCOLIGADA AND 
			F2.IDTURMADISC = D.IDTURMADISC AND
			F2.RA = D.RA AND 
			F2.CODETAPA = '4'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) N3 (RA, NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			N3.CODCOLIGADA = D.CODCOLIGADA AND 
			N3.IDTURMADISC = D.IDTURMADISC AND
			N3.RA = D.RA AND 
			N3.CODETAPA = '5'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS FALTAS, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) F3 (RA, FALTAS, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			F3.CODCOLIGADA = D.CODCOLIGADA AND 
			F3.IDTURMADISC = D.IDTURMADISC AND
			F3.RA = D.RA AND 
			F3.CODETAPA = '6'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) MA (RA, NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			MA.CODCOLIGADA = D.CODCOLIGADA AND 
			MA.IDTURMADISC = D.IDTURMADISC AND
			MA.RA = D.RA AND 
			MA.CODETAPA = '7'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) EX (RA, NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			EX.CODCOLIGADA = D.CODCOLIGADA AND 
			EX.IDTURMADISC = D.IDTURMADISC AND
			EX.RA = D.RA AND 
			EX.CODETAPA = '8'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(FLOAT, NOTAFALTA) AS NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA
		) MF (RA, NOTA, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
			MF.CODCOLIGADA = D.CODCOLIGADA AND 
			MF.IDTURMADISC = D.IDTURMADISC AND
			MF.RA = D.RA AND 
			MF.CODETAPA = '10'
		LEFT JOIN (
			SELECT 
				RA, CONVERT(INT, AULASDADAS) AS TOTAL, CODCOLIGADA, IDTURMADISC, CODETAPA 
			FROM 
				SNOTAETAPA X 
			) AULAS (RA, TOTAL, CODCOLIGADA, IDTURMADISC, CODETAPA) ON
				AULAS.CODCOLIGADA = D.CODCOLIGADA AND 
				AULAS.IDTURMADISC = D.IDTURMADISC AND
				AULAS.RA = D.RA AND 
				AULAS.CODETAPA = '10'
			
WHERE

	S.CODCOLIGADA = '3' AND
	C.CODPERLET = '2016' AND
    A.CODSTATUS IN ('17','43','54','64','67','47','23','53','39','50','60','2','44','65','55','19','18','20','34','28','51','40','61') AND
    D.CODSTATUS IN ('17','43','54','64','67','47','23','53','39','50','60','2','44','65','55','19','18','20','34','28','51','40','61') AND
	D.NUMDIARIO IS NOT NULL AND
	S.CODTURMA = 'EF062'
ORDER BY
	I.CODCURSO,
	A.CODTURMA,
	A.RA,
	L.CODDISC