-- 5. Which item was the most popular for each customer?

use dannys_diner;

with most_popular_item as (
    select
        customer_id,
        product_id,
        Rank() over(
            partition by customer_id
            order by
                count(*) desc
        ) as row_num
    from
        sales
    group by
        customer_id,
        product_id
    order by
        customer_id
)
SELECT
    customer_id,
    product_name
FROM
    most_popular_item,
    menu
WHERE
    most_popular_item.product_id = menu.product_id
    AND row_num = 1
ORDER BY
    customer_id;
