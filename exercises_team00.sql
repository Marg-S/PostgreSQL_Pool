--00-- Classical TSP
CREATE TABLE nodes
( point1 VARCHAR NOT NULL,
  point2 VARCHAR NOT NULL,
  cost INTEGER NOT NULL
);

INSERT INTO nodes VALUES 
  ('a', 'b', 10),
  ('a', 'c', 15),
  ('a', 'd', 20),
  ('b', 'c', 35),
  ('b', 'd', 25),
  ('c', 'd', 30);

CREATE VIEW v_nodes AS 
SELECT 
    * 
FROM nodes 
UNION 
SELECT 
    point2, 
    point1, 
    cost 
FROM nodes 
ORDER BY 1,2;

WITH full_routes AS (
WITH RECURSIVE routes AS (
  SELECT 
    'a' AS tour, 
    point1, 
    point2, 
    cost, 
    cost AS summ 
  FROM v_nodes 
  WHERE point1 = 'a'

  UNION ALL

  SELECT 
    CONCAT(tour, ',', vn.point1), 
    vn.point1, 
    vn.point2,
    vn.cost,
    vn.cost + summ AS summ
  FROM routes r
  JOIN v_nodes vn
  ON vn.point1 = r.point2
  WHERE tour NOT LIKE CONCAT('%', vn.point1, '%')
)

SELECT
    summ AS total_cost,
    CONCAT('{', tour, ',a}') AS tour
FROM routes
WHERE LENGTH(tour) = 7 AND point2 = 'a')

SELECT * FROM full_routes 
WHERE total_cost = (SELECT MIN(total_cost) FROM full_routes)
ORDER BY total_cost, tour;



--01-- Opposite TSP
WITH full_routes AS (
WITH RECURSIVE routes AS (
  SELECT 
    'a' AS tour, 
    point1, 
    point2, 
    cost, 
    cost AS summ 
  FROM v_nodes 
  WHERE point1 = 'a'

  UNION ALL

  SELECT 
    CONCAT(tour, ',', vn.point1), 
    vn.point1, 
    vn.point2,
    vn.cost,
    vn.cost + summ AS summ
  FROM routes r
  JOIN v_nodes vn
  ON vn.point1 = r.point2
  WHERE tour NOT LIKE CONCAT('%', vn.point1, '%')
)

SELECT
    summ AS total_cost,
    CONCAT('{', tour, ',a}') AS tour
FROM routes
WHERE LENGTH(tour) = 7 
AND point2 = 'a')

SELECT * FROM full_routes 
WHERE total_cost = (SELECT MIN(total_cost) FROM full_routes) 
OR total_cost = (SELECT MAX(total_cost) FROM full_routes)
ORDER BY total_cost, tour;