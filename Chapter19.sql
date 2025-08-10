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
WHERE A.AddressID = 42;


