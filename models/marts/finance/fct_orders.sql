select
    o.order_id,
    o.customer_id,
    o.order_date,
    p.status,
    p.amount

from {{ ref('stg_stripe__payments') }} p
left join {{ ref('stg_jaffle_shop__orders') }} o using (order_id)