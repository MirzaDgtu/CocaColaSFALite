SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pmp
-- Create date: 2022-08-03
-- Description:	Добавление тела заказа SFA-CocaCola
-- =============================================
CREATE PROCEDURE CocaCola_SFA_AddMoveOrder 
	-- Add the parameters for the stored procedure here
	@OrderUID varchar(30) = '-1', 
	@OrderDate varchar(20) = Null,
	@ClientID int = -1,
	@ClientID_Distrib varchar(12) = Null,
	@Product_Code varchar(20) = '-1',
	@Product_Name varchar(250) = 'Неопределен',
	@Qty_Cases float = 0.0,
	@Qty_Bottles float = 0.0,
	@Free_Case float = 0.0,
	@Discount float = 0.0,
	@Price_Case float = 0.0,
	@Price_EA float = 0.0,
	@ActGrinum varchar(30) = '1',
	@Cases_Discounted float = 0.0,
	@Discount_Promo_ID varchar(150) = Null,
	@Free_Case_Promo_ID varchar(150) = Null,
	@Gross_Value float = 0.0,
	@Input_Channel varchar(50) = Null
AS

	if ISNULL(@OrderUID, '-1') != '-1'
		BEGIN
			BEGIN TRANSACTION
				BEGIN TRY
					INSERT INTO REPORTS..COLA_SFA_Order_Details (ORDERID, ORDER_DATE, CLIENTID, CLIENTID_DISTRIB,
																PRODUCT_CODE, PRODUCT_NAME, QTY_CASES, QTY_BOTTLES,
																FREE_CASE, DISCOUNT, PRICE_CASE, PRICE_EA,
																ACTGRINUM, CASES_DISCOUNTED, DISCOUNT_PROMO_ID, FREE_CASE_PROMO_ID,
																GROSS_VALUE, INPUT_CHANNEL)

					VALUES										(@OrderUID, @OrderDate, @ClientID, @ClientID_Distrib,
																 @Product_Code, @Product_Name, @Qty_Cases, @Qty_Bottles,
																 @Free_Case, @Discount, @Price_Case, @Price_EA,
																 @ActGrinum, @Cases_Discounted, @Discount_Promo_ID, @Free_Case_Promo_ID,
																 @Gross_Value, @Input_Channel)

					if @@TRANCOUNT > 0
						BEGIN
							print ('Заявка - ' + @OrderUID + ' товар -' + @Product_Code + '_' + @Product_Name + ' успешно добавлена.')
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
