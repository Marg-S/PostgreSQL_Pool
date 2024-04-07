--00-- Let’s expand our data model to involve a new business feature.
------ Every person wants to see a personal discount and every business wants
------ to be closer for clients.
------ Please think about personal discounts for people from one side and
------ pizzeria restaurants from other. Need to create a new relational table
------ (please set a name `person_discounts`) with the next rules.
------ - set id attribute like a Primary Key (please take a look on id column
------ in existing tables and choose the same data type)
------ - set for attributes person_id and pizzeria_id foreign keys for
------ corresponding tables (data types should be the same like for id columns
------ in corresponding parent tables)
------ - please set explicit names for foreign keys constraints by pattern
------ fk_{table_name}_{column_name}, for example
------ `fk_person_discounts_person_id`
------ - add a discount attribute to store a value of discount in percent.
------ Remember, discount value can be a number with floats (please just use
------ `numeric` data type). So, please choose the corresponding data type to
------ cover this possibility.
CREATE TABLE person_discounts 
(id BIGINT PRIMARY KEY, 
person_id BIGINT, 
pizzeria_id BIGINT, 
CONSTRAINT fk_person_discounts_person_id 
  FOREIGN KEY (person_id) REFERENCES person(id), 
CONSTRAINT fk_person_discounts_pizzeria_id 
  FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id),
discount NUMERIC); 


--01-- Actually, we created a structure to store our discounts and we are ready
------ to go further and fill our `person_discounts` table with new records.
------ So, there is a table `person_order` that stores the history of a
------ person's orders. Please write a DML statement
------ (`INSERT INTO ... SELECT ...`) that makes  inserts new records into
------ `person_discounts` table based on the next rules.
------ - take aggregated state by person_id and pizzeria_id columns 
------ - calculate personal discount value by the next pseudo code:
------ if “amount of orders” = 1 then “discount” = 10.5 
------ else if “amount of orders” = 2 then “discount” = 22
------ else “discount” = 30`
------ - to generate a primary key for the person_discounts table please use
------ SQL construction below (this construction is from the WINDOW FUNCTION
------ SQL area).
------ `... ROW_NUMBER( ) OVER ( ) AS id ...`
INSERT INTO person_discounts 
SELECT ROW_NUMBER() OVER (), person_id, pizzeria_id,
  CASE WHEN COUNT(*) = 1 THEN 10.5 ELSE 
    CASE WHEN COUNT(*) = 2 THEN 22 ELSE 30 END 
  END 
FROM person_order JOIN menu ON menu.id = menu_id 
GROUP BY person_id, pizzeria_id;


--02-- Please write a SQL statement that returns orders with actual price and
------ price with applied discount for each person in the corresponding
------ pizzeria restaurant and sort by person name, and pizza name.
SELECT pr.name, pizza_name, price, 
  ROUND (price - price * discount / 100) AS discount_price, 
  pz.name AS pizzeria_name 
FROM person pr 
  JOIN person_order po ON pr.id = po.person_id 
  JOIN menu ON menu.id = po.menu_id 
  JOIN pizzeria pz ON pz.id = menu.pizzeria_id 
  JOIN person_discounts pd ON pd.person_id = pr.id AND pd.pizzeria_id = pz.id
ORDER BY pr.name, pizza_name;


--03-- Actually, we have to make improvements to data consistency from one side
------ and performance tuning from the other side. Please create a multicolumn
------ unique index (with name `idx_person_discounts_unique`) that prevents
------ duplicates of pair values person and pizzeria identifiers.
------ After creation of a new index, please provide any simple SQL statement
------ that shows proof of index usage (by using `EXPLAIN ANALYZE`).
------ The example of “proof” is below:
------ ...Index Scan using idx_person_discounts_unique on person_discounts...
CREATE UNIQUE INDEX idx_person_discounts_unique 
ON person_discounts (person_id, pizzeria_id);

SET ENABLE_SEQSCAN = OFF;

SELECT name, age, pizzeria_id, discount 
FROM person_discounts JOIN person ON person.id = person_id;
EXPLAIN ANALYZE 
SELECT name, age, pizzeria_id, discount 
FROM person_discounts JOIN person ON person.id = person_id;

RESET ENABLE_SEQSCAN;


--04-- Please add the following constraint rules for existing columns of the
------ `person_discounts` table.
------ - person_id column should not be NULL (use constraint name
------ `ch_nn_person_id`)
------ - pizzeria_id column should not be NULL (use constraint name
------ `ch_nn_pizzeria_id`)
------ - discount column should not be NULL (use constraint name
------ `ch_nn_discount`)
------ - discount column should be 0 percent by default
------ - discount column should be in a range values from 0 to 100 (use
------ constraint name `ch_range_discount`)
ALTER TABLE person_discounts 
  ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL),
  ADD CONSTRAINT ch_nn_pizzeria_id CHECK (pizzeria_id IS NOT NULL),
  ADD CONSTRAINT ch_nn_discount CHECK (discount IS NOT NULL),
  ALTER discount SET DEFAULT 0,
  ADD CONSTRAINT ch_range_discount CHECK (discount BETWEEN 0 AND 100);


--05-- To satisfy Data Governance Policies need to add comments for the table
------ and table's columns. Let’s apply this policy for the `person_discounts`
------ table. Please add English or Russian comments (it's up to you) that
------ explain what is a business goal of a table and all included attributes.
COMMENT ON TABLE person_discounts 
  IS 'Personal discounts for people';
COMMENT ON COLUMN person_discounts.id 
  IS 'Primary key';
COMMENT ON COLUMN person_discounts.person_id 
  IS 'Foreign key for table Person';
COMMENT ON COLUMN person_discounts.pizzeria_id 
  IS 'Foreign key for table Pizzeria';
COMMENT ON COLUMN person_discounts.discount 
  IS 'Value of discount in percent';


--06-- Let’s create a Database Sequence with the name `seq_person_discounts`
------ (starting from 1 value) and set a default value for id attribute of
------ `person_discounts` table to take a value from `seq_person_discounts`
------ each time automatically. 
------ Please be aware that your next sequence number is 1, in this case please
------ set an actual value for database sequence based on formula “amount of
------ rows in person_discounts table” + 1. Otherwise you will get errors about
------ Primary Key violation constraint.
CREATE SEQUENCE seq_person_discounts START 1;
SELECT SETVAL('seq_person_discounts', MAX(id)) FROM person_discounts;
ALTER TABLE person_discounts 
  ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');