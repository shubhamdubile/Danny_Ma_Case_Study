/*C. Ingredient Optimisation*/


-------------------------------------------------------------------------------------------------------

/*C.1 What are the standard ingredients for each pizza?*/
SELECT
    PIZZA_ID,
    STRING_AGG(
        CONVERT(NVARCHAR(max), ISNULL([topping_name], 'N/A')),
        ','
    ) AS NN
FROM
    [pizza_recipes] AS PR
    JOIN [pizza_toppings] AS PT ON PR.toppings = PT.topping_id
GROUP BY
    PIZZA_ID;

-------------------------------------------------------------------------------------------------------

/*C.2 What was the most commonly added extra?*/
WITH COM_EXTRAS AS (
    SELECT
        TOP 1 CS.value,
        COUNT(CS.VALUE) AS T
    FROM
        [customer_orders]
        CROSS APPLY string_split([EXTRAS], ',') CS
    GROUP BY
        CS.VALUE
    ORDER BY
        COUNT(CS.VALUE) DESC
)
SELECT
    [topping_name] AS MOST_COM_EXTRAS
FROM
    COM_EXTRAS CE
    JOIN [pizza_toppings] PT ON PT.topping_id = CE.value;


-------------------------------------------------------------------------------------------------------


/*C.3 What was the most common exclusion?*/
WITH COM_exclusion AS (
    SELECT
        TOP 1 CS.value,
        COUNT(CS.VALUE) AS T
    FROM
        [customer_orders]
        CROSS APPLY string_split([exclusionS], ',') CS
    GROUP BY
        CS.VALUE
    ORDER BY
        COUNT(CS.VALUE) DESC
)
SELECT
    [topping_name] AS MOST_COM_exclusion
FROM
    COM_exclusion CE
    JOIN [pizza_toppings] PT ON PT.topping_id = CE.value;

-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------

/*C.4 Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

WITH CTE_B AS (
    SELECT
        RECORD_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([EXCLUSIONS], ',') cs
),
CTE_c AS (
    SELECT
        RECORD_ID,
        CONCAT(
            'Exclude ',
            STRING_AGG(CAST(t.topping_name AS VARCHAR(100)), ', ')
        ) AS record_options
    FROM
        CTE_B e
        JOIN pizza_toppings t ON e.VALUE = t.topping_id
    GROUP BY
        e.record_id
),
CTE_d AS (
    SELECT
        RECORD_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([extras], ',') cs
),
CTE_E AS (
    SELECT
        RECORD_ID,
        CONCAT(
            'Extra ',
            STRING_AGG(CAST(t.topping_name AS VARCHAR(100)), ', ')
        ) AS record_options
    FROM
        CTE_D e
        JOIN pizza_toppings t ON e.VALUE = t.topping_id
    GROUP BY
        e.record_id
),
CTE_UNION AS (
    SELECT
        *
    FROM
        CTE_C
    UNION
    SELECT
        *
    FROM
        CTE_e
)
SELECT
    CO.ORDER_ID,
    CO.[pizza_id],
    CO.[pizza_id],
    CO.order_time,
    CO.record_id,
    CONCAT_WS(
        ' - ',
        CAST(PN.pizza_name AS VARCHAR(100)),
        STRING_AGG(u.record_options, ' - ')
    ) AS pizza_info
FROM
    [customer_orders] CO
    LEFT JOIN CTE_UNION U ON CO.record_id = u.record_id
    JOIN [pizza_names] AS PN ON CO.pizza_id = PN.pizza_id
GROUP BY
    CO.ORDER_ID,
    CO.[pizza_id],
    CO.[pizza_id],
    CO.order_time,
    CO.record_id,
    CAST(PN.pizza_name AS VARCHAR(100))
ORDER BY
    RECORD_ID;


-------------------------------------------------------------------------------------------------------

/*C.5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x 
in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

WITH TOPPING AS (
    SELECT
        [pizza_id],
        [toppings],
        [topping_name]
    FROM
        [pizza_recipes] PR
        JOIN [pizza_toppings] PT ON PR.toppings = PT.topping_id
),
EXTRASS AS (
    SELECT
        RECORD_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([extras], ',') cs
),
exclusionsS AS (
    SELECT
        RECORD_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([exclusions], ',') cs
),
ingredients AS (
    SELECT
        c.*,
        p.pizza_name,
        CASE
            WHEN t.[toppings] IN (
                SELECT
                    VALUE
                FROM
                    EXTRASS e
                WHERE
                    e.record_id = c.record_id
            ) THEN '2x' + CAST(t.[topping_name] AS VARCHAR(100))
            ELSE t.[topping_name]
        END AS topping
    FROM
        customer_orders c
        JOIN TOPPING t ON t.pizza_id = c.pizza_id
        JOIN pizza_names p ON p.pizza_id = c.pizza_id
    WHERE
        t.toppings NOT IN (
            SELECT
                VALUE
            FROM
                exclusionsS e
            WHERE
                c.record_id = e.record_id
        )
)
SELECT
    record_id,
    order_id,
    customer_id,
    pizza_id,
    order_time,
    CONCAT(
        CAST(pizza_name AS VARCHAR(100)) + ': ',
        STRING_AGG(CAST(topping AS VARCHAR(100)), ', ')
    ) AS ingredients_list
FROM
    ingredients
GROUP BY
    record_id,
    record_id,
    order_id,
    customer_id,
    pizza_id,
    order_time,
    CAST(pizza_name AS VARCHAR(100))
ORDER BY
    record_id;

-------------------------------------------------------------------------------------------------------

/*C.6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? */
WITH TOPPING AS (
    SELECT
        [pizza_id],
        [toppings],
        [topping_name]
    FROM
        [pizza_recipes] PR
        JOIN [pizza_toppings] PT ON PR.toppings = PT.topping_id
),
EXTRASS AS (
    SELECT
        RECORD_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([extras], ',') cs
),
exclusionsS AS (
    SELECT
        RECORD_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([exclusions], ',') cs
),
ingredients AS (
    SELECT
        c.record_id,
        t.topping_name,
        CASE
            WHEN t.[toppings] IN (
                SELECT
                    VALUE
                FROM
                    EXTRASS e
                WHERE
                    e.record_id = c.record_id
            ) THEN 2
            WHEN t.[toppings] IN (
                SELECT
                    VALUE
                FROM
                    exclusionsS e
                WHERE
                    e.record_id = c.record_id
            ) THEN 0
            ELSE 1
        END AS NUM_USED
    FROM
        customer_orders c
        JOIN TOPPING t ON t.pizza_id = c.pizza_id
        JOIN pizza_names p ON p.pizza_id = c.pizza_id
    WHERE
        t.toppings NOT IN (
            SELECT
                VALUE
            FROM
                exclusionsS e
            WHERE
                c.record_id = e.record_id
        )
)
SELECT
    CAST(topping_name AS varchar(100)) toppings_name,
    SUM(NUM_USED) AS times_used
FROM
    ingredients
GROUP BY
    CAST(topping_name AS varchar(100))
ORDER BY
    times_used DESC;