--00-- Please write a SQL statement which returns a list of pizzerias names
------ with corresponding rating value which have not been visited by persons.
------ Denied: NOT IN, IN, NOT EXISTS, EXISTS, UNION, EXCEPT, INTERSECT
SELECT name, rating 
FROM pizzeria LEFT JOIN person_visits ON pizzeria.id = pizzeria_id 
WHERE pizzeria_id IS NULL;


--01-- Please write a SQL statement which returns the missing days from 1st to
------ 10th of January 2022 (including all days) for visits  of persons with
------ identifiers 1 or 2 (it means days missed by both). Please order by
------ visiting days in ascending mode.
------ Denied: NOT IN, IN, NOT EXISTS, EXISTS, UNION, EXCEPT, INTERSECT
SELECT DISTINCT A.visit_date AS missing_date 
FROM (SELECT * FROM person_visits) A 
LEFT JOIN (SELECT visit_date FROM person_visits 
  WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-10' 
  AND (person_id = 1 OR person_id = 2)) V 
ON A.visit_date = V.visit_date 
WHERE V.visit_date IS NULL 
ORDER BY missing_date;


--02-- Please write a SQL statement that returns a whole list of person names
------ visited (or not visited) pizzerias during the period from 1st to 3rd of
------ January 2022 from one side and the whole list of pizzeria names which
------ have been visited (or not visited) from the other side. Please pay
------ attention to the substitution value ‘-’ for NULL values in person_name
------ and pizzeria_name columns. Please also add ordering for all 3 columns.
------ Denied: NOT IN, IN, NOT EXISTS, EXISTS, UNION, EXCEPT, INTERSECT
SELECT 
  CASE WHEN person.name IS NULL THEN '-' ELSE person.name END 
    AS person_name, 
  visit_date, 
  CASE WHEN pizzeria.name IS NULL THEN '-' ELSE pizzeria.name END 
    AS pizzeria_name 
FROM person FULL JOIN 
  (SELECT * FROM person_visits 
    WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') V 
  ON person.id = person_id 
  FULL JOIN pizzeria ON pizzeria.id = pizzeria_id 
ORDER BY person_name, visit_date, pizzeria_name;


--03-- Let’s return back to Exercise #01, please rewrite your SQL by using the
------ CTE (Common Table Expression) pattern. Please move into the CTE part of
------ your "day generator". The result should be similar like in Exercise #01
------ Denied: NOT IN, IN, NOT EXISTS, EXISTS, UNION, EXCEPT, INTERSECT
WITH day_generator_cte (visit_date) 
AS (SELECT visit_date FROM person_visits 
  WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-10' 
  AND (person_id = 1 OR person_id = 2)) 
SELECT DISTINCT person_visits.visit_date AS missing_date 
FROM person_visits LEFT JOIN day_generator_cte 
  ON person_visits.visit_date = day_generator_cte.visit_date 
WHERE day_generator_cte.visit_date IS NULL 
ORDER BY missing_date;


--04-- Find full information about all possible pizzeria names and prices to
------ get mushroom or pepperoni pizzas. Please sort the result by pizza name
------ and pizzeria name then.
SELECT pizza_name, name AS pizzeria_name, price 
FROM menu JOIN pizzeria ON pizzeria.id = pizzeria_id 
WHERE pizza_name = 'mushroom pizza' OR pizza_name = 'pepperoni pizza' 
ORDER BY pizza_name, pizzeria_name;


--05-- Find names of all female persons older than 25 and order the result by
------ name.
SELECT name FROM person WHERE gender = 'female' AND age > 25 ORDER BY name;


--06-- Please find all pizza names (and corresponding pizzeria names using menu
------ table) that Denis or Anna ordered. Sort a result by both columns.
SELECT DISTINCT pizza_name, pizzeria.name AS pizzeria_name 
FROM menu JOIN pizzeria ON pizzeria.id = pizzeria_id 
  JOIN person_order ON menu.id = menu_id 
  JOIN person ON person.id = person_id 
WHERE person.name = 'Denis' OR person.name = 'Anna' 
ORDER BY pizza_name, pizzeria_name;


--07-- Please find the name of pizzeria Dmitriy visited on January 8, 2022 and
------ could eat pizza for less than 800 rubles.
SELECT pizzeria.name AS pizzeria_name 
FROM pizzeria JOIN person_visits ON pizzeria.id = pizzeria_id 
  JOIN person ON person.id = person_id 
  JOIN menu ON pizzeria.id = menu.pizzeria_id 
WHERE visit_date = '2022-01-08' AND person.name = 'Dmitriy' AND price < 800;


--08-- Please find the names of all males from Moscow or Samara cities who
------ orders either pepperoni or mushroom pizzas (or both). Please order the
------ result by person name in descending mode.
SELECT DISTINCT name 
FROM person JOIN person_order ON person.id = person_id 
  JOIN menu ON menu.id = menu_id 
WHERE gender = 'male' AND address IN ('Moscow', 'Samara') 
  AND (pizza_name LIKE '%pepperoni%' OR pizza_name LIKE '%mushroom%') 
ORDER BY name DESC;


--09-- Please find the names of all females who ordered both pepperoni and
------ cheese pizzas (at any time and in any pizzerias). Make sure that the
------ result is ordered by person name.
WITH women_pizza_cte (name, pizza_name) AS 
  (SELECT name, pizza_name 
  FROM person JOIN person_order ON person.id = person_id 
    JOIN menu ON menu.id = menu_id 
  WHERE gender = 'female') 
SELECT P.name 
FROM (SELECT * FROM women_pizza_cte WHERE pizza_name LIKE '%pepperoni%') P 
  JOIN (SELECT * FROM women_pizza_cte WHERE pizza_name LIKE '%cheese%') C 
  ON P.name = C.name 
ORDER BY P.name;


--10-- Please find the names of persons who live on the same address. Make sure
------ that the result is ordered by 1st person, 2nd person's name and common 
------ address.
SELECT P1.name AS person_name1, 
  P2.name AS person_name2, 
  P1.address AS common_address 
FROM (SELECT * FROM person) P1 
  JOIN (SELECT * FROM person) P2 ON P1.address = P2.address 
WHERE P1.id > P2.id 
ORDER BY person_name1, person_name2, common_address;