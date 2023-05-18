/* E. Bonus Questions */
/*
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would 
happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
*/

INSERT INTO [pizza_names]
([pizza_id],[pizza_name])
VALUES(3,'Supreme');

INSERT INTO [pizza_recipes]
VALUES
(3,1),
(3,5),
(3,4),
(3,3),
(3,11),
(3,8),
(3,9),
(3,6)
;