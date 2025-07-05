--Listing 9-1
SELECT TOP 10
       p.ProductID,
       p.[Name],
       p.StandardCost,
       p.[Weight],
       ROW_NUMBER() OVER (ORDER BY p.NAME DESC) AS RowNumber
FROM Production.Product p
ORDER BY p.NAME DESC;

SELECT TOP 10
       p.ProductID,
       p.[Name],
       p.StandardCost,
       p.[Weight],
       ROW_NUMBER() OVER (ORDER BY p.NAME DESC) AS RowNumber
FROM Production.Product p
ORDER BY p.StandardCost DESC;


--Listing 9-2
IF
(
    SELECT OBJECT_ID('IndexTest')
) IS NOT NULL
    DROP TABLE dbo.IndexTest;
GO
CREATE TABLE dbo.IndexTest
(
    C1 INT,
    C2 INT,
    C3 VARCHAR(50)
);
WITH Nums
AS (SELECT TOP (10000)
           ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM MASTER.sys.all_columns ac1
        CROSS JOIN MASTER.sys.all_columns ac2)
INSERT INTO dbo.IndexTest
(
    C1,
    C2,
    C3
)
SELECT n,
       n,
       'C3'
FROM Nums;


--Listing 9-3
SET STATISTICS IO ON;

UPDATE dbo.IndexTest
SET C1 = 1,
    C2 = 1
WHERE C2 = 1;

SET STATISTICS IO OFF;


--Listing 9-4
CREATE CLUSTERED INDEX iTest
ON dbo.IndexTest(C1);


--Listing 9-5
CREATE INDEX iTest2
ON dbo.IndexTest(C2);


--Listing 9-6
SET STATISTICS IO ON;

SELECT p.ProductID,
       p.Name,
       p.StandardCost,
       p.Weight
FROM Production.Product p;
GO 50


SET STATISTICS IO OFF;


--Listing 9-7

SELECT p.ProductID,
       p.NAME,
       p.StandardCost,
       p.Weight
FROM Production.Product AS p
WHERE p.ProductID = 738;
GO 50



--Listing 9-8
IF
(
    SELECT OBJECT_ID('Test1')
) IS NOT NULL
    DROP TABLE dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT
);
WITH Nums
AS (SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Nums
    WHERE n < 20)
INSERT INTO dbo.Test1
(
    C1,
    C2
)
SELECT n,
       2
FROM Nums;
CREATE INDEX iTest ON dbo.Test1 (C1);



--Listing 9-9
SELECT i.name,
       i.type_desc,
       ddips.page_count,
       ddips.record_count,
       ddips.index_level
FROM sys.indexes i
    JOIN sys.dm_db_index_physical_stats(DB_ID(N'AdventureWorks'), OBJECT_ID(N'dbo.Test1'), NULL, NULL, 'DETAILED') AS ddips
        ON i.index_id = ddips.index_id
WHERE i.object_id = OBJECT_ID(N'dbo.Test1');


--Listing 9-10
DROP INDEX dbo.Test1.iTest;
ALTER TABLE dbo.Test1 ALTER COLUMN C1 CHAR(500);
CREATE INDEX iTest ON dbo.Test1 (C1);


--Listing 9-11
SELECT COUNT(DISTINCT E.MaritalStatus) AS DistinctColValues,
       COUNT(E.MaritalStatus) AS NumberOfRows,
       
(CAST(COUNT(DISTINCT E.MaritalStatus) AS DECIMAL) / CAST(COUNT(E.MaritalStatus) AS DECIMAL)) AS Selectivity,
       (1.0 / (COUNT(DISTINCT E.MaritalStatus))) AS Density
FROM HumanResources.Employee AS E;


--Listing 9-12
SELECT e.BusinessEntityID,
       e.MaritalStatus,
       e.BirthDate
FROM HumanResources.Employee AS e
WHERE e.MaritalStatus = 'M'
      AND e.BirthDate = '1982-02-11';
GO 50

--Listing 9-13
CREATE INDEX IX_Employee_Test ON HumanResources.Employee (MaritalStatus);


--Listing 9-14
SELECT e.BusinessEntityID,
       e.MaritalStatus,
       e.BirthDate
FROM HumanResources.Employee AS e WITH (INDEX(IX_Employee_Test))
WHERE e.MaritalStatus = 'M'
      AND e.BirthDate = '1982-02-11';
GO 50



--Listing 9-15
CREATE INDEX IX_Employee_Test
ON HumanResources.Employee (
                               BirthDate,
                               MaritalStatus
                           )
WITH DROP_EXISTING;


--Listing 9-16
DROP INDEX IF EXISTS IX_Employee_Test ON HumanResources.Employee;



--Listing 9-17
CREATE INDEX IX_Address_Test ON Person.ADDRESS (City, PostalCode);



--Listing 9-18
SELECT A.AddressID,
       A.City,
       A.PostalCode
FROM Person.ADDRESS AS A
WHERE A.City = 'Dresden'
GO 50


--Listing 9-19
SELECT A.AddressID,
       A.City,
       A.PostalCode
FROM Person.ADDRESS AS A
WHERE A.PostalCode = '01071';
GO 50


--Listing 9-20
DROP INDEX IF EXISTS IX_Address_Test ON Person.ADDRESS;



--Listing 9-21
SELECT dl.DatabaseLogID,
       dl.PostTime
FROM dbo.DatabaseLog AS dl
WHERE dl.DatabaseLogID = 115;


--Listing 9-22
SELECT d.DepartmentID,
       d.ModifiedDate
FROM HumanResources.Department AS d
WHERE d.DepartmentID = 10;



--Listing 9-23
IF
(
    SELECT OBJECT_ID('Test1')
) IS NOT NULL
    DROP TABLE dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT
);
WITH Nums
AS (SELECT TOP (20)
           ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM master.sys.all_columns ac1
        CROSS JOIN master.sys.all_columns ac2)
INSERT INTO dbo.Test1
(
    C1,
    C2
)
SELECT n,
       n + 1
FROM Nums;
CREATE CLUSTERED INDEX iClustered ON dbo.Test1 (C2);
CREATE NONCLUSTERED INDEX iNonClustered ON dbo.Test1 (C1);



--Listing 9-24
SELECT i.name,
       i.type_desc,
       s.page_count,
       s.record_count,
       s.index_level
FROM sys.indexes i
    JOIN sys.dm_db_index_physical_stats(DB_ID(N'AdventureWorks'), OBJECT_ID(N'dbo.Test1'), NULL, NULL, 'DETAILED') AS s
        ON i.index_id = s.index_id
WHERE i.object_id = OBJECT_ID(N'dbo.Test1');


--Listing 9-25
DROP INDEX dbo.Test1.iClustered;
ALTER TABLE dbo.Test1 ALTER COLUMN C2 CHAR(500);
CREATE CLUSTERED INDEX iClustered ON dbo.Test1 (C2);


--Listing 9-26
IF
(
    SELECT OBJECT_ID('od')
) IS NOT NULL
    DROP TABLE dbo.od;
GO
SELECT pod.PurchaseOrderID,
       pod.PurchaseOrderDetailID,
       pod.DueDate,
       pod.OrderQty,
       pod.ProductID,
       pod.UnitPrice,
       pod.LineTotal,
       pod.ReceivedQty,
       pod.RejectedQty,
       pod.StockedQty,
       pod.ModifiedDate
INTO dbo.od
FROM Purchasing.PurchaseOrderDetail AS pod;


--Listing 9-27
SELECT od.PurchaseOrderID,
       od.PurchaseOrderDetailID,
       od.DueDate,
       od.OrderQty,
       od.ProductID,
       od.UnitPrice,
       od.LineTotal,
       od.ReceivedQty,
       od.RejectedQty,
       od.StockedQty,
       od.ModifiedDate
FROM dbo.od
WHERE od.ProductID
BETWEEN 500 AND 510
ORDER BY od.ProductID;
GO 50


--Listing 9-28
CREATE CLUSTERED INDEX i1 ON od (ProductID);


--Listing 9-29
BEGIN TRAN;
SET STATISTICS IO ON;
UPDATE Sales.SpecialOfferProduct
SET ProductID = 720
WHERE SpecialOfferID = 1
      AND ProductID = 721;
SET STATISTICS IO OFF;
ROLLBACK TRAN;


--Listing 9-30
CREATE NONCLUSTERED INDEX ixTest
ON Sales.SpecialOfferProduct (ModifiedDate);


--Listing 9-31
DROP INDEX ixTest ON Sales.SpecialOfferProduct;



--Listing 9-32
--SET STATISTICS IO ON;
SELECT bp.Name AS ProductName,
       COUNT(bth.ProductID),
       SUM(bth.Quantity),
       AVG(bth.ActualCost)
FROM dbo.bigProduct AS bp
    JOIN dbo.bigTransactionHistory AS bth
        ON bth.ProductID = bp.ProductID
GROUP BY bp.Name;
--GO 50
--SET STATISTICS IO OFF;



--Listing 9-33
CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON dbo.bigTransactionHistory (
                                 ProductID,
                                 Quantity,
                                 ActualCost
                             );



--Listing 9-34
SELECT a.AddressID,
       a.AddressLine1,
       a.AddressLine2,
       a.City,
       sp.Name AS StateProvinceName,
       a.PostalCode
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE a.City = 'London';






