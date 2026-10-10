-- Data Quality Checks

-- 1. Row Counts of all tables

select 'Customers' as Table_name, count(*) as Row_Count from customers
union all 
select 'Inventory', count(*) from inventory
union all
select 'Promotions', count(*) from promotions
union all 
select 'Sales', count (*) from sales
union all
select 'Skus', count(*) from skus
union all 
select 'Stores', count(*) from stores

--2. Null checks

--customer table
select count(*) as Total_Rows,
count_if(c.cust_id is null) as null_cust_id,
count_if(c.age is null) as null_age,
count_if(c.gender is null) as null_gender,
count_if(c.city is null) as null_city,
count_if(c.loyalty_segment is null) as null_loyalty_segment,
count_if(c.preferred_channel is null) as null_preferred_channel,
count_if(c.registration_date is null) as null_registration_date
from customers as c
--no null values found

--inventory table
select count(*) as Total_Rows,
count_if(i.store_id is null) as null_store_id,
count_if(i.sku_id is null) as null_sku_id,
count_if(i.stock_on_hand is null) as null_stock,
count_if(i.reorder_point is null) as null_reorder_point,
count_if(i.safety_stock is null) as null_safety_stock,
count_if(i.last_restock_date is null) as null_last_restock_date,
count_if(i.snapshot_date is null) as null_snapshot_date
from inventory as i
-- no null values found

--promotions table
select count(*) as Total_Rows,
count_if(p.promo_name is null) as null_promo_name,
count_if(p.start_date is null) as null_start_date,
count_if(p.end_date is null) as null_end_date,
count_if(p.discount_pct is null) as null_discount_pct,
count_if(p.promo_type is null) as null_promo_type,
count_if(p.promo_id is null) as null_promo_id
from promotions as p
--no null values found

--sales table
select count(*) as Total_Rows,
count_if(s.store_id is null) as null_store_id,
count_if(s.sku_id is null) as null_sku_id,
count_if(s.customer_id is null) as null_customer_id,
count_if(s.quantity is null) as null_quantity,
count_if(s.unit_price is null) as null_unit_price,
count_if(s.total_value is null) as null_total_value,
count_if(s.channel is null) as null_channel,
count_if(s.discount_pct is null) as null_discount_pct
from sales as s
--nulls found in column - customer_id = 159821

select * from sales
where customer_id is null

--skus table
select count(*) as Total_Rows,
count_if(sk.sku_id is null) as null_sku_id,
count_if(sk.sku_name is null) as null_sku_name,
count_if(sk.category is null) as null_category,
count_if(sk.subcategory is null) as null_subcategory,
count_if(sk.unit_price is null) as null_unit_price,
count_if(sk.cost_price is null) as null_cost_price,
count_if(sk.brand is null) as null_brand
from skus as sk
--no null values found

--stores table
select count(*) as Total_Rows,
count_if(st.store_id is null) as null_store_id,
count_if(st.store_name is null) as null_store_name,
count_if(st.city is null) as null_city,
count_if(st.store_type is null) as null_store_type,
count_if(st.opening_date is null) as null_opening_date
from stores as st
--no null values found

--3. Check Duplicates

--customers table
select c.cust_id,c.age,c.gender,c.city,c.loyalty_segment,c.preferred_channel,c.registration_date,
count(*) as row_count
from customers as c
group by c.cust_id,c.age,c.gender,c.city,c.loyalty_segment,c.preferred_channel,c.registration_date
having count(*) > 1
--no duplicate records found

--inventory table
select i.store_id,i.sku_id,i.stock_on_hand,i.reorder_point,i.safety_stock,i.last_restock_date,i.snapshot_date,
count(*) as row_count
from inventory as i
group by i.store_id,i.sku_id,i.stock_on_hand,i.reorder_point,i.safety_stock,i.last_restock_date,i.snapshot_date
having count(*) > 1
--no duplicate records found

--promotions table
select p.promo_name,p.start_date,p.end_date,p.discount_pct,p.promo_type,p.promo_id,
count(*) as row_count 
from promotions as p
group by p.promo_name,p.start_date,p.end_date,p.discount_pct,p.promo_type,p.promo_id
having count(*) > 1
--no duplicate records found

--sales table
select s.date,s.store_id,s.sku_id,s.customer_id,s.quantity,s.unit_price,s.total_value,s.channel,s.discount_pct,
count(*) as row_count
from sales as s
group by s.date,s.store_id,s.sku_id,s.customer_id,s.quantity,s.unit_price,s.total_value,s.channel,s.discount_pct
having count(*) > 1
--Duplicate Rows found in sales table

select sum(Duplicate_Rows - 1) as Actual_Duplicate_Rows
from (
    select s.date, s.store_id,s.sku_id,s.customer_id,s.quantity,s.unit_price,s.total_value,s.channel,s.discount_pct,
    count(*) as Duplicate_Rows
    from sales as s
    group by s.date, s.store_id,s.sku_id,s.customer_id,s.quantity,s.unit_price,s.total_value,s.channel,s.discount_pct
    having count(*) > 1
    )
--Actual duplicate rows in sales table = 45

create table sales_pseudo as
select distinct * from sales

select count (*) as row_count from sales_pseudo

select sp.date, sp.store_id,sp.sku_id,sp.customer_id,sp.quantity,sp.unit_price,sp.total_value,sp.channel,sp.discount_pct,
count(*) as row_count
from sales_pseudo as sp
group by sp.date, sp.store_id,sp.sku_id,sp.customer_id,sp.quantity,sp.unit_price,sp.total_value,sp.channel,sp.discount_pct
having count(*) > 1

create or replace table sales as
select * from sales_pseudo

drop table sales_pseudo
--duplicates removed

--skus table
select sk.sku_id,sk.sku_name,sk.category,sk.subcategory,sk.unit_price,sk.cost_price,sk.brand,
count(*) as row_count
from skus as sk
group by sk.sku_id,sk.sku_name,sk.category,sk.subcategory,sk.unit_price,sk.cost_price,sk.brand
having count(*) > 1
--no duplicate records found

--stores table
select st.store_id,st.store_name,st.city,st.store_type,st.opening_date,
count(*) as row_count
from stores as st
group by st.store_id,st.store_name,st.city,st.store_type,st.opening_date
having count(*) > 1
--no duplicate records found

--4. Invalid Value Checks 

select 
min(c.age) as min_age,
max(c.age) as max_age,
min(c.registration_date) as first_reg_date,
max(c.registration_date) as last_reg_date
from customers as c

select distinct(c.gender) as gender
from customers as c

select distinct(c.city) as city
from customers as c

select distinct(c.loyalty_segment) as loyalty_segment
from customers as c

select min(i.stock_on_hand) as min_stock,
max(i.stock_on_hand) as max_stock,
min(i.reorder_point) as min_reorder,
max(i.reorder_point) as max_reorder,
min(i.safety_stock) as min_safety_stock,
max(i.safety_stock) as max_safety_stock,
min(i.last_restock_date) as min_restock_date,
max(i.last_restock_date) as max_restock_date,
min(i.snapshot_date) as min_snapshot_date,
max(i.snapshot_date) as max_snapshot_date
from inventory as i

select * from inventory
where last_restock_date > snapshot_date

select * from inventory
where safety_stock > reorder_point

select min(start_date) as min_start_date,
max(start_date) as max_start_date,
min(end_date) as min_end_date,
max(end_date) as max_end_date,
min(discount_pct) as min_disc,
max(discount_pct) as max_disc
from promotions 

select * from promotions
where end_date < start_date

select distinct promo_type from promotions

select 
min(s.date) as first_sale_date,
max(s.date) as last_sale_date,
min(s.quantity) as min_qty,
max(s.quantity) as max_qty,
min(s.unit_price) as min_unit_price,
max(s.unit_price) as max_unit_price,
min(s.total_value) as min_value,
max(s.total_value) as max_value,
min(s.discount_pct) as min_discount,
max(s.discount_pct) as max_discount
from sales as s

select * from sales as s
where s.total_value != s.quantity*s.unit_price

select min(unit_price) as min_unit_price,
max(unit_price) as max_unit_price,
min(cost_price) as min_cost_price,
max(cost_price) as max_cost_price,
from skus

select distinct category from skus

select distinct subcategory from skus

select distinct brand from skus

select * from skus
where cost_price > unit_price

select min(opening_date) as min_open_dt,
max(opening_date) as max_opn_dt
from stores

select distinct store_name from stores

select distinct city from stores

select distinct store_type from stores


--5. Referential Integrity

select count(*) as invalid_sales 
from sales as s
join stores as st
on s.store_id = st.store_id
where s.date < st.opening_date
-- sales didn't occur before a store opened

select distinct s.store_id
from sales as s
left join stores as st
on s.store_id = st.store_id
where st.store_id is null
--every sales.store_id exists in stores

select distinct s.sku_id
from sales as s
left join skus as sk
on s.sku_id = sk.sku_id
where sk.sku_id is null
--every sales.sku_id exists in skus

select distinct s.customer_id
from sales as s
left join customers as c
on s.customer_id = c.cust_id
where s.customer_id is not null and c.cust_id is null
--every non-null sales.customer_id exists in customers

select distinct i.store_id
from inventory as i
left join stores as st
on i.store_id = st.store_id
where st.store_id is null
--every inventory.store_id exists in stores

select distinct i.sku_id
from inventory as i 
left join skus as sk
on i.sku_id = sk.sku_id
where sk.sku_id is null
--every inventory.sku_id exists in skus

select distinct discount_pct
from sales
order by discount_pct

select distinct discount_pct
from promotions
order by discount_pct

select 
    p1.promo_name as promo_1,
    p2.promo_name as promo_2,
    p1.discount_pct,
    p1.start_date as promo_1_start,
    p1.end_date as promo_1_end,
    p2.start_date as promo_2_start,
    p2.end_date as promo_2_end
from promotions as p1
join promotions as p2
on 
    p1.promo_id < p2.promo_id
    and p1.discount_pct = p2.discount_pct
    and p1.start_date <= p2.end_date
    and p2.start_date <= p1.end_date
--Both promotions have 20% discount, and both include 01-Jul-2023

select count(*) as overlapping_sales from sales
where date = '2023-07-01' and discount_pct = 20
--187 rows in sales have been affected by 20% discount overlap

select count(*) as unmatched_discounted_sales
from sales as s
where s.discount_pct > 0
and not exists(
    select 1 from promotions as p
    where s.date between p.start_date and p.end_date
    and s.discount_pct = p.discount_pct
)
--0 unmatched discounted sales





