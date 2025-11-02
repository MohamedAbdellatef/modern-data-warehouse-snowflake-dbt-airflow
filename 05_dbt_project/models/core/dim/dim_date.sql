{{ config(materialized='table') }}

with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('2000-01-01')",
        end_date="dateadd(year, 2, current_date())"
        )
    }}
),
d as (
    select
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_key,
        date_day                                       as full_date,
        to_char(date_day,'YYYY-MM-DD')                 as ymd,
        dayofweek(date_day)                            as day_of_week_num, 
        to_char(date_day,'DY')                         as day_of_week_code,
        to_char(date_day,'Day')                        as day_name,
        extract(week from date_day)                    as week_number,
        month(date_day)                                as month_number,
        to_char(date_day,'Mon')                        as month_code,
        to_char(date_day,'Month')                      as month_name,
        quarter(date_day)                              as quarter_number,
        year(date_day)                                 as year,
        date_trunc('month', date_day)                  as month_start_date,
        last_day(date_day, 'month')                    as month_end_date,
        (dayofweek(date_day) in (7,1))::boolean        as is_weekend
    from spine
)
select * from d