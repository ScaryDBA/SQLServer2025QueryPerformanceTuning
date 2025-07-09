--Listing 12-1
DROP TABLE IF EXISTS dbo.SplitTest;
GO
CREATE TABLE dbo.SplitTest
(
    C1 INT,
    C2 CHAR(999),
    C3 VARCHAR(10)
);
INSERT INTO dbo.SplitTest
(
    C1,
    C2,
    C3
)
VALUES
(100, 'C2', ''),
(200, 'C2', ''),
(300, 'C2', ''),
(400, 'C2', ''),
(500, 'C2', ''),
(600, 'C2', ''),
(700, 'C2', ''),
(800, 'C2', '');
CREATE CLUSTERED INDEX iClustered ON dbo.SplitTest (C1);



--Listing 12-2
SELECT ddips.avg_fragmentation_in_percent,
       ddips.fragment_count,
       ddips.page_count,
       ddips.avg_page_space_used_in_percent,
       ddips.record_count,
       ddips.avg_record_size_in_bytes
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks'), OBJECT_ID(N'dbo.SplitTest'), NULL, NULL, 'Sampled') AS ddips;



--Listing 12-3
UPDATE dbo.SplitTest
SET C3 = 'Add data'
WHERE C1 = 200;


--Listing 12-4
INSERT INTO dbo.SplitTest
VALUES
(110, 'C2', '');



--Listing 12-5
ALTER TABLE dbo.bigTransactionHistory
DROP CONSTRAINT pk_bigTransactionHistory;

DROP INDEX IF EXISTS ix_csTest ON dbo.bigTransactionHistory;

CREATE CLUSTERED COLUMNSTORE INDEX cci_bigTransactionHistory
ON dbo.bigTransactionHistory;



--Listing 12-6
SELECT OBJECT_NAME(i.object_id) AS TableName,
       i.name AS IndexName,
       csrg.row_group_id,
       csrg.state_description,
       csrg.total_rows,
       csrg.deleted_rows,
       100 * (total_rows - ISNULL(deleted_rows, 0)) / total_rows AS PercentFull
FROM sys.indexes AS i
    JOIN sys.column_store_row_groups AS csrg
        ON i.object_id = csrg.object_id
           AND i.index_id = csrg.index_id
WHERE name = 'cci_bigTransactionHistory'
ORDER BY OBJECT_NAME(i.object_id),
         i.name,
         row_group_id;



--Listing 12-7
DELETE dbo.bigTransactionHistory
WHERE Quantity = 13;


--Listing 12-8
DROP TABLE IF EXISTS dbo.FragTest;
GO
CREATE TABLE dbo.FragTest
(
    C1 INT,
    C2 INT,
    C3 INT,
    c4 CHAR(2000)
);
CREATE CLUSTERED INDEX iClustered ON dbo.FragTest (C1);
WITH Nums
AS (SELECT TOP (10000)
           ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM MASTER.sys.all_columns AS ac1
        CROSS JOIN MASTER.sys.all_columns AS ac2)
INSERT INTO dbo.FragTest
(
    C1,
    C2,
    C3,
    c4
)
SELECT n,
       n,
       n,
       'a'
FROM Nums;
WITH Nums
AS (SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Nums
    WHERE n < 10000)
INSERT INTO dbo.FragTest
(
    C1,
    C2,
    C3,
    c4
)
SELECT 10000 - n,
       n,
       n,
       'a'
FROM Nums
OPTION (MAXRECURSION 10000);



--Listing 12-9
--Reads 6 rows
SELECT ft.C1,
       ft.C2,
       ft.C3,
       ft.c4
FROM dbo.FragTest AS ft
WHERE C1
BETWEEN 21 AND 23;
GO 50
--Reads all rows
SELECT ft.C1,
       ft.C2,
       ft.C3,
       ft.c4
FROM dbo.FragTest AS ft
WHERE C1
BETWEEN 1 AND 10000;
GO 50


--Listing 12-10
ALTER INDEX iClustered ON dbo.FragTest REBUILD;



--Listing 12-11
SELECT bth.Quantity,
       AVG(bth.ActualCost)
FROM dbo.bigTransactionHistory AS bth
WHERE bth.Quantity
BETWEEN 8 AND 15
GROUP BY bth.Quantity;
GO 50


--Listing 12-12
DELETE dbo.bigTransactionHistory
WHERE Quantity
BETWEEN 9 AND 12;



--Listing 12-13
--Intentionally using SELECT *
SELECT ddips.*
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks'), OBJECT_ID(N'dbo.FragTest'), NULL, NULL, 'Detailed') AS ddips;


--Listing 12-14
CREATE UNIQUE CLUSTERED INDEX PK_EmailAddress_BusinessEntityID_EmailAddressID
ON Person.EmailAddress (
                           BusinessEntityID,
                           EmailAddressID
                       )
WITH (DROP_EXISTING = ON);


--Listing 12-15
ALTER INDEX ALL ON dbo.FragTest REBUILD;



SELECT ddips.avg_fragmentation_in_percent,
       ddips.fragment_count,
       ddips.page_count,
       ddips.avg_page_space_used_in_percent,
       ddips.record_count,
       ddips.avg_record_size_in_bytes
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks'), OBJECT_ID(N'dbo.FragTest'), NULL, NULL, 'Sampled') AS ddips;


--Listing 12-16
ALTER INDEX iClustered ON dbo.FragTest REORGANIZE;



--Listing 12-17
DELETE dbo.bigTransactionHistory
WHERE Quantity
BETWEEN 8 AND 17;



--Listing 12-18
SELECT OBJECT_NAME(ddcsrgps.object_id) AS TableName,
       i.name IndexName,
       100 * (ddcsrgps.total_rows - ISNULL(ddcsrgps.deleted_rows, 0)) / total_rows AS PercentFull,
       ddcsrgps.row_group_id,
       ddcsrgps.state_desc
FROM sys.dm_db_column_store_row_group_physical_stats AS ddcsrgps
    JOIN sys.indexes AS i
        ON i.object_id = ddcsrgps.object_id
           AND i.index_id = ddcsrgps.index_id
ORDER BY ddcsrgps.row_group_id ASC;


--Listing 12-19
ALTER INDEX cci_bigTransactionHistory ON dbo.bigTransactionHistory REORGANIZE;


--Listing 12-20
ALTER INDEX cci_bigTransactionHistory
ON dbo.bigTransactionHistory
REORGANIZE
WITH (COMPRESS_ALL_ROW_GROUPS = ON);


--Listing 12-21
ALTER INDEX i1 ON dbo.Test1 REBUILD PARTITION = ALL WITH (ONLINE = ON);


--Listing 12-22
ALTER INDEX i1 ON dbo.Test1 REBUILD PARTITION = 1 WITH (ONLINE = ON);


--Listing 12-23
ALTER INDEX i1
ON dbo.Test1
REBUILD PARTITION = 1
WITH (   ONLINE = ON
         (
             WAIT_AT_LOW_PRIORITY
             (
                 MAX_DURATION = 20,
                 ABORT_AFTER_WAIT = SELF
             )
         )
     );



--Listing 12-24
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 CHAR(999)
);
WITH Nums
AS (SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Nums
    WHERE n < 24)
INSERT INTO dbo.Test1
(
    C1,
    C2
)
SELECT n * 100,
       'a'
FROM Nums;


--Listing 12-25
CREATE CLUSTERED INDEX FillIndex ON Test1(C1);




SELECT ddips.avg_fragmentation_in_percent,
       ddips.fragment_count,
       ddips.page_count,
       ddips.avg_page_space_used_in_percent,
       ddips.record_count,
       ddips.avg_record_size_in_bytes
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks'), OBJECT_ID(N'dbo.Test1'), NULL, NULL, 'Sampled') AS ddips;




--Listing 12-26
ALTER INDEX FillIndex ON dbo.Test1 REBUILD
WITH  (FILLFACTOR= 75);


--Listing 12-27
INSERT  INTO dbo.Test1
VALUES  (110, 'a'),  --25th row
        (120, 'a') ;  --26th row



--Listing 12-28
INSERT  INTO dbo.Test1
VALUES  (130, 'a') ;  --27th row






