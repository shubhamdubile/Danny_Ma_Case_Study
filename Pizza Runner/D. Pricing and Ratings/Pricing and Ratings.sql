/* D. Pricing and Ratings */

-------------------------------------------------------------------------------------------------------

/*D.1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
 how much money has Pizza Runner made so far if there are no delivery fees?*/
SELECT
    SUM(
        CASE
            WHEN PIZZA_ID = 1 THEN 12
            ELSE 10
        END
    ) AS TOTAL_MONEY
FROM
    [customer_orders] CO
    JOIN [runner_orders] RO on CO.ORDER_ID = RO.ORDER_ID
WHERE
    RO.cancellation IS NULL;

-------------------------------------------------------------------------------------------------------

/*D.2 What if there was an additional $1 charge for any pizza extras?
 Add cheese is $1 extra*/
WITH TOTAL AS (
    select
        CO.order_id,
        sum(
            case
                WHEN PIZZA_ID = 1 THEN 12
                ELSE 10
            END
        ) AS Total_Earned
    FROM
        [customer_orders] CO
        JOIN [runner_orders] RO ON CO.order_id = RO.order_id
    WHERE
        RO.[cancellation] IS NULL
    GROUP BY
        CO.order_id
),
CT AS (
    SELECT
        ORDER_ID,
        VALUE
    FROM
        [customer_orders]
        cross apply string_split([extras], ',') cs
),
CTE_B AS (
    SELECT
        CT.ORDER_ID,
        VALUE,
cASE
            WHEN VALUE != 4 THEN 1
            ELSE 2
        END AS PP
    FROM
        CT
        JOIN [runner_orders] RO ON CT.order_id = RO.order_id
    WHERE
        RO.cancellation IS NULL
),
UNION_CTE AS (
    SELECT
        *
    FROM
        TOTAL
    UNION
    SELECT
        ORDER_ID,
        PP
    FROM
        CTE_B
)
SELECT
    SUM(Total_Earned) AS TOTAL_COST
FROM
    UNION_CTE;

-------------------------------------------------------------------------------------------------------

/*D.3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
 how would you design an additional table for this new dataset - generate a schema for this new table and insert your own 
 data for ratings for each successful customer order between 1 to 5.*/
CREATE TABLE RATING (ORDER_ID INT NOT NULL, RATING INT)
INSERT INTO
    RATING
VALUES
    (1, 4),
    (2, 5),
    (3, 3),
    (4, 1),
    (5, 5),
    (7, 2),
    (8, 4),
    (10, 2);

SELECT
    *
FROM
    RATING;

-------------------------------------------------------------------------------------------------------

/*D.4 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
 customer_id
 order_id
 runner_id
 rating
 order_time
 pickup_time
 Time between order and pickup
 Delivery duration
 Average speed
 Total number of pizzas*/
SELECT
    CO.[customer_id],
    CO.[order_id],
    RO.[runner_id],
    R.RATING,
    CO.order_time,
    RO.pickup_time,
    DATEDIFF(MINUTE, order_time, pickup_time) AS Time_between_order_and_pickup,
    duration DELIVERY_DURATION,
    round(AVG(RO.DISTANCE * 1000 / RO.DURATION) ,2) AS "AVG_SPEED(mps)",
    COUNT(PIZZA_ID) AS NUM_PIZZA
FROM
    [customer_orders] CO
    JOIN [runner_orders] RO ON CO.order_id = RO.order_id
    JOIN RATINGS R ON R.ORDER_ID = CO.order_id
GROUP BY
    CO.[customer_id],
    CO.[order_id],
    RO.[runner_id],
    R.RATING,
    CO.order_time,
    RO.pickup_time,
    DATEDIFF(MINUTE, order_time, pickup_time),
    duration;
-------------------------------------------------------------------------------------------------------

/*D.5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
 how much money does Pizza Runner have left over after these deliveries? */
WITH TOTAL AS (
    select
        CO.order_id,
        sum(
            case
                WHEN PIZZA_ID = 1 THEN 12
                ELSE 10
            END
        ) AS Total_Earned
    FROM
        [customer_orders] CO
        JOIN [runner_orders] RO ON CO.order_id = RO.order_id
    WHERE
        RO.[cancellation] IS NULL
    GROUP BY
        CO.order_id
),
DELIVERY AS (
    SELECT
        ORDER_ID,
        DISTANCE * 0.3 AS Runner_pay
    FROM
        [runner_orders]
    WHERE
        [cancellation] IS NULL
)
SELECT
    SUM(Total_Earned - Runner_pay) as money_left
FROM
    TOTAL AS A
    JOIN DELIVERY AS B ON A.order_id = B.order_id;
