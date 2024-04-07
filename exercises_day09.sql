--00-- Audit of incoming inserts
CREATE TABLE person_audit 
( created TIMESTAMP(0) WITH TIME ZONE DEFAULT NOW() NOT NULL, 
  type_event CHAR(1) DEFAULT 'I' NOT NULL, 
  CONSTRAINT ch_type_event CHECK (type_event IN ('I', 'U', 'D')), 
  row_id BIGINT NOT NULL, 
  name VARCHAR, 
  age INTEGER, 
  gender VARCHAR, 
  address VARCHAR
);

CREATE FUNCTION fnc_trg_person_insert_audit() 
RETURNS TRIGGER AS $trg_person_insert_audit$ 
BEGIN 
  INSERT INTO person_audit VALUES (now(), 'I', NEW.*); 
  RETURN NULL; 
END;
$trg_person_insert_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_insert_audit AFTER INSERT ON person 
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_insert_audit();

INSERT INTO person(id, name, age, gender, address) 
VALUES (10, 'Damir', 22, 'male', 'Irkutsk');


--01-- Audit of incoming updates
CREATE FUNCTION fnc_trg_person_update_audit() 
RETURNS TRIGGER AS $trg_person_update_audit$ 
BEGIN 
  INSERT INTO person_audit VALUES (now(), 'U', OLD.*); 
  RETURN NULL; 
END;
$trg_person_update_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_update_audit AFTER UPDATE ON person 
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_update_audit();

UPDATE person SET name = 'Bulat' WHERE id = 10; 
UPDATE person SET name = 'Damir' WHERE id = 10;


--02-- Audit of incoming deletes
CREATE FUNCTION fnc_trg_person_delete_audit() 
RETURNS TRIGGER AS $trg_person_delete_audit$ 
BEGIN 
  INSERT INTO person_audit VALUES (now(), 'D', OLD.*); 
  RETURN NULL; 
END;
$trg_person_delete_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_delete_audit AFTER DELETE ON person 
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;


--03-- Generic Audit
CREATE FUNCTION fnc_trg_person_audit() 
RETURNS TRIGGER AS $trg_person_audit$ 
BEGIN 
  IF (TG_OP = 'INSERT') THEN 
    INSERT INTO person_audit VALUES (now(), 'I', NEW.*); 
  ELSIF (TG_OP = 'UPDATE') THEN 
    INSERT INTO person_audit VALUES (now(), 'U', OLD.*); 
  ELSIF (TG_OP = 'DELETE') THEN 
    INSERT INTO person_audit VALUES (now(), 'D', OLD.*); 
  END IF; 
  RETURN NULL; 
END;
$trg_person_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_audit AFTER INSERT OR UPDATE OR DELETE ON person 
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_audit();

DROP TRIGGER trg_person_insert_audit ON person;
DROP TRIGGER trg_person_update_audit ON person;
DROP TRIGGER trg_person_delete_audit ON person;

DROP FUNCTION fnc_trg_person_insert_audit, 
  fnc_trg_person_update_audit, fnc_trg_person_delete_audit;

TRUNCATE TABLE person_audit;

INSERT INTO person(id, name, age, gender, address) 
VALUES (10, 'Damir', 22, 'male', 'Irkutsk');

UPDATE person SET name = 'Bulat' WHERE id = 10; 
UPDATE person SET name = 'Damir' WHERE id = 10;

DELETE FROM person WHERE id = 10;


--04-- Database View VS Database Function
CREATE FUNCTION fnc_persons_female() RETURNS SETOF person AS $$ 
  SELECT * FROM person WHERE gender = 'female'; 
$$ LANGUAGE SQL;

CREATE FUNCTION fnc_persons_male() RETURNS SETOF person AS $$ 
  SELECT * FROM person WHERE gender = 'male'; 
$$ LANGUAGE SQL;

SELECT * FROM fnc_persons_male();
SELECT * FROM fnc_persons_female();


--05-- Parameterized Database Function
DROP FUNCTION fnc_persons_female, fnc_persons_male;

CREATE FUNCTION fnc_persons(IN pgender text DEFAULT 'female') 
RETURNS SETOF person AS $$ 
  SELECT * FROM person WHERE gender = $1; 
$$ LANGUAGE SQL;

SELECT * FROM fnc_persons(pgender := 'male');
SELECT * FROM fnc_persons();


--06-- Function like a function-wrapper
CREATE FUNCTION fnc_person_visits_and_eats_on_date(
  IN pperson text DEFAULT 'Dmitriy', 
  IN pprice int DEFAULT 500, 
  IN pdate date DEFAULT '2022-01-08') 
RETURNS SETOF VARCHAR AS $$ 
BEGIN 
  RETURN QUERY 
  SELECT DISTINCT pizzeria.name FROM person_visits 
  JOIN pizzeria ON pizzeria.id = pizzeria_id 
  JOIN person ON person.id = person_id 
  JOIN menu ON pizzeria.id = menu.pizzeria_id 
  WHERE person.name = $1 AND price < $2 AND visit_date = $3; 
END; 
$$ LANGUAGE plpgsql;

SELECT * FROM fnc_person_visits_and_eats_on_date(pprice := 800);
SELECT * FROM fnc_person_visits_and_eats_on_date(pperson := 'Anna', 
  pprice := 1300, pdate := '2022-01-01');


--07-- Different view to find a Minimum
CREATE FUNCTION func_minimum(VARIADIC arr numeric[]) 
RETURNS numeric AS $$ 
  SELECT min($1[i]) FROM generate_subscripts($1, 1) g(i); 
$$ LANGUAGE SQL;

SELECT func_minimum(VARIADIC arr => ARRAY[10.0, -1.0, 5.0, 4.4]);


--08-- Fibonacci algorithm is in a function
CREATE FUNCTION fnc_fibonacci(pstop int DEFAULT 10) 
RETURNS SETOF int AS $$ 
  WITH RECURSIVE fib(x1, x2) AS 
    (VALUES(0, 1) 
    UNION ALL 
    SELECT greatest(x1, x2), x1 + x2 AS x1 FROM fib WHERE x2 < $1) 
  SELECT x1 FROM fib; 
$$ LANGUAGE SQL;

SELECT * FROM fnc_fibonacci(100);
SELECT * FROM fnc_fibonacci();