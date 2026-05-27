with cleaned as (
    select
        p.product_id,
        coalesce(t.product_category_name_english,
                 p.product_category_name,
                 'uncategorized')         as category,
        cast(p.product_name_lenght as int)        as name_length,
        cast(p.product_description_lenght as int) as description_length,
        cast(p.product_photos_qty as int)         as photo_count,
        cast(p.product_weight_g as int)           as weight_g,
        cast(p.product_length_cm as decimal(8,2)) as length_cm,
        cast(p.product_height_cm as decimal(8,2)) as height_cm,
        cast(p.product_width_cm as decimal(8,2))  as width_cm
    from bronze.raw_olist_products_dataset p
    left join bronze.raw_product_category_name_translation t
        on p.product_category_name = t.product_category_name
    where p.product_id is not null AND p._rescued_data is null
)

select * from cleaned