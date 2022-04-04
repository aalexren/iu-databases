DROP TABLE IF EXISTS Ex1;

CREATE TABLE IF NOT EXISTS Ex1(
	order_id INTEGER NOT NULL,
	date_ DATE NOT NULL,
	customer_id INTEGER NOT NULL,
	customer_name VARCHAR,
	city VARCHAR,
	item_id INTEGER NOT NULL,
	item_name VARCHAR,
	quant INTEGER,
	price REAL,
	
	PRIMARY KEY(order_id, item_id, customer_id)
);

INSERT INTO Ex1 VALUES
(2301, '2011-02-23', 101, 'Martin', 'Prague', 3786, 'Net', 3, 35.),
(2301, '2011-02-23', 101, 'Martin', 'Prague', 4011, 'Racket', 6, 65.),
(2301, '2011-02-23', 101, 'Martin', 'Prague', 9132, 'Pack-3', 8, 4.75),
(2302, '2011-02-25', 107, 'Herman', 'Madrid', 5794, 'Pack-6', 4, 5.),
(2303, '2011-02-27', 110, 'Pedro', 'Moscow', 4011, 'Racket', 2, 65.),
(2303, '2011-02-27', 110, 'Pedro', 'Moscow', 3141, 'Cover', 2, 10.);

DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Items CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Order_Item CASCADE;

CREATE TABLE IF NOT EXISTS Items(
	item_id INTEGER PRIMARY KEY,
	item_name VARCHAR,
	price REAL
);

CREATE TABLE IF NOT EXISTS Customers(
	customer_id INTEGER PRIMARY KEY,
	customer_name VARCHAR,
	city VARCHAR
);

CREATE TABLE IF NOT EXISTS Orders(
	order_id INTEGER PRIMARY KEY,
	date_ DATE,
	customer_id INTEGER,
	
	FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE IF NOT EXISTS Order_Item(
	order_id INTEGER NOT NULL,
	item_id INTEGER NOT NULL,
	quant INTEGER,
	
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES Orders(order_id),
	FOREIGN KEY (item_id) REFERENCES Items(item_id)
);

INSERT INTO Items (item_id, item_name, price)
(SELECT DISTINCT item_id, item_name, price FROM Ex1);

INSERT INTO Customers (customer_id, customer_name, city)
(SELECT DISTINCT customer_id, customer_name, city FROM Ex1);

INSERT INTO Orders (order_id, date_, customer_id)
(SELECT DISTINCT order_id, date_, customer_id FROM Ex1);

INSERT INTO Order_Item (order_id, item_id, quant)
(SELECT DISTINCT order_id, item_id, quant FROM Ex1);

-- 1) Calculate the total number of items per order and 
-- the total amount to pay for the order.
SELECT OI.order_id, COUNT(OI.item_id), SUM(Items.price * OI.quant)
FROM Order_Item AS OI, Items 
WHERE OI.item_id = Items.item_id
GROUP BY OI.order_id;

-- 2) Obtain the customer whose purchase in terms of money has been greater
-- than the others
SELECT DISTINCT C_.customer_id, SUM(OI.quant * IT.price) AS COST_
FROM Customers AS C_, Order_Item AS OI, Orders AS OD, Items AS IT
WHERE OI.order_id = OD.order_id 
	  AND OD.customer_id = C_.customer_id
	  AND OI.item_id = IT.item_id
GROUP BY C_.customer_id
ORDER BY COST_ DESC LIMIT 1;

-- ONE MORE POSSIBILLITY TO DO THAT INSTEAD OF 'ORDER BY'

-- HAVING SUM(OI.quant * IT.price)
-- >= ALL 
-- (
-- 	SELECT SUM(quant * price) FROM Order_Item, Items, Orders, Customers
-- 	WHERE Order_Item.item_id = Items.item_id
-- 		AND Orders.order_id = Order_Item.order_id
-- 		AND Orders.customer_id = Customers.customer_id
-- 	GROUP BY Customers.customer_id
-- );