-- START Q1
WITH late_order AS (SELECT customerid, orderid, productid, unitprice*quantity total,
						RANK() OVER(PARTITION BY customerid ORDER BY orderdate)
					FROM orders o 
					JOIN order_details od USING (orderid)
					WHERE shippeddate > requireddate)

SELECT p.productname, SUM(total) total_value_of_late_orders, 
		SUM(total) * 0.2 total_refunded_value
FROM late_order t1
JOIN products p USING (productid)
WHERE rank > 1
GROUP BY p.productname
ORDER BY 2 DESC;
-- END Q1
-- START Q2
WITH count_tbl AS (SELECT e.reportsto, 
							COUNT(DISTINCT t.regionid) regions,
							COUNT(DISTINCT e.employeeid) employees,
							COUNT(DISTINCT et.*) territories,
							COUNT(DISTINCT o.*) orders,
							COUNT(DISTINCT c.*) customers
					FROM employees e
					JOIN orders o USING (employeeid)
					JOIN customers c USING (customerid)
					JOIN employeeterritories et USING (employeeid)
					JOIN territories t USING (territoryid)
					WHERE reportsto IS NOT NULL
					GROUP BY e.reportsto)

SELECT CONCAT(e.firstname, ' ', e.lastname) manager_name, 
		regions, employees, territories, orders, customers
FROM count_tbl t1
JOIN employees e ON t1.reportsto = e.employeeid;
-- END Q2
-- START Q3
WITH germany AS (SELECT customerid
				FROM customers
				WHERE country = 'Germany'),

order_total AS (SELECT o.orderid, orderdate,
						(quantity*unitprice*(1-discount)) total
				FROM germany
				JOIN orders o USING (customerid)
				JOIN order_details od USING (orderid)),
				
agg_order_total AS (SELECT orderid, orderdate, SUM(total) total
					FROM order_total
					GROUP BY orderid, orderdate
					ORDER BY 2)
					
SELECT orderid, orderdate, 
		SUM(total) order_total,
		SUM(total) OVER (ORDER BY orderdate),
		AVG(total) OVER (ORDER BY orderdate)
FROM agg_order_total
GROUP BY orderid, orderdate, total;
-- END Q3
-- START Q4
WITH markdown_tbl AS (SELECT od.productid, p.productname,
					  		((p.unitprice - od.unitprice) * quantity) markdown
					 FROM order_details od
					 JOIN products p USING (productid)
					 JOIN categories c USING (categoryid)
					 WHERE categoryname NOT IN ('Meat/Poultry'))
					
SELECT productid, productname, SUM(markdown)
FROM markdown_tbl
GROUP BY productid, productname
HAVING SUM(markdown) > 3000
ORDER BY 3 DESC;
-- END Q4
-- START Q5
WITH order_per_emp AS (SELECT e.employeeid, 
					   			CONCAT(firstname, ' ', lastname) fullname,
					   			COUNT(*) orders,
					   			SUM(COUNT(*)) OVER () all_time_total,
					   			AVG(COUNT(*)) OVER () all_time_avg
								--(COUNT(*)/(SELECT COUNT(*) FROM orders)) pct_of_order
						FROM employees e 
						JOIN orders o USING (employeeid)
						GROUP BY e.employeeid
						ORDER BY 2 DESC)
												
SELECT employeeid, fullname, orders,
		ROUND(orders/all_time_total, 2) pct_of_order,
		ROUND(orders - all_time_avg, 2) order_differential,
		CASE WHEN orders > 100 THEN 'Principal'
		WHEN orders > 50 THEN 'Senior Associate'
		ELSE 'Associate' END AS title
FROM order_per_emp
ORDER BY 3 DESC;
-- END Q5
-- START Q6
WITH display AS (SELECT 'Number of Orders' category, COUNT(*) FROM orders
				UNION
				SELECT 'Number of Customers' category, COUNT(*) FROM customers
				UNION
				SELECT 'Number of Territories' category, COUNT(*) FROM territories
				UNION
				SELECT 'Number of Employees' category, COUNT(*) FROM employees)
				
SELECT *
FROM display
ORDER BY 2 DESC;
-- END Q6
-- START Q7
WITH t1 AS (SELECT orderdate, 
					(quantity*unitprice) order_total, 
					orderid
			FROM orders o
			JOIN order_details od USING (orderid))
			
SELECT orderdate, orderid, SUM(order_total) order_total,
		AVG(SUM(order_total)) OVER (ORDER BY orderdate, orderid
									ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) last_3_avg_order_total
FROM t1
GROUP BY orderid, orderdate
-- END Q7