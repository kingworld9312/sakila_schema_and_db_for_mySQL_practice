-- Sakila Sample Database Schema (SQLite Compatible)

--
-- Table structure for table `actor`
--

CREATE TABLE actor (
  actor_id INTEGER PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_actor_last_name ON actor (last_name);

--
-- Table structure for table `address`
--

CREATE TABLE address (
  address_id INTEGER PRIMARY KEY,
  address TEXT NOT NULL,
  address2 TEXT,
  district TEXT NOT NULL,
  city_id INTEGER NOT NULL,
  postal_code TEXT,
  phone TEXT NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_city_id ON address (city_id);

--
-- Table structure for table `category`
--

CREATE TABLE category (
  category_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- Table structure for table `city`
--

CREATE TABLE city (
  city_id INTEGER PRIMARY KEY,
  city TEXT NOT NULL,
  country_id INTEGER NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_country_id ON city (country_id);

--
-- Table structure for table `country`
--

CREATE TABLE country (
  country_id INTEGER PRIMARY KEY,
  country TEXT NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- Table structure for table `customer`
--

CREATE TABLE customer (
  customer_id INTEGER PRIMARY KEY,
  store_id INTEGER NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  address_id INTEGER NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  create_date TEXT NOT NULL,
  last_update TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_store_id ON customer (store_id);
CREATE INDEX idx_fk_address_id ON customer (address_id);
CREATE INDEX idx_last_name ON customer (last_name);

--
-- Table structure for table `film`
--

CREATE TABLE film (
  film_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  release_year INTEGER,
  language_id INTEGER NOT NULL,
  original_language_id INTEGER,
  rental_duration INTEGER NOT NULL DEFAULT 3,
  rental_rate NUMERIC NOT NULL DEFAULT 4.99,
  length INTEGER,
  replacement_cost NUMERIC NOT NULL DEFAULT 19.99,
  rating TEXT DEFAULT 'G',
  special_features TEXT,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (original_language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_title ON film (title);
CREATE INDEX idx_fk_language_id ON film (language_id);
CREATE INDEX idx_fk_original_language_id ON film (original_language_id);

--
-- Table structure for table `film_actor`
--

CREATE TABLE film_actor (
  actor_id INTEGER NOT NULL,
  film_id INTEGER NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id, film_id),
  FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_film_id ON film_actor (film_id);

--
-- Table structure for table `film_category`
--

CREATE TABLE film_category (
  film_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id, category_id),
  FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Table structure for table `film_text`
--

CREATE TABLE film_text (
  film_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT
);
-- Note: SQLite does not have a native FULLTEXT index.
-- For full-text search, you would need to use a separate FTS module.

--
-- Triggers for loading film_text from film
--

CREATE TRIGGER ins_film AFTER INSERT ON film
BEGIN
    INSERT INTO film_text (film_id, title, description)
    VALUES (new.film_id, new.title, new.description);
END;

CREATE TRIGGER upd_film AFTER UPDATE ON film
BEGIN
    UPDATE film_text
    SET title=new.title,
        description=new.description
    WHERE film_id=old.film_id;
END;

CREATE TRIGGER del_film AFTER DELETE ON film
BEGIN
    DELETE FROM film_text WHERE film_id = old.film_id;
END;

--
-- Table structure for table `inventory`
--

CREATE TABLE inventory (
  inventory_id INTEGER PRIMARY KEY,
  film_id INTEGER NOT NULL,
  store_id INTEGER NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_film_id ON inventory (film_id);
CREATE INDEX idx_store_id_film_id ON inventory (store_id, film_id);

--
-- Table structure for table `language`
--

CREATE TABLE language (
  language_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- Table structure for table `payment`
--

CREATE TABLE payment (
  payment_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  staff_id INTEGER NOT NULL,
  rental_id INTEGER,
  amount NUMERIC NOT NULL,
  payment_date TEXT NOT NULL,
  last_update TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_staff_id ON payment (staff_id);
CREATE INDEX idx_fk_customer_id ON payment (customer_id);

--
-- Table structure for table `rental`
--

CREATE TABLE rental (
  rental_id INTEGER PRIMARY KEY,
  rental_date TEXT NOT NULL,
  inventory_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  return_date TEXT,
  staff_id INTEGER NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX idx_unique_rental ON rental (rental_date, inventory_id, customer_id);
CREATE INDEX idx_fk_inventory_id ON rental (inventory_id);
CREATE INDEX idx_fk_customer_id ON rental (customer_id);
CREATE INDEX idx_fk_staff_id ON rental (staff_id);

--
-- Table structure for table `staff`
--

CREATE TABLE staff (
  staff_id INTEGER PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  address_id INTEGER NOT NULL,
  picture BLOB,
  email TEXT,
  store_id INTEGER NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  username TEXT NOT NULL,
  password TEXT,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_store_id ON staff (store_id);
CREATE INDEX idx_fk_address_id ON staff (address_id);

--
-- Table structure for table `store`
--

CREATE TABLE store (
  store_id INTEGER PRIMARY KEY,
  manager_staff_id INTEGER NOT NULL,
  address_id INTEGER NOT NULL,
  last_update TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX idx_unique_manager ON store (manager_staff_id);
CREATE INDEX idx_fk_address_id ON store (address_id);

---

## Views

--
-- View structure for view `customer_list`
--

CREATE VIEW customer_list AS
SELECT
  cu.customer_id AS ID,
  cu.first_name || ' ' || cu.last_name AS name,
  a.address AS address,
  a.postal_code AS "zip code",
  a.phone AS phone,
  city.city AS city,
  country.country AS country,
  CASE WHEN cu.active THEN 'active' ELSE '' END AS notes,
  cu.store_id AS SID
FROM customer AS cu
JOIN address AS a ON cu.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

--
-- View structure for view `film_list`
--

CREATE VIEW film_list AS
SELECT
  film.film_id AS FID,
  film.title AS title,
  film.description AS description,
  category.name AS category,
  film.rental_rate AS price,
  film.length AS length,
  film.rating AS rating,
  GROUP_CONCAT(actor.first_name || ' ' || actor.last_name, ', ') AS actors
FROM film
LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id
LEFT JOIN film_actor ON film.film_id = film_actor.film_id
LEFT JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;

--
-- View structure for view `nicer_but_slower_film_list`
--

CREATE VIEW nicer_but_slower_film_list AS
SELECT
  film.film_id AS FID,
  film.title AS title,
  film.description AS description,
  category.name AS category,
  film.rental_rate AS price,
  film.length AS length,
  film.rating AS rating,
  GROUP_CONCAT(
    UPPER(SUBSTR(actor.first_name, 1, 1)) || LOWER(SUBSTR(actor.first_name, 2)) || ' ' ||
    UPPER(SUBSTR(actor.last_name, 1, 1)) || LOWER(SUBSTR(actor.last_name, 2)),
    ', '
  ) AS actors
FROM film
LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id
LEFT JOIN film_actor ON film.film_id = film_actor.film_id
LEFT JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;

--
-- View structure for view `staff_list`
--

CREATE VIEW staff_list AS
SELECT
  s.staff_id AS ID,
  s.first_name || ' ' || s.last_name AS name,
  a.address AS address,
  a.postal_code AS "zip code",
  a.phone AS phone,
  city.city AS city,
  country.country AS country,
  s.store_id AS SID
FROM staff AS s
JOIN address AS a ON s.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

--
-- View structure for view `sales_by_store`
--

CREATE VIEW sales_by_store AS
SELECT
  c.city || ',' || cy.country AS store,
  m.first_name || ' ' || m.last_name AS manager,
  SUM(p.amount) AS total_sales
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

--
-- View structure for view `sales_by_film_category`
--

CREATE VIEW sales_by_film_category AS
SELECT
  c.name AS category,
  SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;

--
-- View structure for view `actor_info`
-- Note: This is a complex view with a subquery that is difficult to
-- translate directly to SQLite. The following is a simplified version.
--

CREATE VIEW actor_info AS
SELECT
  a.actor_id,
  a.first_name,
  a.last_name,
  GROUP_CONCAT(c.name || ': ' ||
    (SELECT GROUP_CONCAT(f.title, ', ')
     FROM film f
     INNER JOIN film_category fc ON f.film_id = fc.film_id
     INNER JOIN film_actor fa ON f.film_id = fa.film_id
     WHERE fc.category_id = c.category_id
     AND fa.actor_id = a.actor_id
     ORDER BY f.title
    ), '; '
  ) AS film_info
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
