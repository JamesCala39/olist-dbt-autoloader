with cleaned as (
    select
        seller_id,
        seller_zip_code_prefix            as zip_code,
        initcap(seller_city)              as city,
        upper(trim(seller_state))         as state
    from bronze.raw_olist_sellers_dataset
    where seller_id is not null
    and _rescued_data is null
)

select * from cleaned