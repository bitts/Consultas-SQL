/*
	PLT09 - Script para cubo do ENAD
	Create By Bitts (31/07/2015)
	
	Obs.: Iniciado por Marcelo Fumaco e Terminado por Bitts
*/

SELECT
	A.RA,
	G.CODPESSOA,
	UPPER(H.NOME) AS NOME,
	I.NOME AS CURSO,
	M.DESCRICAO AS [SITUACAO],
	B.CODGRADE AS [MATRIZ CURRICULAR],
		
	ELETIVAS.CHT_ELETIVA AS [CARGA HORARIA TORAL - DISCIPLINAS ELETIVAS],
	SUM(F.CH) AS [CARGA HORARIA REALIZADA - DISCIPLINAS ELETIVAS],
	CONVERT(VARCHAR, CEILING((CASE WHEN SUM(F.CH) > ELETIVAS.CHT_ELETIVA THEN ELETIVAS.CHT_ELETIVA ELSE SUM(F.CH) END) * 100 / ELETIVAS.CHT_ELETIVA )) +'%' AS [PERCENTAGEM CONCLUIDA - DISCIPLINAS ELETIVAS],
	
	SOPTATIVAS.CHT_OPTATIVAS AS [CARGA HORARIA TOTAL - DISCIPLINAS OPTATIVAS],
	ISNULL (OPTATIVAS.CHTOTAL,0) AS [CARGA HORARIA - DISCIPLINAS OPTATIVAS],
	CONVERT(VARCHAR, CEILING((CASE WHEN ISNULL (OPTATIVAS.CHTOTAL,0) > SOPTATIVAS.CHT_OPTATIVAS THEN SOPTATIVAS.CHT_OPTATIVAS ELSE ISNULL (OPTATIVAS.CHTOTAL,0) END) * 100 / SOPTATIVAS.CHT_OPTATIVAS))+'%' AS [PERCENTAGEM CONCLUIDA - DISCIPLINAS OPTATIVAS],
	
	K.VALORMINIMO AS [CARGA HORARIA TOTAL - ATIVIDADES COMPLEMENTARES],
	ISNULL (SATIVCOMP.CARGH, 0) AS [CARGA HORARIA - ATIVIDADES COMPLEMENTARES],
	CONVERT(VARCHAR, CEILING((CASE WHEN ISNULL (SATIVCOMP.CARGH, 0) > K.VALORMINIMO THEN K.VALORMINIMO ELSE ISNULL (SATIVCOMP.CARGH, 0) END) * 100 / K.VALORMINIMO))+'%' AS [PERCENTAGEM CONCLUIDA - ATIVIDADES COMPLEMENTARES],
	
	(ELETIVAS.CHT_ELETIVA + SOPTATIVAS.CHT_OPTATIVAS + K.VALORMINIMO) AS [CARGA HORARIA TOTAL DO CURSO],
	
	(CASE WHEN SUM(F.CH) > ELETIVAS.CHT_ELETIVA THEN ELETIVAS.CHT_ELETIVA ELSE SUM(F.CH) END) + 
	(CASE WHEN ISNULL (OPTATIVAS.CHTOTAL,0) > SOPTATIVAS.CHT_OPTATIVAS THEN SOPTATIVAS.CHT_OPTATIVAS ELSE ISNULL (OPTATIVAS.CHTOTAL,0) END) + 
	(CASE WHEN ISNULL (SATIVCOMP.CARGH, 0) > K.VALORMINIMO THEN K.VALORMINIMO ELSE ISNULL (SATIVCOMP.CARGH, 0) END) AS [CARGA HORARIA TOTAL]
	,	
	CONVERT(VARCHAR, CEILING(
	(
		(CASE WHEN SUM(F.CH) > ELETIVAS.CHT_ELETIVA THEN ELETIVAS.CHT_ELETIVA ELSE SUM(F.CH) END) + 
		(CASE WHEN ISNULL (OPTATIVAS.CHTOTAL,0) > SOPTATIVAS.CHT_OPTATIVAS THEN SOPTATIVAS.CHT_OPTATIVAS ELSE ISNULL (OPTATIVAS.CHTOTAL,0) END) + 
		(CASE WHEN ISNULL (SATIVCOMP.CARGH, 0) > K.VALORMINIMO THEN K.VALORMINIMO ELSE ISNULL (SATIVCOMP.CARGH, 0) END)
	) * 100 / (ELETIVAS.CHT_ELETIVA + SOPTATIVAS.CHT_OPTATIVAS + K.VALORMINIMO)
	))+'%' AS [PERCENTAGEM TOTAL CONCLUIDA DO CURSO],
	
	DISC_TOTAL.TOTAL_DISCIPLINAS AS [TOTAL DE DISCIPLINAS],
	ISNULL( DISC_REST.TOTAL_RESTANTES, 0) AS [DISCIPLINAS RESTANTES],
	CONVERT(VARCHAR, CEILING(( ISNULL(DISC_REST.TOTAL_RESTANTES,0) * 100) / DISC_TOTAL.TOTAL_DISCIPLINAS ))+'%' AS [PERCENTAGEM RESTANTE DISCIPLINAS],
	
	DISC_STATUS.CODDISC AS [DISCIPLINA - CODIGO], 
	DISC_STATUS.CH AS [DISCIPLINA - CARGA HORARIA], 
	DISC_STATUS.NOME AS [DISCIPLINA - NOME], 
	DISC_STATUS.STATUS AS [DISCIPLINA - STATUS]
FROM
	SHABILITACAOALUNO A(NOLOCK)
		LEFT JOIN  (
			SELECT 
				RA, SUM (CARGAHORARIAATV) AS ATIVIDADES 
			FROM  
				SATIVIDADEALUNO	(NOLOCK)		
			GROUP BY RA
		) SATIVCOMP (RA, CARGH) ON 
			SATIVCOMP.RA = A.RA
	
		LEFT JOIN (
			SELECT  
				A.RA, SUM(F.CH) AS CHTOTAL
			FROM
				SHABILITACAOALUNO A(NOLOCK),
				SHABILITACAOFILIAL B(NOLOCK),
				SGRADE C(NOLOCK),
				SPERIODO D(NOLOCK),
				SDISCGRADE E(NOLOCK)
					LEFT JOIN 
					SHISTDISCOPTELETIVAS F(NOLOCK) ON 
						F.STATUS = 'Aprovado'
			WHERE
				A.CODCOLIGADA = '3' AND
				A.CODCOLIGADA = B.CODCOLIGADA AND
				A.IDHABILITACAOFILIAL = B.IDHABILITACAOFILIAL AND
				B.CODCOLIGADA = C.CODCOLIGADA AND
				B.CODCURSO = C.CODCURSO AND
				B.CODHABILITACAO = C.CODHABILITACAO AND
				B.CODGRADE = C.CODGRADE AND
				C.CODCOLIGADA = D.CODCOLIGADA AND
				C.CODCURSO = D.CODCURSO AND
				C.CODHABILITACAO = D.CODHABILITACAO AND
				C.CODGRADE = D.CODGRADE AND
				D.CODCOLIGADA = E.CODCOLIGADA AND
				D.CODCURSO = E.CODCURSO AND
				D.CODHABILITACAO = E.CODHABILITACAO AND
				D.CODGRADE = E.CODGRADE AND
				D.CODPERIODO = E.CODPERIODO AND
				E.TIPODISC IN ('O','E') AND
				A.CODCOLIGADA = F.CODCOLIGADA AND
				A.RA = F.RA AND
				E.CODDISC = F.CODDISC AND
				A.IDHABILITACAOFILIAL = F.IDHABILITACAOFILIAL
			GROUP BY 
				A.RA, F.STATUS
		) OPTATIVAS (RA, CHTOTAL) ON OPTATIVAS.RA = A.RA
		
		LEFT JOIN (
			SELECT 
				C.RA, COUNT(B.CODDISC) AS DISCIPLINAS_RESTANTES
			FROM 
				SDISCGRADE A (NOLOCK)
					LEFT JOIN SDISCIPLINA B (NOLOCK) ON 
						A.CODDISC = B.CODDISC,
				SHABILITACAOALUNO C (NOLOCK)
					LEFT JOIN SHABILITACAOFILIAL D (NOLOCK) ON 
						C.IDHABILITACAOFILIAL = D.IDHABILITACAOFILIAL
			WHERE 
				A.TIPODISC = 'B' AND 
				A.CODGRADE = D.CODGRADE AND 
				B.CODDISC NOT IN (SELECT CODDISC FROM SHISTDISCCONCLUIDAS WHERE RA=C.RA)
			GROUP BY 
				C.RA	
		) DISC_REST (RA, TOTAL_RESTANTES) ON 
			DISC_REST.RA = A.RA
			
		LEFT JOIN (
			SELECT 
				C.RA, COUNT(B.CODDISC) AS TOTAL_DISCIPLINAS
			FROM 
				SDISCGRADE A (NOLOCK)
					LEFT JOIN SDISCIPLINA B (NOLOCK) ON 
						A.CODDISC = B.CODDISC,
				SHABILITACAOALUNO C (NOLOCK)
					LEFT JOIN SHABILITACAOFILIAL D (NOLOCK) ON 
						C.IDHABILITACAOFILIAL = D.IDHABILITACAOFILIAL
			WHERE 
				A.TIPODISC = 'B' AND 
				A.CODGRADE = D.CODGRADE
			GROUP BY
				C.RA
		) DISC_TOTAL (RA, TOTAL_DISCIPLINAS) ON DISC_TOTAL.RA = A.RA
	
		LEFT JOIN (
			SELECT 
				C.RA, A.CODCURSO, C.IDHABILITACAOFILIAL, B.CODDISC, CONVERT(INT, B.CH) AS CH, B.NOME, CASE WHEN ISNULL(E.CODSTATUS,0) = 0 THEN 'Não Realizada' ELSE 'Concluida' END AS STATUS
			FROM 
				SDISCGRADE AS A (NOLOCK) 
					INNER JOIN SDISCIPLINA AS B (NOLOCK) ON 
						A.TIPODISC = 'B' AND
						A.CODDISC = B.CODDISC AND 
						A.CODCOLIGADA = B.CODCOLIGADA
					INNER JOIN SHABILITACAOALUNO AS C (NOLOCK) ON			
						A.CODCOLIGADA = C.CODCOLIGADA
					INNER JOIN SHABILITACAOFILIAL AS D (NOLOCK) ON 
						C.IDHABILITACAOFILIAL = D.IDHABILITACAOFILIAL AND 
						A.CODGRADE = D.CODGRADE	AND
						D.IDHABILITACAOFILIAL = C.IDHABILITACAOFILIAL AND
						A.CODCOLIGADA = D.CODCOLIGADA AND 
						A.CODCURSO = D.CODCURSO
					LEFT JOIN SHISTDISCCONCLUIDAS AS E (NOLOCK) ON
						A.CODDISC = E.CODDISC AND
						A.CODCOLIGADA = E.CODCOLIGADA AND
						E.RA = C.RA
		) DISC_STATUS (RA, CODCURSO, IDHABILITACAOFILIAL, CODDISC, CH, NOME, STATUS ) ON 
			DISC_STATUS.RA = A.RA AND 
			DISC_STATUS.IDHABILITACAOFILIAL = A.IDHABILITACAOFILIAL
	,
	SHABILITACAOFILIAL B(NOLOCK)
		LEFT JOIN (
			SELECT 
				SG.CODGRADE, SUM(SD.CH) AS TOTAL_CH_ELETIVA
			FROM 
				SDISCGRADE SG (NOLOCK)
				LEFT JOIN SDISCIPLINA SD (NOLOCK) ON 
					SG.CODDISC=SD.CODDISC
			WHERE 
				SG.TIPODISC = 'B'
			GROUP BY 
				SG.CODCURSO, SG.CODGRADE, SG.TIPODISC
		) ELETIVAS ( CODGRADE, CHT_ELETIVA ) ON ELETIVAS.CODGRADE=B.CODGRADE	
	
		LEFT JOIN  (
			SELECT 
				SUM(VALOROPTATIVA) AS CHT_OPTATIVAS, CODGRADE
			FROM 
				SPERIODO (NOLOCK)
			GROUP BY 
				CODCURSO, CODGRADE
		) SOPTATIVAS (CHT_OPTATIVAS, CODGRADE) ON 
			SOPTATIVAS.CODGRADE = B.CODGRADE 
	,
	SGRADE C(NOLOCK),
	SPERIODO D(NOLOCK),
	SDISCGRADE E(NOLOCK),
	SHISTDISCCONCLUIDAS F(NOLOCK),
	SALUNO G(NOLOCK),
	PPESSOA H (NOLOCK),
	SCURSO I(NOLOCK),
	SCOMPONENTECURRICULAR K (NOLOCK), 
	SCOMPONENTE L (NOLOCK),
	SSTATUS M (NOLOCK)
WHERE
	A.CODSTATUS = M.CODSTATUS AND
	A.CODCOLIGADA = '3' AND
	A.CODCOLIGADA = B.CODCOLIGADA AND
	A.IDHABILITACAOFILIAL = B.IDHABILITACAOFILIAL AND
	B.CODCOLIGADA = C.CODCOLIGADA AND
	B.CODCURSO = C.CODCURSO AND
	B.CODHABILITACAO = C.CODHABILITACAO AND
	B.CODGRADE = C.CODGRADE AND
	C.CODCOLIGADA = D.CODCOLIGADA AND
	C.CODCURSO = D.CODCURSO AND
	C.CODHABILITACAO = D.CODHABILITACAO AND
	C.CODGRADE = D.CODGRADE AND
	D.CODCOLIGADA = E.CODCOLIGADA AND
	D.CODCURSO = E.CODCURSO AND
	D.CODHABILITACAO = E.CODHABILITACAO AND
	D.CODGRADE = E.CODGRADE AND
	D.CODPERIODO = E.CODPERIODO AND
    E.TIPODISC IN ('B','E') AND
	A.CODCOLIGADA = F.CODCOLIGADA AND
	A.RA = F.RA AND
	E.CODDISC = F.CODDISC AND
    A.IDHABILITACAOFILIAL = F.IDHABILITACAOFILIAL AND	
	G.RA = A.RA AND
	G.CODPESSOA = H.CODIGO AND
	B.CODCURSO = I.CODCURSO AND
	K.CODCOMPONENTE=L.CODCOMPONENTE AND
	B.IDHABILITACAOFILIAL=K.IDHABILITACAOFILIAL
--AND G.RA = '%'
GROUP BY 
	A.RA, 
	M.DESCRICAO,
	H.NOME, 
	G.RA, 
	OPTATIVAS.CHTOTAL, 
	G.CODPESSOA, 
	I.NOME, 
	SATIVCOMP.CARGH, 
	ELETIVAS.CHT_ELETIVA, 
	B.CODGRADE, 
	K.VALORMINIMO,
	SOPTATIVAS.CHT_OPTATIVAS,
	DISC_REST.TOTAL_RESTANTES,
	DISC_TOTAL.TOTAL_DISCIPLINAS,	
	DISC_STATUS.CODDISC, 
	DISC_STATUS.CH, 
	DISC_STATUS.NOME, 
	DISC_STATUS.STATUS