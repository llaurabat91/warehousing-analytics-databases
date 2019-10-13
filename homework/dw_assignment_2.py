#import packages

import pandas as pd
import sqlalchemy as sqla
import datetime as dt

#load content of original sql database into pandas dataframes via sqlalchemy package

engine1 = sqla.create_engine('postgresql://postgres@localhost:5432/dw_assignment_1')

off = pd.read_sql_query('SELECT * FROM offices', con = engine)
empl = pd.read_sql_query('SELECT * FROM employees', con = engine)
cust = pd.read_sql_query('SELECT * FROM customers', con = engine)
orde = pd.read_sql_query('SELECT * FROM orders', con = engine)
prod = pd.read_sql_query('SELECT * FROM products', con = engine)
prod_ord = pd.read_sql_query('SELECT * FROM products_ordered', con = engine)

#create a big join of all the tables (I need to fillna for the dates so to match with my date_dim table nas)

measures_full= prod_ord.merge(prod, how = 'inner', on = 'product_code').merge(orde, how = 'inner', on = 'order_number'
                             ).merge(cust, how = 'inner', on = 'customer_number'
                             ).merge(empl, how = 'inner', left_on = 'sales_rep_employee_number', right_on = 'employee_number'
                                    ).merge(off, how = 'inner', on = 'office_code')
measures_full['shipped_date']=measures_full['shipped_date'].fillna(datetime.date(1111,11,11))
measures_full['order_date']=measures_full['order_date'].fillna(datetime.date(1111,11,11))
measures_full['required_date']=measures_full['required_date'].fillna(datetime.date(1111,11,11))

#define my measures table:

# (1) only keep the numerical variables and the id columns I will constrain to be foreign keys in the new sql database

measures = measures_full[['order_number','product_code','customer_number','office_code','order_line_number','order_date','shipped_date','required_date','reports_to','sales_rep_employee_number','quantity_ordered', 'price_each','quantity_in_stock','buy_price','_m_s_r_p','credit_limit']]

# (2) define new columns for revenues, costs, profits and profit margin

measures['revenues']= measures['quantity_ordered']*measures['price_each']
measures['cost']= measures['quantity_ordered']*measures['buy_price']
measures['profits']= measures['revenues']-measures['cost']
measures['profit_margin']= measures['profits']/measures['revenues']

#define dimension table for date:

#(1) append order_date, required_date and shipped_date and then dropping duplicates, so to have a column of unique dates
# Here I am also dropping nas for date so not to have problems when stripping the day, month, year, ..

date_dim = pd.DataFrame(orders['order_date'].append(orders['required_date']
            ).append(orders['shipped_date'].dropna())).drop_duplicates().rename(columns = {0:'unique_date'})

#(2) create columns for day, day of week, month, year, quarter

date_dim['day_of_month']=date_dim['unique_date'].map(lambda x: x.day)
date_dim['day_of_week']=date_dim['unique_date'].map(lambda x: x.weekday())
date_dim['month']=date_dim['unique_date'].map(lambda x: x.month)
date_dim['year']=date_dim['unique_date'].map(lambda x: x.year)
date_dim['quarter']=date_dim['unique_date'].map(lambda x: (x.month-1)//3+1)

#(3) adding back one row with id = 1111-11-11 which represents my null date (that I can then match with the dates ids in measures as I also replaced nas with 1111-11-11 in measure table)

date_dim = date_dim.append(pd.Series([datetime.date(1111,11,11),None,None,None,None,None], index = ['unique_date','day_of_month','day_of_week','month','year','quarter']), ignore_index=True)

#create the other dimension tables (apart from offices, for which I keep the original dataframe):
employees_dim = empl[['employee_number','last_name','first_name','job_title']]
customers_dim = cust[['customer_number','customer_name','contact_last_name','contact_first_name','city','state','country','customer_location']]
order_line_number_dim = prod_ord['order_line_number'].drop_duplicates()
orders_dim = orde[['order_number','status','comments']]
product_types_dim = prod[['product_code','product_line','product_name','product_scale','product_vendor','product_description']]

#load the pd.dataframes into the new sql database via sql alchemy package
engine2 = sqla.create_engine('postgresql://postgres@localhost:5432/dw_assignment_2')

off.to_sql('offices_dim', engine2, if_exists = 'append', index = False)
date_dim.to_sql('date_dim', engine2, if_exists = 'append', index = False)
employees_dim.to_sql('employees_dim', engine2, if_exists = 'append', index = False)
customers_dim.to_sql('customers_dim', engine2, if_exists = 'append', index = False)
order_line_number_dim.to_sql('order_line_number_dim', engine2, if_exists = 'append', index = False)
product_types_dim.to_sql('product_types_dim', engine2, if_exists = 'append', index = False)
orders_dim.to_sql('orders_dim', engine2, if_exists = 'append', index = False)
measures.to_sql('measures', engine2, if_exists = 'append', index = False)




