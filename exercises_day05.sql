--00-- Please create a simple BTree index for every foreign key in our
------ database. The name pattern should satisfy the next rule
------ “idx_{table_name}_{column_name}”. For example, the name BTree index for
------ the pizzeria_id column in the `menu` table is `idx_menu_pizzeria_id`.
CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);
CREATE INDEX idx_person_order_person_id ON person_order (person_id);
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);


--01-- Before further steps please write a SQL statement that returns pizzas’
------ and corresponding pizzeria names.
------ Let’s provide proof that your indexes are working for your SQL.
------ The sample of proof is the output of the `EXPLAIN ANALYZE` command:
------ ->  Index Scan using idx_menu_pizzeria_id on menu m  (...)
------ Hint: please think why your indexes are not working in a direct way and
------ what should we do to enable it?
SET ENABLE_SEQSCAN = OFF;

SELECT pizza_name, name AS pizzeria_name 
FROM pizzeria p JOIN menu m ON p.id = m.pizzeria_id;
EXPLAIN ANALYZE 
SELECT pizza_name, name AS pizzeria_name 
FROM pizzeria p JOIN menu m ON p.id = m.pizzeria_id;

RESET ENABLE_SEQSCAN


--02-- Please create a functional B-Tree index with name `idx_person_name` for
------ the column name of the `person` table. Index should contain person names
------ in upper case. Please write and provide any SQL with proof (`EXPLAIN 
------ANALYZE`) that index idx_person_name is working. 
CREATE INDEX idx_person_name ON person (UPPER(name));
SET ENABLE_SEQSCAN = OFF;

SELECT name FROM person WHERE UPPER(name) = 'DENIS';
EXPLAIN ANALYZE 
SELECT name FROM person WHERE UPPER(name) = 'DENIS';

RESET ENABLE_SEQSCAN;


--03-- Please create a better multicolumn B-Tree index with the name
------ `idx_person_order_multi` for the SQL statement below.
------ SELECT person_id, menu_id,order_date
------ FROM person_order
------ WHERE person_id = 8 AND menu_id = 19;
------ The `EXPLAIN ANALYZE` command should return the next pattern:
------ Index Only Scan using idx_person_order_multi on person_order ...
------ Please pay attention to "Index Only Scan" scanning!
------ Please provide any SQL with proof (`EXPLAIN ANALYZE`) that index
------ `idx_person_order_multi` is working. 
CREATE INDEX idx_person_order_multi 
  ON person_order (person_id, menu_id, order_date);
SET ENABLE_SEQSCAN = OFF;

SELECT person_id, menu_id, order_date 
FROM person_order WHERE person_id = 8 AND menu_id = 19;
EXPLAIN ANALYZE 
SELECT person_id, menu_id, order_date 
FROM person_order WHERE person_id = 8 AND menu_id = 19;

SELECT menu_id FROM person_order JOIN person ON person.id = person_id 
WHERE name = 'Denis';
EXPLAIN ANALYZE 
SELECT menu_id FROM person_order JOIN person ON person.id = person_id 
WHERE name = 'Denis';

RESET ENABLE_SEQSCAN;


--04-- Please create a unique BTree index with the name `idx_menu_unique` on
------ the `menu` table for  `pizzeria_id` and `pizza_name` columns. 
------ Please write and provide any SQL with proof (`EXPLAIN ANALYZE`) that
------ index `idx_menu_unique` is working. 
CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);
SET ENABLE_SEQSCAN = OFF;

SELECT pizza_name FROM menu WHERE pizzeria_id = 2;
EXPLAIN ANALYZE 
SELECT pizza_name FROM menu WHERE pizzeria_id = 2;

RESET ENABLE_SEQSCAN;


--05-- Please create a partial unique BTree index with the name
------ `idx_person_order_order_date` on the `person_order` table for
------ `person_id` and `menu_id` attributes with partial uniqueness for
------ `order_date` column for date ‘2022-01-01’.
------ The `EXPLAIN ANALYZE` command should return the next pattern:
------ Index Only Scan using idx_person_order_order_date on person_order ...
CREATE UNIQUE INDEX idx_person_order_order_date 
ON person_order (person_id, menu_id) WHERE order_date = '2022-01-01';
SET ENABLE_SEQSCAN = OFF;

SELECT person_id FROM person_order WHERE order_date = '2022-01-01';
EXPLAIN ANALYZE 
SELECT person_id FROM person_order WHERE order_date = '2022-01-01';

RESET ENABLE_SEQSCAN;


--06-- Please take a look at SQL below from a technical perspective (ignore a
------ logical case of that SQL statement) .
------ SELECT
------   m.pizza_name AS pizza_name,
------   max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS
------     BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
------ FROM  menu m
------ INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
------ ORDER BY 1,2;
------ Create a new BTree index with name `idx_1` which should improve the
------ “Execution Time” metric of this SQL. Please provide proof (`EXPLAIN
------ ANALYZE`) that SQL was improved.
------ Hint: this exercise looks like a “brute force” task to find a good
------ covering index therefore before your new test remove `idx_1` index.
CREATE INDEX idx_1 ON pizzeria (rating);
SET ENABLE_SEQSCAN = OFF;

EXPLAIN ANALYZE 
SELECT m.pizza_name AS pizza_name, 
  max(rating) OVER (PARTITION BY rating ORDER BY rating 
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k 
FROM menu m INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id ORDER BY 1,2;

DROP INDEX idx_1;

EXPLAIN ANALYZE 
SELECT m.pizza_name AS pizza_name, 
  max(rating) OVER (PARTITION BY rating ORDER BY rating 
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k 
FROM menu m INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id ORDER BY 1,2;

RESET ENABLE_SEQSCAN;