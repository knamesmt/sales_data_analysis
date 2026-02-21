
/*Change columns' name in product_category_name_translation*/
alter table product_category_name_translation rename column c1 to "product_category_name";
alter table product_category_name_translation rename column c2 to "product_category_name_translation";

delete from product_category_name_translation
WHERE ctid IN (
    SELECT ctid
    FROM product_category_name_translation
    LIMIT 1
);

/*Change columns name in orders_dataset */
alter table olist_orders_dataset rename column c1 to "order_id";
alter table olist_orders_dataset rename column c2 to "customer_id";
alter table olist_orders_dataset rename column c3 to "order_status";
alter table olist_orders_dataset rename column c4 to "order_purchase_timestamp";
alter table olist_orders_dataset rename column c5 to "order_approved_at";
alter table olist_orders_dataset rename column c6 to "order_delivered_carrier_date";
alter table olist_orders_dataset rename column c7 to "order_delivered_customer_date";
alter table olist_orders_dataset rename column c8 to "order_estimated_delivery_date";

delete from olist_orders_dataset
WHERE ctid IN (
    SELECT ctid
    FROM olist_orders_dataset
    LIMIT 1
);


/* top 10 product categories by revenue*/

create table top_10_product_category as
with cte_q1 as (
        select ooid.product_id,
           pcnt.product_category_name_translation,
           SUM(CAST(ooid.price AS numeric)) AS total_revenue
    from olist_order_items_dataset as ooid
    join olist_products_dataset as opd
        on ooid.product_id = opd.product_id
    join product_category_name_translation as pcnt
        on opd.product_category_name = pcnt.product_category_name
    join olist_orders_dataset as ood
        on ooid.order_id = ood.order_id
    where ood.order_status = 'delivered'
    group by ooid.product_id, pcnt.product_category_name_translation
    ORDER BY total_revenue DESC
    LIMIT 10
)
select *
from cte_q1;


