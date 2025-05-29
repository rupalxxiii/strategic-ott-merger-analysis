use jotstar_db;
select count(*)  from subscribers;             -- 44620 
select count(*) from contents ;                 -- 2360 
select count(*) from content_consumption ;         -- 133860 

select * from subscribers;
select * from contents ; 
select * from content_consumption ;


-- Key metrics to focus: 
-- 1. Total content items 

SELECT COUNT(*) AS total_content_items
FROM Jotstar_db.contents;                         -- 2360 

-- 2. Total users 

SELECT COUNT(*) AS total_users
FROM Jotstar_db.subscribers;            -- 44620       

-- 3. Paid users 

SELECT COUNT(*) AS paid_users
FROM Jotstar_db.subscribers
WHERE subscription_plan IN ('VIP', 'Premium');           -- 32524 

-- 4. Paid users % 

SELECT 
    (COUNT(CASE WHEN subscription_plan IN ('VIP', 'Premium') THEN 1 END) * 100.0 / COUNT(*)) AS paid_users_percentage
FROM Jotstar_db.subscribers;                      -- 72.89108 

-- 5. Active users 

SELECT COUNT(*) AS active_users
FROM Jotstar_db.subscribers
WHERE last_active_date IS NULL;             -- 37968 

-- 6. Inactive users  

SELECT COUNT(*) AS inactive_users
FROM Jotstar_db.subscribers
WHERE last_active_date IS NOT NULL;

-- 7. Inactive Rate (%) 

SELECT 
    (COUNT(CASE WHEN last_active_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)) AS inactive_rate
FROM Jotstar_db.subscribers;

-- 8. Active Rate (%)

SELECT 
    (COUNT(CASE WHEN last_active_date IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS active_rate
FROM Jotstar_db.subscribers;
 
-- 9. Upgraded users 

SELECT COUNT(*) AS upgraded_users
FROM Jotstar_db.subscribers
WHERE new_subscription_plan IN ('VIP', 'Premium')
AND subscription_plan <> new_subscription_plan;

-- 10. Upgrade Rate (%) 

SELECT 
    (COUNT(CASE WHEN new_subscription_plan IN ('VIP', 'Premium') AND subscription_plan <> new_subscription_plan THEN 1 END) * 100.0 / COUNT(*)) AS upgrade_rate
FROM Jotstar_db.subscribers;

-- 11. Downgraded users 

SELECT COUNT(*) AS downgraded_users
FROM Jotstar_db.subscribers
WHERE new_subscription_plan IN ('Free', 'VIP')
AND subscription_plan <> new_subscription_plan;

-- 12. Downgrade Rate (%) 

SELECT 
    (COUNT(CASE WHEN new_subscription_plan IN ('Free', 'VIP') AND subscription_plan <> new_subscription_plan THEN 1 END) * 100.0 / COUNT(*)) AS downgrade_rate
FROM Jotstar_db.subscribers;

-- 13. Total watch time (hrs) 

SELECT SUM(total_watch_time) / 60.0 AS total_watch_time_hours
FROM Jotstar_db.content_consumption;

-- 14. Average watch time (hrs) 

SELECT 
    (SUM(total_watch_time) / 60.0) / COUNT(DISTINCT user_id) AS avg_watch_time_hours
FROM Jotstar_db.content_consumption;

-- 15. Monthly users Growth Rate (%) 

SELECT 
    DATE_TRUNC('month', subscription_date) AS month, 
    COUNT(user_id) AS new_users,
    LAG(COUNT(user_id)) OVER (ORDER BY DATE_TRUNC('month', subscription_date)) AS prev_month_users,
    CASE 
        WHEN LAG(COUNT(user_id)) OVER (ORDER BY DATE_TRUNC('month', subscription_date)) IS NOT NULL 
        THEN (COUNT(user_id) - LAG(COUNT(user_id)) OVER (ORDER BY DATE_TRUNC('month', subscription_date))) * 100.0 / LAG(COUNT(user_id)) OVER (ORDER BY DATE_TRUNC('month', subscription_date))
        ELSE NULL
    END AS monthly_growth_rate
FROM Jotstar_db.subscribers
GROUP BY DATE_TRUNC('month', subscription_date)
ORDER BY month;

-- 16. Upgrade / Downgrade Rate (%) 

SELECT 
    (COUNT(CASE WHEN new_subscription_plan IN ('VIP', 'Premium') AND subscription_plan <> new_subscription_plan THEN 1 END) * 100.0 / COUNT(*)) AS upgrade_rate,
    (COUNT(CASE WHEN new_subscription_plan IN ('Free', 'VIP') AND subscription_plan <> new_subscription_plan THEN 1 END) * 100.0 / COUNT(*)) AS downgrade_rate
FROM Jotstar_db.subscribers;




