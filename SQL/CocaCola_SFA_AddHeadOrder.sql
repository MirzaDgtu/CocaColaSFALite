SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pmp
-- Create date: 2022-08-03
-- Description:	Добавление шапки заказа SFA-CocaCola
-- =============================================
alter PROCEDURE CocaCola_SFA_AddHeadOrder 
	-- Add the parameters for the stored procedure here
	@OrderUID varchar(30) = '-1', 
	@OrderDate varchar(20) = Null,
	@Devilery_Date varchar(20) = Null,
	@Sales_Repid varchar(150) = Null,
	@ClientID int = -1,
	@Client_Name varchar(200) = Null,
	@Client_Adress varchar(250) = Null,
	@DTC varchar(20) = Null,
	@ClientID_Distrib varchar(12) = Null,
	@Fiscal_Number varchar(20) = Null,
	@Actgrinum varchar(30) = '1',
	@City varchar(150) = Null,
	@Input_Channel varchar(50) = Null
AS

	if ISNULL(@OrderUID, '-1') != '-1'
		BEGIN
			BEGIN TRANSACTION
				BEGIN TRY
					INSERT INTO REPORTS..COLA_SFA_Orders (ORDERID, ORDER_DATE, DELIVERY_DATE, SALES_REPID, 
														  CLIENTID, CLIENT_NAME, CLIENT_ADDRESS, DTC,
														  CLIENTID_DISTRIB, FISCAL_NUMBER, ACTGRINUM,
														  CITY, INPUT_CHANNEL)

					VALUES								 (@OrderDate, @OrderDate, @Devilery_Date, @Sales_Repid,
														  @ClientID, @Client_Name, @Client_Adress, @DTC,
														  @ClientID_Distrib, @Fiscal_Number, @Actgrinum,
														  @City, @Input_Channel)

					if @@TRANCOUNT > 0
						BEGIN
							print ('Заявка - ' + @OrderUID + ' успешно добавлена.')
							COMMIT TRANSACTION;
						END
				
				END TRY
				BEGIN CATCH
					SELECT ERROR_NUMBER() AS N,
						   ERROR_LINE() AS L,
						   ERROR_MESSAGE() AS M

					IF @@ROWCOUNT > 0
							ROLLBACK TRANSACTION;
				END CATCH
		END



			

GO
