with cleaned as (
    select
        customer_id,
        customer_unique_id,               -- true customer identity across orders
        customer_zip_code_prefix          as zip_code,
        initcap(customer_city)            as city,
        upper(trim(customer_state))       as state
    from bronze.raw_olist_customers_dataset
    where customer_id is not null
    AND _rescued_data is null
)

select * from cleaned