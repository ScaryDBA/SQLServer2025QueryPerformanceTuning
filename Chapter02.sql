--Listing 2-1
--NOTE: This intentionally generates an error

CREATE TABLE dbo.Example
(
    Col1 INT
);
INSERT INTO dbo.Example
(
    Col1
)
VALUES
(1);
SELECT e.Col1
FORM dbo.Example AS e; -- Generates an error because of 'FORM'

