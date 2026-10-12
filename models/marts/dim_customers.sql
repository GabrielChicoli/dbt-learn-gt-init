with customers as (
    select *
    from {{ ref('stg_jaffle_shop__customers') }}

),

stg_orders as (
    select *
    from {{ ref('stg_jaffle_shop__orders') }}
),

stg_payments as (
    select *
    from {{ ref('stg_stripe__payments') }}
),

fct_orders as (
    select
        stg_orders.order_id,
        stg_orders.customer_id,
        stg_orders.order_date,
        stg_payments.status,
        stg_payments.amount
    from stg_orders
    left join stg_payments using (order_id)
),

customer_orders as (

    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(case when status = 'success' then amount else 0 end) as lifetime_value
    from fct_orders

    group by 1

),


final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        coalesce(customer_orders.lifetime_value, 0) as lifetime_value

    from customers

    left join customer_orders using (customer_id)

)

select * from final
