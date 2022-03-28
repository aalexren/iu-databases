CREATE TABLE Manufacturer
(
manufacturer_id int PRIMARY KEY,
phone_number INT
);

CREATE TABLE Item
(
item_id int,
description VARchar(20),

PRIMARY KEY(item_id)
);

CREATE TABLE Produce
(
item_id int,
manufacturer_id INT,
quantity int,

PRIMARY KEY(item_id, manufacturer_id),
FOREIGN KEY(item_id) REFERENCES Item(item_id),
FOREIGN KEY(manufacturer_id) REFERENCES Manufacturer(manufacturer_id)
);

CREATE TABLE Customer_Addresses
(
address_id int,
client_id int,
house int,
street VARchar(20),
district VARchar(20),
city VARchar(20),

PRIMARY KEY(address_id, client_id), FOREIGN KEY (client_id) REFERENCES Customer(client_id)
);

CREATE TABLE Order_Addresses
(
order_id int,
house int,
street VARchar(20),
district VARchar(20),
city VARchar(20),

PRIMARY KEY(order_id), FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Orders
(
order_id int,
date_d TEXT,
shipping_addresses_id int,
client_id int,

PRIMARY KEY(order_id),
FOREIGN KEY(client_id) REFERENCES Customer(client_id),
FOREIGN KEY(shipping_addresses_id) REFERENCES Order_Addresses(order_id)
);

CREATE TABLE Includes
(
order_id int,
item_id int,
quantity int NOT NULL,

PRIMARY KEY(order_id, item_id),
FOREIGN KEY(order_id) REFERENCES Orders(order_id),
FOREIGN KEY(item_id) REFERENCES Item(item_id)
);

CREATE TABLE Customer
(
client_id int,
balance INT,
credit_limit INT,
discount INT,

PRIMARY KEY(client_id)
);