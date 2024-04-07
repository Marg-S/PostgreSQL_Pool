--00-- Classical DWH
SELECT
    coalesce(u.name, 'not defined') AS name, 
    coalesce(u.lastname, 'not defined') AS lastname, 
    b.type, 
    SUM(b.money) AS volume, 
    coalesce(c.name, 'not defined') AS currency_name,
    coalesce(c.rate_to_usd, 1) AS last_rate_to_usd,
    (SUM(b.money) * coalesce(c.rate_to_usd, 1))::REAL AS total_volume_in_usd
FROM public.user u
FULL JOIN balance b ON u.id = b.user_id
FULL JOIN (
    SELECT
        c1.id, 
        c2.rate_to_usd, 
        c1.name
    FROM (
        SELECT 
            id, 
            name, 
            max(updated) as updated 
        FROM currency
    GROUP BY id, name) as c1
    JOIN currency c2
    ON c2.updated = c1.updated
    WHERE c2.name = c1.name
    ) c 
ON c.id = b.currency_id
GROUP BY u.id, b.type, c.name, c.rate_to_usd
ORDER BY name DESC, lastname, type;



--01-- Detailed Query
INSERT INTO currency VALUES (100, 'EUR', 0.85, '2022-01-01 13:29');
INSERT INTO currency VALUES (100, 'EUR', 0.79, '2022-01-08 13:29');

WITH cte AS (
    SELECT
    (b.updated - c.updated) AS dif,
    c.id,
    b.user_id,
    b.type,
    c.updated,
    b.updated AS balance_updated
FROM balance b
CROSS JOIN currency c
WHERE b.currency_id = c.id
), cte_neg AS (SELECT * FROM cte WHERE dif < INTERVAL '0 0:00:00.000'),
cte_pos AS (SELECT * FROM cte WHERE dif >= INTERVAL '0 0:00:00.000'),
cte_union AS (
SELECT 
    t1.user_id, 
    t1.id, 
    t1.dif, 
    updated, 
    balance_updated 
FROM (
    SELECT 
        user_id, 
        id, 
        min(dif) AS dif 
    FROM cte_pos 
    GROUP BY user_id, id, balance_updated
    ) t1
JOIN cte_pos ON cte_pos.dif = t1.dif AND cte_pos.user_id = t1.user_id AND cte_pos.id = t1.id
UNION 
SELECT 
    t2.user_id, 
    t2.id, 
    t2.dif, 
    updated, 
    balance_updated 
FROM (
    SELECT
        user_id, 
        id, 
        max(dif) AS dif 
    FROM cte_neg 
    GROUP BY user_id, id, balance_updated) t2
JOIN cte_neg ON cte_neg.dif = t2.dif AND cte_neg.user_id = t2.user_id AND cte_neg.id = t2.id
),
cte_res AS (
    SELECT 
        user_id, 
        id, 
        max(dif) AS dif, 
        balance_updated 
    FROM cte_union 
    GROUP BY user_id, id, balance_updated),
cte_result AS (
SELECT 
    t2.user_id, 
    t2.id, 
    t2.dif, 
    t2.updated, 
    t2.balance_updated 
FROM cte_res t1
JOIN cte_union t2 ON t1.user_id = t2.user_id AND t1.dif = t2.dif AND t2.id = t1.id)

SELECT
    coalesce(name, 'not defined') AS name, 
    coalesce(lastname, 'not defined') AS lastname, 
    coalesce(currency_name, 'not defined') AS currency_name,
    (money * coalesce(rate_to_usd, 1))::REAL AS currency_in_usd
FROM (
    SELECT 
        c.id, 
        cu.name AS currency_name, 
        c.dif, cu.rate_to_usd, 
        c.updated, 
        c.balance_updated, 
        u.name, 
        u.lastname, 
        b.money, 
        b.type 
    FROM cte_result c
LEFT JOIN balance b 
ON c.user_id = b.user_id AND c.balance_updated = b.updated AND b.currency_id = c.id
LEFT JOIN public.user u
ON c.user_id = u.id 
LEFT JOIN currency cu
ON cu.updated = c.updated  AND cu.id = c.id
UNION
SELECT 
    c.id, 
    cu.name AS currency_name, 
    c.dif, cu.rate_to_usd, 
    c.updated, 
    c.balance_updated, 
    u.name, 
    u.lastname, 
    b.money, 
    b.type 
FROM cte_result c
LEFT JOIN balance b 
ON c.user_id = b.user_id AND c.balance_updated = b.updated AND b.currency_id = c.id
LEFT JOIN public.user u
ON c.user_id = u.id 
LEFT JOIN currency cu
ON cu.updated = c.updated AND cu.id = c.id
) r
ORDER BY name DESC, lastname, currency_name;