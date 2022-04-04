DROP TABLE Ex2;

CREATE TABLE IF NOT EXISTS Ex2
(
	school VARCHAR,
	teacher VARCHAR,
	course VARCHAR,
	room VARCHAR,
	grade VARCHAR,
	book VARCHAR,
	publisher VARCHAR,
	loan_date DATE
);

INSERT INTO Ex2 VALUES
('Horizon Education Institute', 'Chad Russell', 'Logical thinking', '1.A01', '1st grade', 'Learning and teaching in early childhood', 'BOA Editions', '2010-09-09'),
('Horizon Education Institute', 'Chad Russell', 'Wrtting', '1.A01', '1st grade', 'Preschool,N56', 'Taylor & Francis Publishing', '2010-05-05'),
('Horizon Education Institute', 'Chad Russell', 'Numerical Thinking', '1.A01', '1st grade', 'Learning and teaching in early childhood', 'BOA Editions', '2010-05-05'),
('Horizon Education Institute', 'E.F.Codd', 'Spatial, Temporal and Causal Thinking', '1.B01', '1st grade', 'Early Childhood Education N9', 'Prentice Hall', '2010-05-06'),
('Horizon Education Institute', 'E.F.Codd', 'Numerical Thinking', '1.B01', '1st grade', 'Learning and teaching in early childhood', 'BOA Editions', '2010-05-06'),
('Horizon Education Institute', 'Jones Smith', 'Wrtting', '1.A01', '2nd grade', 'Learning and teaching in early childhood', 'BOA Editions', '2010-09-09'),
('Horizon Education Institute', 'Jones Smith', 'English', '1.A01', '2nd grade', 'Know how to educate: guide for Parents and', 'McGraw Hill', '2010-05-05'),
('Bright Institution', 'Adam Baker', 'Logical thinking', '2.B01', '1st grade', 'Know how to educate: guide for Parents and', 'McGraw Hill', '2010-10-18'),
('Bright Institution', 'Adam Baker', 'Numerical Thinking', '2.B01', '1st grade', 'Learning and teaching in early childhood', 'BOA Editions', '2010-05-06');

DROP TABLE IF EXISTS TeachIn CASCADE;
DROP TABLE IF EXISTS Classes CASCADE;
DROP TABLE IF EXISTS Books CASCADE;

CREATE TABLE IF NOT EXISTS Books
(
	book VARCHAR,
	publisher VARCHAR,
	
	PRIMARY KEY (book)
);

CREATE TABLE IF NOT EXISTS TeachIn
(
	teacher VARCHAR,
	school VARCHAR,
	
	PRIMARY KEY (teacher)
);

CREATE TABLE IF NOT EXISTS Classes
(
	course VARCHAR NOT NULL,
	teacher VARCHAR NOT NULL,
	room VARCHAR NOT NULL, 
	loan_date DATE NOT NULL,
	book VARCHAR,
	grade VARCHAR,
	
	PRIMARY KEY (course, teacher, room, loan_date),
	FOREIGN KEY (book) REFERENCES Books(book),
	FOREIGN KEY (teacher) REFERENCES TeachIn(teacher)
);

INSERT INTO Books (book, publisher) 
(SELECT DISTINCT book, publisher FROM Ex2);

INSERT INTO TeachIn
(SELECT DISTINCT teacher, school FROM Ex2);

INSERT INTO Classes
(SELECT course, teacher, room, loan_date, book, grade FROM Ex2);

-- 1) Obtain for each of the schools, 
-- the number of books that have been loaned to each publishers.
SELECT DISTINCT school, Books.book, COUNT(Books.book), publisher
FROM Classes, Books, TeachIn
WHERE Classes.book = Books.book AND Classes.teacher = TeachIn.teacher
GROUP BY school, Books.book;


-- 2) For each school, find the book that has been on loan the longest 
-- and the teacher in charge of it.
SELECT DISTINCT ON (school) school, Classes.book, loan_date, Classes.teacher
FROM Classes, Books, TeachIn
WHERE Classes.book = Books.book AND TeachIn.teacher = Classes.teacher
ORDER BY school, loan_date DESC, Classes.book;

-- SELECT DISTINCT school, Classes.book, Classes.teacher, loan_date, MIN(loan_date)
-- FROM Classes, TeachIn, Books
-- WHERE Classes.teacher = TeachIn.teacher 
-- 	AND Classes.book = Books.book
-- GROUP BY loan_date, school, Classes.book, Classes.teacher
-- ORDER BY loan_date, school, Classes.book, Classes.teacher DESC LIMIT 2;



