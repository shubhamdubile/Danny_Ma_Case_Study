/*9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
how many points would each customer have?
*/

use dannys_diner;

with total_point as (
    SELECT
        customer_id,
        CASE
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
        END AS total_points
    FROM
        sales,
        menu
    WHERE
        sales.product_id = menu.product_id
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
