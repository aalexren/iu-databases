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

ALTER TABLE account ADD COLUMN BankName VARCHAR;
UPDATE account SET BankName = 'Sberbank' WHERE uid IN (1, 3);
UPDATE account SET BankName = 'Tinkoff' WHERE uid = 2;

INSERT INTO account VALUES (4, 'Account 4', 0, 'RUB', NULL);

DROP FUNCTION IF EXISTS transfer_money_fee;
CREATE OR REPLACE FUNCTION transfer_money_fee(from_uid INT, to_uid INT, amount DECIMAL)
RETURNS TABLE 
	(uid INT, name VARCHAR, credit DECIMAL, currency VARCHAR, bankname VARCHAR) AS 
$$
#variable_conflict use_column -- to not use uid_ in the arguments, 
							  -- plpgsql will understand the difference between output
							  -- and the input; details here:
							  -- https://stackoverflow.com/questions/21662295/it-could-refer-to-either-a-pl-pgsql-variable-or-a-table-column
	BEGIN
		UPDATE account SET credit = credit + amount WHERE uid = to_uid;
		UPDATE account SET credit = credit - amount WHERE uid = from_uid;

		IF EXISTS (SELECT 1 FROM account AS A1, account AS A2 
				   WHERE A1.uid = from_uid AND A2.uid = to_uid 
				   AND A1.bankname != A2.bankname)
		THEN
			UPDATE account SET credit = credit - 30 WHERE uid = to_uid;
			UPDATE account SET credit = credit + 30 WHERE uid = 4;
		END IF;
	
		RETURN QUERY 
			SELECT * FROM account;
	END
			
$$ LANGUAGE plpgSQL;

SELECT * FROM account;
