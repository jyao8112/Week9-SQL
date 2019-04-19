USE sakila;
-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;
-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name,"  " ,last_name) as "Actor Name"  FROM actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name,last_name FROM actor
WHERE first_name = "Joe";
-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";
-- 2c Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name,first_name;
-- 2d Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id,country FROM country
WHERE Country IN ('Afghanistan', 'Bangladesh', 'China');
-- 3a create a column in the table `actor` named `description` and use the data type `BLOB`
ALTER TABLE actor
ADD COLUMN description BLOB;
-- 3b Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;
-- 4a List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;
-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name
HAVING COUNT(last_name)>=2;
-- 4c The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name='HARPO'
WHERE first_name='GROUCHO' AND last_name="WILLIAMS";
-- 4d 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, 
-- as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER!
-- (Hint: update the record using a unique identifier.
 UPDATE actor
  SET first_name =
  CASE
   WHEN first_name = 'HARPO'
    THEN 'GROUCHO'
   ELSE 'MUCHO GROUCHO'
  END
  WHERE actor_id = 172;
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
--  6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT first_name,last_name,address
FROM staff
LEFT JOIN address 
ON staff.address_id=address.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT SUM(payment.amount),staff.staff_id
FROM staff
LEFT JOIN payment ON payment.staff_id=staff.staff_id 
WHERE payment.payment_date LIKE "2005-08%"
GROUP BY staff.staff_id;
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'Actors'
FROM film_actor AS fa
INNER JOIN film as f
ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY Actors desc;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory.inventory_id),title
FROM inventory
INNER JOIN film on inventory.film_id=film.film_id
WHERE film.title='Hunchback Impossible'
GROUP BY title;
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT SUM(payment.amount),customer.last_name
FROM payment
INNER JOIN customer ON payment.customer_id=customer.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT film.title,language.name
FROM film
INNER JOIN language ON film.language_id=language.language_id
WHERE language.name="English" AND ( film.title LIKE "Q%") OR ( film.title LIKE "K%");
--  7b. Use subqueries to display all actors who appear in the film `Alone Trip`
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN
( SELECT actor_id
  FROM film_actor 
  WHERE film_id IN
  ( SELECT film_id 
    FROM film
    WHERE title = 'Alone Trip'
   )
);
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.  
 SELECT first_name, last_name, email
 FROM customer
 WHERE address_id IN
 ( SELECT address_id 
   FROM address
   WHERE city_id IN 
   (
    SELECT city_id 
    FROM city
    WHERE country_id IN
     (
      SELECT country_id
      FROM country
      WHERE country = 'Canada'
        )
	   )
	  );
-- 7d. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
(SELECT film_id
 FROM film_category
 WHERE category_id IN
 (SELECT category_id
 FROM category
 WHERE name="Family"
   )
  );
--  7e. Display the most frequently rented movies in descending order.   
SELECT title, COUNT(title) as 'Rentals'
FROM film
INNER JOIN inventory
ON (film.film_id = inventory.film_id)
INNER JOIN rental
ON (inventory.inventory_id = rental.inventory_id)
GROUP by title
ORDER BY rentals DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT  store.store_id,sum(amount) AS 'Gross Revenue'
From store
INNER JOIN inventory
ON store.store_id=inventory.store_id
INNER JOIN rental
ON inventory.inventory_id=rental.inventory_id
INNER JOIN payment
ON payment.rental_id=rental.rental_id
GROUP BY store.store_id;
-- 7g.Write a query to display for each store its store ID, city, and country.
SELECT s.store_id,ct.city,co.country
FROM store s
INNER JOIN address a
ON s.address_id=a.address_id
INNER JOIN city ct
ON ct.city_id=a.city_id
INNER JOIN country co
ON co.country_id=ct.country_id;
-- 7h.List the top five genres in gross revenue in descending order.
SELECT ca.name AS 'Genres', SUM(amount) AS 'Gross Revenue'
FROM category ca
INNER JOIN film_category fc
ON ca.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id=i.film_id  
INNER JOIN rental r
ON i.inventory_id=r.inventory_id
INNER JOIN payment p
ON r.rental_id=p.rental_id
GROUP BY ca.name
ORDER BY SUM(amount) DESC
LIMIT 5;
-- 8a Use the solution from the problem above to create a view
CREATE VIEW top_five_genres AS
SELECT ca.name AS 'Genres', SUM(amount) AS 'Gross Revenue'
FROM category ca
INNER JOIN film_category fc
ON ca.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id=i.film_id  
INNER JOIN rental r
ON i.inventory_id=r.inventory_id
INNER JOIN payment p
ON r.rental_id=p.rental_id
GROUP BY ca.name
ORDER BY SUM(amount) DESC
LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres