--3. What was the first item from the menu purchased by each customer?

use dannys_diner;

with first_item_cte as (
    select
        customer_id,
        product_id,
        order_date,
        Rank() over(
            partition by customer_id
            order by
                order_date
        ) as row_num
    from
        sales
)
SELECT
    ct.customer_id,
    ct.product_id,
    product_name
FROM
    first_item_cte AS ct,
    menu AS mu
WHERE
    ct.product_id = mu.product_id
    AND ct.row_num = 1
ORDER BY
    ct.customer_id;