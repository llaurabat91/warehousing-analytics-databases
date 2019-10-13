
--- Get the top 3 product types that have proven most profitable

SELECT product_line, sum(profits)
FROM product_types_dim
INNER JOIN measures
ON product_types_dim.product_code = measures.product_code
GROUP BY product_line
ORDER BY sum(profits) DESC
LIMIT(3);

--- Get the top 3 products by most items sold

SELECT product_types_dim.product_code, product_name, sum(quantity_ordered),
FROM product_types_dim
INNER JOIN measures
ON product_types_dim.product_code = measures.product_code
GROUP BY product_types_dim.product_code
ORDER BY sum(quantity_ordered) DESC
LIMIT(3);

#--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium

(SELECT product_name, sum(quantity_ordered), customers_dim.country
FROM product_types_dim
INNER JOIN measures
ON product_types_dim.product_code = measures.product_code
INNER JOIN customers_dim
ON measures.customer_number = customers_dim.customer_number
WHERE customers_dim.country = 'USA'
GROUP BY customers_dim.country, product_name
ORDER BY sum(quantity_ordered) DESC
LIMIT(3))
UNION ALL
(SELECT product_name, sum(quantity_ordered), customers_dim.country
FROM product_types_dim
INNER JOIN measures
ON product_types_dim.product_code = measures.product_code
INNER JOIN customers_dim
ON measures.customer_number = customers_dim.customer_number
WHERE customers_dim.country = 'Spain'
GROUP BY customers_dim.country, product_name
ORDER BY sum(quantity_ordered) DESC
LIMIT(3))
UNION ALL
(SELECT product_name, sum(quantity_ordered), customers_dim.country
FROM product_types_dim
INNER JOIN measures
ON product_types_dim.product_code = measures.product_code
INNER JOIN customers_dim
ON measures.customer_number = customers_dim.customer_number
WHERE customers_dim.country = 'Belgium'
GROUP BY customers_dim.country, product_name
ORDER BY sum(quantity_ordered) DESC
LIMIT(3))
;


--- Get the most profitable day of the week

SELECT sum(profits) AS total_profits, date_dim.day_of_week
FROM date_dim
INNER JOIN measures
ON date_dim.unique_date = measures.order_date
GROUP BY day_of_week
ORDER BY sum(profits) DESC
LIMIT(1);

--- Get the top 3 city-quarters with the highest average profit margin in their sales

SELECT avg(profit_margin), offices_dim.city, date_dim.quarter
FROM date_dim
INNER JOIN measures
ON date_dim.unique_date = measures.order_date
INNER JOIN offices_dim
ON measures.office_code = offices_dim.office_code
GROUP BY offices_dim.city, date_dim.quarter
ORDER BY avg(profit_margin) DESC
LIMIT(3);

-- List the employees who have sold more goods (in $ amount) than the average employee.

SELECT employees_dim.employee_number as most_performing_employees, sum(revenues)
FROM employees_dim
INNER JOIN measures
ON employees_dim.employee_number = measures.sales_rep_employee_number
GROUP BY employee_number
HAVING sum(revenues) >
  (SELECT sum(revenues)/COUNT(DISTINCT(employee_number))
      FROM employees_dim
      INNER JOIN measures
      ON employees_dim.employee_number = measures.sales_rep_employee_number
);


-- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts
--(BONUS: Add the employee number)

SELECT order_number, sales_rep_employee_number, sum(revenues)
FROM measures
GROUP BY order_number, sales_rep_employee_number
ORDER BY sum(revenues) DESC
LIMIT(SELECT (COUNT(*)/10) AS top10percent FROM orders_dim)
;
