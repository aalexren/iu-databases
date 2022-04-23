DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users
(
	username VARCHAR NOT NULL,
	fullname VARCHAR NOT NULL,
	balance INT NOT NULL,
	group_id INT NOT NULL,
	
	PRIMARY KEY (username)
);

INSERT INTO users VALUES
('jones', 'Alice Jones', 82, 1),
('bitdiddl', 'Ben Bitdiddle', 65, 1),
('mike', 'Michael Dole', 73, 2),
('alyssa', 'Alyssa P.Hacker', 79, 3),
('bbrown', 'Bob Brown', 100, 3);

SELECT * FROM users;