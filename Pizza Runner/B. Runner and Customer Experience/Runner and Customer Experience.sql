--B:-- Runner and Customer Experience

-------------------------------------------------------------------------------------------------------

/*B.1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/
select
    DATEPART(wk, [registration_date]) as week,
    count([runner_id]) as count_runner
from
    [runners]
group by
    DATEPART(wk, [registration_date]);


-------------------------------------------------------------------------------------------------------

/*B.2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?*/
select
    [runner_id],
    avg(DATEDIFF(MINUTE, [order_time], [pickup_time])) as AVG_time_reach_HQ
from
    [runner_orders] ro
    JOIN [customer_orders] as co ON co.order_id = ro.order_id
group by
    [runner_id];

-------------------------------------------------------------------------------------------------------

/*B.3 Is there any relationship between the number of pizzas and how long the order takes to prepare?*/
select
    co.[order_id],
    count([pizza_id]) as Pizza_count,
    avg(DATEDIFF(MINUTE, [order_time], [pickup_time])) as AVG_time_reach_HQ
from
    [runner_orders] ro
    JOIN [customer_orders] as co ON co.order_id = ro.order_id
where
    ro.cancellation is null
group by
    co.[order_id];

-------------------------------------------------------------------------------------------------------

/*B.4 What was the average distance travelled for each customer?*/
select
    [customer_id],
    round(
        avg(
            DATEDIFF(MINUTE, [order_time], [pickup_time]) + distance
        ),
        2
    ) as AVG_time_reach_HQ
from
    [runner_orders] ro
    JOIN [customer_orders] as co ON co.order_id = ro.order_id
where
    ro.cancellation is null
group by
    [customer_id];

-------------------------------------------------------------------------------------------------------

/*B.5 What was the difference between the longest and shortest delivery times for all orders?*/
with long_short as (
    select
        co.[order_id],
        round(
            (
                DATEDIFF(MINUTE, [order_time], [pickup_time]) + distance
            ),
            2
        ) as Dis
    from
        [runner_orders] ro
        JOIN [customer_orders] as co ON co.order_id = ro.order_id
    where
        ro.cancellation is null
)
select
    MAx(Dis) - MIN(dis) long_short_diff
from
    long_short;

-------------------------------------------------------------------------------------------------------

/*B.6 What was the average speed for each runner for each delivery and do you notice any trend for these values?*/
select
    [runner_id],
    avg([distance] * 1000 / [duration] * 60) as avg_speed_mps
from
    [runner_orders]
where
    [cancellation] is null
group by
    [runner_id];

-------------------------------------------------------------------------------------------------------


/*B.7 What is the successful delivery percentage for each runner?*/
with total_order as (
    select
        [runner_id],
        count([order_id]) as total_order
    from
        [runner_orders]
    group by
        [runner_id]
),
success_order as (
    select
        [runner_id],
        count([order_id]) as success_orders
    from
        [runner_orders]
    where
        [cancellation] is null
    group by
        [runner_id]
)
select
    t.[runner_id],
    success_orders * 100 / total_order as success_percentage
from
    success_order so
    Join total_order t ON so.[runner_id] = t.[runner_id];
