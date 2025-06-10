--Listing 7-1
SELECT decp.refcounts,
       decp.usecounts,
       decp.size_in_bytes,
       decp.cacheobjtype,
       decp.objtype,
       decp.plan_handle
FROM sys.dm_exec_cached_plans AS decp;



--Listing 7-2
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = 29690
      AND sod.ProductID = 711;



--Listing 7-3
SELECT c.usecounts,
       c.cacheobjtype,
       c.objtype
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) AS t
WHERE t.text = 'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = 29690
      AND sod.ProductID = 711;';


--Listing 7-4
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = 29500
      AND sod.ProductID = 711;



--Listing 7-5
SELECT c.usecounts,
       c.cacheobjtype,
       c.objtype,
       t.text,
       c.plan_handle
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) AS t
WHERE t.text LIKE 'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID%';



--Listing 7-6
EXEC sys.sp_configure 'show advanced option', '1';
GO
RECONFIGURE;
GO
EXEC sys.sp_configure 'optimize for ad hoc workloads', 1;
GO
RECONFIGURE;


DBCC FREEPROCCACHE();


SELECT c.usecounts,
       c.cacheobjtype,
       c.objtype,
       c.size_in_bytes
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) AS t
WHERE t.text = 'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = 29690
      AND sod.ProductID = 711;';



--Listing 7-7
EXEC sp_configure 'optimize for ad hoc workloads', 0;
GO
RECONFIGURE;
GO
EXEC sp_configure 'show advanced option', '0';
GO
RECONFIGURE;



--Listing 7-8
SELECT a.AddressLine1,
       a.City,
       a.StateProvinceID
FROM Person.Address AS a
WHERE a.AddressID = 42;


SELECT c.usecounts,
       c.cacheobjtype,
       c.objtype,
       t.text
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) AS t;



--Listing 7-9
SELECT a.AddressLine1,
       a.City,
       a.StateProvinceID
FROM Person.Address AS a
WHERE a.AddressID = 32509;



DBCC FREEPROCCACHE();


--Listing 7-10
SELECT a.AddressLine1,
       a.City,
       a.StateProvinceID
FROM Person.Address AS a
WHERE a.AddressID = 56;



--Listing 7-11
SELECT a.AddressLine1,
       a.PostalCode
FROM Person.Address AS a
WHERE a.AddressID
BETWEEN 40 AND 60;



--Listing 7-12
SELECT a.AddressLine1,
       a.PostalCode
FROM Person.Address AS a
WHERE a.AddressID >= 40
      AND a.AddressID <= 60;

SELECT c.usecounts,
       c.cacheobjtype,
       c.objtype,
       t.text
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) AS t;



--Listing 7-13
ALTER DATABASE AdventureWorks SET PARAMETERIZATION FORCED;



--Listing 7-14
SELECT ea.EmailAddress,
       e.BirthDate,
       a.City
FROM Person.Person AS p
    JOIN HumanResources.Employee AS e
        ON p.BusinessEntityID = e.BusinessEntityID
    JOIN Person.BusinessEntityAddress AS bea
        ON e.BusinessEntityID = bea.BusinessEntityID
    JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
    JOIN Person.EmailAddress AS ea
        ON p.BusinessEntityID = ea.BusinessEntityID
WHERE ea.EmailAddress LIKE 'david%'
      AND sp.StateProvinceCode = 'WA';



--Listing 7-15
ALTER DATABASE AdventureWorks SET PARAMETERIZATION SIMPLE;

GO

--Listing 7-16
CREATE OR ALTER PROCEDURE dbo.BasicSalesInfo
    @ProductID INT,
    @CustomerID INT
AS
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = @CustomerID
      AND sod.ProductID = @ProductID;



--Listing 7-17
--This is powershell, not T-SQL
/*
$credential = Get-Credential 'sa'
$instance = Connect-DbaInstance -SqlInstance "localhost" -SqlCredential $credential

Invoke-DbaQuery -SqlInstance $instance -Query 'dbo.BasicSalesInfo' -SqlParameter @{ CustomerId = 29690; ProductID = 711 }  -Database 'AdventureWorks' -CommandType StoredProcedure
*/
DBCC FREEPROCCACHE();


--Listing 7-18
CREATE OR ALTER PROCEDURE dbo.MyNewProc
AS
SELECT MyID
FROM dbo.NotHere; --Table dbo.NotHere doesn't exist


--Listing 7-19
DECLARE @query NVARCHAR(MAX),
        @paramlist NVARCHAR(MAX);
SET @query
    = N'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = @CustomerID
      AND sod.ProductID = @ProductID';
SET @paramlist = N'@CustomerID INT, @ProductID INT';
EXEC sys.sp_executesql @query,
                       @paramlist,
                       @CustomerID = 29690,
                       @ProductID = 711;


--Listing 7-20
SELECT c.usecounts,
       c.cacheobjtype,
       c.objtype,
       t.text
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) AS t
WHERE text LIKE '(@CustomerID%';


DECLARE @query NVARCHAR(MAX),
        @paramlist NVARCHAR(MAX);
SET @query
    = N'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = @CustomerID
      AND sod.ProductID = @ProductID';
SET @paramlist = N'@CustomerID INT, @ProductID INT';
EXEC sys.sp_executesql @query,
                       @paramlist,
                       @CustomerID = 29690,
                       @ProductID = 777;


DECLARE @query NVARCHAR(MAX),
        @paramlist NVARCHAR(MAX);
SET @query
    = N'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = @customerid
      AND sod.ProductID = @ProductID';
SET @paramlist = N'@CustomerID INT, @ProductID INT';
EXEC sys.sp_executesql @query,
                       @paramlist,
                       @CustomerID = 29690,
                       @ProductID = 777;


--Listing 7-21
ALTER DATABASE SCOPED CONFIGURATION
SET OPTIMIZED_SP_EXECUTESQL = ON;



--Listing 7-22
--Remember, run 'em separately with matching white space
SELECT p.Name AS ProductName,
       ps.Name AS SubCategory,
       pc.Name AS Category
FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
      AND ps.Name = 'Touring Bikes';
SELECT p.Name AS ProductName,
       ps.Name AS SubCategory,
       pc.Name AS Category
FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
where pc.Name = 'Bikes'
      and ps.Name = 'Road Bikes';


--Listing 7-23
SELECT deqs.execution_count,
       deqs.query_hash,
       deqs.query_plan_hash,
       dest.text
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE dest.text LIKE 'SELECT p.Name AS ProductName%';

DBCC FREEPROCCACHE();

--Listing 7-24
SELECT p.Name AS ProductName
FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
      AND ps.Name = 'Touring Bikes';


--Listing 7-25
SELECT p.Name,
       tha.TransactionDate,
       tha.TransactionType,
       tha.Quantity,
       tha.ActualCost
FROM Production.TransactionHistoryArchive AS tha
    JOIN Production.Product AS p
        ON tha.ProductID = p.ProductID
WHERE p.ProductID = 461;
SELECT p.Name,
       tha.TransactionDate,
       tha.TransactionType,
       tha.Quantity,
       tha.ActualCost
FROM Production.TransactionHistoryArchive AS tha
    JOIN Production.Product AS p
        ON tha.ProductID = p.ProductID
WHERE p.ProductID = 712;


SELECT deqs.execution_count,
       deqs.query_hash,
       deqs.query_plan_hash,
       dest.text
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE dest.text LIKE 'SELECT p.Name,%';