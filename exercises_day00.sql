--00-- Let’s make our first task. Please make a select statement which returns
------ all person's names and person's ages from the city ‘Kazan’.
SELECT name, age FROM person 
WHERE address = 'Kazan';


--01-- Please make a select statement which returns names, ages for all women
------ from the city ‘Kazan’. Yep, and please sort result by name.
SELECT name, age FROM person 
WHERE gender = 'female' AND address = 'Kazan' 
ORDER BY name;


--02-- Please make 2 syntax different select statements which return a list of
------ pizzerias (pizzeria name and rating) with rating between 3.5 and
------ 5 points (including limit points) and ordered by pizzeria rating.

--02-1-- the 1st select statement must contain comparison signs  (<=, >=)
SELECT name, rating FROM pizzeria 
WHERE rating >= 3.5 AND rating <= 5 
ORDER BY rating;

--02-2-- the 2nd select statement must contain BETWEEN keyword
SELECT name, rating FROM pizzeria 
WHERE rating BETWEEN 3.5 AND 5 
ORDER BY rating;


--03-- Please make a select statement which returns the person's identifiers
------ (without duplication) who visited pizzerias in a period from 6th of
------ January 2022 to 9th of January 2022 (including all days) or visited
------ pizzeria with identifier 2. Also include ordering clause by person
------ identifier in descending mode.
SELECT DISTINCT person_id FROM person_visits 
WHERE visit_date BETWEEN '2022-01-06' AND '2022-01-09' OR pizzeria_id = 2 
ORDER BY person_id DESC;


--04-- Please make a select statement which returns one calculated field with
------ name ‘person_information’ in one string like described in the next
------ sample: Anna (age:16,gender:'female',address:'Moscow')
------ Finally, please add the ordering clause by calculated column in
------ ascending mode. Please pay attention to quote symbols in your formula!
SELECT CONCAT 
  (name, ' (age:', age, ',gender:''', gender, ''',address:''', address, ''')')
  AS person_information 
FROM person 
ORDER BY person_information;


--05-- Please make a select statement which returns person's names (based on
------ internal query in SELECT clause) who made orders for the menu with
------ identifiers 13 , 14 and 18 and date of orders should be equal 7th of
------ January 2022. Denied: IN, any types of JOINs
SELECT 
  (SELECT name FROM person WHERE person.id = person_id) AS NAME 
FROM person_order 
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18)
  AND order_date = '2022-01-07';


--06-- Please use SQL construction from Exercise 05 and add a new calculated
------ column with name ‘check_name’ with a check statement (a pseudo code for
------ this check is presented below) in the SELECT clause:
------ if (person_name == 'Denis') then return true else return false
------ Denied: IN, any types of JOINs
SELECT 
  (SELECT name FROM person 
  WHERE person.id = person_id) AS name, 
  (SELECT CASE WHEN name = 'Denis' THEN 'true' ELSE 'false' END FROM person 
  WHERE person.id = person_id) AS check_name 
FROM person_order 
WHERE (menu_id = 13 OR menu_id = 14 or menu_id = 18)
  AND order_date = '2022-01-07';


--07-- Let’s apply data intervals for the person table. Please make a SQL
------ statement which returns a person's identifiers, person's names and
------ interval of person’s ages (set a name of a new calculated column as
------ ‘interval_info’) based on pseudo code below.
------ if (age >= 10 and age <= 20) then return 'interval #1'
------ else if (age > 20 and age < 24) then return 'interval #2'
------ else return 'interval #3'
------ Please sort a result by ‘interval_info’ column in ascending mode.
SELECT id, name, 
  CASE WHEN age BETWEEN 10 AND 20 THEN 'interval #1' 
       WHEN age > 20 AND age < 24 THEN 'interval #2' 
  ELSE 'interval #3' END 
  AS interval_info 
FROM person 
ORDER BY interval_info;


--08-- Please make a SQL statement which returns all columns from the
------ person_order table with rows whose identifier is an even number.
------ The result have to order by returned identifier.
SELECT * FROM person_order 
WHERE id % 2 = 0 
ORDER BY id;


--09-- Please make a select statement that returns person names and pizzeria
------ names based on the person_visits table with date of visit in a period
------ from 07th of January to 09th of January 2022 (including all days) (based
------ on internal query in FROM clause). Please add a ordering clause by
------ person name in ascending mode and by pizzeria name in descending mode.
------ Denied: any types of JOINs
SELECT 
  (SELECT name FROM person 
  WHERE person.id = person_id) AS person_name, 
  (SELECT name FROM pizzeria 
  WHERE pizzeria.id = pizzeria_id) AS pizzeria_name
FROM 
  (SELECT * FROM person_visits 
  WHERE visit_date BETWEEN '2022-01-07' AND '2022-01-09') AS pv 
ORDER BY person_name, pizzeria_name DESC;