--Listing 14-1
SELECT NAME,
       TerritoryID
FROM Sales.SalesTerritory AS st
WHERE st.Name = 'Australia';
GO 50

SELECT * 
FROM Sales.SalesTerritory AS st
WHERE st.Name = 'Australia'
GO 50


--Listing 14-2
SELECT sod.CarrierTrackingNumber,
       sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
WHERE sod.SalesOrderID IN ( 51825, 51826, 51827, 51828 );
GO 100

--Listing 14-3
SELECT sod.CarrierTrackingNumber,
       sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
WHERE sod.SalesOrderID = 51825
      OR sod.SalesOrderID = 51826
      OR sod.SalesOrderID = 51827
      OR sod.SalesOrderID = 51828;
GO 100

--Listing 14-4
SELECT sod.CarrierTrackingNumber,
       sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
WHERE sod.SalesOrderID
BETWEEN 51825 AND 51828;
GO 100


--Listing 14-5
SELECT C.CurrencyCode
FROM Sales.Currency AS C
WHERE C.NAME LIKE 'Ice%';


--Listing 14-6
SELECT poh.TotalDue,
       poh.Freight
FROM Purchasing.PurchaseOrderHeader AS poh
WHERE poh.PurchaseOrderID >= 2975;
SELECT poh.TotalDue,
       poh.Freight
FROM Purchasing.PurchaseOrderHeader AS poh
WHERE poh.PurchaseOrderID !< 2975;


--Listing 14-7
SELECT poh.EmployeeID,
       poh.OrderDate
FROM Purchasing.PurchaseOrderHeader AS poh
WHERE poh.PurchaseOrderID * 2 = 3400;
GO 50


--Listing 14-8
SELECT poh.EmployeeID,
       poh.OrderDate
FROM Purchasing.PurchaseOrderHeader AS poh
WHERE poh.PurchaseOrderID = 3400 / 2;
GO 50


--Listing 14-9
IF EXISTS
(
    SELECT *
    FROM sys.indexes
    WHERE OBJECT_ID = OBJECT_ID(N'[Sales].[SalesOrderHeader]')
          AND NAME = N'IndexTest'
)
    DROP INDEX IndexTest ON Sales.SalesOrderHeader;
GO
CREATE INDEX IndexTest ON Sales.SalesOrderHeader (OrderDate);


--Listing 14-10
SELECT soh.SalesOrderID,
       soh.OrderDate
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE DATEPART(yy, soh.OrderDate) = 2008
      AND DATEPART(mm, soh.OrderDate) = 4;
GO 50


--Listing 14-11
SELECT soh.SalesOrderID,
       soh.OrderDate
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate >= '2008-04-01'
      AND soh.OrderDate < '2008-05-01';
GO 50


--Listing 14-12
DROP INDEX Sales.SalesOrderHeader.IndexTest;


--Listing 14-13
CREATE OR ALTER FUNCTION dbo.ProductStandardCost
(
    @ProductID INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Cost MONEY;
    SELECT TOP 1
           @Cost = pch.StandardCost
    FROM Production.ProductCostHistory AS pch
    WHERE pch.ProductID = @ProductID
    ORDER BY pch.StartDate DESC;
    IF @Cost IS NULL
        SET @Cost = 0;
    RETURN @Cost;
END;


--Listing 14-14
SELECT p.NAME,
       dbo.ProductStandardCost(p.ProductID)
FROM Production.Product AS p
WHERE p.ProductNumber LIKE 'HL%';
GO 50


--Listing 14-15
SELECT p.NAME,
       pc.StandardCost
FROM Production.Product AS p
    CROSS APPLY
(
    SELECT TOP 1
           pch.StandardCost
    FROM Production.ProductCostHistory AS pch
    WHERE pch.ProductID = p.ProductID
    ORDER BY pch.StartDate DESC
) AS pc
WHERE p.ProductNumber LIKE 'HL%';
GO 50

--Listing 14-16
SELECT s.NAME AS StoreName,
       p.LastName + ', ' + p.FirstName
FROM Sales.Store AS s
    JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
    JOIN HumanResources.Employee AS E
        ON sp.BusinessEntityID = E.BusinessEntityID
    JOIN Person.Person AS p
        ON E.BusinessEntityID = p.BusinessEntityID;
GO 50


--Listing 14-17
SELECT s.NAME AS StoreName,
       p.LastName + ',   ' + p.FirstName
FROM Sales.Store AS s
    JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
    JOIN HumanResources.Employee AS E
        ON sp.BusinessEntityID = E.BusinessEntityID
    JOIN Person.Person AS p
        ON E.BusinessEntityID = p.BusinessEntityID
OPTION (LOOP JOIN);
GO 50



--Listing 14-18
SELECT s.NAME AS StoreName,
       p.LastName + ',   ' + p.FirstName
FROM Sales.Store AS s
    INNER LOOP JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
    JOIN HumanResources.Employee AS E
        ON sp.BusinessEntityID = E.BusinessEntityID
    JOIN Person.Person AS p
        ON E.BusinessEntityID = p.BusinessEntityID;
GO 50


--Listing 14-19
SELECT poh.EmployeeID,
       poh.OrderDate
FROM Purchasing.PurchaseOrderHeader AS poh WITH (INDEX(PK_PurchaseOrderHeader_PurchaseOrderID))
WHERE poh.PurchaseOrderID * 2 = 3400;
GO 50


--Listing 14-20
SELECT p.FirstName
FROM Person.Person AS p
WHERE p.FirstName < 'B'
      OR p.FirstName >= 'C';
SELECT p.MiddleName
FROM Person.Person AS p
WHERE p.MiddleName < 'B'
      OR p.MiddleName >= 'C';




