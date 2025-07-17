DROP SCHEMA IF EXISTS sakila;




CREATE TABLE actor (
actor_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (actor_id),
) ;


CREATE TABLE address (
address_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
address VARCHAR(50) NOT NULL,
address2 VARCHAR(50) DEFAULT NULL,
district VARCHAR(20) NOT NULL,
city_id SMALLINT UNSIGNED NOT NULL,
postal_code VARCHAR(10) DEFAULT NULL,
phone VARCHAR(20) NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (address_id),
) ;


CREATE TABLE category (
category_id TINYINT UNSIGNED NOT NULL AUTOINCREMENT,
name VARCHAR(25) NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (category_id)
) ;


CREATE TABLE city (
city_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
city VARCHAR(50) NOT NULL,
country_id SMALLINT UNSIGNED NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (city_id),
) ;


CREATE TABLE country (
country_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
country VARCHAR(50) NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (country_id)
) ;


CREATE TABLE customer (
customer_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
store_id TINYINT UNSIGNED NOT NULL,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
email VARCHAR(50) DEFAULT NULL,
address_id SMALLINT UNSIGNED NOT NULL,
active INTEGER NOT NULL DEFAULT TRUE,
create_date DATETIME NOT NULL,
last_update TIMESTAMP  ,
PRIMARY KEY  (customer_id),
) ;


CREATE TABLE film (
film_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
title VARCHAR(128) NOT NULL,
description TEXT DEFAULT NULL,
release_year YEAR DEFAULT NULL,
language_id TINYINT UNSIGNED NOT NULL,
original_language_id TINYINT UNSIGNED DEFAULT NULL,
rental_duration TINYINT UNSIGNED NOT NULL DEFAULT 3,
rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
length SMALLINT UNSIGNED DEFAULT NULL,
replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
rating TEXT DEFAULT 'G',
special_features TEXT DEFAULT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (film_id),
) ;


CREATE TABLE film_actor (
actor_id SMALLINT UNSIGNED NOT NULL,
film_id SMALLINT UNSIGNED NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (actor_id,film_id),
) ;


CREATE TABLE film_category (
film_id SMALLINT UNSIGNED NOT NULL,
category_id TINYINT UNSIGNED NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY (film_id, category_id),
) ;



CREATE TABLE film_text (
film_id SMALLINT UNSIGNED NOT NULL,
title VARCHAR(255) NOT NULL,
description TEXT,
PRIMARY KEY  (film_id),
) ;



CREATE TRIGGER `ins_film` AFTER INSERT ON `film` FOR EACH ROW BEGIN
INSERT INTO film_text (film_id, title, description)
VALUES (new.film_id, new.title, new.description);
END;;


CREATE TRIGGER `upd_film` AFTER UPDATE ON `film` FOR EACH ROW BEGIN
IF (old.title != new.title) OR (old.description != new.description) OR (old.film_id != new.film_id)
THEN
UPDATE film_text
description=new.description,
film_id=new.film_id
WHERE film_id=old.film_id;
END IF;
END;;


CREATE TRIGGER `del_film` AFTER DELETE ON `film` FOR EACH ROW BEGIN
DELETE FROM film_text WHERE film_id = old.film_id;
END;;



CREATE TABLE inventory (
inventory_id MEDIUMINT UNSIGNED NOT NULL AUTOINCREMENT,
film_id SMALLINT UNSIGNED NOT NULL,
store_id TINYINT UNSIGNED NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (inventory_id),
) ;


CREATE TABLE language (
language_id TINYINT UNSIGNED NOT NULL AUTOINCREMENT,
name CHAR(20) NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY (language_id)
) ;


CREATE TABLE payment (
payment_id SMALLINT UNSIGNED NOT NULL AUTOINCREMENT,
customer_id SMALLINT UNSIGNED NOT NULL,
staff_id TINYINT UNSIGNED NOT NULL,
rental_id INT DEFAULT NULL,
amount DECIMAL(5,2) NOT NULL,
payment_date DATETIME NOT NULL,
last_update TIMESTAMP  ,
PRIMARY KEY  (payment_id),
) ;



CREATE TABLE rental (
rental_id INT NOT NULL AUTOINCREMENT,
rental_date DATETIME NOT NULL,
inventory_id MEDIUMINT UNSIGNED NOT NULL,
customer_id SMALLINT UNSIGNED NOT NULL,
return_date DATETIME DEFAULT NULL,
staff_id TINYINT UNSIGNED NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY (rental_id),
) ;


CREATE TABLE staff (
staff_id TINYINT UNSIGNED NOT NULL AUTOINCREMENT,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
address_id SMALLINT UNSIGNED NOT NULL,
picture BLOB DEFAULT NULL,
email VARCHAR(50) DEFAULT NULL,
store_id TINYINT UNSIGNED NOT NULL,
active INTEGER NOT NULL DEFAULT TRUE,
username VARCHAR(16) NOT NULL,
password VARCHAR(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (staff_id),
) ;


CREATE TABLE store (
store_id TINYINT UNSIGNED NOT NULL AUTOINCREMENT,
manager_staff_id TINYINT UNSIGNED NOT NULL,
address_id SMALLINT UNSIGNED NOT NULL,
last_update TIMESTAMP NOT NULL  ,
PRIMARY KEY  (store_id),
) ;


CREATE VIEW customer_list
AS
SELECT cu.customer_id AS ID, CONCAT(cu.first_name, _utf8mb4' ', cu.last_name) AS name, a.address AS address, a.postal_code AS `zip code`,
a.phone AS phone, city.city AS city, country.country AS country, IF(cu.active, _utf8mb4'active',_utf8mb4'') AS notes, cu.store_id AS SID
FROM customer AS cu JOIN address AS a ON cu.address_id = a.address_id JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;


CREATE VIEW film_list
AS
SELECT film.film_id AS FID, film.title AS title, film.description AS description, category.name AS category, film.rental_rate AS price,
film.length AS length, film.rating AS rating, GROUP_CONCAT(CONCAT(actor.first_name, _utf8mb4' ', actor.last_name) SEPARATOR ', ') AS actors
FROM film LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id LEFT
JOIN film_actor ON film.film_id = film_actor.film_id LEFT JOIN actor ON
film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;


CREATE VIEW nicer_but_slower_film_list
AS
SELECT film.film_id AS FID, film.title AS title, film.description AS description, category.name AS category, film.rental_rate AS price,
film.length AS length, film.rating AS rating, GROUP_CONCAT(CONCAT(CONCAT(UCASE(SUBSTR(actor.first_name,1,1)),
LCASE(SUBSTR(actor.first_name,2,LENGTH(actor.first_name))),_utf8mb4' ',CONCAT(UCASE(SUBSTR(actor.last_name,1,1)),
LCASE(SUBSTR(actor.last_name,2,LENGTH(actor.last_name)))))) SEPARATOR ', ') AS actors
FROM film LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id LEFT
JOIN film_actor ON film.film_id = film_actor.film_id LEFT JOIN actor ON
film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;


CREATE VIEW staff_list
AS
SELECT s.staff_id AS ID, CONCAT(s.first_name, _utf8mb4' ', s.last_name) AS name, a.address AS address, a.postal_code AS `zip code`, a.phone AS phone,
city.city AS city, country.country AS country, s.store_id AS SID
FROM staff AS s JOIN address AS a ON s.address_id = a.address_id JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;


CREATE VIEW sales_by_store
AS
SELECT
CONCAT(c.city, _utf8mb4',', cy.country) AS store
, CONCAT(m.first_name, _utf8mb4' ', m.last_name) AS manager
, SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN store AS s ON i.store_id = s.store_id
INNER JOIN address AS a ON s.address_id = a.address_id
INNER JOIN city AS c ON a.city_id = c.city_id
INNER JOIN country AS cy ON c.country_id = cy.country_id
INNER JOIN staff AS m ON s.manager_staff_id = m.staff_id
GROUP BY s.store_id
ORDER BY cy.country, c.city;


CREATE VIEW sales_by_film_category
AS
SELECT
c.name AS category
, SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;


CREATE DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW actor_info
AS
SELECT
a.actor_id,
a.first_name,
a.last_name,
GROUP_CONCAT(DISTINCT CONCAT(c.name, ': ',
(SELECT GROUP_CONCAT(f.title ORDER BY f.title SEPARATOR ', ')
FROM sakila.film f
INNER JOIN sakila.film_category fc
ON f.film_id = fc.film_id
INNER JOIN sakila.film_actor fa
ON f.film_id = fa.film_id
WHERE fc.category_id = c.category_id
AND fa.actor_id = a.actor_id
)
)
ORDER BY c.name SEPARATOR '; ')
AS film_info
FROM sakila.actor a
LEFT JOIN sakila.film_actor fa
ON a.actor_id = fa.actor_id
LEFT JOIN sakila.film_category fc
ON fa.film_id = fc.film_id
LEFT JOIN sakila.category c
ON fc.category_id = c.category_id
GROUP BY a.actor_id, a.first_name, a.last_name;



CREATE PROCEDURE rewards_report (
IN min_monthly_purchases TINYINT UNSIGNED
, IN min_dollar_amount_purchased DECIMAL(10,2)
, OUT count_rewardees INT
)
LANGUAGE SQL
NOT DETERMINISTIC
READS SQL DATA
SQL SECURITY DEFINER
COMMENT 'Provides a customizable report on best customers'
proc: BEGIN

DECLARE last_month_start DATE;
DECLARE last_month_end DATE;

/* Some sanity checks... */
IF min_monthly_purchases = 0 THEN
SELECT 'Minimum monthly purchases parameter must be > 0';
LEAVE proc;
END IF;
IF min_dollar_amount_purchased = 0.00 THEN
SELECT 'Minimum monthly dollar amount purchased parameter must be > $0.00';
LEAVE proc;
END IF;

/* Determine start and end time periods */

/*
Create a temporary storage area for
Customer IDs.
*/
CREATE TEMPORARY TABLE tmpCustomer (customer_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY);

/*
Find all customers meeting the
monthly purchase requirements
*/
INSERT INTO tmpCustomer (customer_id)
SELECT p.customer_id
FROM payment AS p
WHERE DATE(p.payment_date) BETWEEN last_month_start AND last_month_end
GROUP BY customer_id
HAVING SUM(p.amount) > min_dollar_amount_purchased
AND COUNT(customer_id) > min_monthly_purchases;

/* Populate OUT parameter with count of found customers */
SELECT COUNT(*) FROM tmpCustomer INTO count_rewardees;

/*
Output ALL customer information of matching rewardees.
Customize output as needed.
*/
SELECT c.*
FROM tmpCustomer AS t
INNER JOIN customer AS c ON t.customer_id = c.customer_id;

/* Clean up */
DROP TABLE tmpCustomer;
END //



CREATE FUNCTION get_customer_balance(p_customer_id INT, p_effective_date DATETIME) RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN

#OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
#THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED

DECLARE v_rentfees DECIMAL(5,2); #FEES PAID TO RENT THE VIDEOS INITIALLY
DECLARE v_overfees INTEGER;      #LATE FEES FOR PRIOR RENTALS
DECLARE v_payments DECIMAL(5,2); #SUM OF PAYMENTS MADE PREVIOUSLY

SELECT IFNULL(SUM(film.rental_rate),0) INTO v_rentfees
FROM film, inventory, rental
WHERE film.film_id = inventory.film_id
AND inventory.inventory_id = rental.inventory_id
AND rental.rental_date <= p_effective_date
AND rental.customer_id = p_customer_id;

SELECT IFNULL(SUM(IF((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) > film.rental_duration,
((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) - film.rental_duration),0)),0) INTO v_overfees
FROM rental, inventory, film
WHERE film.film_id = inventory.film_id
AND inventory.inventory_id = rental.inventory_id
AND rental.rental_date <= p_effective_date
AND rental.customer_id = p_customer_id;


SELECT IFNULL(SUM(payment.amount),0) INTO v_payments
FROM payment

WHERE payment.payment_date <= p_effective_date
AND payment.customer_id = p_customer_id;

RETURN v_rentfees + v_overfees - v_payments;
END $$



CREATE PROCEDURE film_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT)
READS SQL DATA
BEGIN
SELECT inventory_id
FROM inventory
WHERE film_id = p_film_id
AND store_id = p_store_id
AND inventory_in_stock(inventory_id);

SELECT COUNT(*)
FROM inventory
WHERE film_id = p_film_id
AND store_id = p_store_id
AND inventory_in_stock(inventory_id)
INTO p_film_count;
END $$



CREATE PROCEDURE film_not_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT)
READS SQL DATA
BEGIN
SELECT inventory_id
FROM inventory
WHERE film_id = p_film_id
AND store_id = p_store_id
AND NOT inventory_in_stock(inventory_id);

SELECT COUNT(*)
FROM inventory
WHERE film_id = p_film_id
AND store_id = p_store_id
AND NOT inventory_in_stock(inventory_id)
INTO p_film_count;
END $$



CREATE FUNCTION inventory_held_by_customer(p_inventory_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE v_customer_id INT;
DECLARE EXIT HANDLER FOR NOT FOUND RETURN NULL;

SELECT customer_id INTO v_customer_id
FROM rental
WHERE return_date IS NULL
AND inventory_id = p_inventory_id;

RETURN v_customer_id;
END $$



CREATE FUNCTION inventory_in_stock(p_inventory_id INT) RETURNS INTEGER
READS SQL DATA
BEGIN
DECLARE v_rentals INT;
DECLARE v_out     INT;

#AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
#FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED

SELECT COUNT(*) INTO v_rentals
FROM rental
WHERE inventory_id = p_inventory_id;

IF v_rentals = 0 THEN
RETURN TRUE;
END IF;

SELECT COUNT(rental_id) INTO v_out
FROM inventory LEFT JOIN rental USING(inventory_id)
WHERE inventory.inventory_id = p_inventory_id
AND rental.return_date IS NULL;

IF v_out > 0 THEN
RETURN FALSE;
ELSE
RETURN TRUE;
END IF;
END $$