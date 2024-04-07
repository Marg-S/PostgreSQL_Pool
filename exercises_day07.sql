--00-- Let’s make a simple aggregation, please write a SQL statement that
------ returns person identifiers and corresponding number of visits in any
------ pizzerias and sorting by count of visits in descending mode and sorting
------ in `person_id` in ascending mode.
SELECT person_id, COUNT(*) AS count_of_visits 
FROM person_visits 
GROUP BY person_id 
ORDER BY count_of_visits DESC, person_id;


--01-- Please change a SQL statement from Exercise 00 and return a person name
------ (not identifier). Additional clause is  we need to see only top-4
------ persons with maximal visits in any pizzerias and sorted by a person
------ name.
SELECT name, COUNT(*) AS count_of_visits 
FROM person_visits JOIN person ON person.id = person_id 
GROUP BY name 
ORDER BY count_of_visits DESC, name LIMIT 4;


--02-- Please write a SQL statement to see 3 favorite restaurants by visits and
------ by orders in one list (please add an action_type column with values
------ ‘order’ or ‘visit’, it depends on data from the corresponding table).
------ The result should be sorted by action_type column in ascending mode and
------ by count column in descending mode.
(SELECT name, COUNT(*) AS count, 'visit' AS action_type 
FROM person_visits JOIN pizzeria ON pizzeria.id = pizzeria_id 
GROUP BY name 
ORDER BY count DESC LIMIT 3) 
UNION 
(SELECT name, COUNT(*), 'order' 
FROM person_order JOIN menu ON menu.id = menu_id 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
GROUP BY name 
ORDER BY count DESC LIMIT 3) 
ORDER BY action_type, count DESC;


--03-- Please write a SQL statement to see restaurants are grouping by visits
------ and by orders and joined with each other by using restaurant name.
------ You can use internal SQLs from Exercise 02 (restaurants by visits and by
------ orders) without limitations of amount of rows.
------ Additionally, please add the next rules.
------ - calculate a sum of orders and visits for corresponding pizzeria (be
------ aware, not all pizzeria keys are presented in both tables).
------ - sort results by `total_count` column in descending mode and by `name`
------ in ascending mode.
SELECT name, SUM(count) AS total_count 
FROM ((SELECT name, COUNT(name) AS count 
  FROM person_visits JOIN pizzeria ON pizzeria.id = pizzeria_id 
  GROUP BY name) 
  UNION ALL 
  (SELECT name, COUNT(name) FROM person_order JOIN menu ON menu.id = menu_id 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
  GROUP BY name)) A 
GROUP BY name 
ORDER BY total_count DESC, name;


--04-- Please write a SQL statement that returns the person name and
------ corresponding number of visits in any pizzerias if the person has
------ visited more than 3 times (> 3). Denied: WHERE
SELECT name, COUNT(*) AS count_of_visits 
FROM person_visits JOIN person ON person.id = person_id 
GROUP BY name 
HAVING COUNT(*) > 3;


--05-- Please write a simple SQL query that returns a list of unique person
------ names who made orders in any pizzerias. The result should be sorted by
------ person name. Denied: GROUP BY, any type (UNION,...) working with sets
SELECT DISTINCT name 
FROM person_order JOIN person ON person.id = person_id 
ORDER BY name;


--06-- Please write a SQL statement that returns the amount of orders, average
------ of price, maximum and minimum prices for sold pizza by corresponding
------ pizzeria restaurant. The result should be sorted by pizzeria name.
------ Round your average price to 2 floating numbers.
SELECT pizzeria.name, COUNT(*) AS count_of_orders, 
  ROUND (AVG(price), 2)::REAL, MAX(price), MIN(price) 
FROM person_order JOIN menu ON menu.id = menu_id 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
GROUP BY pizzeria.name 
ORDER BY pizzeria.name;


--07-- Please write a SQL statement that returns a common average rating (the
------ output attribute name is global_rating) for all restaurants. Round your
------ average rating to 4 floating numbers.
SELECT ROUND(AVG(rating), 4) AS global_rating FROM pizzeria;


--08-- We know about personal addresses from our data. Let’s imagine, that
------ particular person visits pizzerias in his/her city only. Please write a
------ SQL statement that returns address, pizzeria name and amount of persons’
------ orders. The result should be sorted by address and then by restaurant
------ name.
SELECT address, pizzeria.name, COUNT(*) AS count_of_orders 
FROM person_order JOIN person ON person.id = person_id 
  JOIN menu ON menu.id = menu_id 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
GROUP BY pizzeria.name, address 
ORDER BY address, name;


--09-- Please write a SQL statement that returns aggregated information by
------ person’s address, the result of
------ “Maximal Age - (Minimal Age  / Maximal Age)” that is presented as a
------ formula column, next one is average age per address and the result of
------ comparison between formula and average columns (other words, if formula
------ is greater than  average then True, otherwise False value).
------ The result should be sorted by address column.
SELECT address, formula, average, 
  CASE WHEN formula > average THEN 'true' ELSE 'false' END AS comparison 
FROM (SELECT address, ROUND(MAX(age) - (MIN(age::NUMERIC) / MAX(age)), 2)::REAL
  AS formula, ROUND(AVG(age), 2)::REAL AS average 
  FROM person 
  GROUP BY address) A 
ORDER BY address;