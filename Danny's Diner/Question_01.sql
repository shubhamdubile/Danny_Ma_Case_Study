-- 1. What is the total amount each customer spent at the restaurant?

use dannys_diner;

SELECT
    sales.customer_id,
    SUM(menu.price) AS total_amount
FROM
    sales,
    menu
WHERE
    sales.product_id = menu.product_id
GROUP BY
    sales.customer_id;