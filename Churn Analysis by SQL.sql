create database churnanalysis;
use churnanalysis;
show tables;
select * from subscriptions;
select * from churnanalysis.usage;

-- Q1. HOW MANY CUSTOMERS ARE THERE?
SELECT COUNT(*) AS total_customers FROM subscriptions;


-- Q2. HOW MANY CUSTOMERS ARE CHURNED?
SELECT COUNT(*) AS churned_customers FROM subscriptions
WHERE churned = 'yes';

-- Q3. HOW MANY CUSTOMERS ARE STILL ACTIVE?
SELECT COUNT(*) AS active_customers
FROM subscriptions
WHERE churned = 'no';

-- Q.4 WHAT ARE THE DIFFERENT PLAN TYPES?
SELECT DISTINCT plan_type FROM subscriptions;

-- Q5. WHAT ARE THE DIFFERENT PLAN TIERS
SELECT DISTINCT plan_tier FROM subscriptions;

-- Q6. WHAT ACQUISITION CHANNEL EXIST?
SELECT DISTINCT acquisition_channel FROM subscriptions;

-- Q7.WHAT DEVISES DO CUSTOMER USE?
SELECT DISTINCT primary_device FROM subscriptions;


-- Q8.WHAT IS THE CHURNED VS ACTIVE CUSTOMER COUNT?
SELECT churned, COUNT(*) AS customer_count FROM subscriptions GROUP BY churned;

-- Q9. WHAT IS THE OVERALL CHURN RATE?
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM subscriptions;

-- Q10. WHAT IA THE CHURN RATE BY PLAN TYPE
SELECT plan_type, COUNT(*) AS total_customers,
SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) * 100.0/ COUNT(*),2) AS churn_rate_percentage FROM subscriptions
GROUP BY plan_type ORDER BY churn_rate_percentage DESC;

-- Q11. WHAT IA THE CHURN RATE BY PLAN TIER
SELECT
    plan_tier,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM subscriptions
GROUP BY plan_tier
ORDER BY churn_rate_percentage DESC;


-- Q12. WHAT IS THE CHURN RATE BY AGE GROUP?
SELECT
    age_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM subscriptions
GROUP BY age_group
ORDER BY churn_rate_percentage DESC;

-- Q13. WHAT IA THE CHURN RATE BY ACQUISITION CHANNEL?
SELECT
    acquisition_channel,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM subscriptions
GROUP BY acquisition_channel
ORDER BY churn_rate_percentage DESC;


-- Q14. WHAT Is THE CHURN RATE BY DEVICE?
SELECT
    primary_device,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM subscriptions
GROUP BY primary_device
ORDER BY churn_rate_percentage DESC;

-- REVENUE ANALYSIS 
-- Q15.WHAT IS THE MONTHLY REVENUE BY ACTIVE CUSTOMER?
SELECT
    ROUND(SUM(monthly_price), 2) AS active_monthly_revenue
FROM subscriptions
WHERE churned = 'no';


-- Q15.WHAT IS THE MONTHLY REVENUE BY CHURNED CUSTOMER?
SELECT
    ROUND(SUM(monthly_price), 2) AS churned_customer_revenue
FROM subscriptions
WHERE churned = 'yes';

-- 16. WHAT IS THE CANCELATION REASON ?
SELECT
    cancel_reason,
    COUNT(*) AS churned_customers
FROM subscriptions
WHERE churned = 'yes'
GROUP BY cancel_reason
ORDER BY churned_customers DESC;

-- 17.Cancellation reason by plan type
SELECT
    plan_type,
    cancel_reason,
    COUNT(*) AS churned_customers
FROM subscriptions
WHERE churned = 'yes'
GROUP BY
    plan_type,
    cancel_reason
ORDER BY
    plan_type,
    churned_customers DESC;

-- DATE ANALYSIS
-- 18.customer signed up by year
SELECT
    YEAR(signup_date) AS signup_year,
    COUNT(*) AS customers
FROM subscriptions
GROUP BY YEAR(signup_date)
ORDER BY signup_year;

-- 19.churn by year
SELECT
    YEAR(churn_date) AS churn_year,
    COUNT(*) AS churned_customers
FROM subscriptions
WHERE churned = 'yes'
GROUP BY YEAR(churn_date)
ORDER BY churn_year;

-- 20.monthly churned rate
SELECT
    DATE_FORMAT(churn_date, '%Y-%m') AS churn_month,
    COUNT(*) AS churned_customers
FROM subscriptions
WHERE churned = 'yes'
GROUP BY DATE_FORMAT(churn_date, '%Y-%m')
ORDER BY churn_month;



-- JOIN ANALYSIS
-- 21.HOW MANY USAGE RECORDS DOES CUSTOMER HAVE
SELECT
    customer_id,
    COUNT(*) AS usage_records
FROM churnanalysis.usage
GROUP BY customer_id
ORDER BY usage_records DESC;


-- 21.Average usage by churn status
SELECT
    s.churned,
    ROUND(AVG(u.workouts_completed), 2) AS avg_workouts,
    ROUND(AVG(u.minutes_active), 2) AS avg_minutes_active,
    ROUND(AVG(u.classes_booked), 2) AS avg_classes_booked,
    ROUND(AVG(u.support_tickets), 2) AS avg_support_tickets
FROM subscriptions s
JOIN churnanalysis.usage u
    ON s.customer_id = u.customer_id
GROUP BY s.churned;

-- CUSTOMER LEVEL USAGE ANALYSIS
-- 22.customer-level usage summary
SELECT
    customer_id,
    COUNT(*) AS months_recorded,
    ROUND(AVG(workouts_completed), 2) AS avg_workouts,
    ROUND(AVG(minutes_active), 2) AS avg_minutes_active,
    ROUND(AVG(classes_booked), 2) AS avg_classes_booked,
    ROUND(AVG(support_tickets), 2) AS avg_support_tickets
FROM churnanalysis.usage
GROUP BY customer_id;

-- CTE ANALYSIS 
-- 23.Compare customer engagement and churn
WITH customer_usage AS (
    SELECT
        customer_id,
        AVG(workouts_completed) AS avg_workouts,
        AVG(minutes_active) AS avg_minutes_active,
        AVG(classes_booked) AS avg_classes_booked,
        AVG(support_tickets) AS avg_support_tickets
    FROM churnanalysis.usage
    GROUP BY customer_id
)

SELECT
    s.churned,
    ROUND(AVG(cu.avg_workouts), 2) AS avg_workouts,
    ROUND(AVG(cu.avg_minutes_active), 2) AS avg_minutes_active,
    ROUND(AVG(cu.avg_classes_booked), 2) AS avg_classes_booked,
    ROUND(AVG(cu.avg_support_tickets), 2) AS avg_support_tickets
FROM subscriptions s
JOIN customer_usage cu
    ON s.customer_id = cu.customer_id
GROUP BY s.churned;

-- IDENTIFYING HIGH RISK CUSTOMERS
-- 23customers with low activity
WITH customer_usage AS (
    SELECT
        customer_id,
        AVG(workouts_completed) AS avg_workouts,
        AVG(minutes_active) AS avg_minutes_active
    FROM churnanalysis.usage
    GROUP BY customer_id
)

SELECT
    s.customer_id,
    s.plan_type,
    s.plan_tier,
    s.monthly_price,
    s.churned,
    ROUND(cu.avg_workouts, 2) AS avg_workouts,
    ROUND(cu.avg_minutes_active, 2) AS avg_minutes_active
FROM subscriptions s
JOIN customer_usage cu
    ON s.customer_id = cu.customer_id
WHERE cu.avg_workouts < 3
   OR cu.avg_minutes_active < 100
ORDER BY cu.avg_workouts;

-- ADVANCED CASE ANALYSIS
--  24.customer engagement segments
WITH customer_usage AS (
    SELECT
        customer_id,
        AVG(workouts_completed) AS avg_workouts,
        AVG(minutes_active) AS avg_minutes_active
    FROM churnanalysis.usage
    GROUP BY customer_id
)
SELECT
    s.customer_id,
    s.churned,
    ROUND(cu.avg_workouts, 2) AS avg_workouts,
    ROUND(cu.avg_minutes_active, 2) AS avg_minutes_active,

    CASE
        WHEN cu.avg_workouts >= 8
             AND cu.avg_minutes_active >= 300
            THEN 'Highly Engaged'

        WHEN cu.avg_workouts >= 4
             AND cu.avg_minutes_active >= 150
            THEN 'Moderately Engaged'

        ELSE 'Low Engagement'
    END AS engagement_segment

FROM subscriptions s
JOIN customer_usage cu
    ON s.customer_id = cu.customer_id;
   
   

-- 25.Churn rate by engagement segment
WITH customer_usage AS (
    SELECT
        customer_id,
        AVG(workouts_completed) AS avg_workouts,
        AVG(minutes_active) AS avg_minutes_active
    FROM churnanalysis.usage
    GROUP BY customer_id
),

customer_segments AS (
    SELECT
        customer_id,

        CASE
            WHEN avg_workouts >= 8
                 AND avg_minutes_active >= 300
                THEN 'Highly Engaged'

            WHEN avg_workouts >= 4
                 AND avg_minutes_active >= 150
                THEN 'Moderately Engaged'

            ELSE 'Low Engagement'
        END AS engagement_segment

    FROM customer_usage
)

SELECT
    cs.engagement_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN s.churned = 'yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN s.churned = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_segments cs
JOIN subscriptions s
    ON cs.customer_id = s.customer_id
GROUP BY cs.engagement_segment
ORDER BY churn_rate_percentage DESC;

-- Rank cancellation reasons with Windows Function
WITH reason_counts AS (
    SELECT
        cancel_reason,
        COUNT(*) AS churned_customers
    FROM subscriptions
    WHERE churned = 'yes'
    GROUP BY cancel_reason
)

SELECT
    cancel_reason,
    churned_customers,
    RANK() OVER (
        ORDER BY churned_customers DESC
    ) AS reason_rank
FROM reason_counts;

-- Rank plan types by churn rate
WITH plan_analysis AS (
    SELECT
        plan_type,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN churned = 'yes' THEN 1 ELSE 0 END)
            AS churned_customers
    FROM subscriptions
    GROUP BY plan_type
),

plan_rates AS (
    SELECT
        plan_type,
        total_customers,
        churned_customers,
        ROUND(
            churned_customers * 100.0 / total_customers,
            2
        ) AS churn_rate
    FROM plan_analysis
)

SELECT
    plan_type,
    total_customers,
    churned_customers,
    churn_rate,
    RANK() OVER (
        ORDER BY churn_rate DESC
    ) AS churn_rate_rank
FROM plan_rates;


-- 26.customer lifetime before churn
SELECT
    customer_id,
    signup_date,
    churn_date,
    DATEDIFF(churn_date, signup_date) AS customer_lifetime_days
FROM subscriptions
WHERE churned = 'yes'
ORDER BY customer_lifetime_days;


-- 27.Average customer lifetime
SELECT
    ROUND(
        AVG(DATEDIFF(churn_date, signup_date)),
        0
    ) AS avg_lifetime_days
FROM subscriptions
WHERE churned = 'yes';

-- Churn by customer lifetime group
SELECT 
    CASE
        WHEN DATEDIFF(churn_date, signup_date) < 90 THEN '0-89 Days'
        WHEN DATEDIFF(churn_date, signup_date) < 180 THEN '90-179 Days'
        WHEN DATEDIFF(churn_date, signup_date) < 365 THEN '180-364 Days'
        ELSE '365+ Days'
    END AS lifetime_group,
    COUNT(*) AS churned_customers
FROM
    subscriptions
WHERE
    churned = 'yes'
GROUP BY CASE
    WHEN DATEDIFF(churn_date, signup_date) < 90 THEN '0-89 Days'
    WHEN DATEDIFF(churn_date, signup_date) < 180 THEN '90-179 Days'
    WHEN DATEDIFF(churn_date, signup_date) < 365 THEN '180-364 Days'
    ELSE '365+ Days'
END
ORDER BY churned_customers DESC; 


WITH customer_usage AS (

    SELECT
        customer_id,

        COUNT(*) AS months_recorded,

        ROUND(AVG(workouts_completed), 2)
            AS avg_workouts,

        ROUND(AVG(minutes_active), 2)
            AS avg_minutes_active,

        ROUND(AVG(classes_booked), 2)
            AS avg_classes_booked,

        ROUND(AVG(support_tickets), 2)
            AS avg_support_tickets,

        ROUND(SUM(workouts_completed), 2)
            AS total_workouts,

        ROUND(SUM(minutes_active), 2)
            AS total_minutes_active,

        ROUND(SUM(classes_booked), 2)
            AS total_classes_booked,

        SUM(support_tickets)
            AS total_support_tickets

    FROM churnanalysis.usage

    GROUP BY customer_id
)

SELECT

    s.customer_id,

    s.signup_date,

    s.plan_type,

    s.plan_tier,

    s.monthly_price,

    s.acquisition_channel,

    s.primary_device,

    s.age_group,

    s.churned,

    s.churn_date,

    s.cancel_reason,

    cu.months_recorded,

    cu.avg_workouts,

    cu.avg_minutes_active,

    cu.avg_classes_booked,

    cu.avg_support_tickets,

    cu.total_workouts,

    cu.total_minutes_active,

    cu.total_classes_booked,

    cu.total_support_tickets,

    CASE
        WHEN cu.avg_workouts >= 8
             AND cu.avg_minutes_active >= 300
            THEN 'Highly Engaged'

        WHEN cu.avg_workouts >= 4
             AND cu.avg_minutes_active >= 150
            THEN 'Moderately Engaged'

        ELSE 'Low Engagement'
    END AS engagement_segment

FROM subscriptions s

LEFT JOIN customer_usage cu
    ON s.customer_id = cu.customer_id;
    
    
    
    
    
    
    
    



SELECT
    customer_id,
    signup_date,
    plan_type,
    CONCAT(
        UPPER(LEFT(TRIM(plan_tier),1)),
        LOWER(SUBSTRING(TRIM(plan_tier),2))
    ) AS plan_tier_clean,
    monthly_price,
    acquisition_channel,
    primary_device,
    age_group,
    churned,
    churn_date,
    cancel_reason
FROM subscriptions;
SELECT COUNT(*) AS missing_minutes
FROM churnanalysis.usage
WHERE minutes_active IS NULL;




SELECT
    customer_id,
    CASE
        WHEN LOWER(TRIM(acquisition_channel)) = 'organic'
            THEN 'Organic'
        WHEN LOWER(TRIM(acquisition_channel)) = 'paid_social'
            THEN 'Paid Social'
        WHEN LOWER(TRIM(acquisition_channel)) = 'partner'
            THEN 'Partner'
        WHEN LOWER(TRIM(acquisition_channel)) = 'promo_offer'
            THEN 'Promo Offer'
        WHEN LOWER(TRIM(acquisition_channel)) = 'referral'
            THEN 'Referral'
        ELSE acquisition_channel
    END AS acquisition_channel_clean
FROM subscriptions;

