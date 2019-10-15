--- Get the top 3 product types that have proven most profitable
SELECT product_code, SUM(total_profit) as sum_total_profit  FROM orders_measure
GROUP BY product_code
ORDER BY sum_total_profit DESC
LIMIT(3);

--- Get the top 3 products by most items sold
SELECT product_code, SUM(quantity_ordered) as sum_quantity_ordered
FROM orders_measure
GROUP BY product_code
ORDER BY sum_quantity_ordered DESC
LIMIT(3);

--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium

/* Partition the data by country and assign rank using quantity_ordered \-
KL noteselect the first 3 rows from each group */

WITH items_per_country AS (
     SELECT product_code, SUM(quantity_ordered) as sum_quantity_ordered, country
     FROM orders_measure
     	  LEFT JOIN customers_d
	  USING(customer_number)
	  WHERE country IN ('USA', 'Spain', 'Belgium')
     GROUP BY product_code, country
     ORDER BY sum_quantity_ordered DESC),

     groups AS (
     SELECT product_code, sum_quantity_ordered, country,
     ROW_NUMBER() OVER(
     		  PARTITION BY country
		  ORDER BY sum_quantity_ordered DESC
		  ) AS row_number
	FROM items_per_country)

SELECT * FROM groups
WHERE groups.row_number < 4;


--- Get the most profitable day of the week
SELECT day_of_week, SUM(total_profit) as sum_total_profit
FROM orders_measure
    LEFT JOIN date_d
    USING(order_date)
GROUP BY day_of_week
ORDER BY sum_total_profit DESC
LIMIT(1);

--- Get the top 3 city-quarters with the highest average profit margin in their sales

SELECT city, quarter, year, AVG(profit_margin) as avg_profit_margin
FROM orders_measure
     LEFT JOIN date_d
     USING(order_date)
     LEFT JOIN offices_d
     USING(office_code)
GROUP BY city, quarter, year
ORDER BY avg_profit_margin DESC
LIMIT(3);


-- List the employees who have sold more goods (in $ amount) than the average employee.
WITH profit_by_employee AS (
     SELECT employee_number, first_name, last_name, SUM(total_profit) as sum_total_profit
     FROM orders_measure
     	  LEFT JOIN employees_d
	  USING(employee_number)
     GROUP BY employee_number, first_name, last_name
     ORDER BY sum_total_profit DESC)

SELECT employee_number, first_name, last_name, sum_total_profit
FROM profit_by_employee
WHERE sum_total_profit >
       (SELECT AVG(sum_total_profit)
       FROM profit_by_employee)
ORDER BY sum_total_profit DESC;

-- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts (BONUS: Add the employee number)


SELECT order_number, SUM(total_revenue) as sum_total_revenue, employee_number
FROM orders_measure
GROUP BY order_number, employee_number
ORDER BY sum_total_revenue DESC
LIMIT (SELECT (count(*) / 90) as selnum FROM orders_measure);
