/* Demonstration of Code */
USE bcs350_finalproject
GO
-- Initial state of all Tables
SELECT * FROM CustomersFP;
SELECT * FROM ItemsFP;
SELECT * FROM OrdersFP;
SELECT * FROM InvoicesFP;
SELECT * FROM CustomerLogs;
SELECT * FROM OrdersUpdateInvoicesLogs;

-- Add a Customer
EXEC AddCustomerInfo @FirstName='John', @LastName='Doe', @Email='john.doe@example.com', 
@Phone='1234567890', @Address='1234 Street', @City='Hauppauge', @State='NY', @Zip='11788';

-- State of CustomersFP and CustomerLogs after adding a customer
SELECT * FROM CustomersFP;
SELECT * FROM CustomerLogs;

-- Add an Item
EXEC AddItemsToInventory @ItemDescription='Tanjiro Kamado Costume', @UnitPrice=70.99, @AmountLeft=12;

-- State of ItemsFP after adding an item
SELECT * FROM ItemsFP;

-- Before creating an order, state of OrdersFP
SELECT * FROM OrdersFP;

-- Create an Order
EXEC AddOrder @ShipDate='2024-02-15', @CustomerID=23, @InvoiceId=NULL, @ItemID=1;

-- State of OrdersFP after creating an order
SELECT * FROM OrdersFP;

-- Before generating an invoice, state of InvoicesFP and OrdersFP
SELECT * FROM InvoicesFP;
SELECT * FROM OrdersFP;

-- Create an Invoice
EXEC AddInvoices @Total=64.99, @PaymentDue='2024-03-15', @OrderID=9, @ItemID=1002, @CustomerID=23;

-- State of InvoicesFP after generating an invoice
SELECT * FROM InvoicesFP;

-- State of OrdersFP after invoice generation (to see the InvoiceID updated)
SELECT * FROM OrdersFP;

-- State of OrdersUpdateInvoicesLogs after generating an invoice
SELECT * FROM OrdersUpdateInvoicesLogs;

-- Use Function to Calculate Tax and Shipping for InvoiceID 4
SELECT * FROM dbo.fnCalculateTaxPlusShipping(4);

-- Use Function to Get Customer's Item and Payment Info for CustomerID 1
SELECT * FROM dbo.fnCustomersItemAndPayment(1);