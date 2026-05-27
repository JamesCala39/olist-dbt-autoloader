with orders as (
    select * from {{ ref('orders') }}
    where order_status = 'delivered'
),

items as (
    select * from {{ ref('order_items') }}
),

reviews as (
    select * from {{ ref('order_reviews') }}
),

customers as (
    select * from {{ ref('customers') }}
),

customer_orders as (
    select
        o.customer_id,
        o.order_id,
        o.purchased_at,
        o.days_to_deliver,
        sum(i.total_item_value)           as order_value
    from orders o
    join items i on o.order_id = i.order_id
    group by o.customer_id, o.order_id,
             o.purchased_at, o.days_to_deliver
),

customer_reviews as (
    select
        o.customer_id,
        avg(r.review_score)               as avg_review_score,
        count(r.review_id)                as reviews_given
    from orders o
    join reviews r on o.order_id = r.order_id
    group by o.customer_id
),

rfm as (
    select
        customer_id,

        -- Recency: days since last order (lower = better)
        datediff(
            current_date(),
            max(purchased_at)
        )                                 as recency_days,

        -- Frequency: number of orders
        count(distinct order_id)          as frequency,

        -- Monetary: total spend
        sum(order_value)                  as monetary_value,
        avg(order_value)                  as avg_order_value,

        -- behaviour
        min(purchased_at)                 as first_order_at,
        max(purchased_at)                 as last_order_at,
        avg(days_to_deliver)              as avg_days_to_deliver
    from customer_orders
    group by customer_id
),

final as (
    select
        -- customer info
        r.customer_id,
        c.customer_unique_id,
        c.city,
        c.state,

        -- RFM metrics
        r.recency_days,
        r.frequency,
        r.monetary_value,
        r.avg_order_value,

        -- activity
        r.first_order_at,
        r.last_order_at,
        datediff(r.last_order_at, r.first_order_at) as customer_lifespan_days,
        r.avg_days_to_deliver,

        -- reviews
        cr.avg_review_score,
        cr.reviews_given,

        -- RFM segment (simple tier based on frequency + spend)
        case
            when r.frequency >= 3
             and r.monetary_value >= 500  then 'Champions'
            when r.frequency >= 2
             and r.monetary_value >= 200  then 'Loyal'
            when r.recency_days <= 90
             and r.frequency = 1          then 'Promising'
            when r.recency_days > 180
             and r.frequency >= 2         then 'At Risk'
            when r.recency_days > 180
             and r.frequency = 1          then 'Lost'
            else 'New'
        end                               as customer_segment
    from rfm r
    join customers c        on r.customer_id = c.customer_id
    left join customer_reviews cr on r.customer_id = cr.customer_id
)

select * from final
order by monetary_value desc