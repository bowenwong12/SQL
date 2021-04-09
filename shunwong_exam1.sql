-- START Q1
SELECT categoryname, supplierid, unitsinstock as remainingunits
FROM products p 
JOIN categories c ON p.categoryid = c.categoryid
WHERE unitsinstock = 0 AND discontinued = 0;
-- END Q1
-- START Q2
SELECT CONCAT(firstname, ' ', lastname) employeename, orderid, orderdate, c.companyname
FROM orders o
JOIN employees e ON e.employeeid = o.employeeid
JOIN customers c ON c.customerid = o.customerid
ORDER BY orderdate DESC
LIMIT 5;
-- END Q2
-- START Q3
SELECT c.customerid, companyname, contactname, contacttitle
FROM customers c
JOIN orders o ON o.customerid = c.customerid 
GROUP BY c.customerid, companyname, contactname, contacttitle
HAVING COUNT(*) < 5
ORDER BY 1;
-- END Q3
-- START Q4
SELECT country, COUNT(*) nonactive_customers
FROM customers c
LEFT JOIN orders o ON c.customerid = o.customerid
WHERE o.orderid IS NULL
GROUP BY country;
-- END Q4
-- START Q5
SELECT categoryname, COUNT(*) number_of_products
FROM products p
JOIN categories c ON c.categoryid = p.categoryid
WHERE (unitsinstock > 0)
	AND (unitprice > 20)
GROUP BY categoryname;
-- END Q5
-- START Q6
SELECT COUNT(DISTINCT c.customerid) num_customers
FROM orders o
JOIN customers c ON c.customerid = o.customerid
JOIN order_details od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
JOIN categories cat ON cat.categoryid = p.categoryid
WHERE cat.categoryname = 'Seafood';
-- END Q6
-- START Q7
SELECT managername, COUNT(*) num_of_employees_managed
FROM employees e
JOIN (SELECT CONCAT(firstname, ' ', lastname) managername, managerid
		FROM (SELECT DISTINCT(reportsto) managerid
				FROM employees
				WHERE reportsto IS NOT NULL) manager_id
		JOIN employees e ON e.employeeid = manager_id.managerid) managers
ON managers.managerid = e.reportsto
GROUP BY managername;
-- END Q7
-- START Q8
SELECT employeeid, employeename, SUM(total_ordered_value) total_ordered_value
FROM (SELECT e.employeeid, CONCAT(firstname, ' ', lastname) employeename, (od.unitprice*od.quantity) total_ordered_value
		FROM employees e
		JOIN orders o ON o.employeeid = e.employeeid
		JOIN order_details od ON o.orderid = od.orderid
	    WHERE title NOT IN ('Vice President, Sales')) order_value
GROUP BY employeeid, employeename
ORDER BY 3 DESC
LIMIT 3;
-- END Q8
-- START Q9
SELECT total_orders_table.companyname, total_orders, on_time_orders
FROM (SELECT companyname, COUNT(*) total_orders
		FROM customers c
		JOIN orders o ON o.customerid = c.customerid
		GROUP BY companyname
	 	ORDER BY 2 DESC) total_orders_table
JOIN (SELECT companyname, COUNT(*) on_time_orders
		FROM customers c
		JOIN orders o ON o.customerid = c.customerid
		WHERE shippeddate < requireddate
		GROUP BY companyname) on_time_orders_table
ON total_orders_table.companyname = on_time_orders_table.companyname
ORDER BY 2 DESC, 3 DESC
LIMIT 5;
-- END Q9
-- START Q10
SELECT s.companyname, COUNT(*) shipped_orders
FROM shippers s
JOIN orders o ON o.shipvia = s.shipperid 
GROUP BY s.companyname
ORDER BY 2
LIMIT 1;
-- END Q10
-- START Q11
SELECT CONCAT(firstname, ' ', lastname) employeename, COUNT(*) num_orders,
		CASE WHEN COUNT(*) >= 75 THEN 'High Performer'
		WHEN COUNT(*) >= 50 THEN 'Mid Tier'
		ELSE 'Low Performer' END AS performance_rating
FROM orders o
JOIN employees e ON e.employeeid = o.employeeid 
GROUP BY e.employeeid, firstname, lastname;
-- END Q11