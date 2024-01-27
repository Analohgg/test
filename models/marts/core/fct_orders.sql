{{
    config(
        materialized='view'
    )
}}

WITH orders AS (
    SELECT  
        *
    FROM {{ ref('stg_orders') }}
),

payments AS (
    SELECT 
        *
    FROM {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        sum(case when status = 'success' then amount end) as amount
    from payments
    group by 1
),

final as (
    SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    coalesce(order_payments.amount, 0) as amount

    FROM orders 
    LEFT JOIN order_payments USING (order_id)
)

select * from final