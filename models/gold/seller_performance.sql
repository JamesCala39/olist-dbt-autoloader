with items as (
    select * from {{ ref('order_items') }}
),

orders as (
    select * from {{ ref('orders') }}
    where order_status = 'delivered'
),

reviews as (
    select * from {{ ref('order_reviews') }}
),

sellers as (
    select * from {{ ref('sellers') }}
),

products as (
    select * from {{ ref('products') }}
),

seller_orders as (
    select
        i.seller_id,
        i.order_id,
        i.product_id,
        i.unit_price,
        i.freight_value,
        i.total_item_value,
        o.purchased_at,
        o.days_to_deliver,
        o.is_late_delivery
    from items i
    inner join orders o on i.order_id = o.order_id
),

seller_reviews as (
    select
        i.seller_id,
        avg(r.review_score)              as avg_review_score,
        count(distinct r.review_id)      as total_reviews,
        sum(case when r.sentiment = 'positive'
            then 1 else 0 end)           as positive_reviews,
        sum(case when r.sentiment = 'negative'
            then 1 else 0 end)           as negative_reviews
    from items i
    join orders o  on i.order_id = o.order_id
    join reviews r on i.order_id = r.order_id
    group by i.seller_id
),

final as (
    select
        -- seller info
        so.seller_id,
        s.city                           as seller_city,
        s.state                          as seller_state,

        -- volume
        count(distinct so.order_id)      as total_orders,
        count(distinct so.product_id)    as distinct_products_sold,

        -- revenue
        sum(so.unit_price)               as product_revenue,
        sum(so.freight_value)            as freight_revenue,
        sum(so.total_item_value)         as gross_revenue,
        avg(so.total_item_value)         as avg_order_value,

        -- delivery
        avg(so.days_to_deliver)          as avg_days_to_deliver,
        sum(case when so.is_late_delivery
            then 1 else 0 end)           as late_orders,
        round(
            sum(case when so.is_late_delivery
                then 1 else 0 end) * 100.0
            / nullif(count(distinct so.order_id), 0), 2
        )                                as late_delivery_rate_pct,

        -- reviews
        sr.avg_review_score,
        sr.total_reviews,
        sr.positive_reviews,
        sr.negative_reviews,
        round(
            sr.positive_reviews * 100.0
            / nullif(sr.total_reviews, 0), 2
        )                                as positive_review_rate_pct,

        -- activity window
        min(so.purchased_at)             as first_sale_at,
        max(so.purchased_at)             as last_sale_at,
        datediff(
            max(so.purchased_at),
            min(so.purchased_at)
        )                                as active_days
    from seller_orders so
    join sellers s      on so.seller_id = s.seller_id
    left join seller_reviews sr on so.seller_id = sr.seller_id
    group by so.seller_id, s.city, s.state,
             sr.avg_review_score, sr.total_reviews,
             sr.positive_reviews, sr.negative_reviews
)

select * from final
order by gross_revenue desc