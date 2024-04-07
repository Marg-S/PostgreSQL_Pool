--00-- Please write a SQL statement which returns menu’s identifier and pizza
------ names from menu table and person’s identifier and person name from
------ person table in one global list (with column names object_id,
------ object_name) ordered by object_id and then by object_name columns.
SELECT id AS object_id, pizza_name AS object_name FROM menu 
UNION ALL
SELECT id, name FROM person 
ORDER BY object_id, object_name;


--01-- Please modify a SQL statement from “exercise 00” by removing the
------ object_id column. Then change ordering by object_name for part of data
------ from the person table and then from menu table. Please save duplicates!
(SELECT name AS object_name FROM person ORDER BY name) 
UNION ALL 
(SELECT pizza_name FROM menu ORDER BY pizza_name);


--02-- Please write a SQL statement which returns unique pizza names from the
------ menu table and orders by pizza_name column in descending mode. Please
------ pay attention to the Denied section.
------ Denied: DISTINCT, GROUP BY, HAVING, any type of JOINs
SELECT pizza_name FROM menu 
UNION 
SELECT pizza_name FROM menu 
ORDER BY pizza_name DESC;


--03-- Please write a SQL statement which returns common rows for attributes
------ order_date, person_id from person_order table from one side and
------ visit_date, person_id from person_visits table from the other side. In
------ other words, let’s find identifiers of persons, who visited and ordered
------ some pizza on the same day. Actually, please add ordering by action_date
------ in ascending mode and then by person_id in descending mode.
------ Denied: any type of JOINs
SELECT order_date AS action_date, person_id FROM person_order 
INTERSECT ALL
SELECT visit_date, person_id FROM person_visits 
ORDER BY action_date, person_id DESC;


--04-- Please write a SQL statement which returns a difference (minus) of
------ person_id column values with saving duplicates between person_order
------ table and person_visits table for order_date and visit_date are for
------ 7th of January of 2022. Denied: any type of JOINs
SELECT person_id FROM person_order 
WHERE order_date = '2022-01-07' 
EXCEPT ALL 
SELECT person_id FROM person_visits 
WHERE visit_date = '2022-01-07';


--05-- Please write a SQL statement which returns all possible combinations
------ between person and pizzeria tables and please set ordering by person
------ identifier and then by pizzeria identifier columns.
SELECT person.id AS person_id, 
  person.name AS person_name, 
  age, gender, address, pizzeria.id AS pizzeria_id, 
  pizzeria.name AS pizzeria_name, rating 
FROM person CROSS JOIN pizzeria 
ORDER BY person.id, pizzeria.id;


--06-- Let's return our mind back to exercise #03 and change our SQL statement
------ to return person names instead of person identifiers and change ordering
------ by action_date in ascending mode and then by person_name in descending
------ mode.
SELECT order_date AS action_date, name AS person_name
FROM person_order JOIN person ON person.id = person_id
INTERSECT ALL
SELECT visit_date, name 
FROM person_visits JOIN person ON person.id = person_id 
ORDER BY action_date, person_name DESC;


--07-- Please write a SQL statement which returns the date of order from the
------ person_order table and corresponding person name (name and age are
------ formatted as: Andrey (age:21)) which made an order from the person
------ table. Add a sort by both columns in ascending mode.
SELECT order_date, CONCAT (name, ' (age:', age, ')') AS person_information 
FROM person_order JOIN person ON person.id = person_id 
ORDER BY order_date, person_information;


--08-- Please rewrite a SQL statement from exercise #07 by using NATURAL JOIN
------ construction. The result must be the same like for exercise #07.
------ Denied: other type of  JOINs
SELECT order_date, CONCAT (name, ' (age:', age, ')') AS person_information 
FROM person_order NATURAL JOIN
  (SELECT name, age, id AS person_id FROM person) P 
ORDER BY order_date, person_information;


--09-- Please write 2 SQL statements which return a list of pizzerias names
------ which have not been visited by persons by using IN for 1st one and
------ EXISTS for the 2nd one.
SELECT name FROM pizzeria 
WHERE id NOT IN (SELECT pizzeria_id FROM person_visits);
  
SELECT name FROM pizzeria 
WHERE NOT EXISTS 
  (SELECT pizzeria_id FROM person_visits 
  WHERE pizzeria.id = pizzeria_id);


--10-- Please write a SQL statement which returns a list of the person names
------ which made an order for pizza in the corresponding pizzeria. Please make
------ ordering by 3 columns (person_name, pizza_name, pizzeria_name) in
------ ascending mode.
SELECT person.name AS person_name, menu.pizza_name, 
  pizzeria.name AS pizzeria_name 
FROM person_order JOIN person ON person.id = person_id 
  JOIN menu ON menu.id = menu_id 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
ORDER BY person_name, pizza_name, pizzeria_name;