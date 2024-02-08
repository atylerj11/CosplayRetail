USE BCS350_FinalProject
GO

--Functions
CREATE FUNCTION fnCalculateTaxPlusShipping(@InvoiceID int)
RETURNS TABLE
RETURN
	(SELECT InvoiceID, UnitPrice, ROUND(TotalAmtDue - UnitPrice, 2) as 'Tax and Shipping'
	FROM InvoicesFP JOIN ItemsFP ON InvoicesFP.ItemID = ItemsFP.ItemID
	WHERE InvoiceID = @InvoiceID);

SELECT * FROM fnCalculateTaxPlusShipping(4);

CREATE FUNCTION fnCustomersItemAndPayment(@CustomerID int)
RETURNS TABLE 
RETURN
	(SELECT CustomersFP.CustomerID, ItemDescription, ROUND(TotalAmtDue, 2) as TotalAmtDue, UnitPrice
	FROM CustomersFP 
	JOIN InvoicesFP ON InvoicesFP.CustomerID = CustomersFP.CustomerID
	JOIN ItemsFP ON InvoicesFP.ItemID = ItemsFP.ItemID
	WHERE CustomersFP.CustomerID = @CustomerID);

SELECT * FROM fnCustomersItemAndPayment(4)