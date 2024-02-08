USE BCS350_FinalProject
GO

/* Important notes for myself
INSERTED pseudo table - used in triggers for INSERT and UPDATE operations. 
It stores a temporary copy of all rows that are being inserted or the new version of rows that are being updated. 
Inserted holds NEW VERSIONS of the rows

DELETED pseudo table -  is used in triggers for DELETE and UPDATE operations. 
It stores a temporary copy of all rows that are being deleted or the original version of rows that are being updated. 
Shows rows BEFORE ANY CHANGES applied
*/

--Logs Table created for Customer
CREATE TABLE CustomerLogs(
	CustomerID int, 
	Status varchar(50),
	CompletionDate datetime
)

--Add Insert Action to CustomerLogs
CREATE TRIGGER CustomerInsert
ON CustomersFP
AFTER INSERT
AS
BEGIN
	-- This command prevents the trigger from generating messages about the number of rows affected
    SET NOCOUNT ON; 
	DECLARE @CustomerID int

	-- Select the CustomerID from the inserted pseudo-table.
	SELECT @CustomerID = Inserted.CustomerID 
	FROM Inserted

	-- Add information into the CustomerLogs Table, GETDATE() for when it happened
	INSERT INTO CustomerLogs
	VALUES (@CustomerID, 'Inserted', GETDATE())
END

--Create Logs for Invoice Updates in OrdersFP table
CREATE TABLE OrdersUpdateInvoicesLogs(
	OrderID int,
	Status varchar(50),
	CompletionDate datetime
)

--Add Update Action to Logs
CREATE TRIGGER InvoiceUpdateOrdersFP
ON OrdersFP
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	-- Inserts records into the OrdersUpdateInvoicesLogs table	
	INSERT INTO OrdersUpdateInvoicesLogs(OrderID, Status, CompletionDate)
	SELECT Inserted.OrderID,  -- Selects the OrderID from the Inserted pseudo-table, which represents the state of the rows after the update
	       CASE 
	           WHEN Update(InvoiceID) THEN 'InvoiceID Updated'  -- Checks if the InvoiceID column was updated. If it was, sets the Status to 'InvoiceID Updated'
	           ELSE NULL -- If the InvoiceID was not updated, sets Status to NULL. This part could be adjusted based on additional requirements.
	       END, 
	       GETDATE()
	FROM Inserted
	WHERE Update(InvoiceID); -- Filters to only include rows where the InvoiceID was actually updated
END;
