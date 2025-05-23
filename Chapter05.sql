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
--GO 50


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



--Listing 5-6
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS OFF;



--Listing 5-7
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS ON;



--Listing 5-8
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    Test1_C1 INT IDENTITY,
    Test1_C2 INT
);
INSERT INTO dbo.Test1
(
    Test1_C2
)
VALUES
(1  );
SELECT TOP 10000
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS scl,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    Test1_C2
)
SELECT 2
FROM #Nums;
GO
CREATE CLUSTERED INDEX i1 ON dbo.Test1 (Test1_C1);
--Create second table with 10001 rows, -- but opposite data distribution
IF
(
    SELECT OBJECT_ID('dbo.Test2')
) IS NOT NULL
    DROP TABLE dbo.Test2;
GO
CREATE TABLE dbo.Test2
(
    Test2_C1 INT IDENTITY,
    Test2_C2 INT
);
INSERT INTO dbo.Test2
(
    Test2_C2
)
VALUES
(2  );
INSERT INTO dbo.Test2
(
    Test2_C2
)
SELECT 1
FROM #Nums;
DROP TABLE #Nums;
GO
CREATE CLUSTERED INDEX il ON dbo.Test2 (Test2_C1);


--Listing 5-9
SELECT DATABASEPROPERTYEX('AdventureWorks', 'IsAutoCreateStatistics');



--Listing 5-10
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS ON;


--Listing 5-11
SELECT t1.Test1_C2,
       t2.Test2_C2
FROM dbo.Test1 AS t1
    JOIN dbo.Test2 AS t2
        ON t1.Test1_C2 = t2.Test2_C2
WHERE t1.Test1_C2 = 2;


--Listing 5-12
SELECT s.name,
       s.auto_created,
       s.user_created
FROM sys.stats AS s
WHERE object_id = OBJECT_ID('Test1');



--Listing 5-13
SELECT t1.Test1_C2,
       t2.Test2_C2
FROM dbo.Test1 AS t1
    JOIN dbo.Test2 AS t2
        ON t1.Test1_C2 = t2.Test2_C2
WHERE t1.Test1_C2 = 1;


--Listing 5-14
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS OFF;
