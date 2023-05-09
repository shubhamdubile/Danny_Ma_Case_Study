/* 10. In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - how many points do customer 
A and B have at the end of January? */

use dannys_diner;

with total_point as (
    SELECT
        sales.customer_id,
        CASE
            WHEN order_date >= join_date
            AND (
                CAST((order_date) AS DATE) - CAST((join_date) AS DATE)
            ) <= 7 THEN price * 20
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
        END AS total_points
    FROM
        sales
        JOIN menu ON sales.product_id = menu.product_id
        JOIN members ON sales.customer_id = members.customer_id
    WHERE
        order_date BETWEEN '2021-01-01'
        AND '2021-01-31'
)
SELECT
    customer_id,
    SUM(total_points) AS total_points
FROM
    total_point
GROUP BY
    customer_id
ORDER BY
    customer_id;
