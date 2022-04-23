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