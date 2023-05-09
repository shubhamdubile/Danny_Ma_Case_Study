--Bonus Questions Part 01(Join All The Things)--
/*
Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to 
quickly derive insights without needing to join the underlying tables using SQL.*/

use dannys_diner;

SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date < mm.join_date THEN 'N'
        ELSE 'Y'
    END AS member
FROM
    sales AS s
    JOIN menu AS m ON s.product_id = m.product_id
    LEFT JOIN members mm ON s.customer_id = mm.customer_id