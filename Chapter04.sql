-- Listing 4-1

SELECT soh.SalesOrderNumber,
       p.Name,
       sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE soh.CustomerID = 30052;
--GO 35


--Listing 4-2
SELECT dest.text,
       deqp.query_plan,
       deqs.execution_count,
       deqs.total_elapsed_time,
       deqs.last_elapsed_time
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'SELECT soh.SalesOrderNumber%';



--Listing 4-3
ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;



--Listing 4-4
SELECT dest.text,
       deqps.query_plan,
       deqs.execution_count,
       deqs.total_elapsed_time,
       deqs.last_elapsed_time
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan_stats(deqs.plan_handle) AS deqps
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'SELECT soh.SalesOrderNumber%';



--Listing 4-5
SELECT qsq.query_id,
       qsq.query_hash,
       CAST(qsp.query_plan AS XML) AS QueryPlan
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
WHERE qsqt.query_sql_text LIKE 'SELECT soh.SalesOrderNumber%';

