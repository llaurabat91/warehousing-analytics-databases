-- cat create-databases.sql | docker run --net host -i postgres psql --host 0.0.0.0 --user postgres

SELECT
   *
FROM
   pg_stat_activity
WHERE
   datname = 'dw_assignment_2';

   SELECT
   pg_terminate_backend (pg_stat_activity.pid)
FROM
   pg_stat_activity
WHERE
   pg_stat_activity.datname = 'dw_assignment_2';

DROP DATABASE dw_assignment_2;
CREATE DATABASE dw_assignment_2;
\c dw_assignment_2;

CREATE TABLE offices_dim (
office_code INTEGER PRIMARY KEY,
city VARCHAR NOT NULL,
state VARCHAR,
country VARCHAR,
office_location VARCHAR
);

CREATE TABLE employees_dim (
employee_number INTEGER PRIMARY KEY,
last_name VARCHAR NOT NULL,
first_name VARCHAR NOT NULL,
job_title VARCHAR
);

CREATE TABLE date_dim (
unique_date DATE PRIMARY KEY,
day_of_month INTEGER,
day_of_week INTEGER,
month INTEGER,
quarter INTEGER,
year INTEGER
);

CREATE TABLE customers_dim (
customer_number INTEGER PRIMARY KEY,
customer_name VARCHAR NOT NULL,
contact_last_name VARCHAR,
contact_first_name VARCHAR,
city VARCHAR,
state VARCHAR,
country VARCHAR,
customer_location VARCHAR
);

CREATE TABLE order_line_number_dim (
order_line_number INTEGER PRIMARY KEY
);


CREATE TABLE orders_dim (
order_number INTEGER PRIMARY KEY,
status VARCHAR,
comments VARCHAR
);

CREATE TABLE product_types_dim (
product_code VARCHAR PRIMARY KEY,
product_line VARCHAR NOT NULL,
product_name VARCHAR,
product_scale VARCHAR,
product_vendor VARCHAR,
product_description VARCHAR
);

CREATE TABLE measures (
quantity_ordered INTEGER NOT NULL,
price_each FLOAT NOT NULL,
revenues FLOAT,  -- = quantity_ordered*price_each
quantity_in_stock INTEGER,
buy_price FLOAT,
cost FLOAT, -- = quantity_ordered*buy_price
profits FLOAT, -- = revenues - cost
profit_margin FLOAT, -- = (revenues - costs)/revenues
_m_s_r_p FLOAT,
credit_limit INTEGER,
-- foreign keys
order_number INTEGER REFERENCES orders_dim(order_number),
product_code VARCHAR REFERENCES product_types_dim(product_code),
customer_number INTEGER REFERENCES customers_dim(customer_number),
office_code INTEGER REFERENCES offices_dim(office_code),
order_line_number INTEGER REFERENCES order_line_number_dim(order_line_number),
order_date DATE REFERENCES date_dim(unique_date),
shipped_date DATE REFERENCES date_dim(unique_date),
required_date DATE REFERENCES date_dim(unique_date),
reports_to INTEGER REFERENCES employees_dim(employee_number),
sales_rep_employee_number INTEGER REFERENCES employees_dim(employee_number)
);
