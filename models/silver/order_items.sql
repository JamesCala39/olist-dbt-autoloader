with cleaned as (
    select
        order_id,
        cast(order_item_id as int)          as item_sequence,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_at,
        cast(price as decimal(10,2))        as unit_price,
        cast(freight_value as decimal(10,2)) as freight_value,
        cast(price as decimal(10,2))
            + cast(freight_value as decimal(10,2)) as total_item_value
    from bronze.raw_olist_order_items_dataset
    where order_id is not null
      and product_id is not null
      and _rescued_data is null
)

select * from cleaned