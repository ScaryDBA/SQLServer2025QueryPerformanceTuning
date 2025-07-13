--Listing 13-1
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.NAME,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END;


--Listing 13-2
EXEC dbo.ProductTransactionHistoryByReference @ReferenceOrderID = 53465;
--GO 50


--Listing 13-3
DECLARE @planhandle VARBINARY(64);
SELECT @planhandle = deps.plan_handle
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');
IF @planhandle IS NOT NULL
    DBCC FREEPROCCACHE(@planhandle);


EXEC dbo.ProductTransactionHistoryByReference @ReferenceOrderID = 816;
GO 50




--Listing 13-4
DECLARE @ReferenceOrderID INT = 53465;
SELECT p.Name,
       p.ProductNumber,
       th.ReferenceOrderID
FROM Production.Product AS p
    JOIN Production.TransactionHistory AS th
        ON th.ProductID = p.ProductID
WHERE th.ReferenceOrderID = @ReferenceOrderID;
GO 50



--Listing 13-5
SELECT deps.EXECUTION_COUNT,
       deps.total_elapsed_time,
       deps.total_logical_reads,
       deps.total_logical_writes,
       deqp.query_plan
FROM sys.dm_exec_procedure_stats AS deps
    CROSS APPLY sys.dm_exec_query_plan(deps.plan_handle) AS deqp
WHERE deps.OBJECT_ID = OBJECT_ID('dbo.ProductTransactionHistoryByReference');


--Listing 13-6
SELECT SUM(qsrs.count_executions) AS ExecutionCount,
       AVG(qsrs.avg_duration) AS AvgDuration,
       AVG(qsrs.avg_logical_io_reads) AS AvgReads,
       AVG(qsrs.avg_logical_io_writes) AS AvgWrites,
       CAST(qsp.query_plan AS XML) AS QueryPlan,
       qsp.query_id,
       qsp.plan_id
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
    JOIN sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
WHERE qsq.OBJECT_ID = OBJECT_ID('dbo.ProductTransactionHistoryByReference')
GROUP BY qsp.query_plan,
         qsp.query_id,
         qsp.plan_id;


--Listing 13-7
CREATE EVENT SESSION [ExecutionPlans]
ON SERVER
    ADD EVENT sqlserver.query_post_execution_showplan
    (WHERE (
               
[sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name], N'AdventureWorks')
               AND [object_name] = N'ProductTransactionHistoryByReference'
           )
    ),
    ADD EVENT sqlserver.rpc_completed
    (WHERE (
               
[sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name], N'AdventureWorks')
               AND [object_name] = N'ProductTransactionHistoryByReference'
           )
    )
    ADD TARGET package0.event_file
    (SET FILENAME = N'ExecutionPlans')
WITH
(
    TRACK_CAUSALITY = ON
);


--Listing 13-8
DECLARE @KeyValue INT = 618;
WITH histolow
AS (SELECT ddsh.step_number,
           ddsh.range_high_key,
           ddsh.range_rows,
           ddsh.equal_rows,
           ddsh.average_range_rows
    
FROM sys.dm_db_stats_histogram(OBJECT_ID('Production.TransactionHistory'), 3) AS ddsh ),
     histojoin
AS (SELECT h1.step_number,
           h1.range_high_key,
           h2.range_high_key AS range_high_key_step1,
           h1.range_rows,
           h1.equal_rows,
           h1.average_range_rows
    FROM histolow AS h1
        LEFT JOIN histolow AS h2
            ON h1.step_number = h2.step_number + 1)
SELECT hj.range_high_key,
       hj.equal_rows,
       hj.average_range_rows
FROM histojoin AS hj
WHERE hj.range_high_key >= @KeyValue
      AND
      (
          hj.range_high_key_step1 < @KeyValue
          OR hj.range_high_key_step1 IS NULL
      );



--Listing 13-9
DBCC TRACEON (4136,-1);



--Listing 13-10
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF;


--Listing 13-11
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.NAME,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
    OPTION (USE HINT ('DISABLE_PARAMETER_SNIFFING'));
END;


--Listing 13-12
CREATE OR ALTER PROC dbo.AddressByCity
(@City VARCHAR(30))
AS
BEGIN
    --To help deal with parameter sniffing issues
    DECLARE @LocalCity VARCHAR(30) = @City;
    SELECT A.AddressID,
           A.PostalCode,
           sp.NAME,
           A.City
    FROM Person.ADDRESS AS A
        JOIN Person.StateProvince AS sp
            ON sp.StateProvinceID = A.StateProvinceID
    WHERE A.City = @LocalCity;
END;


--Listing 13-13
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.NAME,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
        OPTION(RECOMPILE);
END;


--Listing 13-14
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.NAME,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
    OPTION (OPTIMIZE FOR (@ReferenceOrderID = 53465));
END;


--Listing 13-15
EXEC dbo.ProductTransactionHistoryByReference @ReferenceOrderID = 816;


--Listing 13-16
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.NAME,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
    OPTION (OPTIMIZE FOR (@ReferenceOrderID UNKNOWN));
END;



--Listing 13-17
CREATE OR ALTER PROCEDURE dbo.OptionalParameter @ReferenceOrderID INT = NULL
AS
BEGIN
    SELECT p.ProductNumber
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
          OR @ReferenceOrderID IS NULL;
END;


SELECT productid, COUNT(productid) AS pcount FROM dbo.bigTransactionHistory AS bth
GROUP BY bth.ProductID
ORDER BY pcount DESC


--Listing 13-18
--Modify data to get 100K rows
UPDATE dbo.bigTransactionHistory
SET ProductID = 1319
WHERE ProductID IN ( 28417, 28729, 11953, 35521, 11993, 29719, 20431, 29531, 29749, 7913, 29947, 10739, 26921, 20941,4497,3480,48453,30733,17393,47981,10397,44819,
5737,
6449,
27767, 27941, 47431, 31847, 32411, 39383, 39511, 35531, 28829, 35759, 29713, 29819, 16001, 29951, 10453, 34967, 16363, 41347, 39719, 39443, 39829, 38917, 41759, 16453, 16963, 17453, 16417, 17473, 17713, 10729, 21319, 21433, 21473, 29927, 21859, 16477
);
GO
--Add a single row to both tables
INSERT INTO dbo.bigProduct
(
    ProductID,
    Name,
    ProductNumber,
    SafetyStockLevel,
    ReorderPoint,
    DaysToManufacture,
    SellStartDate,
    MakeFlag,
    FinishedGoodsFlag,
    StandardCost,
    ListPrice
)
VALUES
(42, 'FarbleDing', 'CA-2222-1000', 0, 0, 0, GETDATE(), 1, 1, 42, 54);
INSERT INTO dbo.bigTransactionHistory
(
    TransactionID,
    ProductID,
    TransactionDate,
    Quantity,
    ActualCost
)
VALUES
(31263602, 42, GETDATE(), 42, 42);
GO
--Create an index for testing
CREATE INDEX ProductIDTransactionDate
ON dbo.bigTransactionHistory (
                                 ProductID,
                                 TransactionDate
                             );
GO
--Create a procedure
CREATE OR ALTER PROC dbo.TransactionInfo
(@ProductID INT)
AS
BEGIN
    SELECT bp.Name,
           bp.ProductNumber,
           bth.TransactionDate
    FROM dbo.bigTransactionHistory AS bth
        JOIN dbo.bigProduct AS bp
            ON bp.ProductID = bth.ProductID
    WHERE bth.ProductID = @ProductID;
END;



--Listing 13-19
--Execute the Queries
EXEC dbo.TransactionInfo @ProductID = 1319;
EXEC dbo.TransactionInfo @ProductID = 42;


--Listing 13-20
SELECT deqs.query_hash,
       deqs.query_plan_hash,
       dest.text,
       deqp.query_plan
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%SELECT bp.Name,
           bp.ProductNumber,
           bth.TransactionDate
    FROM dbo.bigTransactionHistory AS bth%';


--Listing 13-21
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = OFF;


SELECT * FROM sys.query_store_query_variant




--listing 13-21
CREATE OR ALTER PROCEDURE dbo.OptionalParameter @ReferenceOrderID INT = NULL
AS
BEGIN
    SELECT p.ProductNumber
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
          OR @ReferenceOrderID IS NULL;
END;



--Listing 13-22
EXEC dbo.OptionalParameter @ReferenceOrderID = 1319;
EXEC dbo.OptionalParameter;

 
 --Listing 13-23
 ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = OFF;


