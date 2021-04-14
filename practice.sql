-- START Q1
SELECT companyname, contactname, COUNT(orderid)
FROM customers c
JOIN orders o ON o.customerid = c.customerid
GROUP BY companyname, contactname
ORDER BY 3 DESC
LIMIT 5;
-- END Q1
-- START Q2
SELECT c.companyname,
		c.contactname,
		(SELECT COUNT(*)
			FROM orders o
			WHERE o.customerid = c.customerid) num_orders
FROM customers c
ORDER BY 3 DESC
LIMIT 5;
-- END Q2
-- START Q3
SELECT country, COUNT(*) number_of_no_order_customer
FROM customers c
LEFT JOIN orders o ON o.customerid = c.customerid
WHERE orderid IS NULL
GROUP BY country;
-- END Q3
-- START Q4
SELECT c.customerid, COUNT(*) num_orders
FROM customers c
JOIN orders o ON o.customerid = c.customerid
GROUP BY c.customerid
HAVING COUNT(*) > (SELECT AVG(num_orders)
					FROM (SELECT c.customerid, COUNT(*) num_orders
							FROM customers c
							JOIN orders o ON o.customerid = c.customerid
							GROUP BY c.customerid) avg_num_orders)
ORDER BY 2 DESC
LIMIT 5;
-- END Q4
-- START Q5
WITH total_order_value as (SELECT *, unitprice*quantity total
							FROM order_details
							ORDER BY unitprice*quantity DESC),

top5_products as (	SELECT productid, SUM(total) total
					FROM total_order_value
					GROUP BY productid
					ORDER BY 2 DESC
					LIMIT 5),
										
top5_unitsinstock as (SELECT p.unitsinstock
						FROM top5_products t
						JOIN products p USING (productid))
						
SELECT AVG(unitsinstock)
FROM top5_unitsinstock;
-- END Q5
-- START Q6
WITH total_value AS (SELECT e.employeeid, o.orderid, unitprice*quantity total
			FROM employees e
			JOIN orders o USING(employeeid)
			JOIN order_details od USING (orderid)),
			
employee_over100000 AS (SELECT employeeid, SUM(total) total
						FROM total_value
						GROUP BY employeeid
						HAVING SUM(total) > 100000)
						
SELECT o.orderid, customerid, freight, orderdate
FROM employee_over100000 t1 
JOIN orders o USING(employeeid)
ORDER BY orderdate DESC
LIMIT 10;
-- END Q6
-- START Q7
SELECT CONCAT(firstname, ' ', lastname) employee_name, total_heavy_orders
FROM (SELECT employeeid, COUNT(*) total_heavy_orders
		FROM orders
		WHERE freight > 200
		GROUP BY employeeid
		HAVING COUNT(*) > 10) t1
JOIN employees e USING (employeeid);
-- END Q7
-- START Q8
WITH t1 AS (SELECT employeeid, COUNT(*) total_heavy_orders
			FROM orders
			WHERE freight > 200
			GROUP BY employeeid),

t2 AS (SELECT AVG(count)
		FROM(SELECT customerid, COUNT(*)
			FROM orders
			GROUP BY customerid) order_per_cus)
			
SELECT CONCAT(firstname, ' ', lastname) employee_name, total_heavy_orders
FROM t1
JOIN employees e USING (employeeid)
WHERE total_heavy_orders > (SELECT * FROM t2);
-- END Q8
-- START Q9
WITH t1 AS (SELECT CONCAT(firstname, ' ', lastname) employee_name,
					s.companyname shipper_name, c.companyname customer_name
			FROM orders o
			JOIN shippers s ON o.shipvia = s.shipperid
			JOIN employees e USING (employeeid)
			JOIN customers c USING (customerid)
			WHERE (shippeddate > requireddate) and
					s.companyname IN ('Federal Shipping', 'United Package'))

SELECT employee_name, shipper_name, customer_name, 
		COUNT(*) late_order_shipments
FROM t1
GROUP BY 1,2,3
ORDER BY 1;
-- END Q9