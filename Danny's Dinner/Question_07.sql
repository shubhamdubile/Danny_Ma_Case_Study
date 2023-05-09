--7. Which item was purchased just before the customer became a member?

use dannys_diner;

with first_item as (
    select
        sales.customer_id,
        product_id,
        order_date,
        rank() over(
            partition by sales.customer_id
            order by
                order_date desc
        ) as ord
    from
        sales,
        members
    where
        sales.customer_id = members.customer_id
        and order_date < join_date
)
SELECT
    customer_id,
    product_name AS first_purchased_item
FROM
    first_item,
    menu
WHERE
    first_item.product_id = menu.product_id
    AND ord = 1
ORDER BY
    customer_id;