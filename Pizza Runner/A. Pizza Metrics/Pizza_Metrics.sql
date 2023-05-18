--A. Pizza Metrics

/*A.1 How many pizzas were ordered?*/
select
    count([order_id]) As Total_Order
from
    [customer_orders];

-------------------------------------------------------------------------------------------------------

/*A.2 How many unique customer orders were made?*/
select
    count(distinct [customer_id]) As Total_unique_customer
from
    [customer_orders];

-------------------------------------------------------------------------------------------------------

/*A.3 How many successful orders were delivered by each runner?*/
select
    count(order_id) as count_Successful_order
from
    [runner_orders]
where
    [cancellation] is null;

-------------------------------------------------------------------------------------------------------

/*A.4 How many of each type of pizza was delivered?*/
select
    co.pizza_id,
    count(co.[pizza_id]) as count_pizza_delivered
from
    [customer_orders] as co
    JOIN [runner_orders] as ro ON co.order_id = ro.order_id
where
    [cancellation] is null
group by
    co.[pizza_id];

-------------------------------------------------------------------------------------------------------

/*A.5 How many Vegetarian and Meatlovers were ordered by each customer?*/
Select
    [customer_id],
    cast(pizza_name as nvarchar(100)) as Pizza_name,
    count(co.[pizza_id]) as count_pizza_ordered
from
    [customer_orders] as co
    JOIN [pizza_names] pn on co.pizza_id = pn.pizza_id
group by
    [customer_id],
    cast(pizza_name as nvarchar(100))
Order by
    [customer_id];

-------------------------------------------------------------------------------------------------------

/*A.6 What was the maximum number of pizzas delivered in a single order?*/
select
    top 1 [order_id],
    count([pizza_id]) as Pizza_count
from
    [customer_orders]
group by
    [order_id]
order by
    count([pizza_id]) desc;


-------------------------------------------------------------------------------------------------------

/*A.7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?*/
with change_cte as (
    select
        [customer_id],
        sum(
            Case
                when [exclusions] is not null
                or [extras] is not null then 1
                else 0
            end
        ) as one_changes,
        sum(
            case
                when [extras] is null
                and [exclusions] is null then 1
                else 0
            end
        ) as NOchanges
    from
        [customer_orders] co
        LEFT JOIN [runner_orders] ro on co.order_id = ro.order_id
    where
        ro.cancellation is null
    group by
        [customer_id]
)
select
    *
from
    change_cte

-------------------------------------------------------------------------------------------------------


/*A.8 How many pizzas were delivered that had both exclusions and extras?*/
with change_cte as (
    select
        co.order_id,
        count(pizza_id) as num_pizza_order
    from
        [customer_orders] co
        LEFT JOIN [runner_orders] ro on co.order_id = ro.order_id
    where
        ro.cancellation is null
        and [extras] is not null
        and [exclusions] is not null
    group by
        co.order_id
)
select
    *
from
    change_cte;
	
	
	
-------------------------------------------------------------------------------------------------------

/*A.9 What was the total volume of pizzas ordered for each hour of the day?*/
select
    DATEPART(hour, [order_time]) as hours,
    count(pizza_id) count_order_pizza
from
    [customer_orders]
group by
    DATEPART(hour, [order_time]);

-------------------------------------------------------------------------------------------------------

/*A.10 What was the volume of orders for each day of the week?*/
select
    DATEPART(DW, [order_time]) as week_day,
    count([order_id]) as volumn_order
from
    [customer_orders]
group by
    DATEPART(DW, [order_time]);