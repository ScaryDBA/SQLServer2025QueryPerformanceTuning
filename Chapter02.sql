--Listing 2-1
--NOTE: This intentionally generates an error

CREATE TABLE dbo.Example
(
    Col1 INT
);
INSERT INTO dbo.Example
(
    Col1
)
VALUES
(1);
SELECT e.Col1
FORM dbo.Example AS e; -- Generates an error because of 'FORM'

--Listing 2-2

SELECT soh.AccountNumber,
       soh.OrderDate,
       soh.PurchaseOrderNumber,
       soh.SalesOrderNumber
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesOrderID
BETWEEN 62500 AND 62550;
