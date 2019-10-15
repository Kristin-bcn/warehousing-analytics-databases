DROP DATABASE hw2_analytics_db;

CREATE DATABASE hw2_analytics_db;
\c hw2_analytics_db;

CREATE TABLE employees_d(
employee_number INTEGER PRIMARY KEY,
last_name VARCHAR,
first_name VARCHAR,
reports_to VARCHAR,
job_title VARCHAR);

CREATE TABLE offices_d(
office_code INTEGER PRIMARY KEY,
city VARCHAR,
state VARCHAR,
country VARCHAR,
office_location VARCHAR
);

CREATE TABLE products_d(
product_line VARCHAR,
product_code VARCHAR PRIMARY KEY,
product_name VARCHAR,
product_scale VARCHAR,
product_vendor VARCHAR,
product_description VARCHAR,
quantity_in_stock INTEGER,
buy_price FLOAT,
_m_s_r_p FLOAT,
html_description VARCHAR
);

CREATE TABLE customers_d(
customer_number INTEGER PRIMARY KEY,
customer_name VARCHAR,
contact_last_name VARCHAR,
contact_first_name VARCHAR,
city VARCHAR,
state VARCHAR,
country VARCHAR
);

CREATE TABLE date_d(
order_date DATE PRIMARY KEY,
day_of_week VARCHAR,
month INTEGER,
year INTEGER,
quarter INTEGER
);

CREATE TABLE orders_measure(
order_number INTEGER,
order_line_number INTEGER,
customer_number INTEGER REFERENCES customers_d,
office_code INTEGER REFERENCES offices_d,
employee_number INTEGER REFERENCES employees_d,
product_code VARCHAR  REFERENCES products_d,
order_date DATE REFERENCES date_d,
quantity_ordered INTEGER,
price_each FLOAT,
total_cost FLOAT,
total_revenue FLOAT,
total_profit FLOAT,
profit_margin FLOAT
);
