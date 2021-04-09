-- START Q1
SELECT user_id, AVG(stars) average_star_rating
FROM reviews
GROUP BY user_id
HAVING COUNT(*) > 2
ORDER BY 2 DESC
LIMIT 5;
-- END Q1
-- START Q2
WITH business_cat AS (SELECT business_id, name, review_count, stars,
								unnest(string_to_array(categories, ', ')) AS category
						FROM businesses)
						
SELECT category, 
		SUM(review_count*stars)/SUM(review_count) weighted_average_stars, 
		COUNT(business_id) num_businesses
FROM business_cat
GROUP BY category
HAVING COUNT(business_id) > 3
ORDER BY 2 DESC;
-- END Q2
-- START Q3
SELECT u.name username,
		b.name businessname,
		COUNT(DISTINCT t.date) tips_left, 
		COUNT(DISTINCT review_id) reviews_left
FROM tips t
JOIN users u USING (user_id)
JOIN businesses b USING (business_id)
JOIN reviews r USING (user_id, business_id)
GROUP BY u.name, b.name
ORDER BY 2,1;
-- END Q3
-- START Q4
SELECT r.user_id, u.fans, u.name username, text
FROM reviews r
JOIN businesses b USING (business_id)
JOIN users u USING (user_id)
WHERE b.name = 'Burlington Coat Factory' AND
		u.fans >= 5;
-- END Q4
-- START Q6
WITH stars_tbl AS (SELECT stars, 
						COALESCE(attributes::JSON ->> 'BusinessAcceptsCreditCards', 'False') accepts_credit_cards,
						COALESCE(attributes::JSON ->> 'RestaurantsTakeOut', 'False') offers_takeout
				FROM businesses)
				
SELECT accepts_credit_cards, offers_takeout, AVG(stars) average_stars
FROM stars_tbl
GROUP BY accepts_credit_cards, offers_takeout
ORDER BY 3 DESC;
-- END Q6
-- START Q7
WITH eng_per_ent AS (SELECT entertainerid, startdate, contractprice,
							RANK() OVER(PARTITION BY entertainerid ORDER BY startdate)
					FROM engagements)
					
(SELECT 'First Five Engagements' engagement_category, AVG(contractprice)
FROM eng_per_ent
WHERE rank <= 5)
UNION
(SELECT '6th and Beyond Engagements' engagement_category, AVG(contractprice)
FROM eng_per_ent
WHERE rank > 5);
-- END Q7
-- START Q8
SELECT AVG(contractprice) avg_contract_price, 
		MAX(startdate) most_recent_start_date, 
		COUNT(*) num_engagements
FROM engagements e
WHERE contractprice>(SELECT AVG(contractprice) FROM engagements);
-- END Q8
-- START Q9
SELECT gender, stylename, COUNT(DISTINCT memberid) num_members
FROM entertainer_members em
JOIN members m USING (memberid)
JOIN entertainer_styles es USING (entertainerid)
JOIN musical_styles ms USING(styleid)
GROUP BY gender, stylename
HAVING COUNT(DISTINCT memberid) > 4
ORDER BY 3 DESC;
-- END Q9
-- START Q10
WITH contract AS (SELECT customerid, engagementnumber, contractprice, startdate,
							RANK() OVER(PARTITION BY customerid, DATE_TRUNC('month', startdate)
										ORDER BY startdate)
					FROM customers c
					JOIN engagements e USING (customerid)
					JOIN agents a USING (agentid)
					WHERE CONCAT(agtfirstname, ' ', agtlastname) <> 'Karen Smith'),
					
with_multiplier AS (SELECT *,  
				CASE WHEN rank >= 3 THEN 0.9
				ELSE 1.0 END AS multiplier
		FROM contract),
		
contract_adjusted AS (SELECT customerid, (contractprice * multiplier) paid
		FROM with_multiplier)
		
SELECT customerid, SUM(paid) total_paid
FROM contract_adjusted
GROUP BY customerid
ORDER BY 2 DESC;
-- END Q10