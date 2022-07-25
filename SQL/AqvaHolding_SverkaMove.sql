SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pmp
-- Create date: 2022-07-28
-- Description:	Отчет о движении ТМЦ
-- =============================================
alter PROCEDURE AqvaHolding_SverkaMove 
	@dtBeg smalldatetime = Null, 
	@dtEnd smalldatetime = Null
AS

	-- Остатки на начало и конец выбранных дат
	SELECT DISTINCT A.COD_ARTIC,
				CAST(SUM(REPORTS.dbo.A_GetStorageRest(A.COD_ARTIC, @dtBeg, A.ID_SCLAD, 0)) as numeric(10, 2)) as 'UpakBeg',
				CAST(SUM(REPORTS.dbo.A_GetStorageRest(A.COD_ARTIC, @dtEnd+1, A.ID_SCLAD, 0)) as numeric(10, 2)) as 'UpakEnd'
	INTO #Balance
	FROM FOLIOBASE2..SCL_ARTC A WITH (NOLOCK)
	WHERE A.TIP_TOVR = 'ТЭСТИ'
		  and A.ID_SCLAD != 14
		  and A.NGROUP_TVR != 'Снято'
	GROUP BY A.COD_ARTIC
	ORDER BY A.COD_ARTIC



	-- Продажи
	SELECT DISTINCT A.COD_ARTIC,
		  CAST(SUM(M.KOLC_PREDM) as numeric(10,2)) as KOLC_PREDM
	INTO #Sales
	FROM FOLIOBASE2..SCL_NAKL N WITH (NOLOCK)
		LEFT JOIN FOLIOBASE2..SCL_MOVE M WITH (NOLOCK) ON N.UNICUM_NUM = M.UNICUM_NUM
		LEFT JOIN FOLIOBASE2..SCL_ARTC A WITH (NOLOCK) ON A.COD_ARTIC = M.NAME_PREDM
														  AND M.ID_SCLAD = A.ID_SCLAD
	WHERE N.DATE_P_POR BETWEEN @dtBeg AND @dtEnd
		  AND A.TIP_TOVR = 'ТЭСТИ'
		  AND N.TYPE_DOC= 'Р'
		  AND A.NGROUP_TVR != 'Снято'
		  AND ISNULL(N.VID_DOC, '') NOT IN ('МЕЖСКЛАДСКАЯ', 'ВИТРИНА')
		  AND N.ID_SCLAD != 14
	GROUP BY 
			A.COD_ARTIC


	-- Приходы от поставщика
	SELECT A.COD_ARTIC,
		   CAST(SUM(IsNull(M.KOLC_PREDM, 0)) as numeric(10, 2)) as KOLC_PREDM
	INTO #Incomes   
	FROM FOLIOBASE2..SCL_NAKL N WITH (NOLOCK) 
		LEFT JOIN FOLIOBASE2..SCL_MOVE M WITH (NOLOCK) ON N.UNICUM_NUM = M.UNICUM_NUM
		LEFT JOIN FOLIOBASE2..SCL_ARTC A WITH (NOLOCK) ON A.COD_ARTIC = M.NAME_PREDM
														  AND A.ID_SCLAD = M.ID_SCLAD
	WHERE A.NGROUP_TVR != 'Снято'
		  AND A.ID_SCLAD != 14
		  AND A.TIP_TOVR = 'ТЭСТИ'
		  AND N.TYPE_DOC = 'П'
		  AND N.DATE_P_POR BETWEEN @dtBeg AND @dtEnd
	GROUP BY A.COD_ARTIC,	
		     A.ID_SCLAD



    -- Приходы при коррекции
	SELECT DISTINCT A.COD_ARTIC,
		   CAST(SUM(M.KOLC_PREDM) as numeric(10,2)) as KOLC_PREDM
	INTO #IncomesCorrect
	FROM FOLIOBASE2..SCL_NAKL N WITH (NOLOCK)
		LEFT JOIN FOLIOBASE2..SCL_MOVE M WITH (NOLOCK) ON N.UNICUM_NUM = M.UNICUM_NUM
		LEFT JOIN FOLIOBASE2..SCL_ARTC A WITH (NOLOCK) ON A.COD_ARTIC = M.NAME_PREDM
														  AND M.ID_SCLAD = A.ID_SCLAD
	WHERE N.DATE_P_POR BETWEEN @dtBeg AND @dtEnd
		  AND A.TIP_TOVR = 'ТЭСТИ'
		  AND M.TYPDOCM_PR = 'П'
		  AND A.NGROUP_TVR != 'Снято'
		  AND IsNull(N.VID_DOC, '') IN  ('РЕВИЗИЯ', 'СБОРКА')
		  AND N.ID_SCLAD != 14
		  AND N.TYPE_DOC = 'Б'
	GROUP BY A.COD_ARTIC



    -- Расходы при коррекции
	SELECT DISTINCT A.COD_ARTIC,
		   CAST(SUM(M.KOLC_PREDM) as numeric(10,2)) as KOLC_PREDM
	INTO #SalesCorrect
	FROM FOLIOBASE2..SCL_NAKL N WITH (NOLOCK)
		LEFT JOIN FOLIOBASE2..SCL_MOVE M WITH (NOLOCK) ON N.UNICUM_NUM = M.UNICUM_NUM
		LEFT JOIN FOLIOBASE2..SCL_ARTC A WITH (NOLOCK) ON A.COD_ARTIC = M.NAME_PREDM
														  AND M.ID_SCLAD = A.ID_SCLAD
	WHERE N.DATE_P_POR BETWEEN @dtBeg AND @dtEnd
		  AND A.TIP_TOVR = 'ТЭСТИ'
		  AND M.TYPDOCM_PR = 'Р'
		  AND A.NGROUP_TVR != 'Снято'
		  AND IsNull(N.VID_DOC, '') IN  ('РЕВИЗИЯ', 'СПИСАНИЕ')
		  AND N.ID_SCLAD != 14
		  AND N.TYPE_DOC = 'Б'
	GROUP BY A.COD_ARTIC


	SELECT DISTINCT A.COD_ARTIC,
		            A.NAME_ARTIC,
					AA.S100,
					AA.S200,
					CAST(ISNULL(B.UpakBeg, 0) as numeric(15, 2)) as 'BegKolc',					
					CAST(ISNULL(S.KOLC_PREDM, 0) as numeric(15, 2)) as 'SalesKolc',
					CAST(ISNULL(I.KOLC_PREDM, 0) as numeric(15, 2)) as 'IncomeKolc',
					CAST(ISNULL(IC.KOLC_PREDM, 0) as numeric(15, 2)) as 'IncCorrKolc',
					CAST(IsNull(SC.KOLC_PREDM, 0) as numeric(15, 2)) as 'SalesCorrKolc',
					CAST(ISNULL(B.UpakEnd, 0) as numeric(15, 2)) as 'EndKolc'	
					
	INTO #Moves			
	FROM FOLIOBASE2..SCL_ARTC A WITH (NOLOCK)
		 LEFT JOIN FOLIOBASE2..ALL_ARTC AA WITH (NOLOCK) ON AA.COD_ARTIC = A.COD_ARTIC
		 LEFT JOIN #Balance B WITH (NOLOCK) ON B.COD_ARTIC = A.COD_ARTIC
		 LEFT JOIN #Sales S WITH (NOLOCK) ON A.COD_ARTIC = S.COD_ARTIC
		 LEFT JOIN #Incomes I WITH (NOLOCK) ON A.COD_ARTIC = I.COD_ARTIC
		 LEFT JOIN #IncomesCorrect IC WITH (NOLOCK) ON A.COD_ARTIC = IC.COD_ARTIC		 
		 LEFT JOIN #SalesCorrect SC WITH (NOLOCK) ON A.COD_ARTIC = SC.COD_ARTIC
	WHERE A.ID_SCLAD = 1
		  AND A.NGROUP_TVR != 'Снято'
		  AND A.TIP_TOVR = 'ТЭСТИ'



	SELECT DISTINCT M.COD_ARTIC,
				    M.NAME_ARTIC,		
					M.S100,			
					M.S200,	
		            SUM(M.BegKolc) as BegKolc,
					SUM(M.SalesKolc) as SalesKolc,
					SUM(M.SalesCorrKolc) as SalesCorrKolc,
					SUM(M.IncomeKolc) as IncomeKolc,
					SUM(M.IncCorrKolc) as IncCorrKolc,
					SUM(M.EndKolc) as EndKolc
	FROM #Moves M
	group by M.COD_ARTIC,
			 M.NAME_ARTIC,
			 M.S100,
			 M.S200
	order by M.COD_ARTIC,
			 M.NAME_ARTIC



GO
