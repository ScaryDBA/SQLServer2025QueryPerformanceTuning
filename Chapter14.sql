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

