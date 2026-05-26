with cleaned as (
    select
        geolocation_zip_code_prefix        as zip_code,
        geolocation_lat                     as latitude,
        geolocation_lng                     as longitude,
        initcap(geolocation_city)            as city,
        upper(trim(geolocation_state))       as state
    from bronze.raw_olist_geolocation_dataset
    where _rescued_data is null
)

select * from cleaned