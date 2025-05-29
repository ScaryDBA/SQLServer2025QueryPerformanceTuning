--Listing 6-1
ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;



--Listing 6-2
SELECT qsq.query_id,
       qsq.object_id,
       qsqt.query_sql_text,
          qsp.plan_id,
       CAST(qsp.query_plan AS XML) AS QueryPlan
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_query_text AS qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');



--Listing 6-3
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID int)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END;



--Listing 6-4
SELECT a.AddressID,
       a.AddressLine1
FROM Person.Address AS a
WHERE a.AddressID = 72;



--Listing 6-5
SELECT qsq.query_id,
       qsq.query_hash,
       qsqt.query_sql_text,
       qsq.query_parameterization_type
FROM sys.query_store_query_text AS qsqt
    JOIN sys.query_store_query AS qsq
        ON qsq.query_text_id = qsqt.query_text_id
    JOIN sys.fn_stmt_sql_handle_from_sql_stmt(
             'SELECT a.AddressID,
       a.AddressLine1
FROM Person.Address AS a
WHERE a.AddressID = 72;',
             2)  AS fsshfss
        ON fsshfss.statement_sql_handle = qsqt.statement_sql_handle;




--Listing 6-6
DECLARE @CompareTime DATETIME = '2025-05-29 12:22';
SELECT CAST(qsp.query_plan AS XML),
       qsrs.count_executions,
       qsrs.avg_duration,
       qsrs.stdev_duration,
       qsws.wait_category_desc,
       qsws.avg_query_wait_time_ms,
       qsws.stdev_query_wait_time_ms
FROM sys.query_store_plan AS qsp
    JOIN sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
    JOIN sys.query_store_runtime_stats_interval AS qsrsi
        ON qsrsi.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
    LEFT JOIN sys.query_store_wait_stats AS qsws
        ON qsws.plan_id = qsrs.plan_id
           AND qsws.plan_id = qsrs.plan_id
           AND qsws.execution_type = qsrs.execution_type
           AND qsws.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
WHERE qsp.plan_id = 11
      AND @CompareTime BETWEEN qsrsi.start_time
                       AND     qsrsi.end_time;


--Listing 6-7
WITH QSAggregate
AS (SELECT qsrs.plan_id,
           SUM(qsrs.count_executions) AS CountExecutions,
           AVG(qsrs.avg_duration) AS AvgDuration,
           AVG(qsrs.stdev_duration) AS StDevDuration,
           qsws.wait_category_desc,
           AVG(qsws.avg_query_wait_time_ms) AS AvgQueryWaitTime,
           AVG(qsws.stdev_query_wait_time_ms) AS StDevQueryWaitTime
    FROM sys.query_store_runtime_stats AS qsrs
        LEFT JOIN sys.query_store_wait_stats AS qsws
            ON qsws.plan_id = qsrs.plan_id
               
AND qsws.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
    GROUP BY qsrs.plan_id,
             qsws.wait_category_desc)
SELECT CAST(qsp.query_plan AS XML),
       qsa.*
FROM sys.query_store_plan AS qsp
    JOIN QSAggregate AS qsa
        ON qsa.plan_id = qsp.plan_id
WHERE qsp.plan_id = 11;



--Listing 6-8
ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;


--Listing 6-9
EXEC sys.sp_query_store_remove_query @query_id = @QueryId;
EXEC sys.sp_query_store_remove_plan @plan_id = @PlanID;



--Listing 6-10
EXEC sys.sp_query_store_flush_db;



--Listing 6-11
SELECT *
FROM sys.database_query_store_options AS dqso;


--Listing 6-12
ALTER DATABASE AdventureWorks SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 200);



--Listing 6-13







