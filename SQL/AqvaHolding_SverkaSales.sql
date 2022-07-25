SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pmp
-- Create date: 2022-07-25
-- Description:	Сверка продаж
-- =============================================
alter PROCEDURE AqvaHolding_SverkaSales 
	-- Add the parameters for the stored procedure here
	@dtBeg smalldatetime = Null, 
	@dtEnd smalldatetime = Null
AS
BEGIN
	SELECT DISTINCT M.NAME_PREDM as 'Номенклатура',
		   N.N_PLAT_POR as 'Номер документа',
		   N.L_CP1_PLAT as 'Торговый представитель',
		   P.NAME_USER as  'Клиент',
		   P.ADRES_USER as 'Адрес ТТ',
		   M.KOLC_PREDM as 'Количество(шт)',
		   M.SUM_PREDM as 'Сумма'		   
	FROM FOLIOBASE2..SCL_NAKL N WITH (NOLOCK)
		LEFT JOIN FOLIOBASE2..SCL_MOVE M WITH (NOLOCK) ON N.UNICUM_NUM = M.UNICUM_NUM
		LEFT JOIN FOLIOBASE2..SCL_ARTC A WITH (NOLOCK) ON A.COD_ARTIC = M.NAME_PREDM
														  AND A.ID_SCLAD = M.ID_SCLAD
		LEFT JOIN FOLIOBASE2.._PARTNER P WITH (NOLOCK) ON P.N_USER = N.BRIEFORG
	WHERE N.DATE_P_POR BETWEEN @dtBeg AND @dtEnd
		  AND N.TYPE_DOC = 'Р'
		  AND N.ID_SCLAD != 14
		  AND (N.VID_DOC LIKE 'ДОСТАВКА%' OR N.BRIEFORG = 'П-ЧАСЛИЦ')
		  AND A.TIP_TOVR = 'ТЭСТИ'
		  AND A.NGROUP_TVR != 'Снято'
	ORDER BY M.NAME_PREDM, N.N_PLAT_POR
END
GO
