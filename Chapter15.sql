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


--Listing 15-6
CREATE INDEX TestIndex ON Sales.SalesOrderDetail (UnitPrice ASC);


--Listing 15-7
DROP INDEX IF EXISTS TestIndex ON dbo.Test1;


--Listing 15-8
DECLARE @Id INT = 67260;
SELECT p.Name,
       p.ProductNumber,
       th.ReferenceOrderID
FROM Production.Product AS p
    JOIN Production.TransactionHistory AS th
        ON th.ProductID = p.ProductID
WHERE th.ReferenceOrderID = @Id;
--GO 50

--Listing 15-9
SELECT p.Name,
       p.ProductNumber,
       th.ReferenceOrderID
FROM Production.Product AS p
    JOIN Production.TransactionHistory AS th
        ON th.ProductID = p.ProductID
WHERE th.ReferenceOrderID = 67260;
--GO 50


--Listing 15-10
SET NOCOUNT ON;


--Listing 15-11
DROP TABLE IF EXISTS dbo.Test1;
CREATE TABLE dbo.Test1
(
    C1 TINYINT
);
GO
DBCC SQLPERF(LOGSPACE);
--Insert 10000 rows
DECLARE @Count INT = 1;
WHILE @Count <= 10000
BEGIN
    INSERT INTO dbo.Test1
    (
        C1
    )
    VALUES
    (@Count % 256);
    SET @Count = @Count + 1;
END;
DBCC SQLPERF(LOGSPACE);


--Listing 15-12
DECLARE @Count INT = 1;
DBCC SQLPERF(LOGSPACE);
BEGIN TRANSACTION;
WHILE @Count <= 10000
BEGIN
    INSERT INTO dbo.Test1
    (
        C1
    )
    VALUES
    (@Count % 256);
    SET @Count = @Count + 1;
END;
COMMIT;
DBCC SQLPERF(LOGSPACE);

--Listing 15-13
DBCC SQLPERF(LOGSPACE);
BEGIN TRANSACTION;
WITH Tally
AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS num
    FROM master.dbo.syscolumns AS A
        CROSS JOIN master.dbo.syscolumns AS B)
INSERT INTO dbo.Test1
(
    C1
)
SELECT TOP 1000
       (Tally.num % 256)
FROM Tally;
COMMIT;
DBCC SQLPERF(LOGSPACE);


--Listing 15-14
SELECT * FROM <TableName> WITH(PAGLOCK);  --Use page level lock


--Listing 15-15
ALTER DATABASE <DatabaseName> SET READ_ONLY;


--Listing 15-16










