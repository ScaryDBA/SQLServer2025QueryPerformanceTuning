--Listing 3-1

SELECT dest.text,
       deqp.query_plan,
       der.cpu_time,
       der.logical_reads,
       der.writes
FROM sys.dm_exec_requests AS der
    CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(der.plan_handle) AS dest;



--Listing 3-2

SELECT dest.text,
       deqp.query_plan,
       deqs.execution_count,
       deqs.min_logical_writes,
       deqs.max_logical_reads,
       deqs.total_logical_reads,
       deqs.total_elapsed_time,
       deqs.last_elapsed_time
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest;


--Listing 3-3
CREATE EVENT SESSION [Query Performance Metrics]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (WHERE (
               [sqlserver].[database_name] = N'AdventureWorks'
               AND [duration] > (1000)
           )
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (
               [sqlserver].[database_name] = N'AdventureWorks'
               AND [duration] > (1000)
           )
    )
    ADD TARGET package0.event_file
    (SET filename = N'Query Performance Metrics');


--Listing 3-4
ALTER EVENT SESSION [Query Performance Metrics]
ON SERVER
STATE = START;
ALTER EVENT SESSION [Query Performance Metrics]
ON SERVER
STATE = STOP;



--Listing 3-5
SELECT fx.object_name,
       fx.file_name,
       fx.event_data
FROM sys.fn_xe_file_target_read_file('.\Query Performance Metrics_*.xel',
                                                                NULL,
                                                                NULL,
                                                                NULL) AS fx;



