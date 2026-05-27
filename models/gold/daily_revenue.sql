with orders as (
    select * from {{ ref('orders') }}
    where order_status = 'delivered'      -- only count completed orders
),

items as (
    select * from {{ ref('order_items') }}
),

payments as (
    select
        order_id,
        sum(payment_value)                as total_payment_value,
        count(distinct payment_type)      as payment_methods_used,
        max(case when payment_type = 'credit_card'
            then 1 else 0 end)            as used_credit_card,
        max(installments)                 as max_installments
    from {{ ref('order_payments') }}
    group by order_id
),

order_totals as (
    select
        i.order_id,
        sum(i.unit_price)                 as product_revenue,
        sum(i.freight_value)              as freight_revenue,
        sum(i.total_item_value)           as gross_revenue,
        count(distinct i.product_id)      as distinct_products,
        sum(i.item_sequence)              as total_items
    from items i
    group by i.order_id
),

final as (
    select
        -- time dimensions
        date_trunc('day',  o.purchased_at)   as order_date,
        date_trunc('week', o.purchased_at)   as order_week,
        date_trunc('month',o.purchased_at)   as order_month,
        year(o.purchased_at)                 as order_year,
        month(o.purchased_at)                as order_month_num,
        dayofweek(o.purchased_at)            as day_of_week,

        -- order counts
        count(distinct o.order_id)           as total_orders,
        count(distinct o.customer_id)        as unique_customers,

        -- revenue
        sum(ot.product_revenue)              as product_revenue,
        sum(ot.freight_revenue)              as freight_revenue,
        sum(ot.gross_revenue)                as gross_revenue,
        avg(ot.gross_revenue)                as avg_order_value,

        -- delivery
        avg(o.days_to_deliver)               as avg_days_to_deliver,
        sum(case when o.is_late_delivery
            then 1 else 0 end)               as late_deliveries,
        round(
            sum(case when o.is_late_delivery
                then 1 else 0 end) * 100.0
            / nullif(count(distinct o.order_id), 0), 2
        )                                    as late_delivery_rate_pct,

        -- payment behaviour
        avg(p.max_installments)              as avg_installments,
        sum(p.used_credit_card)              as credit_card_orders
    from orders o
    join order_totals ot on o.order_id = ot.order_id
    join payments p      on o.order_id = p.order_id
    group by 1, 2, 3, 4, 5, 6
)

select * from final
order by order_date