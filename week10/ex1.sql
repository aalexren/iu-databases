DROP FUNCTION IF EXISTS transfer_money;
CREATE OR REPLACE FUNCTION transfer_money(from_uid INT, to_uid INT, amount DECIMAL)
RETURNS TABLE (uid INT, name VARCHAR, credit DECIMAL, currency VARCHAR)
AS $$
#variable_conflict use_column
	BEGIN
		UPDATE account SET credit = credit + amount WHERE uid = to_uid;
		UPDATE account SET credit = credit - amount WHERE uid = from_uid;

		INSERT INTO ledger (from_uid, to_uid, fee, amount, transaction_date) 
		VALUES (from_uid, to_uid, 0, amount, NOW());
	
	RETURN QUERY
		SELECT uid, name, credit, currency FROM account;
	
	END
$$ LANGUAGE plpgSQL;

DROP TABLE IF EXISTS account CASCADE;
CREATE TABLE IF NOT EXISTS account
(
	uid INT,
	name VARCHAR,
	credit DECIMAL,
	currency VARCHAR,
	
	PRIMARY KEY (uid)
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

-- 		transfer_money(from_uid, to_uid, amount);

		IF EXISTS (SELECT 1 FROM account AS A1, account AS A2 
				   WHERE A1.uid = from_uid AND A2.uid = to_uid 
				   AND A1.bankname != A2.bankname)
		THEN
			UPDATE account SET credit = credit - 30 WHERE uid = to_uid;
			UPDATE account SET credit = credit + 30 WHERE uid = 4;
			INSERT INTO ledger (from_uid, to_uid, fee, amount, transaction_date) 
			VALUES (from_uid, to_uid, 30, amount, NOW());
		ELSE
			INSERT INTO ledger (from_uid, to_uid, fee, amount, transaction_date) 
			VALUES (from_uid, to_uid, 0, amount, NOW());
		END IF;
	
		RETURN QUERY 
			SELECT * FROM account;
	END
			
$$ LANGUAGE plpgSQL;


DROP TABLE IF EXISTS ledger;
CREATE TABLE IF NOT EXISTS ledger
(
	uid SERIAL,
	from_uid INT NOT NULL,
	to_uid INT NOT NULL,
	fee DECIMAL NOT NULL,
	amount DECIMAL NOT NULL,
	transaction_date TIMESTAMPTZ NOT NULL,
	
	PRIMARY KEY (uid),
	FOREIGN KEY (from_uid) REFERENCES account(uid),
	FOREIGN KEY (to_uid) REFERENCES account(uid)
);

-- SELECT transfer_money(1, 3, 700);

-- SELECT transfer_money_fee(1, 2, 700);

-- SELECT * FROM ledger;

