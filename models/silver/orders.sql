with cleaned as 
(
    select
        order_id,
        customer_id,
        lower(trim(order_status))                    as order_status,
        cast(order_purchase_timestamp as timestamp)  as purchased_at,
        cast(order_approved_at as timestamp)         as approved_at,
        cast(order_delivered_carrier_date as timestamp) as shipped_at,
        cast(order_delivered_customer_date as timestamp) as delivered_at,
        cast(order_estimated_delivery_date as timestamp) as estimated_delivery_at,

        -- derived columns
        datediff(
            cast(order_delivered_customer_date as timestamp),
            cast(order_purchase_timestamp as timestamp)
        )                                            as days_to_deliver,
        case
            when cast(order_delivered_customer_date as timestamp)
               > cast(order_estimated_delivery_date as timestamp)
            then true else false
        end                                          as is_late_delivery,
        _ingested_at
    from bronze.raw_olist_orders_dataset
    where order_id is not null AND _rescued_data is null
)

select * from cleaned;