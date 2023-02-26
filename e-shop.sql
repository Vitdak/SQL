# Creating eshop databese
#Eshop 

#
#
#
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
house_numb varchar (255),
flat_numb varchar(255),
postcode int);


drop table orders;
create table orders(
id int not null auto_increment primary key,
buyer_id int,
shipping_address varchar(255),
total_price int);

create table shopping_cart(
id int not null auto_increment primary key,
order_id int,
product_id int,
quantity int,
price bigint,
total bigint);

# sudedu foreign keys'us
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
# keiciau person_code is int  i bigint nes 'netilpo' asmens kodas
insert into card_passport (person_code, expiry_date, buyer_id) values ('39584752654', '2025-01-05', '7'), ('39584743654', '2020-01-05', '2'),
('49584752654', '2027-01-05', '3'), ('39584752154', '2025-01-05', '4'), ('59584752654', '2025-01-05', '5'), ('39584112654', '2025-01-05', '6');

alter table credit_card
modify card_number bigint;

insert into credit_card (card_number, expiry_date, buyer_id) values ('39584752654', '2025-01-05', '7'), ('39584743654', '2020-01-05', '2'),
('49584752654', '2027-01-05', '3'), ('39584752154', '2025-01-05', '4'), ('59584752654', '2025-01-05', '5'), ('39584112654', '2025-01-05', '6');


insert into categories (`name`, adults_only) Values ('Alc_drinks', '1'), ('drinks', '0'), ('Tobacco', '1'), ('snacks', '0');
select * from categories;

#trinu nes netycia 2x runinau 90 query
delete from categories where id between 5 and 8;

insert into products (`name`, price, quantity, categry_id) values ('Corona', '200', '500', '1'), ('Bėganti_kopa', '200', '100', '1'), ('Orange_juice', '250', '100', '2'),
('Taboo', '1100', '20', '3'), ('cheese', '330', '30', '4'), ('sausage', '399', '15', '4'), ('chips', '199', '1000', '4');
select * from products order by quantity;


# sukuriu view, kuris rodys tik prekes suaugusiems
create view `18+` as
select p.id, p.name, p.price, p.quantity
from products p
join categories c on p.category_id = c.id where c.adults_only > 0;

drop view `18+` ;

select * from `18+` ;

# sukuriu view apjungdamas buyer_id ir addresses lentelių reikalingą informaciją.
create view `customer_info` as
select b.f_name, b.l_name, b.email, a.postcode
from buyer b
join addresses a on b.address_id = a.id ;

# taisau rašybos klaidą
ALTER TABLE products
RENAME COLUMN categry_id to category_id;

# randu klientus, kurie naudoja gmail
select * from customer_info where email like "%@gmail%";

# randu klientus, kurie naudoja "vit"  el paštą ir kurių vardas = Vitalijus
select * from customer_info where email like "%vit.lt" having f_name like "Vitalijus";


#sukuriu procedure, kuri pakeičia buyer lentelėje kliento vardą į naujai pateiktą vardą.
DELIMITER $$
CREATE procedure name_change (new_name varchar(100), old_name varchar(100))
BEGIN
	Update product.buyer
    set buyer.f_name = new_name
    where buyer.f_name like old_name ;
END $$
DELIMITER ;

drop procedure name_change;

# tikrinu procedure veikimą
call name_change ('Asterix', 'envy15');
select * from buyer ;





DELIMITER $$
create procedure shopping_cart (customer_id int, _product_id int, qty int)
Begin
insert into orders (buyer_id, shipping_address) value (customer_id, buyer.adress_id)

insert into shopping_cart (order_id, product_id, quantity, price, total) values (SELECT LAST_INSERT_ID()), _product_id, qty,
(select price from products where product_id = _product_id as pr) , (qty*pr))     ????????????????????????

insert into orders (buyer_id, shipping_address, total price) value (customer_id, buyer.adress_id,  )
END $$
DELIMITER ;





