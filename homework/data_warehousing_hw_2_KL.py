#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 11 21:16:17 2019

@author: kristin.lomicka
"""

import dataset
import pandas as pd
import numpy as np

#connect to postgres
ds = dataset.connect("postgresql://postgres@localhost/hw1_data_warehouse")
#export sql tables
customers_a = pd.DataFrame(ds['customers_a'].all())
employees_new = pd.DataFrame(ds['employees_new'].all())
offices_a = pd.DataFrame(ds['offices_a'].all())
order_metadata_a = pd.DataFrame(ds['order_metadata_a'].all())
orders_new_a = pd.DataFrame(ds['orders_new_a'].all())
products_a = pd.DataFrame(ds['products_a'].all())

#create date dimension table
date_d = order_metadata_a[['order_date']].drop_duplicates().reset_index(drop=True)
date_d['order_date_time'] = pd.to_datetime(date_d['order_date'])
date_d['order_date'] = pd.to_datetime(date_d['order_date']).dt.date
date_d['day_of_week'] = date_d['order_date_time'].dt.weekday_name
date_d['month'] = date_d['order_date_time'].dt.month
date_d['year'] = date_d['order_date_time'].dt.year
date_d['quarter']= date_d['order_date_time'].dt.quarter
#insert unique ID
date_d.insert(0, 'date_id', range(1, 1 + len(date_d)))


#create remaining dimension tables
employees_d = employees_new[['employee_number', 'last_name', 'first_name', 'reports_to', 'job_title', 'office_code']]
offices_d = offices_a[['office_code', 'city', 'state', 'country', 'office_location']]
products_d = products_a[['product_line', 'product_code', 'product_name', 'product_scale', 'product_vendor', 'product_description', 'quantity_in_stock', 'buy_price', '_m_s_r_p', 'html_description']]
customers_d = customers_a[['customer_number', 'customer_name', 'contact_last_name', 'contact_first_name', 'city', 'state', 'country']]

#check employees_d for duplicate values
dupes_employees_d = employees_new.pivot_table(index=['employee_number'], aggfunc='size')
print(dupes_employees_d)

#create measure table
orders_measure = orders_new_a[['order_number', 'order_line_number', 'customer_number', 'product_code', 'quantity_ordered', 'price_each']]
orders_measure = pd.merge(orders_measure, order_metadata_a[['order_number', 'order_date', 'sales_rep_employee_number']], on='order_number', how='left')
orders_measure.rename(columns={'sales_rep_employee_number':'employee_number'}, inplace=True)
orders_measure = pd.merge(orders_measure, employees_new[['office_code', 'employee_number']], on='employee_number', how='left')
date_d['order_date'] = pd.to_datetime(date_d['order_date']).dt.date

#calculate total cost
orders_measure = pd.merge(orders_measure, products_d[['product_code', 'buy_price']], on='product_code', how='left')
orders_measure['total_cost'] = orders_measure['quantity_ordered'] * orders_measure['buy_price']
orders_measure = orders_measure.drop(columns= 'buy_price')

#calculate total revenue
orders_measure['total_revenue'] = orders_measure['quantity_ordered'] * orders_measure['price_each']


#calculate total profit
orders_measure['total_profit'] = orders_measure['total_revenue'] - orders_measure['total_cost']

#calculate profit_margin
orders_measure['profit_margin'] = orders_measure['total_profit'] / orders_measure['total_cost'] * 100

#Question: Is there a way to perform the calculation directly from the other dataframe?

#import new dataframes into postgresql
#import employees_d
ds = dataset.connect("postgresql://postgres@localhost/hw2_analytics_db")
cs = ds['employees_d'] #python code name#
cs.insert_many(employees_d.to_dict('records')) #sql code name#
# # # import offices_d
ds = dataset.connect("postgresql://postgres@localhost/hw2_analytics_db")
cs = ds['offices_d'] #python code name#
cs.insert_many(offices_d.to_dict('records')) #sql code name#
# # #import products_d
ds = dataset.connect("postgresql://postgres@localhost/hw2_analytics_db")
cs = ds['products_d'] #python code name#
cs.insert_many(products_d.to_dict('records')) #sql code name#
# # #import customers_d
ds = dataset.connect("postgresql://postgres@localhost/hw2_analytics_db")
cs = ds['customers_d'] #python code name#
cs.insert_many(customers_d.to_dict('records')) #sql code name#
# # #import date_d
ds = dataset.connect("postgresql://postgres@localhost/hw2_analytics_db")
cs = ds['date_d'] #python code name#
cs.insert_many(date_d.to_dict('records')) #sql code name#
# # #import orders_measure
ds = dataset.connect("postgresql://postgres@localhost/hw2_analytics_db")
cs = ds['orders_measure'] #python code name#
cs.insert_many(orders_measure.to_dict('records')) #sql code name#