--Listing 19-1
ALTER DATABASE AdventureWorks
ADD FILEGROUP InMemoryData
CONTAINS MEMORY_OPTIMIZED_DATA;
ALTER DATABASE AdventureWorks
ADD FILE
    (
        NAME = 'InMemoryFile',
        FILENAME = '/var/opt/mssql/data/inmemoryfile.ndf'
    )
TO FILEGROUP InMemoryData;

--Listing 19-2
ALTER DATABASE AdventureWorks REMOVE FILE InMemoryFile;

ALTER DATABASE AdventureWorks REMOVE FILEGROUP InMemoryData;


--Listing 19-3
CREATE TABLE dbo.ADDRESS
(
    AddressID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY NONCLUSTERED HASH
                                          WITH (BUCKET_COUNT = 50000),
    AddressLine1 NVARCHAR(60) NOT NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NOT NULL,
    StateProvinceID INT NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL,
    --SpatialLocation geography NULL,
    --rowguid uniqueidentifier ROWGUIDCOL  NOT NULL CONSTRAINT DF_Address_rowguid  DEFAULT (newid()),
    ModifiedDate DATETIME NOT NULL
        CONSTRAINT DF_Address_ModifiedDate
            DEFAULT (GETDATE())
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);


--Listing 19-4
INSERT dbo.ADDRESS
(
    AddressLine1,
    AddressLine2,
    City,
    StateProvinceID,
    PostalCode
)
SELECT A.AddressLine1,
       A.AddressLine2,
       A.City,
       A.StateProvinceID,
       A.PostalCode
FROM Person.Address AS a;


--Listing 19-5
CREATE TABLE dbo.StateProvince
(
    
StateProvinceID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY NONCLUSTERED HASH
                                                WITH (BUCKET_COUNT = 10000),
    StateProvinceCode NCHAR(3) COLLATE Latin1_General_100_BIN2 NOT NULL,
    CountryRegionCode NVARCHAR(3) NOT NULL,
    NAME VARCHAR(50) NOT NULL,
    TerritoryID INT NOT NULL,
    ModifiedDate DATETIME NOT NULL
        CONSTRAINT DF_StateProvince_ModifiedDate
            DEFAULT (GETDATE())
)
WITH (MEMORY_OPTIMIZED = ON);
CREATE TABLE dbo.CountryRegion
(
    CountryRegionCode NVARCHAR(3) NOT NULL,
    NAME VARCHAR(50) NOT NULL,
    ModifiedDate DATETIME NOT NULL
        CONSTRAINT DF_CountryRegion_ModifiedDate
            DEFAULT (GETDATE()),
    CONSTRAINT PK_CountryRegion_CountryRegionCode
        PRIMARY KEY CLUSTERED (CountryRegionCode ASC)
);
GO
INSERT dbo.StateProvince
(
    StateProvinceCode,
    CountryRegionCode,
    NAME,
    TerritoryID
)
SELECT StateProvinceCode,
       CountryRegionCode,
       NAME,
       TerritoryID
FROM Person.StateProvince AS sp
INSERT dbo.CountryRegion
(
    CountryRegionCode,
    NAME
)
SELECT cr.CountryRegionCode,
       cr.NAME
FROM Person.CountryRegion AS cr;
GO


--Listing 19-6
SELECT a.AddressLine1,
       a.City,
       a.PostalCode,
       sp.NAME AS StateProvinceName,
       cr.NAME AS CountryName
FROM dbo.ADDRESS AS a
    JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    JOIN dbo.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 42;
GO 50

SELECT a.AddressLine1,
       a.City,
       a.PostalCode,
       sp.Name AS StateProvinceName,
       cr.Name AS CountryName
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 42;
GO 50


--Listing 19-7
CREATE TYPE dbo.PostalCodeType AS TABLE
(
    ID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
    City NVARCHAR(30) NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL,
    INDEX CityIndex HASH (City) WITH (BUCKET_COUNT = 100)
)
WITH (MEMORY_OPTIMIZED = ON);

--DROP TYPE PostalCodeType


--Listing 19-8
DECLARE @PostalCode AS dbo.PostalCodeType;

INSERT INTO @PostalCode
(
    City,
    PostalCode
)
SELECT DISTINCT
       a.City,
       a.PostalCode
FROM Person.Address AS a;
GO 50


--Listing 19-9
DECLARE @OldPostalCode AS TABLE
(
    id INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
    City NVARCHAR(30) NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL,
    INDEX CityIndex NONCLUSTERED (City)
);

INSERT INTO @OldPostalCode
(
    City,
    PostalCode
)
SELECT DISTINCT
       a.City,
       a.PostalCode
FROM Person.Address AS a;
GO 50



--Listing 19-10
DECLARE @PostalCode AS dbo.PostalCodeType;

INSERT INTO @PostalCode
(
    City,
    PostalCode
)
SELECT DISTINCT
       a.City,
       a.PostalCode
FROM Person.Address AS a;

SELECT * FROM @PostalCode AS pc
WHERE pc.City = 'London';
GO 50

DECLARE @OldPostalCode AS TABLE
(
    id INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
    City NVARCHAR(30) NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL,
    INDEX CityIndex NONCLUSTERED (City)
);

INSERT INTO @OldPostalCode
(
    City,
    PostalCode
)
SELECT DISTINCT
       a.City,
       a.PostalCode
FROM Person.Address AS a;

SELECT * FROM @OldPostalCode AS pc
WHERE pc.City = 'London';
GO 50


--Listing 19-11
SELECT i.NAME AS [index name],
       hs.total_bucket_count,
       hs.empty_bucket_count,
       hs.avg_chain_length,
       hs.max_chain_length
FROM sys.dm_db_xtp_hash_index_stats AS hs
    JOIN sys.indexes AS i
        ON hs.OBJECT_ID = i.OBJECT_ID
           AND hs.index_id = i.index_id
WHERE OBJECT_NAME(hs.OBJECT_ID) = 'Address';


--Listing 19-12
SELECT A.AddressLine1,
       A.City,
       A.PostalCode,
       sp.NAME AS StateProvinceName,
       cr.NAME AS CountryName
FROM dbo.ADDRESS AS A
    JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = A.StateProvinceID
    JOIN dbo.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE A.City = 'Walla Walla';
GO 50

--Listing 19-13
ALTER TABLE dbo.ADDRESS ADD INDEX nci (City);

ALTER TABLE dbo.ADDRESS DROP INDEX nci



--Listing 19-14
SELECT s.NAME,
       s.stats_id,
       ddsp.last_updated,
       ddsp.ROWS,
       ddsp.rows_sampled,
       ddsp.unfiltered_rows,
       ddsp.persisted_sample_percent,
       ddsp.steps
FROM sys.STATS AS s
    CROSS APPLY sys.dm_db_stats_properties(s.OBJECT_ID, s.stats_id) AS ddsp
WHERE s.OBJECT_ID = OBJECT_ID('Address');


--Listing 19-15
SELECT ddsh.step_number,
       ddsh.range_high_key,
       ddsh.range_rows,
       ddsh.equal_rows,
       ddsh.distinct_range_rows,
       ddsh.average_range_rows
FROM sys.dm_db_stats_histogram(OBJECT_ID('Address'), 2) AS ddsh;


--Listing 19-16
UPDATE STATISTICS dbo.ADDRESS
WITH FULLSCAN,
     NORECOMPUTE;


--Listing 19-17
DROP TABLE IF EXISTS dbo.CountryRegion;
GO
CREATE TABLE dbo.CountryRegion
(
    CountryRegionCode NVARCHAR(3) NOT NULL,
    NAME VARCHAR(50) NOT NULL,
    ModifiedDate DATETIME NOT NULL
        CONSTRAINT DF_CountryRegion_ModifiedDate
            DEFAULT (GETDATE()),
    CONSTRAINT PK_CountryRegion_CountryRegionCode
        PRIMARY KEY NONCLUSTERED (CountryRegionCode ASC)
)
WITH (MEMORY_OPTIMIZED = ON);
GO
INSERT dbo.CountryRegion
(
    CountryRegionCode,
    NAME
)
SELECT cr.CountryRegionCode,
       cr.Name
FROM Person.CountryRegion AS cr;


--Listing 19-18
CREATE PROC dbo.AddressDetails @City NVARCHAR(30)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
    SELECT A.AddressLine1,
           A.City,
           A.PostalCode,
           sp.NAME AS StateProvinceName,
           cr.NAME AS CountryName
    FROM dbo.ADDRESS AS A
        JOIN dbo.StateProvince AS sp
            ON sp.StateProvinceID = A.StateProvinceID
        JOIN dbo.CountryRegion
        AS
        cr
            ON cr.CountryRegionCode = sp.CountryRegionCode
    WHERE A.City = @City;
END;
GO

EXEC dbo.AddressDetails @City = 'Walla Walla'
GO 50


--Listing 19-19
CREATE TABLE dbo.AddressMigrate
(
    AddressID INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
    AddressLine1 NVARCHAR(60) NOT NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NOT NULL,
    StateProvinceID INT NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL
);



--Listing 19-20
CREATE OR ALTER PROCEDURE dbo.FailWizard
(@City NVARCHAR(30))
AS
SELECT A.AddressLine1,
       A.City,
       A.PostalCode,
       sp.NAME AS StateProvinceName,
       cr.NAME AS CountryName
FROM dbo.ADDRESS AS A
    JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = A.StateProvinceID
    JOIN dbo.CountryRegion AS cr WITH (NOLOCK)
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE A.City = @City;
GO
CREATE OR ALTER PROCEDURE dbo.PassWizard
(@City NVARCHAR(30))
AS
SELECT A.AddressLine1,
       A.City,
       A.PostalCode,
       sp.NAME AS StateProvinceName,
       cr.NAME AS CountryName
FROM dbo.ADDRESS AS A
    JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = A.StateProvinceID
    JOIN dbo.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE A.City = @City;
GO
