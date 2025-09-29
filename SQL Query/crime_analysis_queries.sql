CREATE TABLE crime_report (
    report_number INT PRIMARY KEY,         
    date_reported DATE,                    
    date_of_occurrence DATE,                    
    time_of_occurrence TIME,                    
    city VARCHAR(100),             
    crime_code VARCHAR(50),             
    crime_description VARCHAR(255),            
    victim_age INT,                     
    victim_gender VARCHAR(10),             
    weapon_used VARCHAR(100),            
    crime_domain VARCHAR(100),         
    police_deployed INT,                      
    case_status VARCHAR(20),              
    date_case_closed DATE,                    
    victim_age_group VARCHAR(20),            
    year INT,                     
    hour INT                      
);
-------------------------------------------------------------------------------------------
-- EDA

TABLE crime_report;

-- TOTAL NO OF ROWS 

select count(*) as total_rows 
from crime_report;

-- FINDING MISSING VALUES

SELECT 
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(report_number) AS missing_report_number,
    COUNT(*) - COUNT(date_reported) AS missing_date_reported,
    COUNT(*) - COUNT(date_of_occurrence) AS missing_date_of_occurrence,
    COUNT(*) - COUNT(time_of_occurrence) AS missing_time_of_occurrence,
    COUNT(*) - COUNT(city) AS missing_city,
    COUNT(*) - COUNT(crime_code) AS missing_crime_code,
    COUNT(*) - COUNT(crime_description) AS missing_crime_description,
    COUNT(*) - COUNT(victim_age) AS missing_victim_age,
    COUNT(*) - COUNT(victim_gender) AS missing_victim_gender,
    COUNT(*) - COUNT(weapon_used) AS missing_weapon_used,
    COUNT(*) - COUNT(crime_domain) AS missing_crime_domain,
    COUNT(*) - COUNT(police_deployed) AS missing_police_deployed,
    COUNT(*) - COUNT(case_status) AS missing_case_status,
    COUNT(*) - COUNT(date_case_closed) AS missing_date_case_closed,
    COUNT(*) - COUNT(victim_age_group) AS missing_victim_age_group,
    COUNT(*) - COUNT(year) AS missing_year,
    COUNT(*) - COUNT(hour) AS missing_hour
FROM crime_report;

-------------------------------------------------------------------------------------------
-- UNIQUE CRIME REPORTS 

-- Unique cities
SELECT DISTINCT city
FROM crime_report
ORDER BY city;

-- Unique crime code
SELECT DISTINCT crime_code
FROM crime_report
ORDER BY crime_code;

-- Unique crime descriptions
SELECT DISTINCT crime_description
FROM crime_report
ORDER BY crime_description;

-- Unique victim ages
SELECT DISTINCT victim_age
FROM crime_report
ORDER BY victim_age;

-- Unique weapons used
SELECT DISTINCT weapon_used
FROM crime_report
ORDER BY weapon_used;

-- Unique crime domains
SELECT DISTINCT crime_domain
FROM crime_report
ORDER BY crime_domain;

-- Unique police deployment info
SELECT DISTINCT police_deployed
FROM crime_report
ORDER BY police_deployed;
-------------------------------------------------------------------------------------------
-- IMPORTANT INSIGHTS (SQL QUERY BASED)

-- 1) Total Crimes by Year & Month 
WITH monthly_crimes AS (
    SELECT 
        year,
        EXTRACT(MONTH FROM date_of_occurrence) AS month_num,
        TO_CHAR(date_of_occurrence, 'FMMonth') AS month_name,
        COUNT(*) AS total_crimes
    FROM crime_report
    GROUP BY year, month_num, month_name
)
SELECT 
    year,
    month_num,
    month_name,
    total_crimes,
    COALESCE(total_crimes - LAG(total_crimes) OVER (ORDER BY year, month_num), 0) AS month_over_month_change
FROM monthly_crimes
ORDER BY year, month_num;

-- Total Crimes per Year
SELECT 
	year,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY year
ORDER BY year;
	
-------------------------------------------------------------------------------------------

-- 2) Which month/year had the highest crime count ?
SELECT year, month_num, month_name, total_crime
FROM (
    SELECT 
        year, 
        EXTRACT(MONTH FROM date_of_occurrence) AS month_num,
        TO_CHAR(date_of_occurrence, 'FMMonth') AS month_name, 
        COUNT(*) AS total_crime,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY year, month_num, month_name
)
WHERE rnk = 1;

-------------------------------------------------------------------------------------------

-- 3) What are the top 5 highest crime types per Year ?
SELECT year, crime_type, total_crimes, rnk
FROM (
    SELECT 
        year,
        crime_description AS crime_type,
        COUNT(*) AS total_crimes,
        RANK() OVER (PARTITION BY year ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY year, crime_type
) 
WHERE rnk <= 5
ORDER BY year, rnk;

-- Top 5 Common Crime (2020 - 2024)
SELECT
	crime_description,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY crime_description
ORDER BY total_crime desc
LIMIT 5;

-------------------------------------------------------------------------------------------

-- 4) Which are Top 5 least frequent crimes per year ?
SELECT year, crime_type, total_crimes, rnk
FROM (
    SELECT 
        year,
        crime_description AS crime_type,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (PARTITION BY year 
                     ORDER BY COUNT(*)) AS rnk
    FROM crime_report
    GROUP BY year, crime_type
) 
WHERE rnk <= 5
ORDER BY year, rnk;

-------------------------------------------------------------------------------------------

-- 5) What is the most dangerous crime type (by Police deployed) ?
SELECT 
    crime_description,
    SUM(police_deployed) AS total_police_deployed
FROM crime_report
GROUP BY crime_description
ORDER BY total_police_deployed DESC;

-------------------------------------------------------------------------------------------

-- 6) What are the Top 5 cities with the highest crime count Yearly ?
WITH highest_crime AS (
    SELECT 
        year,
        city,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (
            PARTITION BY year 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM crime_report
    GROUP BY year, city
)
SELECT year, city, total_crimes, rnk
FROM highest_crime
WHERE rnk <= 5
ORDER BY year, rnk;

-- Top 5 Highest crime cities (2020 - 2024 [31st July])
SELECT 
	city,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY city
ORDER BY total_crime DESC
LIMIT 5;

-------------------------------------------------------------------------------------------

-- 7) What are the Top 5 cities with the lowest crime count Yearly ?
WITH lowest_crime AS (
    SELECT 
        year,
        city,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (
            PARTITION BY year 
            ORDER BY COUNT(*)
        ) AS rnk
    FROM crime_report
    GROUP BY year, city
)
SELECT year, city, total_crimes, rnk
FROM lowest_crime
WHERE rnk <= 5
ORDER BY year, rnk;

-- Top 5 Lowest crime cities (2020 - 2024 [31st July])
SELECT 
	city,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY city
ORDER BY total_crime
LIMIT 5;

-------------------------------------------------------------------------------------------

-- 8) For each city, what is the most common crime type ?
WITH most_common_crime AS (
    SELECT 
        city,
        crime_description AS crime_type,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY city, crime_description
)
SELECT city, crime_type, total_crimes
FROM most_common_crime
WHERE rnk = 1
ORDER BY city, rnk;

-------------------------------------------------------------------------------------------

-- 9) Crimes by gender distribution (male vs female victims).
SELECT
	 year,
	 victim_gender AS gender,
	 COUNT(*) AS total_crimes
FROM crime_report
GROUP BY year, gender
ORDER BY year, gender;

-- Total crime Gender wise (2020 - 2024 [31st July])
SELECT 
	victim_gender AS gender,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY gender
ORDER BY gender;

-------------------------------------------------------------------------------------------

-- 10) Crimes by age group Yealry.
SELECT 
    year,
    victim_age_group,
    COUNT(*) AS total_crime
FROM crime_report 
GROUP BY year, victim_age_group
ORDER BY year, victim_age_group;

-- Total crime Victim agr Group wise (2020 - 2024 [31st July])
SELECT 
	victim_age_group,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY victim_age_group
ORDER BY victim_age_group;

-------------------------------------------------------------------------------------------

-- 11) What crime type is most common for each age group ?
WITH most_common_crime AS (
	SELECT 
		victim_age_group,
		crime_description AS crime_type,
		COUNT(*) AS total_crime,
		DENSE_RANK() OVER(PARTITION BY victim_age_group ORDER BY COUNT(*) DESC) AS rnk
	FROM crime_report 
	GROUP BY crime_description, victim_age_group
)
SELECT 
	victim_age_group,
	crime_type,
	total_crime
FROM most_common_crime
WHERE rnk = 1
ORDER BY victim_age_group, rnk;

-------------------------------------------------------------------------------------------

-- 12) What are the most common weapons used in crimes?	
SELECT 
    crime_type, 
    most_common_weapon,
	total_crime
FROM (
    SELECT 
        crime_description AS crime_type,
        weapon_used AS most_common_weapon,
        COUNT(*) AS total_crime,
        DENSE_RANK() OVER (PARTITION BY crime_description ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY crime_description, weapon_used
) 
WHERE rnk = 1
ORDER BY crime_type, rnk;

-- Top 5 used weapons in Crime
SELECT 
	weapon_used,
	COUNT(*) AS total_crime
FROM crime_report
WHERE weapon_used NOT IN('None','Other')
GROUP BY weapon_used
ORDER BY total_crime DESC
LIMIT 5;

-------------------------------------------------------------------------------------------

-- 13) Which crime types are most often associated with 'Firearm' ?
SELECT 
    crime_type, 
    total_crimes
FROM (
    SELECT
        crime_description AS crime_type,
        weapon_used AS most_common_weapon,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (PARTITION BY crime_description ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY crime_description, weapon_used
) 
WHERE rnk = 1 
  AND most_common_weapon = 'Firearm'
ORDER BY total_crimes DESC, rnk;

-------------------------------------------------------------------------------------------

-- 14) Weapon related crime percentage ?
SELECT 
    city,
    COUNT(*) AS total_crimes,
    SUM(CASE WHEN weapon_used NOT IN('None','Other') THEN 1 ELSE 0 END) AS weapon_crimes,
    ROUND(
        SUM(CASE WHEN weapon_used NOT IN('None','Other') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS weapon_crime_percentage
FROM crime_report
GROUP BY city
ORDER BY weapon_crime_percentage DESC;

-------------------------------------------------------------------------------------------

-- 15) Firearm as most common weapon per city.
WITH city_weapon_rank AS (
    SELECT
        city,
        weapon_used AS most_common_weapon,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY city, weapon_used
)
SELECT 
    city, 
    total_crimes
FROM city_weapon_rank
WHERE rnk = 1 
  AND most_common_weapon = 'Firearm'
ORDER BY total_crimes DESC,rnk;

-------------------------------------------------------------------------------------------

-- 16) How many cases were closed vs still open (with percentage)?
SELECT 
    year,
    case_status,
    COUNT(*) AS total_crime,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY year), 
        2
    ) AS percentage
FROM crime_report
GROUP BY year, case_status
ORDER BY year, case_status;

-------------------------------------------------------------------------------------------

-- 17) Average case closure time per city.
SELECT 
    city,
    ROUND(AVG(date_case_closed - date_of_occurrence), 2) AS avg_days_to_close
FROM crime_report
WHERE case_status = 'Closed'
  AND date_case_closed IS NOT NULL
  AND date_of_occurrence IS NOT NULL
GROUP BY city
ORDER BY avg_days_to_close;

-------------------------------------------------------------------------------------------

-- 18) % of closed cases per city.
SELECT 
    city,
    COUNT(*) AS total_cases,
    SUM(CASE WHEN case_status = 'Closed' THEN 1 ELSE 0 END) AS closed_cases,
    ROUND(100.0 * SUM(CASE WHEN case_status = 'Closed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS closure_rate_percent
FROM crime_report
GROUP BY city
ORDER BY closure_rate_percent DESC;

-------------------------------------------------------------------------------------------

-- 19) What hour of the day has the most crimes?
WITH most_crime_per_hour AS (
    SELECT
        city AS city,
        hour,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER ( PARTITION BY city ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY city, hour
)
SELECT
    city,
    hour as day_hour,
    total_crimes
FROM most_crime_per_hour
WHERE rnk = 1
ORDER BY total_crimes DESC, city, rnk;

-------------------------------------------------------------------------------------------

-- 20) What day of the week has the most crimes?
WITH most_crime_per_day_of_week AS (
    SELECT 
        city,
        TO_CHAR(date_of_occurrence, 'FMDay') AS day_name,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY city, day_name
)
SELECT
    city,
    day_name,
    total_crimes
FROM most_crime_per_day_of_week
WHERE rnk = 1
ORDER BY total_crimes DESC;

-- Peak Crime hours - Top 5 (2020 - 2024 [31st July])
SELECT
	hour,
	COUNT(*) AS total_crime
FROM crime_report
GROUP BY hour
ORDER BY total_crime DESC
LIMIT 5;

-------------------------------------------------------------------------------------------

-- 21) Which crime type is most common during day vs night?
WITH crime_shifts_detail AS (
    SELECT
        crime_description AS crime_type,
        CASE
            WHEN hour BETWEEN 8 AND 19 THEN 'DAY'
            WHEN hour BETWEEN 20 AND 23 
              OR hour BETWEEN 0 AND 7 THEN 'NIGHT'
        END AS crime_shift,
        COUNT(*) AS total_crime
    FROM crime_report
    GROUP BY crime_type, crime_shift
),
ranked_crimes AS (
    SELECT
        crime_shift,
        crime_type,
        total_crime,
        DENSE_RANK() OVER (
            PARTITION BY crime_shift
            ORDER BY total_crime DESC
        ) AS rnk
    FROM crime_shifts_detail
)
SELECT
    crime_shift,
    crime_type,
    total_crime
FROM ranked_crimes
WHERE rnk <= 5
ORDER BY crime_shift, rnk;

-------------------------------------------------------------------------------------------

-- 22) Top 5 crime types per city
WITH top_crimes_per_city AS (
    SELECT
        city AS city,
        crime_description AS crime_type,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (
            PARTITION BY city 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM crime_report
    GROUP BY city, crime_type
)
SELECT 
    city,
    crime_type,
    total_crimes
FROM top_crimes_per_city 
WHERE rnk <= 5
ORDER BY city, rnk;

-------------------------------------------------------------------------------------------

-- 23) Top 5 High-Risk Timings per City
WITH high_risk_timings AS (
    SELECT 
        city AS city,
        hour crime_hour,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (
            PARTITION BY city 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM crime_report 
    GROUP BY city, crime_hour
)
SELECT 
    city,
    crime_hour,
    total_crimes 
FROM high_risk_timings
WHERE rnk <= 5
ORDER BY city, rnk;

-------------------------------------------------------------------------------------------

-- 24) Crime domain contributing the most to total crimes (Highest -> Lowest)
SELECT
	crime_domain,
	COUNT(*) AS total_crimes
FROM crime_report
    GROUP BY crime_domain
	ORDER BY total_crimes DESC;

-------------------------------------------------------------------------------------------

-- 25) Trend of Firearm crimes with year-over-year change
WITH firearm_trend AS (
    SELECT 
        year,
        COUNT(*) AS total_crimes
    FROM crime_report
    WHERE weapon_used = 'Firearm'
    GROUP BY year
)
SELECT 
    year,
    total_crimes,
    COALESCE(total_crimes - LAG(total_crimes) OVER (ORDER BY year),0) AS year_over_year_change
FROM firearm_trend
ORDER BY year;

-------------------------------------------------------------------------------------------

-- 26) The followings with the most crime:

-- Hour
SELECT 
    hour,
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY hour
ORDER BY total_crimes DESC
LIMIT 1;

-- Weekday
SELECT 
    TO_CHAR(date_of_occurrence, 'FMDay') AS day_of_week,
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY day_of_week
ORDER BY total_crimes DESC
LIMIT 1;

-- Month
SELECT 
    EXTRACT(MONTH FROM date_of_occurrence) AS month,
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY month
ORDER BY total_crimes DESC
LIMIT 1;

-- Year
SELECT 
    year,
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY year
ORDER BY total_crimes DESC
LIMIT 1;

--***************************************************************************************--





