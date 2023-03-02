# Creating eshop database

create database product;

use product;

create table buyer(
id int auto_increment primary key,
f_name varchar(255),
l_name varchar (255),
email varchar(255),
age int);

alter table buyer
RENAME COLUMN adress_id to address_id;



create table card_passport(
id int auto_increment primary key,
person_code int unique,
expiry_date date,
buyer_id int unique);

create table credit_card(
id int auto_increment primary key,
card_number int unique,
expiry_date date,
buyer_id int unique);

create table products(
id int not null auto_increment primary key,
`name` varchar(255),
price bigint,
quantity bigint,
categry_id int);

create table categories(
id int not null auto_increment primary key,
`name` varchar (255),
adults_only bool);

alter table buyer
add column adress_id int;

create table addresses(
id int not null auto_increment primary key,
country varchar (255),
street varchar (255),
house_numb int,
flat_numb int,
postcode int);


# adding foreign keys
ALTER TABLE buyer
ADD FOREIGN KEY (address_id) REFERENCES addresses(id);

ALTER TABLE card_passport
ADD FOREIGN KEY (buyer_id) REFERENCES buyer(id);

ALTER TABLE products
ADD FOREIGN KEY (category_id) REFERENCES categories(id);


insert into addresses (country, street, house_numb, flat_numb, postcode) values ('Lithuania', 'Ozo', '1', '2', '12345'), ('Lithuania', 'Ozo', '1', '3', '12345'), ('Lithuania', 'Ozo', '1', '4', '12345'),
('Lithuania', 'Ozo', '1', '5', '12345'), ('Lithuania', 'Ozo', '1', '6', '12345'), ('Lithuania', 'Ozo', '1', '7', '12345'), ('Lithuania', 'Ozo', '1', '8', '12345');
select * from addresses;

insert into buyer (f_name, l_name, email, age, adress_id) values ('Vitalijus', 'Nesakysiu', 'vit@vit.lt', '18', '1'), ('Saulius', 'Nesakysiu', 'vit1@vit.lt', '16', '2'),
('oliala', 'Nesakysiu', 'vit11@vit.lt', '19', '4'), ('empathy', 'Nesakysiu', 'vit1@vit.lt', '60', '6'), ('envy15', 'Nesakysiu', 'envy@vit.lt', '60', '8');
select * from buyer;

alter table card_passport
modify person_code bigint;

# I changed person_code from int  to bigint because the personal code was too long for int

insert into card_passport (person_code, expiry_date, buyer_id) values ('39584752654', '2025-01-05', '7'), ('39584743654', '2020-01-05', '2'),
('49584752654', '2027-01-05', '3'), ('39584752154', '2025-01-05', '4'), ('59584752654', '2025-01-05', '5'), ('39584112654', '2025-01-05', '6');

alter table credit_card
modify card_number bigint;

insert into credit_card (card_number, expiry_date, buyer_id) values ('39584752654', '2025-01-05', '7'), ('39584743654', '2020-01-05', '2'),
('49584752654', '2027-01-05', '3'), ('39584752154', '2025-01-05', '4'), ('59584752654', '2025-01-05', '5'), ('39584112654', '2025-01-05', '6');


insert into categories (`name`, adults_only) Values ('Alc_drinks', '1'), ('drinks', '0'), ('Tobacco', '1'), ('snacks', '0');
select * from categories;

#delete because accidently 2x executed insert into categories
delete from categories where id between 5 and 8;

insert into products (`name`, price, quantity, categry_id) values ('Corona', '200', '500', '1'), ('Bėganti_kopa', '200', '100', '1'), ('Orange_juice', '250', '100', '2'),
('Taboo', '1100', '20', '3'), ('cheese', '330', '30', '4'), ('sausage', '399', '15', '4'), ('chips', '199', '1000', '4');
select * from products order by quantity;


#I create a view, which will show goods for adults only.
create view `18+` as
select p.id, p.name, p.price, p.quantity
from products p
left join categories c on p.category_id = c.id where c.adults_only > 0;

drop view `18+` ;

select * from `18+` ;

# I create a view joining buyer_id and addresses table information about the buyer.
create view `customer_info` as
select b.f_name, b.l_name, b.email, a.postcode
from buyer b
left join addresses a on b.address_id = a.id ;

drop view `customer_info` ;

# correcting mistake
ALTER TABLE products
RENAME COLUMN categry_id to category_id;

# searching for clients who use Gmail
select * from customer_info where email like "%@gmail%";

# searching for clients who use "vit.lt"  email and which name = Vitalijus
select * from customer_info where email like "%vit.lt" having f_name like "Vitalijus";


# creating procedure, which changes the buyer's name into a new given one
DELIMITER $$
CREATE procedure name_change (new_name varchar(100), old_name varchar(100))
BEGIN
	Update product.buyer
    set buyer.f_name = new_name
    where buyer.f_name like old_name ;
END $$
DELIMITER ;

drop procedure name_change;

# I check the procedure
call name_change ('Asterix', 'envy15');
select * from buyer ;

# I create a view which will show buyers info, his card expiry date and his credit card expiry date while joining 3 tables
create view expiry_date as
select b.f_name as first_name, b.l_name as last_name, p.expiry_date as card_or_passport_expiration_date, c.expiry_date as credit_card_expiration_date
from buyer as b
left join card_passport as p on b.id=p.buyer_id
left join credit_card as c on b.id=c.buyer_id;

drop view expiry_date;
select * from expiry_date;


# I create a function that counts all goods which are cheaper than the given value and is in the given category 

DELIMITER $$
CREATE FUNCTION category_and_price (check_category int, check_price bigint)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE answer INT;
    select count(id) into answer from products
    where check_category = category_id
    and check_price > price;
    RETURN answer;
END $$
DELIMITER ;

drop function category_and_price;
select  category_and_price ('4', '300');


# I'm making shopping cart and orders tables and functionality

CREATE TABLE carts (
  id INT PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  purchased_at TIMESTAMP
);

CREATE TABLE cart_items (
  cart_id INT,
  product_id INT,
  quantity INT,
  PRIMARY KEY (cart_id, product_id),
  FOREIGN KEY (cart_id) REFERENCES carts(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE orders (
  id int not null auto_increment PRIMARY KEY,
  cart_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  customer_name VARCHAR(255),
  customer_email VARCHAR(255),
  customer_address VARCHAR(255),
  FOREIGN KEY (cart_id) REFERENCES carts(id)
);


CREATE TABLE order_items (
  order_id INT,
  product_id INT,
  quantity INT,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

# creating new cart
INSERT INTO carts (id) Values ('1');

# inserting items in shoping cart
INSERT INTO cart_items (cart_id, product_id, quantity) Values ('1', '3', '1') , ('1', '7', '3');


# checkinkg the contents of the cart

SELECT products.name, cart_items.quantity, products.price, (cart_items.quantity * products.price) AS total_price
FROM cart_items
JOIN products ON cart_items.product_id = products.id
WHERE cart_items.cart_id = 1;

# creating an order
insert into orders (cart_id, customer_name, customer_email, customer_address) VALUES
  ('1', (select `f_name` from buyer where id = '2'), (select `email` from buyer where id = '2'),
 concat((select country from addresses where id = 1), ' ', (select street from addresses where id = 1), ' ', (select house_numb from addresses where id = 1), ' ',
 (select flat_numb from addresses where id = 1)));

#adding items from shoping cart to order items
INSERT INTO order_items 
(order_id, product_id, quantity)  
SELECT 
    orders.id, 
    cart_items.product_id, 
    cart_items.quantity
FROM cart_items 
left join orders on cart_items.cart_id=orders.cart_id;

# checking the contents of the order
SELECT products.name, order_items.quantity, products.price, (order_items.quantity * products.price) AS total_price
FROM order_items
JOIN products ON order_items.product_id = products.id
WHERE order_items.order_id = 4;

# delete the cart and its associated items
DELETE FROM cart_items WHERE cart_id = 1;
DELETE FROM carts WHERE id = 1;

select * from carts;
select * from cart_items;

