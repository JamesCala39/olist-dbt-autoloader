with cleaned as (
    select
        order_id,
        cast(payment_sequential as int)     as payment_sequence,
        lower(trim(payment_type))           as payment_type,
        cast(payment_installments as int)   as installments,
        cast(payment_value as decimal(10,2)) as payment_value
    from bronze.raw_olist_order_payments_dataset
    where order_id is not null
      and payment_value > 0
      AND _rescued_data is null
)

select * from cleaned