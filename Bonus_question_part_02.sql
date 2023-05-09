--Bonus Questions Part 02 (Rank All The Things)--
/*Danny also requires further information about the ranking of customer products, 
but he purposely does not need the ranking for non-member purchases so he expects 
null ranking values for the records when customers are not yet part of the loyalty program.*/

use dannys_diner;

with rank_member as (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        m.price,
        CASE
            WHEN s.order_date < mm.join_date
            OR mm.join_date IS NULL THEN 'N'
            ELSE 'Y'
        END AS member
    FROM
        sales AS s
        JOIN menu AS m ON s.product_id = m.product_id
        LEFT JOIN members mm ON s.customer_id = mm.customer_id
)
select
    *,
    case
        when member != 'N' then DENSE_RANK() Over(
            Partition by customer_id,
            member
            order by
                order_date
        )
        else 'null'
    end as ranking
from
    rank_member
order by
    customer_id