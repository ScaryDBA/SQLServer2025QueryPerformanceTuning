--Listing 20-1
CREATE DATABASE RadioGraph;
GO
USE RadioGraph;
GO
--Create schema to hold different structures
CREATE SCHEMA grph;
GO
CREATE SCHEMA rel;
GO


--Listing 20-2
CREATE TABLE grph.RadioOperator
(
    RadioOperatorID INT IDENTITY(1, 1) NOT NULL,
    OperatorName VARCHAR(50) NOT NULL,
    CallSign VARCHAR(9) NOT NULL
) AS NODE;
CREATE TABLE grph.Frequency
(
    FrequencyID INT IDENTITY(1, 1) NOT NULL,
    FrequencyValue DECIMAL(6, 3) NOT NULL,
    Band VARCHAR(12) NOT NULL,
    FrequencyUnit VARCHAR(3) NOT NULL
) AS NODE;
CREATE TABLE grph.Radio
(
    RadioID INT IDENTITY(1, 1),
    RadioName VARCHAR(50) NOT NULL
) AS NODE;

--Listing 20-3
CREATE TABLE grph.Calls AS EDGE;
CREATE TABLE grph.Uses AS EDGE;


--Listing 20-4
INSERT INTO grph.RadioOperator
(
    OperatorName,
    CallSign
)
VALUES
('Grant Fritchey', 'KC1KCE'),
('Bob McCall', 'QQ5QQQ'),
('Abigail Serrano', 'VQ5ZZZ'),
('Josephine Wykovic', 'YQ9LLL');
INSERT INTO grph.Frequency
(
    FrequencyValue,
    Band,
    FrequencyUnit
)
VALUES
(14.250, '20 Meters', 'MHz'),
(145.520, '2 Meters', 'MHz'),
(478, '630 Meters', 'kHz'),
(14.225, '20 Meters', 'MHz'),
(14.3, '20 Meters', 'MHz'),
(7.18, '40 Meters', 'MHz');
INSERT INTO grph.Radio
(
    RadioName
)
VALUES
('Yaesu FT-3'),
('Baofeng UV5'),
('Icom 7300'),
('Raddiodity GD-88'),
('Xiegu G90');


--Listing 20-5
INSERT INTO grph.Uses
(
    $from_id,
    $to_id
)
VALUES
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 1
    ));


--Listing 20-6
INSERT INTO grph.Uses
(
    $from_id,
    $to_id
)
VALUES
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 2
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 3
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 2
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 2
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 4
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    ),
    (
        
SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 5
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 1
    )),
(
    (
        
SELECT ro.$node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 4
    ),
    (
        SELECT r.$node_id FROM grph.Radio AS r WHERE r.RadioID = 1
    ));
--edges for radio uses frequency
INSERT INTO grph.Uses
(
    $from_id,
    $to_id
)
VALUES
(
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 1
    ),
    (
        SELECT $node_id FROM grph.Frequency AS F WHERE F.FrequencyID = 2
    )),
(
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 2
    ),
    (
        SELECT $node_id FROM grph.Frequency AS F WHERE F.FrequencyID = 2
    )),
(
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 1
    ),
    (
        SELECT $node_id FROM grph.Radio AS r WHERE r.RadioID = 2
    ));
--edges for calls
INSERT INTO grph.Calls
(
    $from_id,
    $to_id
)
VALUES
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    ),
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 4
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    ),
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 2
    ),
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    ),
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 4
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    ),
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 1
    )),
(
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 3
    ),
    (
        
SELECT $node_id FROM grph.RadioOperator AS ro WHERE ro.RadioOperatorID = 2
    ));


--Listing 20-7
SELECT Calling.OperatorName,
       Calling.CallSign,
       Called.OperatorName,
       Called.CallSign
FROM grph.RadioOperator AS Calling,
     grph.Calls AS C,
     grph.RadioOperator AS Called
WHERE MATCH(Calling-(C)->Called);
GO 50

--Listing 20-8
CREATE TABLE rel.RadioOperator
(
    RadioOperatorID int IDENTITY(1, 1) NOT NULL,
    OperatorName varchar(50) NOT NULL,
    CallSign varchar(9) NOT NULL
);
CREATE TABLE rel.RadioOperatorCall
(
    CallingOperatorID INT NOT NULL,
    CalledOperatorID INT NOT NULL
);
INSERT INTO rel.RadioOperator
(
    OperatorName,
    CallSign
)
VALUES
('Grant Fritchey', 'KC1KCE'),
('Bob McCall', 'QQ5QQQ'),
('Abigail Serrano', 'VQ5ZZZ');
INSERT INTO rel.RadioOperatorCall
(
    CallingOperatorID,
    CalledOperatorID
)
VALUES
(1, 2),
(1, 3),
(2, 3),
(3, 1),
(3, 2),
(3, 4);


--Listing 20-9
SELECT Calling.OperatorName,
       calling.CallSign,
       CALLED.OperatorName,
       CALLED.CallSign
FROM rel.RadioOperator AS Calling
    JOIN rel.RadioOperatorCall AS roc
        ON Calling.RadioOperatorID = roc.CallingOperatorID
    JOIN rel.RadioOperator AS CALLED
        ON roc.CalledOperatorID = CALLED.RadioOperatorID;
GO 50

--Listing 20-10
SELECT Calling.OperatorName,
       Calling.CallSign,
       CALLED.OperatorName,
       CALLED.CallSign,
       TheyCalled.OperatorName,
       TheyCalled.CallSign
FROM grph.RadioOperator AS Calling,
     grph.Calls AS C,
     grph.RadioOperator AS CALLED,
     grph.Calls AS C2,
     grph.RadioOperator AS TheyCalled
WHERE MATCH(Calling-(C)->CALLED-(C2)->TheyCalled)
            AND Calling.RadioOperatorID = 1;

--Listing 20-11
SELECT AllCalled.CallSign AS WasCalledBy,
       WeCalled.CallSign AS CALLED,
       TheyCalled.CallSign AS AlsoCalled
FROM grph.RadioOperator AS AllCalled,
     grph.RadioOperator AS WeCalled,
     grph.RadioOperator AS TheyCalled,
     grph.Calls AS C,
     grph.Calls AS C2
WHERE MATCH(Wecalled-(C)->Allcalled<-(C2)-TheyCalled)
ORDER BY WasCalledBy ASC;


--Listing 20-12
SELECT op1.OperatorName,
       STRING_AGG(op2.OperatorName, '->') WITHIN GROUP(GRAPH PATH) AS Friends,
       LAST_VALUE(op2.OperatorName) WITHIN GROUP(GRAPH PATH) AS LastNode,
       COUNT(op2.OperatorName) WITHIN GROUP(GRAPH PATH) AS levels
FROM grph.RadioOperator AS op1,
     grph.Calls FOR PATH AS C,
     grph.RadioOperator FOR PATH AS op2
WHERE MATCH(SHORTEST_PATH(op1(-(C)->op2)+));


--Listing 20-13
SELECT op1.OperatorName,
       STRING_AGG(op2.OperatorName, '->')WITHIN GROUP(GRAPH PATH) AS Friends,
       LAST_VALUE(op2.OperatorName)WITHIN GROUP(GRAPH PATH) AS LastNode,
       COUNT(op2.OperatorName)WITHIN GROUP(GRAPH PATH) AS levels
FROM grph.RadioOperator AS op1,
     grph.Calls FOR PATH AS C,
     grph.RadioOperator FOR PATH AS op2,
        grph.Uses AS u,
        grph.Radio AS r
WHERE MATCH(SHORTEST_PATH(op1(-(C)->op2)+) AND LAST_NODE(op2)-(u)->r)
AND r.RadioName = 'Xiegu G90';

--Listing 20-14
CREATE UNIQUE CLUSTERED INDEX CallsToFrom ON grph.Calls ($from_id, $to_id);
