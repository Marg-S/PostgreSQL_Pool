--00-- Please write a SQL statement which returns a list of pizza names, pizza
------ prices, pizzerias names and dates of visit for Kate and for prices in
------ range from 800 to 1000 rubles. Please sort by pizza, price and pizzeria
------ names.
SELECT pizza_name, price, pizzeria.name AS pizzeria_name, visit_date 
FROM menu JOIN pizzeria ON pizzeria.id = menu.pizzeria_id 
  JOIN person_visits ON pizzeria.id = person_visits.pizzeria_id 
  JOIN person ON person.id = person_id 
WHERE person.name = 'Kate' AND price BETWEEN 800 AND 1000 
ORDER BY pizza_name, price, pizzeria_name;


--01-- Please find all menu identifiers which are not ordered by anyone. The
------ result should be sorted by identifiers. Denied: any type of JOINs
SELECT id AS menu_id FROM menu 
EXCEPT 
SELECT menu_id FROM person_order 
ORDER BY menu_id;


--02-- Please use SQL statement from Exercise #01 and show pizza names from
------ pizzeria which are not ordered by anyone, including corresponding prices
------ also. The result should be sorted by pizza name and price.
SELECT pizza_name, price, name AS pizzeria_name 
FROM (SELECT id AS menu_id FROM menu 
    EXCEPT SELECT menu_id FROM person_order 
    ORDER BY menu_id) F 
  JOIN menu ON menu.id = menu_id 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
ORDER BY pizza_name, price;


--03-- Please find pizzerias that have been visited more often by women or by
------ men. For any SQL operators with sets save duplicates (UNION ALL,
------ EXCEPT ALL, INTERSECT ALL constructions). Please sort a result by the
------ pizzeria name.
WITH visits_cte AS 
  (SELECT pizzeria.name AS pizzeria_name, gender FROM pizzeria 
    JOIN person_visits ON pizzeria.id = pizzeria_id
    JOIN person ON person.id = person_id), 
  male_cte AS (SELECT pizzeria_name FROM visits_cte WHERE gender = 'male'), 
  female_cte AS (SELECT pizzeria_name FROM visits_cte WHERE gender = 'female') 
SELECT * FROM male_cte 
EXCEPT ALL 
SELECT * FROM female_cte 
UNION ALL 
(SELECT * FROM female_cte EXCEPT ALL SELECT * FROM male_cte) 
ORDER BY pizzeria_name;


--04-- Please find a union of pizzerias that have orders either from women or
------ from men. Other words, you should find a set of pizzerias names have
------ been ordered by females only and make "UNION" operation with set of
------ pizzerias names have been ordered by males only. Please be aware with
------ word “only” for both genders. For any SQL operators with sets don’t save
------ duplicates (UNION, EXCEPT, INTERSECT).  Please sort a result by the
------ pizzeria name.
WITH order_cte AS 
  (SELECT pizzeria.name AS pizzeria_name, gender FROM person_order 
    JOIN menu ON menu.id = menu_id 
    JOIN pizzeria ON pizzeria.id = pizzeria_id 
    JOIN person ON person.id = person_id), 
  male_cte AS (SELECT pizzeria_name FROM order_cte WHERE gender = 'male'), 
  female_cte AS (SELECT pizzeria_name FROM order_cte WHERE gender = 'female') 
SELECT * FROM female_cte 
EXCEPT 
SELECT * FROM male_cte 
UNION 
(SELECT * FROM male_cte 
EXCEPT 
SELECT * FROM female_cte)
ORDER BY pizzeria_name;


--05-- Please write a SQL statement which returns a list of pizzerias which
------ Andrey visited but did not make any orders. Please order by the pizzeria
------ name.
SELECT pizzeria.name AS pizzeria_name FROM pizzeria 
  JOIN person_visits ON pizzeria.id = pizzeria_id 
  JOIN person ON person.id = person_id 
WHERE person.name = 'Andrey' 
EXCEPT 
SELECT pizzeria.name AS pizzeria_name FROM pizzeria 
  JOIN menu ON pizzeria.id = pizzeria_id 
  JOIN person_order ON menu.id = menu_id 
  JOIN person ON person.id = person_id 
WHERE person.name = 'Andrey' 
ORDER BY pizzeria_name;


--06-- Please find the same pizza names who have the same price, but from
------ different pizzerias. Make sure that the result is ordered by pizza name.
WITH pizza_cte AS (SELECT pizza_name, pizzeria.name, price 
  FROM menu JOIN pizzeria ON pizzeria.id = pizzeria_id) 
SELECT P1.pizza_name,
  P1.name AS pizzeria_name_1, 
  P2.name AS pizzeria_name_2, 
  P1.price 
FROM pizza_cte P1 JOIN pizza_cte P2 ON P1.pizza_name = P2.pizza_name 
WHERE P1.price = P2.price AND P1.name < P2.name
ORDER BY P1.pizza_name;


--07-- Please register a new pizza with name “greek pizza” (use id = 19) with
------ price 800 rubles in “Dominos” restaurant (pizzeria_id = 2).
INSERT INTO menu VALUES (19, 2, 'greek pizza', 800);


--08-- Please register a new pizza with name “sicilian pizza” (whose id should
------ be calculated by formula is “maximum id value + 1”) with a price of 900
------ rubles in “Dominos” restaurant (please use internal query to get
------ identifier of pizzeria). Denied: don’t use direct numbers for
------ identifiers of Primary Key and pizzeria
INSERT INTO menu 
VALUES ((SELECT MAX(id) + 1 FROM menu), 
  (SELECT id FROM pizzeria WHERE name = 'Dominos'),'sicilian pizza', 900);


--09-- Please register new visits into Dominos restaurant from Denis and Irina
------ on 24th of February 2022. Denied: don’t use direct numbers for
------ identifiers of Primary Key and pizzeria
INSERT INTO person_visits VALUES 
  ((SELECT MAX(id) + 1 FROM person_visits), 
    (SELECT id FROM person 
    WHERE name = 'Denis'), 
    (SELECT id FROM pizzeria 
    WHERE name = 'Dominos'),
    '2022-02-24'),
  ((SELECT MAX(id) + 2 FROM person_visits), 
    (SELECT id FROM person 
    WHERE name = 'Irina'), 
    (SELECT id FROM pizzeria 
    WHERE name = 'Dominos'), 
    '2022-02-24');


--10-- Please register new orders from Denis and Irina on 24th of February 2022
------ for the new menu with “sicilian pizza”. Denied: don’t use direct numbers
------ for identifiers of Primary Key and pizzeria
INSERT INTO person_order VALUES 
  ((SELECT MAX(id) + 1 FROM person_order), 
    (SELECT id FROM person 
    WHERE name = 'Denis'), 
    (SELECT id FROM menu 
    WHERE pizza_name = 'sicilian pizza'), 
    '2022-02-24'),
  ((SELECT MAX(id) + 2 FROM person_order), 
    (SELECT id FROM person 
    WHERE name = 'Irina'), 
    (SELECT id FROM menu 
    WHERE pizza_name = 'sicilian pizza'), 
    '2022-02-24');


--11-- Please change the price for “greek pizza” on -10% from the current value
UPDATE menu SET price = ROUND(price * 0.9) WHERE pizza_name = 'greek pizza';


--12-- Please register new orders from all persons for “greek pizza” on 25th of
------ February 2022. Denied: don’t use direct numbers for identifiers of
------ Primary Key, and menu. Don’t use window functions like ROW_NUMBER()
------ Don’t use atomic INSERT statements
INSERT INTO person_order 
SELECT MAX(id) + GENERATE_SERIES(1, (SELECT COUNT(*) FROM person)), 
  GENERATE_SERIES((SELECT MIN(id) FROM person), (SELECT MAX(id) FROM person)), 
  (SELECT id FROM menu 
  WHERE pizza_name = 'greek pizza'), 
  '2022-02-25' 
FROM person_order;


--13-- Please write 2 SQL (DML) statements that delete all new orders from
------ exercise #12 based on order date. Then delete “greek pizza” from the
------ menu.
DELETE FROM person_order WHERE order_date = '2022-02-25';
DELETE FROM menu WHERE pizza_name = 'greek pizza';