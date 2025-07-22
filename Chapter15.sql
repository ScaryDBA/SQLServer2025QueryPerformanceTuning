--Listing 15-1
DROP TABLE IF EXISTS dbo.Test1;
CREATE TABLE dbo.Test1
(
    ID INT IDENTITY(1, 1),
    MyKey VARCHAR(50),
    MyValue VARCHAR(50)
);
CREATE UNIQUE CLUSTERED INDEX Test1PrimaryKey ON dbo.Test1 (ID ASC);
CREATE UNIQUE NONCLUSTERED INDEX TestIndex ON dbo.Test1 (MyKey);

WITH Tally
AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS num
    FROM MASTER.dbo.syscolumns AS A
        CROSS JOIN MASTER.dbo.syscolumns AS B)
INSERT INTO dbo.Test1
(
    MyKey,
    MyValue
)
SELECT TOP 10000
       'UniqueKey' + CAST(Tally.num AS VARCHAR),
       'Description'
FROM Tally;

SELECT t.MyValue
FROM dbo.Test1 AS t
WHERE t.MyKey = 'UniqueKey333';
--GO 50
SELECT t.MyValue
FROM dbo.Test1 AS t
WHERE t.MyKey = N'UniqueKey333';
--GO 50


--Listing 15-2
DECLARE @n INT;
SELECT @n = COUNT(*)
FROM Sales.SalesOrderDetail AS sod
WHERE sod.OrderQty = 1;
IF @n > 0
    PRINT 'Record Exists';
--GO 50


--Listing 15-3
IF EXISTS
(
    SELECT sod.OrderQty
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.OrderQty = 1
)
    PRINT 'Record Exists';
--GO 50


--Listing 15-4
SELECT sod.ProductID,
       sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 934
UNION
SELECT sod.ProductID,
       sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 932
UNION
SELECT sod.ProductID,
       sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 708;
--GO 50

SELECT sod.ProductID,
       sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 934
UNION ALL
SELECT sod.ProductID,
       sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 932
UNION ALL
SELECT sod.ProductID,
       sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 708;
--GO 50



--Listing 15-5
SELECT MIN(sod.UnitPrice)
FROM Sales.SalesOrderDetail AS sod;
GO 50


