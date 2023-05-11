--2 How many days has each customer visited the restaurant?

use dannys_diner;

SELECT
    customer_id,
    COUNT(DISTINCT (order_date)) AS days_visited_restaurant
FROM
    dannys_diner.sales
GROUP BY
    customer_id;
