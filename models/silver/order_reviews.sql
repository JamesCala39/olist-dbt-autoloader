with cleaned as (
    select
        review_id,
        order_id,
        cast(review_score as int)               as review_score,
        trim(review_comment_title)               as review_title,
        trim(review_comment_message)             as review_message,
        cast(review_creation_date as timestamp)  as reviewed_at,
        cast(review_answer_timestamp as timestamp) as answered_at,

        -- derived
        case
            when cast(review_score as int) >= 4 then 'positive'
            when cast(review_score as int) = 3  then 'neutral'
            else 'negative'
        end                                      as sentiment
    from bronze.raw_olist_order_reviews_dataset
    where review_id is not null
      and order_id is not null
      AND _rescued_data is null
)

select * from cleaned