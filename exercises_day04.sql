--00-- Please create 2 Database Views (with similar attributes like the
------ original table) based on simple filtering of gender of persons. Set the
------ corresponding names for the database views: `v_persons_female` and
------ `v_persons_male`.
CREATE VIEW v_persons_female AS SELECT * FROM person 
WHERE gender = 'female';

CREATE VIEW v_persons_male AS SELECT * FROM person 
WHERE gender = 'male';


--01-- Please use 2 Database Views from Exercise #00 and write SQL to get
------ female and male person names in one list. Please set the order by person
------ name.
SELECT name FROM v_persons_female 
UNION 
SELECT name FROM v_persons_male 
ORDER BY name;


--02-- Please create a Database View (with name `v_generated_dates`) which
------ should be “store” generated dates from 1st to 31th of January 2022 in
------ DATE type. Don’t forget about order for the generated_date column.  
CREATE VIEW v_generated_dates AS 
SELECT GS::DATE AS generated_date 
FROM GENERATE_SERIES('2022-01-01', '2022-01-31', INTERVAL '1 day') GS 
ORDER BY generated_date;


--03-- Please write a SQL statement which returns missing days for persons’
------ visits in January of 2022. Use `v_generated_dates` view for that task
------ and sort the result by missing_date column.
SELECT generated_date AS missing_date FROM v_generated_dates 
EXCEPT 
SELECT visit_date FROM person_visits 
ORDER BY missing_date;


--04-- Please write a SQL statement which satisfies a formula (R - S)∪(S - R).
------ Where R is the `person_visits` table with filter by 2nd of January 2022,
------ S is also `person_visits` table but with a different filter by 6th of
------ January 2022. Please make your calculations with sets under the
------ `person_id` column and this column will be alone in a result. The result
------ please sort by `person_id` column and your final SQL please present in
------ `v_symmetric_union` (*) database view.
------ (*) to be honest, the definition “symmetric union” doesn’t exist in Set
------ Theory. This is the author's interpretation, the main idea is based on
------ the existing rule of symmetric difference. 
CREATE VIEW v_symmetric_union AS 
WITH R_cte AS (SELECT person_id FROM person_visits 
  WHERE visit_date = '2022-01-02'), 
  S_cte AS (SELECT person_id FROM person_visits 
  WHERE visit_date = '2022-01-06') 
(SELECT * FROM R_cte EXCEPT SELECT * FROM S_cte) 
UNION 
(SELECT * FROM S_cte EXCEPT SELECT * FROM R_cte) 
ORDER BY person_id;


--05-- Please create a Database View `v_price_with_discount` that returns a
------ person's orders with person names, pizza names, real price and
------ calculated column `discount_price` (with applied 10% discount and
------ satisfies formula `price - price*0.1`). The result please sort by person
------ name and pizza name and make a round for `discount_price` column to
------ integer type.
CREATE VIEW v_price_with_discount AS 
SELECT name, pizza_name, price, ROUND(price - price * 0.1) AS discount_price 
FROM person JOIN person_order ON person.id = person_id 
  JOIN menu ON menu.id = menu_id 
ORDER BY name, pizza_name;


--06-- Please create a Materialized View `mv_dmitriy_visits_and_eats` (with
------ data included) based on SQL statement that finds the name of pizzeria
------ Dmitriy visited on January 8, 2022 and could eat pizzas for less than
------ 800 rubles (this SQL you can find out at Day #02 Exercise #07). 
------ To check yourself you can write SQL to Materialized View
------ `mv_dmitriy_visits_and_eats` and compare results with your previous
------ query.
CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS 
SELECT DISTINCT pizzeria.name AS pizzeria_name 
FROM pizzeria JOIN person_visits ON pizzeria.id = pizzeria_id 
  JOIN person ON person.id = person_id 
  JOIN menu ON pizzeria.id = menu.pizzeria_id 
WHERE visit_date = '2022-01-08' AND person.name = 'Dmitriy' AND price < 800;


--07-- Let's refresh data in our Materialized View `mv_dmitriy_visits_and_eats`
------ from exercise #06. Before this action, please generate one more Dmitriy
------ visit that satisfies the SQL clause of Materialized View except pizzeria
------ that we can see in a result from exercise #06. After adding a new visit
------ please refresh a state of data for `mv_dmitriy_visits_and_eats`.
INSERT INTO person_visits VALUES 
  ((SELECT MAX(id) + 1 FROM person_visits), 
  (SELECT id FROM person WHERE name = 'Dmitriy'), 
  (SELECT id FROM pizzeria WHERE name = 'DoDo Pizza'), '2022-01-08');
REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;


--08-- After all our exercises were born a few Virtual Tables and one
------ Materialized View. Let’s drop them!
DROP VIEW v_persons_female, v_persons_male, v_generated_dates, 
  v_price_with_discount, v_symmetric_union;
DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;