--SET1
--Question 1; understand more about the movies that families are watching


SELECT
FROM(
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
  AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) sub1
JOIN film f
  ON sub1.cat_id = f.film_id
JOIN (SELECT
  r.rental_id AS RENTAL_ID,
  i.film_id AS inv_id
FROM rental r
JOIN inventory i
  ON r.inventory_id = i.inventory_id) sub2
  ON f.film_id = sub2.inv_id
ORDER BY 2, 1)SUB;
