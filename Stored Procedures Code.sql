USE BCS350_FinalProject
GO

--Stored Procedures
	--Add Customers Info Into Table
CREATE PROCEDURE AddCustomerInfo
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@Phone char(25),
	@Address varchar(255),
	@City varchar(50),
	@State varchar(20),
	@Zip varchar(20)
AS
BEGIN
	SET NOCOUNT ON --prevents Done_In_Proc message for each statement in stored procedure

	INSERT INTO CustomersFP
	(FirstName, LastName, Email, Phone, StreetAddress, City, State, ZipCode)
	VALUES
	(@FirstName, @LastName, @Email, @Phone, @Address, @City, @State, @Zip)
END

	--Add Items into Inventory
CREATE PROCEDURE AddItemsToInventory
	@ItemDescription varchar(255),
	@UnitPrice money,
	@AmountLeft int
AS 
BEGIN
	SET NOCOUNT ON 

	INSERT INTO ItemsFP(ItemDescription, UnitPrice, AmountLeft)
	VALUES
	(@ItemDescription, @UnitPrice, @AmountLeft)
END

	--Create Order, Check stock and Check if InvoiceID not Provided
CREATE PROCEDURE AddOrder
    @ShipDate date,
    @CustomerID int,
    @InvoiceId int, 
    @ItemID int
AS
BEGIN 
    SET NOCOUNT ON; --prevents Done_In_Proc message for each statement in stored procedure
    BEGIN TRANSACTION; --created to ensure all statements are executed

    -- Check if there is stock available for the item
    DECLARE @AmountLeft INT;
    SELECT @AmountLeft = AmountLeft FROM ItemsFP WHERE ItemID = @ItemID;

    IF @AmountLeft <= 0
    BEGIN
        -- If no stock is available, raise an error
        ROLLBACK TRANSACTION; -- Rollback to ensure transaction is not left open
        RAISERROR('There are no more of this item, order cannot be processed.', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN

		IF(@InvoiceId IS NULL)
			BEGIN
				 -- Insert the order into the Orders table
				INSERT INTO OrdersFP (ShipDate, CustomerID, ItemID)
				VALUES (@ShipDate, @CustomerID, @ItemID);
        
				-- Update the Inventory table by decrementing the inventory count for the ordered product
				UPDATE ItemsFP
				SET AmountLeft = AmountLeft - 1
				WHERE ItemID = @ItemID;
				-- If everything is fine, commit the transaction
				COMMIT TRANSACTION;
			END
		ELSE
			BEGIN
				-- Insert the order into the Orders table
				INSERT INTO OrdersFP (ShipDate, CustomerID, InvoiceID, ItemID)
				VALUES (@ShipDate, @CustomerID, @InvoiceId, @ItemID);
        
				-- Update the Inventory table by decrementing the inventory count for the ordered product
				UPDATE ItemsFP
				SET AmountLeft = AmountLeft - 1
				WHERE ItemID = @ItemID;

				-- If everything is fine, commit the transaction
				COMMIT TRANSACTION;
			END
    END
END

	--Update InvoiceID in OrdersFP
CREATE PROC UpdateOrderInvoiceID
	@InvoiceID int,
	@OrderID int
AS BEGIN
		SET NOCOUNT ON;

		UPDATE OrdersFP
		SET InvoiceID = @InvoiceID
		WHERE OrderID = @OrderID
END

	-- Create Invoice, Update InvoiceID in OrdersFP
CREATE PROC AddInvoices
    @Total money,
    @PaymentDue date,
    @OrderID int,
    @ItemID int, 
    @CustomerID int
AS BEGIN
    SET NOCOUNT ON; -- Prevents Done_In_Proc message for each statement in stored procedure
    BEGIN TRANSACTION; -- Created to ensure all statements are executed

    -- Check if OrderID provided is in OrdersFP
    IF (SELECT OrderID FROM OrdersFP WHERE OrderID = @OrderID) IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('There is no order with this OrderID', 16, 1)
        RETURN;
    END
    ELSE
    BEGIN
        -- Insert the new invoice into InvoicesFP
        INSERT INTO InvoicesFP (TotalAmtDue, PaymentDueDate, OrderID, ItemID, CustomerID)
        VALUES (@Total, @PaymentDue, @OrderID, @ItemID, @CustomerID);

        -- Retrieve the InvoiceID of the newly created invoice
        DECLARE @NewInvoiceID int;
        SELECT @NewInvoiceID = SCOPE_IDENTITY(); -- SCOPE_IDENTITY() returns the last identity value inserted into an identity column in the same scope.

        -- Use the UpdateOrderInvoiceID procedure to update the InvoiceID in OrdersFP
        EXEC UpdateOrderInvoiceID @InvoiceID = @NewInvoiceID, @OrderID = @OrderID;

        -- If everything is fine, commit the transaction
        COMMIT TRANSACTION;
    END
END

