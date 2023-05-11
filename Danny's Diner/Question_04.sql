--4.What is the most purchased item on the menu and how many times was it purchased by all customers?

use dannys_diner;

with most_purchased_cte as (
    SELECT
        product_id,
        COUNT(order_date)
    FROM
        sales
    GROUP BY
        product_id
    ORDER BY
        COUNT(order_date) DESC
    LIMIT
        1
)
SELECT
    s.customer_id,
    m.product_name AS most_purchased_item,
    COUNT(order_date) AS num_times_item_purchased
FROM
    sales s,
    menu m
WHERE
    s.product_id = m.product_id
    AND s.product_id = (
        SELECT
            product_id
        FROM
            most_purchased_cte
    )
GROUP BY
    s.customer_id,
    m.product_name;