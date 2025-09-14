--Listing 22-1
CREATE INDEX ix_ActualCost ON dbo.bigTransactionHistory (ActualCost);
GO
--a simple query for the experiment
CREATE OR ALTER PROCEDURE dbo.ProductByCost
(@ActualCost MONEY)
AS
SELECT bth.ActualCost
FROM dbo.bigTransactionHistory AS bth
    JOIN dbo.bigProduct AS p
        ON p.ProductID = bth.ProductID
WHERE bth.ActualCost = @ActualCost;
GO
--ensuring that Query Store is on and has a clean data set
ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;
ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = OFF;
GO


--Listing 22-2
--establish a history of query performance
EXEC dbo.ProductByCost @ActualCost = 54.838;
GO 30
--remove the plan from cache
DECLARE @PlanHandle VARBINARY(64);
SELECT  @PlanHandle = deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('dbo.ProductByCost');
IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO
--execute a query that will result in a different plan
EXEC dbo.ProductByCost @ActualCost = 0.0;
GO
--establish a new history of poor performance
EXEC dbo.ProductByCost @ActualCost = 54.838;
GO 15


--Listing 22-3
SELECT ddtr.TYPE,
       ddtr.reason,
       ddtr.STATE,
       ddtr.score,
       ddtr.details
FROM sys.dm_db_tuning_recommendations AS ddtr;


--Listing 22-4
WITH DbTuneRec
AS (SELECT ddtr.reason,
           ddtr.score,
           pfd.query_id,
           pfd.regressedPlanId,
           pfd.recommendedPlanId,
           JSON_VALUE(ddtr.STATE, '$.currentValue') AS CurrentState,
           JSON_VALUE(ddtr.STATE, '$.reason') AS CurrentStateReason,
           
JSON_VALUE(ddtr.details, '$.implementationDetails.script') AS ImplementationScript
    FROM sys.dm_db_tuning_recommendations AS ddtr
        CROSS APPLY
        OPENJSON(ddtr.details, '$.planForceDetails')
        WITH
        (
            query_id INT '$.queryId',
            regressedPlanId INT '$.regressedPlanId',
            recommendedPlanId INT '$.recommendedPlanId'
        ) AS pfd)
SELECT qsq.query_id,
       dtr.reason,
       dtr.score,
       dtr.CurrentState,
       dtr.CurrentStateReason,
       qsqt.query_sql_text,
       CAST(rp.query_plan AS XML) AS RegressedPlan,
       CAST(sp.query_plan AS XML) AS SuggestedPlan,
       dtr.ImplementationScript
FROM DbTuneRec AS dtr
    JOIN sys.query_store_plan AS rp
        ON rp.query_id = dtr.query_id
           AND rp.plan_id = dtr.regressedPlanId
    JOIN sys.query_store_plan AS sp
        ON sp.query_id = dtr.query_id
           AND sp.plan_id = dtr.recommendedPlanId
    JOIN sys.query_store_query AS qsq
        ON qsq.query_id = rp.query_id
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;


--Listing 22-5
ALTER DATABASE CURRENT SET AUTOMATIC_TUNING(FORCE_LAST_GOOD_PLAN = ON);


--Listing 22-6
SELECT NAME,
       desired_state,
       desired_state_desc,
       actual_state,
       actual_state_desc,
       reason,
       reason_desc
FROM sys.database_automatic_tuning_options;




--Listing 22-7
--Run on AdventureWorksLT in Azure
CREATE OR ALTER PROCEDURE dbo.CustomerInfo
(@Firstname NVARCHAR(50))
AS
SELECT C.FirstName,
       C.LastName,
       C.Title,
       A.City
FROM SalesLT.Customer AS C
    JOIN SalesLT.CustomerAddress AS ca
        ON ca.CustomerID = C.CustomerID
    JOIN SalesLT.ADDRESS AS A
        ON A.AddressID = ca.AddressID
WHERE C.FirstName = @Firstname;
GO
CREATE OR ALTER PROCEDURE dbo.EmailInfo
(@EmailAddress nvarchar(50))
AS
SELECT C.EmailAddress,
       C.Title,
       soh.OrderDate
FROM SalesLT.Customer AS C
    JOIN SalesLT.SalesOrderHeader AS soh
        ON soh.CustomerID = C.CustomerID
WHERE C.EmailAddress = @EmailAddress;
GO
CREATE OR ALTER PROCEDURE dbo.SalesInfo
(@firstName NVARCHAR(50))
AS
SELECT C.FirstName,
       C.LastName,
       C.Title,
       soh.OrderDate
FROM SalesLT.Customer AS C
    JOIN SalesLT.SalesOrderHeader AS soh
        ON soh.CustomerID = C.CustomerID
WHERE C.FirstName = @firstName;
GO
CREATE OR ALTER PROCEDURE dbo.OddName
(@FirstName NVARCHAR(50))
AS
SELECT C.FirstName
FROM SalesLT.Customer AS C
WHERE C.FirstName
BETWEEN 'Brian' AND @FirstName;
GO


--Listing 22-8
--Powershell, not T-SQL
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=qt2025.database.windows.net;Database=AdventureWorks;User ID=grant;Password=*cthulhu1988'
## load customer names
$DatCmd = New-Object System.Data.SqlClient.SqlCommand
$DatCmd.CommandText = "SELECT c.FirstName, c.EmailAddress
FROM SalesLT.Customer AS c;"
$DatCmd.Connection = $SqlConnection
$DatDataSet = New-Object System.Data.DataSet
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $DatCmd
$SqlAdapter.Fill($DatDataSet)
$Proccmd = New-Object System.Data.SqlClient.SqlCommand
$Proccmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$Proccmd.CommandText = "dbo.CustomerInfo"
$Proccmd.Parameters.Add("@FirstName",[System.Data.SqlDbType]"nvarchar")
$Proccmd.Connection = $SqlConnection
$EmailCmd = New-Object System.Data.SqlClient.SqlCommand
$EmailCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$EmailCmd.CommandText = "dbo.EmailInfo"
$EmailCmd.Parameters.Add("@EmailAddress",[System.Data.SqlDbType]"nvarchar")
$EmailCmd.Connection = $SqlConnection
$SalesCmd = New-Object System.Data.SqlClient.SqlCommand
$SalesCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$SalesCmd.CommandText = "dbo.SalesInfo"
$SalesCmd.Parameters.Add("@FirstName",[System.Data.SqlDbType]"nvarchar")
$SalesCmd.Connection = $SqlConnection
$OddCmd = New-Object System.Data.SqlClient.SqlCommand
$OddCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$OddCmd.CommandText = "dbo.OddName"
$OddCmd.Parameters.Add("@FirstName",[System.Data.SqlDbType]"nvarchar")
$OddCmd.Connection = $SqlConnection
while(1 -ne 0)
{
    foreach($row in $DatDataSet.Tables[0])
        {
        $name = $row[0]
        $email = $row[1]
        $SqlConnection.Open()
        $Proccmd.Parameters["@FirstName"].Value = $name
        $Proccmd.ExecuteNonQuery() | Out-Null
        $EmailCmd.Parameters["@EmailAddress"].Value = $email
        $EmailCmd.ExecuteNonQuery() | Out-Null
        $SalesCmd.Parameters["@FirstName"].Value = $name
        $SalesCmd.ExecuteNonQuery() | Out-Null
        $OddCmd.Parameters["@FirstName"].Value = $name
        $OddCmd.ExecuteNonQuery() | Out-Null
        $SqlConnection.Close()
 }
 }


