/* Retrieve Customer Data */

SELECT *
FROM SalesLT.Customer;

SELECT Title
	, FirstName
	, ISNULL(MiddleName, 'None') AS MiddleName
	, LastName
	, ISNULL(Suffix, 'None') AS Suffix
FROM SalesLT.Customer;

SELECT SalesPerson
	, Title + ' ' + LastName AS CustomerName
	, Phone
FROM SalesLT.Customer;
	
/* Retrieve Customer Order Data */

SELECT CAST(CustomerID AS VARCHAR(10)) + ' : ' + CompanyName
FROM SalesLT.Customer;

SELECT 'SO' + CAST(SalesOrderID AS VARCHAR(10)) + ' (' + CAST(RevisionNumber AS VARCHAR(10)) + ')' AS OrderRevision
	, CONVERT(NVARCHAR(30), OrderDate, 102) AS OrderDate
FROM SalesLT.SalesOrderHeader;
	
/* Retrieve Customer Contact Details */

SELECT FirstName + ' ' + ISNULL(MiddleName + ' ', ' ') + LastName AS CustomerName
FROM SalesLT.Customer;

SELECT CustomerID
	, COALESCE(EmailAddress, Phone) AS PrimaryMethod
FROM SalesLT.Customer

SELECT SalesOrderID
	, OrderDate
	, CASE 
		WHEN ShipDate IS NULL
			THEN 'Awaiting Shipment'
		ELSE 'Shipped'
		END AS ShippingStatus
FROM SalesLT.SalesOrderHeader
