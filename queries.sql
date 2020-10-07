

--SET1
--Question 1; understand more about the movies that families are watching



SELECT DISTINCT
  f.title AS film_title,
  sub1.category_name AS CAT,
  COUNT(*) OVER (PARTITION BY f.title) AS rental_count
FROM (SELECT
  c.name AS category_name,
  fc.film_id AS cat_id
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
  AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) sub1 --Selection family movie categories
JOIN film f
  ON sub1.cat_id = f.film_id
JOIN (SELECT
  r.rental_id AS RENTAL_ID,
  i.film_id AS inv_id
FROM rental r
JOIN inventory i
  ON r.inventory_id = i.inventory_id) sub2
  ON f.film_id = sub2.inv_id
ORDER BY 2, 1;


--Question 2--
SELECT
  f.title AS title,
  sub1.category_name AS name,
  f.rental_duration,
  NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
FROM film f
JOIN (SELECT
  c.name AS category_name,
  fc.film_id AS cat_id
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
  AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) sub1
  ON sub1.cat_id = f.film_id
ORDER BY 4;

--Question 3--
WITH SUBQ
AS (SELECT
  f.title,
  sub1.category_name AS name,
  f.rental_duration,
  NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
FROM film f
JOIN (SELECT
  c.name AS category_name,
  fc.film_id AS cat_id
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
  AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) sub1
  ON sub1.cat_id = f.film_id
ORDER BY 4)

SELECT
  name,
  standard_quartile,
  COUNT(*)
FROM SUBQ
GROUP BY 1,2
ORDER BY 1,2;

--SET 2

--Question 1
SELECT
  DATE_PART('month',r.rental_date) AS Rental_month,
  DATE_PART('year',r.rental_date) AS Rental_year,
  s.store_id AS store_id, count(*) AS Count_rentals
FROM rental r
JOIN staff s
  ON r.staff_id = s.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;


--Question 2
--WINDOW FUNCTION
WITH TOP10 AS(SELECT customer_id, SUM(amount)
              FROM payment
              GROUP BY 1
              ORDER BY 2 DESC
              LIMIT 10)

SELECT DISTINCT DATE_TRUNC('month',p.payment_date) AS pay_mon,
  c.first_name||' '||c.last_name AS fullname,
  COUNT(p.amount) OVER (PARTITION BY DATE_TRUNC('month',p.payment_date),c.first_name||' '||c.last_name  ORDER BY DATE_TRUNC('month',p.payment_date) )AS pay_countpermon,
  SUM(p.amount) OVER  (PARTITION BY DATE_TRUNC('month',p.payment_date),c.first_name||' '||c.last_name  ORDER BY DATE_TRUNC('month',p.payment_date) )AS pay_amount
FROM payment p
JOIN customer c
  ON p.customer_id = c.customer_id
WHERE p.customer_id in (SELECT customer_id from TOP10)
ORDER BY 2;

--Question 3

WITH TOP10 AS(SELECT customer_id, SUM(amount)
              FROM payment
              GROUP BY 1
              ORDER BY 2 DESC
              LIMIT 10)

SELECT pay_mon,fullname,pay_amoun,
pay_amoun -LAG(pay_amoun) OVER (ORDER BY fullname,pay_mon) AS payment_difference
FROM (SELECT DISTINCT DATE_TRUNC('month',p.payment_date) AS pay_mon,
      c.first_name||' '||c.last_name AS fullname,
      SUM(p.amount) OVER  (PARTITION BY DATE_TRUNC('month',p.payment_date),c.first_name||' '||c.last_name  ORDER BY DATE_TRUNC('month',p.payment_date) )AS pay_amoun
      FROM payment p
      JOIN customer c
        ON p.customer_id = c.customer_id
      WHERE p.customer_id in (SELECT customer_id from TOP10))sub
ORDER BY 2,1
