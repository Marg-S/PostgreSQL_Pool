--00-- Simple transaction

---Session #1
BEGIN;
---Session #2
BEGIN;
---Session #1
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #1
COMMIT;
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
COMMIT;


--01-- Lost Update Anomaly

---Session #1
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #1
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
---Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
---Session #1
COMMIT;
---Session #2
COMMIT;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


--02-- Lost Update for Repeatable Read

---Session #1
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #1
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
---Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
---Session #1
COMMIT;
---Session #2
COMMIT;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


--03-- Non-Repeatable Reads Anomaly

---Session #1
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
COMMIT;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
COMMIT;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


--04-- Non-Repeatable Reads for Serialization

---Session #1
BEGIN ISOLATION LEVEL SERIALIZABLE;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN ISOLATION LEVEL SERIALIZABLE;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
UPDATE pizzeria SET rating = 3.0 WHERE name = 'Pizza Hut';
COMMIT;
---Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
COMMIT;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
---Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


--05-- Phantom Reads Anomaly

---Session #1
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
SELECT SUM(rating) FROM pizzeria;
---Session #2
UPDATE pizzeria SET rating = 1 WHERE name = 'Pizza Hut';
COMMIT;
---Session #1
SELECT SUM(rating) FROM pizzeria;
COMMIT;
SELECT SUM(rating) FROM pizzeria;
---Session #2
SELECT SUM(rating) FROM pizzeria;


--06-- Phantom Reads for Repeatable Read

---Session #1
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
SELECT SUM(rating) FROM pizzeria;
---Session #2
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
COMMIT;
---Session #1
SELECT SUM(rating) FROM pizzeria;
COMMIT;
SELECT SUM(rating) FROM pizzeria;
---Session #2
SELECT SUM(rating) FROM pizzeria;


--07-- Deadlock

---Session #1
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #2
BEGIN;
SHOW TRANSACTION ISOLATION LEVEL;
---Session #1
UPDATE pizzeria SET rating = 1 WHERE id = 1;
---Session #2
UPDATE pizzeria SET rating = 2 WHERE id = 2;
---Session #1
UPDATE pizzeria SET rating = 1 WHERE id = 2;
---Session #2
UPDATE pizzeria SET rating = 2 WHERE id = 1;
---Session #1
COMMIT;
---Session #2
COMMIT;