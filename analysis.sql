
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

create table top_10_product as
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

/* Pareto analysis with products and revenue */

create table pareto_analysis as
with product_revenue as (
    select
        ooid.product_id,
        sum(cast(ooid.price as numeric)) as revenue
    from olist_order_items_dataset as ooid
    join olist_orders_dataset as ood
    on ooid.order_id = ood.order_id
    where ood.order_status = 'delivered'
    group by ooid.product_id
),

pareto_calc as (
    select
        product_id,
        revenue,
        sum(revenue) over(order by revenue desc) as cummulative_revenue,
        sum(revenue) over() as total_revenue
    from product_revenue
)

select count(*) as total_product,
sum (
    case
        when cummulative_revenue <= 0.8*total_revenue then 1
        else 0
    end
) as product_generating_80_pct
from pareto_calc;

/* From this analysis, we have gathered an insight that 80% of the revenue comes from
   26% of the products. This is a healthy proportion meaning that we are not too dependent
   on certain products
 */


/* Product category percentage share over the whole catalog */
create table category_pct_share_tbl as
with category_pct_share as (
    select
    product_category_name_translation,
    SUM(CAST(ooid.price AS numeric)) AS total_category_revenue,
    ROUND(
        100.0 * SUM(CAST(ooid.price AS numeric)) / SUM(SUM(CAST(ooid.price AS numeric))) OVER (),
        2
    ) AS revenue_share_pct
    from olist_products_dataset as opd
    join olist_order_items_dataset as ooid
    on opd.product_id = ooid.product_id
    join olist_orders_dataset as ood
    on ood.order_id = ooid.order_id
    join product_category_name_translation as pcnt
    on pcnt.product_category_name = opd.product_category_name
    where ood.order_status = 'delivered'
    group by product_category_name_translation
    order by total_category_revenue desc
    limit 10
)
select * from category_pct_share;

/* percentage of payments made by different payment methods*/

create table payment_method_analysis as
SELECT
    payment_type,
    COUNT(*) AS num_order,
    SUM(CAST(payment_value AS numeric)) AS sum_payment,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS payment_pct
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY num_order DESC;

/* Items that bring in high revenue but has low ratings*/

create table risky_products as
WITH product_revenue AS (
    SELECT
        ooid.product_id,
        SUM(CAST(ooid.price AS numeric)) AS revenue
    FROM olist_order_items_dataset ooid
    JOIN olist_orders_dataset ood
        ON ooid.order_id = ood.order_id
    WHERE ood.order_status = 'delivered'
    GROUP BY ooid.product_id
),

product_reviews AS (
    SELECT
        ooid.product_id,
        AVG(cast(oorv.review_score as numeric)) AS avg_review_score,
        COUNT(oorv.review_id) AS review_count
    FROM olist_order_items_dataset ooid
    JOIN olist_order_reviews_dataset oorv
        ON ooid.order_id = oorv.order_id
    JOIN olist_orders_dataset ood
        ON ooid.order_id = ood.order_id
    WHERE ood.order_status = 'delivered'
    GROUP BY ooid.product_id
),

overall_rating AS (
    SELECT
        AVG(cast(avg_review_score as numeric)) AS overall_avg_review_score
    FROM product_reviews
),

high_revenue_threshold AS (
    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY revenue) AS revenue_cutoff
    FROM product_revenue
)

SELECT
    pr.product_id,
    pr.revenue,
    rev.avg_review_score,
    orr.overall_avg_review_score,
    rev.review_count
FROM product_revenue pr
JOIN product_reviews rev
    ON pr.product_id = rev.product_id
CROSS JOIN overall_rating orr
CROSS JOIN high_revenue_threshold t
WHERE
    pr.revenue >= t.revenue_cutoff
    AND rev.avg_review_score < 3.5
ORDER BY pr.revenue DESC;












