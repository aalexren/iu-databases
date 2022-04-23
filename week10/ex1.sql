DROP FUNCTION IF EXISTS transfer_money;
CREATE OR REPLACE FUNCTION transfer_money(from_uid INT, to_uid INT, amount DECIMAL)
RETURNS TABLE (uid INT, name VARCHAR, credit DECIMAL, currency VARCHAR)
AS $$
	UPDATE account SET credit = credit + amount WHERE uid = to_uid;
	UPDATE account SET credit = credit - amount WHERE uid = from_uid;

	SELECT uid, name, credit, currency FROM account;
$$ LANGUAGE SQL;

DROP TABLE IF EXISTS account;
CREATE TABLE IF NOT EXISTS account
(
	uid INT NOT NULL,
	name VARCHAR,
	credit DECIMAL,
	currency VARCHAR
);

INSERT INTO account VALUES
(1, 'Account 1', 1000, 'RUB'),
(2, 'Account 2', 1000, 'RUB'),
(3, 'Account 3', 1000, 'RUB');

BEGIN;
SAVEPOINT T1;
SELECT * transfer_money(1, 3, 500);
SAVEPOINT T2;
SELECT * transfer_money(2, 1, 700);
SAVEPOINT T3;
SELECT * transfer_money(2, 3, 100);
ROLLBACK TO T1;
SELECT * FROM account;
END;