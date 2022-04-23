a.chernitsa@innopolis.university

Artem Chernitsa, B20-02

# Exercise 1

## Part 1
First of all we will create function `transfer_money` to easily use it for transactions. Actually savepoints work only in the context of the one transaction, so we will use one transaction, but will create few savepoints and show the result of the execution using CLI.

```
lab11=# BEGIN;
BEGIN
lab11=*# SELECT * FROM account;
 uid |   name    | credit | currency
-----+-----------+--------+----------
   1 | Account 1 |   1000 | RUB
   2 | Account 2 |   1000 | RUB
   3 | Account 3 |   1000 | RUB
(3 rows)

lab11=*# SAVEPOINT T1;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money(1, 3, 500);
 uid |   name    | credit | currency
-----+-----------+--------+----------
   2 | Account 2 |   1000 | RUB
   3 | Account 3 |   1500 | RUB
   1 | Account 1 |    500 | RUB
(3 rows)

lab11=*# SAVEPOINT T2;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money(2, 1, 700);
 uid |   name    | credit | currency
-----+-----------+--------+----------
   3 | Account 3 |   1500 | RUB
   1 | Account 1 |   1200 | RUB
   2 | Account 2 |    300 | RUB
(3 rows)

lab11=*# SAVEPOINT T3;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money(2, 3, 100);
 uid |   name    | credit | currency
-----+-----------+--------+----------
   1 | Account 1 |   1200 | RUB
   3 | Account 3 |   1600 | RUB
   2 | Account 2 |    200 | RUB
(3 rows)

lab11=*# ROLLBACK TO T1;
ROLLBACK
lab11=*# SELECT * FROM account;
 uid |   name    | credit | currency
-----+-----------+--------+----------
   1 | Account 1 |   1000 | RUB
   2 | Account 2 |   1000 | RUB
   3 | Account 3 |   1000 | RUB
(3 rows)

lab11=*# END;
COMMIT
```

## Part 2
Now is the second part, we just add one more column, write function with condition for fees and run it again using same transaction rules.
```
lab11=# BEGIN;
BEGIN
lab11=*# SELECT * FROM account;
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   1 | Account 1 |   1000 | RUB      | Sberbank
   3 | Account 3 |   1000 | RUB      | Sberbank
   2 | Account 2 |   1000 | RUB      | Tinkoff
   4 | Account 4 |      0 | RUB      |
(4 rows)

lab11=*# SAVEPOINT T1;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money_fee(1, 3, 500);
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   2 | Account 2 |   1000 | RUB      | Tinkoff
   4 | Account 4 |      0 | RUB      |
   3 | Account 3 |   1500 | RUB      | Sberbank
   1 | Account 1 |    500 | RUB      | Sberbank
(4 rows)

lab11=*# SAVEPOINT T2;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money_fee(2, 1, 700);
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   3 | Account 3 |   1500 | RUB      | Sberbank
   2 | Account 2 |    300 | RUB      | Tinkoff
   1 | Account 1 |   1170 | RUB      | Sberbank
   4 | Account 4 |     30 | RUB      |
(4 rows)

lab11=*# SAVEPOINT T3;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money_fee(2, 3, 100);
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   1 | Account 1 |   1170 | RUB      | Sberbank
   2 | Account 2 |    200 | RUB      | Tinkoff
   3 | Account 3 |   1570 | RUB      | Sberbank
   4 | Account 4 |     60 | RUB      |
(4 rows)

lab11=*# ROLLBACK TO T2;
ROLLBACK
lab11=*# SELECT * FROM account;
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   2 | Account 2 |   1000 | RUB      | Tinkoff
   4 | Account 4 |      0 | RUB      |
   3 | Account 3 |   1500 | RUB      | Sberbank
   1 | Account 1 |    500 | RUB      | Sberbank
(4 rows)

lab11=*# ROLLBACK TO T1;
ROLLBACK
lab11=*# SELECT * FROM account;
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   1 | Account 1 |   1000 | RUB      | Sberbank
   3 | Account 3 |   1000 | RUB      | Sberbank
   2 | Account 2 |   1000 | RUB      | Tinkoff
   4 | Account 4 |      0 | RUB      |
(4 rows)

lab11=*# END;
COMMIT
```

## Part 3
Add table for transactions and a slightly change the code of functions.
```
lab11=# BEGIN;
BEGIN
lab11=*# SELECT * FROM account;
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   1 | Account 1 |   1000 | RUB      | Sberbank
   3 | Account 3 |   1000 | RUB      | Sberbank
   2 | Account 2 |   1000 | RUB      | Tinkoff
   4 | Account 4 |      0 | RUB      |
(4 rows)

lab11=*# SELECT * FROM ledger;
 uid | from_uid | to_uid | fee | amount | transaction_date
-----+----------+--------+-----+--------+------------------
(0 rows)

lab11=*# SAVEPOINT T;
SAVEPOINT
lab11=*# SELECT * FROM transfer_money_fee(1, 3, 500);
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   2 | Account 2 |   1000 | RUB      | Tinkoff
   4 | Account 4 |      0 | RUB      |
   3 | Account 3 |   1500 | RUB      | Sberbank
   1 | Account 1 |    500 | RUB      | Sberbank
(4 rows)

lab11=*# SELECT * FROM transfer_money_fee(2, 1, 700);
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   3 | Account 3 |   1500 | RUB      | Sberbank
   2 | Account 2 |    300 | RUB      | Tinkoff
   1 | Account 1 |   1170 | RUB      | Sberbank
   4 | Account 4 |     30 | RUB      |
(4 rows)

lab11=*# SELECT * FROM transfer_money_fee(2, 3, 100);
 uid |   name    | credit | currency | bankname
-----+-----------+--------+----------+----------
   1 | Account 1 |   1170 | RUB      | Sberbank
   2 | Account 2 |    200 | RUB      | Tinkoff
   3 | Account 3 |   1570 | RUB      | Sberbank
   4 | Account 4 |     60 | RUB      |
(4 rows)

lab11=*# SELECT * FROM ledger;
 uid | from_uid | to_uid | fee | amount |      transaction_date
-----+----------+--------+-----+--------+----------------------------
   1 |        1 |      3 |   0 |    500 | 2022-04-23 17:06:44.101791
   2 |        2 |      1 |  30 |    700 | 2022-04-23 17:06:44.101791
   3 |        2 |      3 |  30 |    100 | 2022-04-23 17:06:44.101791
(3 rows)

lab11=*# ROLLBACK TO T;
ROLLBACK
lab11=*# END;
COMMIT
```

# Exercise 2

Difference between these levels of isolation: https://stackoverflow.com/a/14394210/7502538

## Part 1

### SET ISOLATION LEVEL READ COMMITTED


#### Terminal 1:
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET
lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 jones    | Alice Jones     |      82 |        1
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
(5 rows)

lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 jones    | Alice Jones     |      82 |        1
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
(5 rows)

lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      82 |        1
(5 rows)

lab11=*# UPDATE users SET balance = balance + 10 WHERE username='ajones';
UPDATE 1
lab11=*# COMMIT;
COMMIT
lab11=# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      92 |        1
(5 rows)

lab11=# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      92 |        1
(5 rows)

lab11=#
```

#### Terminal 2:

```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET
lab11=*# UPDATE users SET username='ajones' WHERE username='jones';
UPDATE 1
lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      82 |        1
(5 rows)

lab11=*# COMMIT;
COMMIT
lab11=# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      82 |        1
(5 rows)

lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET
lab11=*# UPDATE users SET balance = balance + 15 WHERE username = 'ajones';
UPDATE 1
lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |     107 |        1
(5 rows)

lab11=*# ROLLBACK;
ROLLBACK
lab11=#
```

**Steps:** 
1.  Simply display information about the users;
2.  Update Alice's username to `ajones`
3. No changes in terminal 1, since we didn't commit anything in the terminal 2.
4. Changed username for Alice.
5. Commit changes.
6. New transaction.
7. Update balance for the Alice with already updated username `ajones`
8. Update balance for the Alice. Get stucked, cause we didn't finish transaction in the terminal 1, waits for the commit.
9. Commit changes. In terminal 2 the operation has been done successfully. 
10. Rollback, means we updated Alice's balance only for 10.

### SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

#### Terminal 1:
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET
lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 jones    | Alice Jones     |      82 |        1
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
(5 rows)

lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 jones    | Alice Jones     |      82 |        1
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
(5 rows)

lab11=*# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 jones    | Alice Jones     |      82 |        1
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
(5 rows)

lab11=*# UPDATE users SET balance = balance + 10 WHERE username='ajones';
UPDATE 0
lab11=*# UPDATE users SET balance = balance + 10 WHERE username='jones';
ERROR:  could not serialize access due to concurrent update
lab11=!# END;
ROLLBACK
lab11=# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      82 |        1
(5 rows)

lab11=#
```

#### Terminal 2:
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET
lab11=*# UPDATE users SET balance = balance + 20 WHERE username='ajones';
UPDATE 1
lab11=*# ROLLBACK;
ROLLBACK
lab11=# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 bitdiddl | Ben Bitdiddle   |      65 |        1
 mike     | Michael Dole    |      73 |        2
 alyssa   | Alyssa P.Hacker |      79 |        3
 bbrown   | Bob Brown       |     100 |        3
 ajones   | Alice Jones     |      82 |        1
(5 rows)

lab11=#
```

## Part 2

### SET TRANSACTION ISOLATION LEVEL READ COMMITTED

#### Terminal 1
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET
lab11=*# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      73 |        2
(1 row)

lab11=*# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      73 |        2
(1 row)

lab11=*# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      73 |        2
 bbrown   | Bob Brown    |     100 |        2
(2 rows)

lab11=*# UPDATE users SET balance = balance + 15 WHERE group_id = 2;
UPDATE 2
lab11=*# COMMIT;
COMMIT
lab11=# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      88 |        2
 bbrown   | Bob Brown    |     115 |        2
(2 rows)

lab11=#
```

#### Terminal 2
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET
lab11=*# UPDATE users SET group_id = 2 WHERE username='bbrown';
UPDATE 1
lab11=*# COMMIT;
COMMIT
lab11=# SELECT * FROM users;
 username |    fullname     | balance | group_id
----------+-----------------+---------+----------
 jones    | Alice Jones     |      82 |        1
 bitdiddl | Ben Bitdiddle   |      65 |        1
 alyssa   | Alyssa P.Hacker |      79 |        3
 mike     | Michael Dole    |      88 |        2
 bbrown   | Bob Brown       |     115 |        2
(5 rows)

lab11=#
```

The main idea is that is this isolation level only the committed data could be read. E.g. you can start transaction and change data during the another transaction and if you committed it another transaction will see it.

### SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

#### Terminal 1:
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET
lab11=*# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      73 |        2
(1 row)

lab11=*# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      73 |        2
(1 row)

lab11=*# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 mike     | Michael Dole |      73 |        2
(1 row)

lab11=*# UPDATE users SET balance = balance + 15 WHERE group_id = 2;
UPDATE 1
lab11=*# COMMIT;
COMMIT
lab11=# SELECT * FROM users WHERE group_id = 2;
 username |   fullname   | balance | group_id
----------+--------------+---------+----------
 bbrown   | Bob Brown    |     100 |        2
 mike     | Michael Dole |      88 |        2
(2 rows)

lab11=#
```

#### Terminal 2
```
lab11=# BEGIN;
BEGIN
lab11=*# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET
lab11=*# UPDATE users SET group_id = 2 WHERE username = 'bbrown';
UPDATE 1
lab11=*# COMMIT;
COMMIT
lab11=#
```