/*table:-- [customer_orders]*/

update
    [customer_orders]
set
    exclusions = case
        When [exclusions] = ''
        or [exclusions] = 'null' Then NULL
        else exclusions
    end;

update
    [customer_orders]
set
    extras = case
        When [extras] = ''
        or [extras] = 'null' Then NULL
        else [extras]
    end;
	

ALTER TABLE [customer_orders]
ADD record_id INT IDENTITY(1,1);

-----------------------------------------------------------------------------------------------


/* Table [runner_orders]:--*/

update
    [runner_orders]
set
    [pickup_time] = case
        When [pickup_time] = 'null' Then NULL
        else [pickup_time]
    end;


update
    [runner_orders]
set
    [duration] = case
        When [duration] = 'null' Then NULL
        when [duration] like '%mins' then replace(duration, 'mins', '')
        when [duration] like '%minutes' then replace(duration, 'minutes', '')
        when [duration] like '%minute' then replace(duration, 'minute', '')
        else [duration]
    end;

Alter table
    [runner_orders]
Alter Column
    [duration] float;



update
    [runner_orders]
set
    [distance] = case
        When [distance] like '%null%' then null
        when [distance] like '%km' then replace(distance, 'km', '')
        else [distance]
    end;

Alter table
    [runner_orders]
Alter Column
    [distance] float;



update
    [runner_orders]
set
    [cancellation] = case
        When [cancellation] = 'null'
        or [cancellation] = '' Then NULL
        else [cancellation]
    end;

--------------------------------------------------------------------------------------------------

/* Table:-- [pizza_recipes] */

Insert into
    [pizza_recipes]
select
    [pizza_id],
    cs.Value as toppings
from
    [pizza_recipes]
    cross apply string_split(CAST([toppings] AS VARCHAR(100)), ',') cs;
	
delete From
    [pizza_recipes]
where
    [toppings] like '%,%';
	
Alter table
    [pizza_recipes]
Alter Column
    [toppings] varchar(20);

Alter table
    [pizza_recipes]
Alter Column
    [toppings] INT;