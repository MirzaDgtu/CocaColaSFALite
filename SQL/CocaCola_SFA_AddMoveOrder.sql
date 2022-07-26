USE [REPORTS]
GO
/****** Object:  StoredProcedure [dbo].[CocaCola_SFA_AddMoveOrder]    Script Date: 03.08.2022 16:52:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pmp
-- Create date: 2022-08-03
-- Description:	Добавление тела заказа SFA-CocaCola
-- =============================================
ALTER PROCEDURE [dbo].[CocaCola_SFA_AddMoveOrder] 
	-- Add the parameters for the stored procedure here
	@OrderID varchar(30) = '-1', 
	@OrderDate varchar(20) = Null,
	@ClientID varchar(50) = '-1',
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

	if (ISNULL(@OrderID, '-1') != '-1') and (NOT EXISTS (select 1
													     from REPORTS..COLA_SFA_Order_Details
													     where ORDERID = @OrderID
															   and PRODUCT_CODE = @Product_Code)) and (NOT EXISTS (select 1 
																												   from REPORTS..COLA_SFA_Orders
																												   where ORDERID = @OrderID)) 
		BEGIN
			BEGIN TRANSACTION
				BEGIN TRY
					INSERT INTO REPORTS..COLA_SFA_Order_Details (ORDERID, ORDER_DATE, CLIENTID, CLIENTID_DISTRIB,
																PRODUCT_CODE, PRODUCT_NAME, QTY_CASES, QTY_BOTTLES,
																FREE_CASE, DISCOUNT, PRICE_CASE, PRICE_EA,
																ACTGRINUM, CASES_DISCOUNTED, DISCOUNT_PROMO_ID, FREE_CASE_PROMO_ID,
																GROSS_VALUE, INPUT_CHANNEL)

					VALUES										(@OrderID, @OrderDate, @ClientID, @ClientID_Distrib,
																 @Product_Code, @Product_Name, @Qty_Cases, @Qty_Bottles,
																 @Free_Case, @Discount, @Price_Case, @Price_EA,
																 @ActGrinum, @Cases_Discounted, @Discount_Promo_ID, @Free_Case_Promo_ID,
																 @Gross_Value, @Input_Channel)

					if @@TRANCOUNT > 0
						BEGIN
							print ('Заявка - ' + @OrderID + ' товар -' + @Product_Code + '_' + @Product_Name + ' успешно добавлена.')
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

