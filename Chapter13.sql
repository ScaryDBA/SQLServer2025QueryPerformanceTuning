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
