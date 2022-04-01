CREATE TABLE IF NOT EXISTS Suppliers
(
	sid INTEGER PRIMARY KEY,
	sname VARCHAR,
	address VARCHAR
);

CREATE TABLE IF NOT EXISTS Parts
(
	pid INTEGER PRIMARY KEY,
	pname VARCHAR,
	color VARCHAR
);

CREATE TABLE IF NOT EXISTS Catalog_
(
	sid INTEGER,
	pid INTEGER,
	cost_ REAL,
	
	PRIMARY KEY (sid, pid),
	FOREIGN KEY (sid) REFERENCES Suppliers(sid),
	FOREIGN KEY (pid) REFERENCES Parts(pid)
);

-- INSERT INTO Suppliers VALUES 
-- (1, 'Yosemithe Sham', 'Devil''s canyon, AZ'),
-- (2, 'Waley E. Coyote', 'RR Asylum, NV'),
-- (3, 'Elmer Fudd', 'Carrot Patch, MN');

-- INSERT INTO Parts VALUES
-- (1, 'Red1', 'Red'),
-- (2, 'Red2', 'Red'),
-- (3, 'Green1', 'Green'),
-- (4, 'Blue1', 'Blue'),
-- (5, 'Red3', 'Red');

-- INSERT INTO Catalog_ VALUES
-- (1, 1, 10.),
-- (1, 2, 20.),
-- (1, 3, 30.),
-- (1, 4, 40.),
-- (1, 5, 50.),
-- (2, 1, 9.),
-- (2, 3, 34.),
-- (2, 5, 48.);
-- (3, 1, 53.);

-- Find the names of suppliers who supply some red part
SELECT DISTINCT sname
FROM Suppliers, Parts, Catalog_
WHERE color='Red' AND Catalog_.sid=Suppliers.sid AND Catalog_.pid=Parts.pid;

-- Find the sids of suppliers who supply some red or green part.
SELECT DISTINCT Suppliers.sid
FROM Parts JOIN Catalog_ ON Parts.pid=Catalog_.pid 
		   JOIN Suppliers ON Suppliers.sid=Catalog_.sid
WHERE Parts.color='Red' OR Parts.color='Green';

-- Find the sids of suppliers who supply some red part or are at 221 Packer Street.
SELECT DISTINCT Suppliers.sid
FROM Parts JOIN Catalog_ ON Parts.pid=Catalog_.pid 
		   JOIN Suppliers ON Suppliers.sid=Catalog_.sid
WHERE Parts.color='Red' 
UNION SELECT sid FROM Suppliers WHERE address LIKE '%221 Packer Street%';

-- Find the sids of suppliers who supply every red or green part.
SELECT DISTINCT T4.sid
FROM Catalog_ AS T4
EXCEPT
SELECT DISTINCT T3.sid
FROM (
	SELECT Suppliers.sid, Parts.pid FROM Suppliers, Parts 
	WHERE Parts.color='Red'
	EXCEPT
	SELECT T2.sid, T2.pid FROM Catalog_ AS T2
	)
AS T3
UNION
SELECT DISTINCT sid FROM Catalog_, Parts WHERE Catalog_.pid=Parts.pid
AND Parts.color='Green';
-- Main part of query is this one (division)
-- DISTINCT T4 - DISTINCT T3,
-- T4 = Catalog_.sid, 
-- T3 = T1 - T2,
-- T2 = Catalog_.sid, Catalog_.pid,
-- T1 = Suppliers x Parts (color='red')

-- Find the sids of suppliers who supply every red part or supply every green part.
SELECT DISTINCT T4.sid
FROM Catalog_ AS T4
EXCEPT
SELECT DISTINCT T3.sid
FROM (
	SELECT Suppliers.sid, Parts.pid FROM Suppliers, Parts 
	WHERE Parts.color='Red'
	EXCEPT
	SELECT T2.sid, T2.pid FROM Catalog_ AS T2
	)
AS T3
UNION
SELECT DISTINCT T4.sid
FROM Catalog_ AS T4
EXCEPT
SELECT DISTINCT T3.sid
FROM (
	SELECT Suppliers.sid, Parts.pid FROM Suppliers, Parts 
	WHERE Parts.color='Green'
	EXCEPT
	SELECT T2.sid, T2.pid FROM Catalog_ AS T2
	)
AS T3;

-- Find pairs of sids such that the supplier with the first sid
-- charges more for some part than the supplier with the second sid.
SELECT S1.sid, S2.sid
FROM Catalog_ AS S1, Catalog_ AS S2
WHERE S1.sid!=S2.sid AND S1.pid=S2.pid AND S1.cost_>S2.cost_;

-- Find the pids of parts supplied by at least two different suppliers.
SELECT DISTINCT C1.pid
FROM Catalog_ AS C1, Catalog_ AS C2
WHERE C1.pid=C2.pid AND C1.sid!=C2.sid;

-- Find the average cost of the red parts and green parts for each of the suppliers
SELECT AVG(Catalog_.cost_), Catalog_.sid, Parts.color
FROM Catalog_ JOIN Parts ON Catalog_.pid=Parts.pid AND Parts.color='Red'
GROUP BY Catalog_.sid, Parts.color
UNION
SELECT AVG(Catalog_.cost_), Catalog_.sid, Parts.color
FROM Catalog_ JOIN Parts ON Catalog_.pid=Parts.pid AND Parts.color='Green'
GROUP BY Catalog_.sid, Parts.color;

-- Find the sids of suppliers whose most expensive part costs $50 or more
SELECT DISTINCT S1.sid
FROM Catalog_ AS S1
WHERE (SELECT MAX(S2.cost_) FROM Catalog_ AS S2 WHERE S1.sid=S2.sid) >= 50.;