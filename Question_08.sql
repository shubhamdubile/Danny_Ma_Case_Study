--8. What is the total items and amount spent for each member before they became a member?

use dannys_diner;

SELECT
    sales.customer_id,
    COUNT(order_date) AS total_items,
    SUM(menu.price) AS amound_spend
FROM
    sales
    JOIN members ON members.customer_id = sales.customer_id
    JOIN menu ON sales.product_id = menu.product_id
WHERE
    order_date < join_date
GROUP BY
    sales.customer_id
ORDER BY
    customer_id;