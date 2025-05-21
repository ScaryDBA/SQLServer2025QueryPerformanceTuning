--Listing 5-1
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT IDENTITY
);
SELECT TOP 1500
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS sC1,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    C1
)
SELECT n
FROM #Nums;
DROP TABLE #Nums;
CREATE NONCLUSTERED INDEX i1 ON dbo.Test1 (C1);



--Listing 5-2
SELECT t.C1,
       t.C2
FROM dbo.Test1 AS t
WHERE t.C1 = 2;



--Listing 5-3
CREATE EVENT SESSION [Statistics]
ON SERVER
    ADD EVENT sqlserver.auto_stats
    (ACTION
     (
         sqlserver.sql_text
     )
     WHERE (sqlserver.database_name = N'AdventureWorks')
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (sqlserver.database_name = N'AdventureWorks'));
GO
ALTER EVENT SESSION [Statistics] ON SERVER STATE = START;


--Listing 5-4
INSERT INTO dbo.Test1
(
    C1
)
VALUES
(2  );



--Listing 5-5
SELECT TOP 1500
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS scl,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    C1
)
SELECT 2
FROM #Nums;
DROP TABLE #Nums;
